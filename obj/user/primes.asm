
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  800040:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800043:	83 ec 04             	sub    $0x4,%esp
  800046:	6a 00                	push   $0x0
  800048:	6a 00                	push   $0x0
  80004a:	56                   	push   %esi
  80004b:	e8 b0 10 00 00       	call   801100 <ipc_recv>
  800050:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800052:	a1 60 40 80 00       	mov    0x804060,%eax
  800057:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005a:	83 c4 0c             	add    $0xc,%esp
  80005d:	53                   	push   %ebx
  80005e:	50                   	push   %eax
  80005f:	68 00 15 80 00       	push   $0x801500
  800064:	e8 df 01 00 00       	call   800248 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800069:	e8 c5 0e 00 00       	call   800f33 <fork>
  80006e:	89 c7                	mov    %eax,%edi
  800070:	83 c4 10             	add    $0x10,%esp
  800073:	85 c0                	test   %eax,%eax
  800075:	78 07                	js     80007e <primeproc+0x4b>
		panic("fork: %e", id);
	if (id == 0)
  800077:	74 ca                	je     800043 <primeproc+0x10>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800079:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80007c:	eb 20                	jmp    80009e <primeproc+0x6b>
		panic("fork: %e", id);
  80007e:	50                   	push   %eax
  80007f:	68 0a 18 80 00       	push   $0x80180a
  800084:	6a 1a                	push   $0x1a
  800086:	68 0c 15 80 00       	push   $0x80150c
  80008b:	e8 d1 00 00 00       	call   800161 <_panic>
		if (i % p)
			ipc_send(id, i, 0, 0);
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	51                   	push   %ecx
  800095:	57                   	push   %edi
  800096:	e8 d2 10 00 00       	call   80116d <ipc_send>
  80009b:	83 c4 10             	add    $0x10,%esp
		i = ipc_recv(&envid, 0, 0);
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	56                   	push   %esi
  8000a6:	e8 55 10 00 00       	call   801100 <ipc_recv>
  8000ab:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000ad:	99                   	cltd   
  8000ae:	f7 fb                	idiv   %ebx
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	85 d2                	test   %edx,%edx
  8000b5:	74 e7                	je     80009e <primeproc+0x6b>
  8000b7:	eb d7                	jmp    800090 <primeproc+0x5d>

008000b9 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000c2:	e8 6c 0e 00 00       	call   800f33 <fork>
  8000c7:	89 c6                	mov    %eax,%esi
  8000c9:	85 c0                	test   %eax,%eax
  8000cb:	78 1a                	js     8000e7 <umain+0x2e>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000cd:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000d2:	74 25                	je     8000f9 <umain+0x40>
		ipc_send(id, i, 0, 0);
  8000d4:	6a 00                	push   $0x0
  8000d6:	6a 00                	push   $0x0
  8000d8:	53                   	push   %ebx
  8000d9:	56                   	push   %esi
  8000da:	e8 8e 10 00 00       	call   80116d <ipc_send>
	for (i = 2; ; i++)
  8000df:	83 c3 01             	add    $0x1,%ebx
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb ed                	jmp    8000d4 <umain+0x1b>
		panic("fork: %e", id);
  8000e7:	50                   	push   %eax
  8000e8:	68 0a 18 80 00       	push   $0x80180a
  8000ed:	6a 2d                	push   $0x2d
  8000ef:	68 0c 15 80 00       	push   $0x80150c
  8000f4:	e8 68 00 00 00       	call   800161 <_panic>
		primeproc();
  8000f9:	e8 35 ff ff ff       	call   800033 <primeproc>

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	f3 0f 1e fb          	endbr32 
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80010d:	e8 3c 0b 00 00       	call   800c4e <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  80011d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800122:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800127:	85 db                	test   %ebx,%ebx
  800129:	7e 07                	jle    800132 <libmain+0x34>
		binaryname = argv[0];
  80012b:	8b 06                	mov    (%esi),%eax
  80012d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800132:	83 ec 08             	sub    $0x8,%esp
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
  800137:	e8 7d ff ff ff       	call   8000b9 <umain>

	// exit gracefully
	exit();
  80013c:	e8 0a 00 00 00       	call   80014b <exit>
}
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800147:	5b                   	pop    %ebx
  800148:	5e                   	pop    %esi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014b:	f3 0f 1e fb          	endbr32 
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800155:	6a 00                	push   $0x0
  800157:	e8 ad 0a 00 00       	call   800c09 <sys_env_destroy>
}
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800161:	f3 0f 1e fb          	endbr32 
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80016a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800173:	e8 d6 0a 00 00       	call   800c4e <sys_getenvid>
  800178:	83 ec 0c             	sub    $0xc,%esp
  80017b:	ff 75 0c             	pushl  0xc(%ebp)
  80017e:	ff 75 08             	pushl  0x8(%ebp)
  800181:	56                   	push   %esi
  800182:	50                   	push   %eax
  800183:	68 24 15 80 00       	push   $0x801524
  800188:	e8 bb 00 00 00       	call   800248 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018d:	83 c4 18             	add    $0x18,%esp
  800190:	53                   	push   %ebx
  800191:	ff 75 10             	pushl  0x10(%ebp)
  800194:	e8 5a 00 00 00       	call   8001f3 <vcprintf>
	cprintf("\n");
  800199:	c7 04 24 47 15 80 00 	movl   $0x801547,(%esp)
  8001a0:	e8 a3 00 00 00       	call   800248 <cprintf>
  8001a5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a8:	cc                   	int3   
  8001a9:	eb fd                	jmp    8001a8 <_panic+0x47>

008001ab <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ab:	f3 0f 1e fb          	endbr32 
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 04             	sub    $0x4,%esp
  8001b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b9:	8b 13                	mov    (%ebx),%edx
  8001bb:	8d 42 01             	lea    0x1(%edx),%eax
  8001be:	89 03                	mov    %eax,(%ebx)
  8001c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cc:	74 09                	je     8001d7 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ce:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001d7:	83 ec 08             	sub    $0x8,%esp
  8001da:	68 ff 00 00 00       	push   $0xff
  8001df:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e2:	50                   	push   %eax
  8001e3:	e8 dc 09 00 00       	call   800bc4 <sys_cputs>
		b->idx = 0;
  8001e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ee:	83 c4 10             	add    $0x10,%esp
  8001f1:	eb db                	jmp    8001ce <putch+0x23>

008001f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f3:	f3 0f 1e fb          	endbr32 
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800200:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800207:	00 00 00 
	b.cnt = 0;
  80020a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800211:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800214:	ff 75 0c             	pushl  0xc(%ebp)
  800217:	ff 75 08             	pushl  0x8(%ebp)
  80021a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800220:	50                   	push   %eax
  800221:	68 ab 01 80 00       	push   $0x8001ab
  800226:	e8 20 01 00 00       	call   80034b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022b:	83 c4 08             	add    $0x8,%esp
  80022e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800234:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023a:	50                   	push   %eax
  80023b:	e8 84 09 00 00       	call   800bc4 <sys_cputs>

	return b.cnt;
}
  800240:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800248:	f3 0f 1e fb          	endbr32 
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800252:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800255:	50                   	push   %eax
  800256:	ff 75 08             	pushl  0x8(%ebp)
  800259:	e8 95 ff ff ff       	call   8001f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 1c             	sub    $0x1c,%esp
  800269:	89 c7                	mov    %eax,%edi
  80026b:	89 d6                	mov    %edx,%esi
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	8b 55 0c             	mov    0xc(%ebp),%edx
  800273:	89 d1                	mov    %edx,%ecx
  800275:	89 c2                	mov    %eax,%edx
  800277:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80027d:	8b 45 10             	mov    0x10(%ebp),%eax
  800280:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800283:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800286:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80028d:	39 c2                	cmp    %eax,%edx
  80028f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800292:	72 3e                	jb     8002d2 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	ff 75 18             	pushl  0x18(%ebp)
  80029a:	83 eb 01             	sub    $0x1,%ebx
  80029d:	53                   	push   %ebx
  80029e:	50                   	push   %eax
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ae:	e8 dd 0f 00 00       	call   801290 <__udivdi3>
  8002b3:	83 c4 18             	add    $0x18,%esp
  8002b6:	52                   	push   %edx
  8002b7:	50                   	push   %eax
  8002b8:	89 f2                	mov    %esi,%edx
  8002ba:	89 f8                	mov    %edi,%eax
  8002bc:	e8 9f ff ff ff       	call   800260 <printnum>
  8002c1:	83 c4 20             	add    $0x20,%esp
  8002c4:	eb 13                	jmp    8002d9 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	56                   	push   %esi
  8002ca:	ff 75 18             	pushl  0x18(%ebp)
  8002cd:	ff d7                	call   *%edi
  8002cf:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002d2:	83 eb 01             	sub    $0x1,%ebx
  8002d5:	85 db                	test   %ebx,%ebx
  8002d7:	7f ed                	jg     8002c6 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d9:	83 ec 08             	sub    $0x8,%esp
  8002dc:	56                   	push   %esi
  8002dd:	83 ec 04             	sub    $0x4,%esp
  8002e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ec:	e8 af 10 00 00       	call   8013a0 <__umoddi3>
  8002f1:	83 c4 14             	add    $0x14,%esp
  8002f4:	0f be 80 49 15 80 00 	movsbl 0x801549(%eax),%eax
  8002fb:	50                   	push   %eax
  8002fc:	ff d7                	call   *%edi
}
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800309:	f3 0f 1e fb          	endbr32 
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800313:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800317:	8b 10                	mov    (%eax),%edx
  800319:	3b 50 04             	cmp    0x4(%eax),%edx
  80031c:	73 0a                	jae    800328 <sprintputch+0x1f>
		*b->buf++ = ch;
  80031e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800321:	89 08                	mov    %ecx,(%eax)
  800323:	8b 45 08             	mov    0x8(%ebp),%eax
  800326:	88 02                	mov    %al,(%edx)
}
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <printfmt>:
{
  80032a:	f3 0f 1e fb          	endbr32 
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800334:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800337:	50                   	push   %eax
  800338:	ff 75 10             	pushl  0x10(%ebp)
  80033b:	ff 75 0c             	pushl  0xc(%ebp)
  80033e:	ff 75 08             	pushl  0x8(%ebp)
  800341:	e8 05 00 00 00       	call   80034b <vprintfmt>
}
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	c9                   	leave  
  80034a:	c3                   	ret    

0080034b <vprintfmt>:
{
  80034b:	f3 0f 1e fb          	endbr32 
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
  800355:	83 ec 3c             	sub    $0x3c,%esp
  800358:	8b 75 08             	mov    0x8(%ebp),%esi
  80035b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800361:	e9 8e 03 00 00       	jmp    8006f4 <vprintfmt+0x3a9>
		padc = ' ';
  800366:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80036a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800371:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800378:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80037f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8d 47 01             	lea    0x1(%edi),%eax
  800387:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038a:	0f b6 17             	movzbl (%edi),%edx
  80038d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800390:	3c 55                	cmp    $0x55,%al
  800392:	0f 87 df 03 00 00    	ja     800777 <vprintfmt+0x42c>
  800398:	0f b6 c0             	movzbl %al,%eax
  80039b:	3e ff 24 85 00 16 80 	notrack jmp *0x801600(,%eax,4)
  8003a2:	00 
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003a6:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003aa:	eb d8                	jmp    800384 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003af:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003b3:	eb cf                	jmp    800384 <vprintfmt+0x39>
  8003b5:	0f b6 d2             	movzbl %dl,%edx
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003c3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ca:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003cd:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003d0:	83 f9 09             	cmp    $0x9,%ecx
  8003d3:	77 55                	ja     80042a <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003d5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003d8:	eb e9                	jmp    8003c3 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8b 00                	mov    (%eax),%eax
  8003df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 40 04             	lea    0x4(%eax),%eax
  8003e8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003ee:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f2:	79 90                	jns    800384 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fa:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800401:	eb 81                	jmp    800384 <vprintfmt+0x39>
  800403:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800406:	85 c0                	test   %eax,%eax
  800408:	ba 00 00 00 00       	mov    $0x0,%edx
  80040d:	0f 49 d0             	cmovns %eax,%edx
  800410:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800416:	e9 69 ff ff ff       	jmp    800384 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80041e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800425:	e9 5a ff ff ff       	jmp    800384 <vprintfmt+0x39>
  80042a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80042d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800430:	eb bc                	jmp    8003ee <vprintfmt+0xa3>
			lflag++;
  800432:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800438:	e9 47 ff ff ff       	jmp    800384 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 78 04             	lea    0x4(%eax),%edi
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	53                   	push   %ebx
  800447:	ff 30                	pushl  (%eax)
  800449:	ff d6                	call   *%esi
			break;
  80044b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80044e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800451:	e9 9b 02 00 00       	jmp    8006f1 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 78 04             	lea    0x4(%eax),%edi
  80045c:	8b 00                	mov    (%eax),%eax
  80045e:	99                   	cltd   
  80045f:	31 d0                	xor    %edx,%eax
  800461:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800463:	83 f8 08             	cmp    $0x8,%eax
  800466:	7f 23                	jg     80048b <vprintfmt+0x140>
  800468:	8b 14 85 60 17 80 00 	mov    0x801760(,%eax,4),%edx
  80046f:	85 d2                	test   %edx,%edx
  800471:	74 18                	je     80048b <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800473:	52                   	push   %edx
  800474:	68 6a 15 80 00       	push   $0x80156a
  800479:	53                   	push   %ebx
  80047a:	56                   	push   %esi
  80047b:	e8 aa fe ff ff       	call   80032a <printfmt>
  800480:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800483:	89 7d 14             	mov    %edi,0x14(%ebp)
  800486:	e9 66 02 00 00       	jmp    8006f1 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80048b:	50                   	push   %eax
  80048c:	68 61 15 80 00       	push   $0x801561
  800491:	53                   	push   %ebx
  800492:	56                   	push   %esi
  800493:	e8 92 fe ff ff       	call   80032a <printfmt>
  800498:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80049b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80049e:	e9 4e 02 00 00       	jmp    8006f1 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	83 c0 04             	add    $0x4,%eax
  8004a9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004b1:	85 d2                	test   %edx,%edx
  8004b3:	b8 5a 15 80 00       	mov    $0x80155a,%eax
  8004b8:	0f 45 c2             	cmovne %edx,%eax
  8004bb:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c2:	7e 06                	jle    8004ca <vprintfmt+0x17f>
  8004c4:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004c8:	75 0d                	jne    8004d7 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004cd:	89 c7                	mov    %eax,%edi
  8004cf:	03 45 e0             	add    -0x20(%ebp),%eax
  8004d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d5:	eb 55                	jmp    80052c <vprintfmt+0x1e1>
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 d8             	pushl  -0x28(%ebp)
  8004dd:	ff 75 cc             	pushl  -0x34(%ebp)
  8004e0:	e8 46 03 00 00       	call   80082b <strnlen>
  8004e5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004e8:	29 c2                	sub    %eax,%edx
  8004ea:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004f2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f9:	85 ff                	test   %edi,%edi
  8004fb:	7e 11                	jle    80050e <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	ff 75 e0             	pushl  -0x20(%ebp)
  800504:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800506:	83 ef 01             	sub    $0x1,%edi
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb eb                	jmp    8004f9 <vprintfmt+0x1ae>
  80050e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800511:	85 d2                	test   %edx,%edx
  800513:	b8 00 00 00 00       	mov    $0x0,%eax
  800518:	0f 49 c2             	cmovns %edx,%eax
  80051b:	29 c2                	sub    %eax,%edx
  80051d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800520:	eb a8                	jmp    8004ca <vprintfmt+0x17f>
					putch(ch, putdat);
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	53                   	push   %ebx
  800526:	52                   	push   %edx
  800527:	ff d6                	call   *%esi
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80052f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800531:	83 c7 01             	add    $0x1,%edi
  800534:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800538:	0f be d0             	movsbl %al,%edx
  80053b:	85 d2                	test   %edx,%edx
  80053d:	74 4b                	je     80058a <vprintfmt+0x23f>
  80053f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800543:	78 06                	js     80054b <vprintfmt+0x200>
  800545:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800549:	78 1e                	js     800569 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80054b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054f:	74 d1                	je     800522 <vprintfmt+0x1d7>
  800551:	0f be c0             	movsbl %al,%eax
  800554:	83 e8 20             	sub    $0x20,%eax
  800557:	83 f8 5e             	cmp    $0x5e,%eax
  80055a:	76 c6                	jbe    800522 <vprintfmt+0x1d7>
					putch('?', putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	53                   	push   %ebx
  800560:	6a 3f                	push   $0x3f
  800562:	ff d6                	call   *%esi
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	eb c3                	jmp    80052c <vprintfmt+0x1e1>
  800569:	89 cf                	mov    %ecx,%edi
  80056b:	eb 0e                	jmp    80057b <vprintfmt+0x230>
				putch(' ', putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	53                   	push   %ebx
  800571:	6a 20                	push   $0x20
  800573:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800575:	83 ef 01             	sub    $0x1,%edi
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	85 ff                	test   %edi,%edi
  80057d:	7f ee                	jg     80056d <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80057f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
  800585:	e9 67 01 00 00       	jmp    8006f1 <vprintfmt+0x3a6>
  80058a:	89 cf                	mov    %ecx,%edi
  80058c:	eb ed                	jmp    80057b <vprintfmt+0x230>
	if (lflag >= 2)
  80058e:	83 f9 01             	cmp    $0x1,%ecx
  800591:	7f 1b                	jg     8005ae <vprintfmt+0x263>
	else if (lflag)
  800593:	85 c9                	test   %ecx,%ecx
  800595:	74 63                	je     8005fa <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059f:	99                   	cltd   
  8005a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 40 04             	lea    0x4(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ac:	eb 17                	jmp    8005c5 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8b 50 04             	mov    0x4(%eax),%edx
  8005b4:	8b 00                	mov    (%eax),%eax
  8005b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 40 08             	lea    0x8(%eax),%eax
  8005c2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005cb:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005d0:	85 c9                	test   %ecx,%ecx
  8005d2:	0f 89 ff 00 00 00    	jns    8006d7 <vprintfmt+0x38c>
				putch('-', putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	6a 2d                	push   $0x2d
  8005de:	ff d6                	call   *%esi
				num = -(long long) num;
  8005e0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e6:	f7 da                	neg    %edx
  8005e8:	83 d1 00             	adc    $0x0,%ecx
  8005eb:	f7 d9                	neg    %ecx
  8005ed:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005f0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f5:	e9 dd 00 00 00       	jmp    8006d7 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	99                   	cltd   
  800603:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 40 04             	lea    0x4(%eax),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
  80060f:	eb b4                	jmp    8005c5 <vprintfmt+0x27a>
	if (lflag >= 2)
  800611:	83 f9 01             	cmp    $0x1,%ecx
  800614:	7f 1e                	jg     800634 <vprintfmt+0x2e9>
	else if (lflag)
  800616:	85 c9                	test   %ecx,%ecx
  800618:	74 32                	je     80064c <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800624:	8d 40 04             	lea    0x4(%eax),%eax
  800627:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80062f:	e9 a3 00 00 00       	jmp    8006d7 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8b 10                	mov    (%eax),%edx
  800639:	8b 48 04             	mov    0x4(%eax),%ecx
  80063c:	8d 40 08             	lea    0x8(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800647:	e9 8b 00 00 00       	jmp    8006d7 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	b9 00 00 00 00       	mov    $0x0,%ecx
  800656:	8d 40 04             	lea    0x4(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80065c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800661:	eb 74                	jmp    8006d7 <vprintfmt+0x38c>
	if (lflag >= 2)
  800663:	83 f9 01             	cmp    $0x1,%ecx
  800666:	7f 1b                	jg     800683 <vprintfmt+0x338>
	else if (lflag)
  800668:	85 c9                	test   %ecx,%ecx
  80066a:	74 2c                	je     800698 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	b9 00 00 00 00       	mov    $0x0,%ecx
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80067c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800681:	eb 54                	jmp    8006d7 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
  800688:	8b 48 04             	mov    0x4(%eax),%ecx
  80068b:	8d 40 08             	lea    0x8(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800691:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800696:	eb 3f                	jmp    8006d7 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a2:	8d 40 04             	lea    0x4(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006a8:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8006ad:	eb 28                	jmp    8006d7 <vprintfmt+0x38c>
			putch('0', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 30                	push   $0x30
  8006b5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b7:	83 c4 08             	add    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	6a 78                	push   $0x78
  8006bd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8b 10                	mov    (%eax),%edx
  8006c4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006c9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006cc:	8d 40 04             	lea    0x4(%eax),%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d2:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006d7:	83 ec 0c             	sub    $0xc,%esp
  8006da:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006de:	57                   	push   %edi
  8006df:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e2:	50                   	push   %eax
  8006e3:	51                   	push   %ecx
  8006e4:	52                   	push   %edx
  8006e5:	89 da                	mov    %ebx,%edx
  8006e7:	89 f0                	mov    %esi,%eax
  8006e9:	e8 72 fb ff ff       	call   800260 <printnum>
			break;
  8006ee:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8006f4:	83 c7 01             	add    $0x1,%edi
  8006f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006fb:	83 f8 25             	cmp    $0x25,%eax
  8006fe:	0f 84 62 fc ff ff    	je     800366 <vprintfmt+0x1b>
			if (ch == '\0')										
  800704:	85 c0                	test   %eax,%eax
  800706:	0f 84 8b 00 00 00    	je     800797 <vprintfmt+0x44c>
			putch(ch, putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	53                   	push   %ebx
  800710:	50                   	push   %eax
  800711:	ff d6                	call   *%esi
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb dc                	jmp    8006f4 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800718:	83 f9 01             	cmp    $0x1,%ecx
  80071b:	7f 1b                	jg     800738 <vprintfmt+0x3ed>
	else if (lflag)
  80071d:	85 c9                	test   %ecx,%ecx
  80071f:	74 2c                	je     80074d <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8b 10                	mov    (%eax),%edx
  800726:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072b:	8d 40 04             	lea    0x4(%eax),%eax
  80072e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800731:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800736:	eb 9f                	jmp    8006d7 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8b 10                	mov    (%eax),%edx
  80073d:	8b 48 04             	mov    0x4(%eax),%ecx
  800740:	8d 40 08             	lea    0x8(%eax),%eax
  800743:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800746:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80074b:	eb 8a                	jmp    8006d7 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80074d:	8b 45 14             	mov    0x14(%ebp),%eax
  800750:	8b 10                	mov    (%eax),%edx
  800752:	b9 00 00 00 00       	mov    $0x0,%ecx
  800757:	8d 40 04             	lea    0x4(%eax),%eax
  80075a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80075d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800762:	e9 70 ff ff ff       	jmp    8006d7 <vprintfmt+0x38c>
			putch(ch, putdat);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	53                   	push   %ebx
  80076b:	6a 25                	push   $0x25
  80076d:	ff d6                	call   *%esi
			break;
  80076f:	83 c4 10             	add    $0x10,%esp
  800772:	e9 7a ff ff ff       	jmp    8006f1 <vprintfmt+0x3a6>
			putch('%', putdat);
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	53                   	push   %ebx
  80077b:	6a 25                	push   $0x25
  80077d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	89 f8                	mov    %edi,%eax
  800784:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800788:	74 05                	je     80078f <vprintfmt+0x444>
  80078a:	83 e8 01             	sub    $0x1,%eax
  80078d:	eb f5                	jmp    800784 <vprintfmt+0x439>
  80078f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800792:	e9 5a ff ff ff       	jmp    8006f1 <vprintfmt+0x3a6>
}
  800797:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5f                   	pop    %edi
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079f:	f3 0f 1e fb          	endbr32 
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	83 ec 18             	sub    $0x18,%esp
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007b6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c0:	85 c0                	test   %eax,%eax
  8007c2:	74 26                	je     8007ea <vsnprintf+0x4b>
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	7e 22                	jle    8007ea <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c8:	ff 75 14             	pushl  0x14(%ebp)
  8007cb:	ff 75 10             	pushl  0x10(%ebp)
  8007ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d1:	50                   	push   %eax
  8007d2:	68 09 03 80 00       	push   $0x800309
  8007d7:	e8 6f fb ff ff       	call   80034b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007df:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e5:	83 c4 10             	add    $0x10,%esp
}
  8007e8:	c9                   	leave  
  8007e9:	c3                   	ret    
		return -E_INVAL;
  8007ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ef:	eb f7                	jmp    8007e8 <vsnprintf+0x49>

008007f1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f1:	f3 0f 1e fb          	endbr32 
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007fe:	50                   	push   %eax
  8007ff:	ff 75 10             	pushl  0x10(%ebp)
  800802:	ff 75 0c             	pushl  0xc(%ebp)
  800805:	ff 75 08             	pushl  0x8(%ebp)
  800808:	e8 92 ff ff ff       	call   80079f <vsnprintf>
	va_end(ap);

	return rc;
}
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    

0080080f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80080f:	f3 0f 1e fb          	endbr32 
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
  80081e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800822:	74 05                	je     800829 <strlen+0x1a>
		n++;
  800824:	83 c0 01             	add    $0x1,%eax
  800827:	eb f5                	jmp    80081e <strlen+0xf>
	return n;
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80082b:	f3 0f 1e fb          	endbr32 
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800835:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800838:	b8 00 00 00 00       	mov    $0x0,%eax
  80083d:	39 d0                	cmp    %edx,%eax
  80083f:	74 0d                	je     80084e <strnlen+0x23>
  800841:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800845:	74 05                	je     80084c <strnlen+0x21>
		n++;
  800847:	83 c0 01             	add    $0x1,%eax
  80084a:	eb f1                	jmp    80083d <strnlen+0x12>
  80084c:	89 c2                	mov    %eax,%edx
	return n;
}
  80084e:	89 d0                	mov    %edx,%eax
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800852:	f3 0f 1e fb          	endbr32 
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	53                   	push   %ebx
  80085a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800860:	b8 00 00 00 00       	mov    $0x0,%eax
  800865:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800869:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80086c:	83 c0 01             	add    $0x1,%eax
  80086f:	84 d2                	test   %dl,%dl
  800871:	75 f2                	jne    800865 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800873:	89 c8                	mov    %ecx,%eax
  800875:	5b                   	pop    %ebx
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800878:	f3 0f 1e fb          	endbr32 
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	53                   	push   %ebx
  800880:	83 ec 10             	sub    $0x10,%esp
  800883:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800886:	53                   	push   %ebx
  800887:	e8 83 ff ff ff       	call   80080f <strlen>
  80088c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80088f:	ff 75 0c             	pushl  0xc(%ebp)
  800892:	01 d8                	add    %ebx,%eax
  800894:	50                   	push   %eax
  800895:	e8 b8 ff ff ff       	call   800852 <strcpy>
	return dst;
}
  80089a:	89 d8                	mov    %ebx,%eax
  80089c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089f:	c9                   	leave  
  8008a0:	c3                   	ret    

008008a1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a1:	f3 0f 1e fb          	endbr32 
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b0:	89 f3                	mov    %esi,%ebx
  8008b2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b5:	89 f0                	mov    %esi,%eax
  8008b7:	39 d8                	cmp    %ebx,%eax
  8008b9:	74 11                	je     8008cc <strncpy+0x2b>
		*dst++ = *src;
  8008bb:	83 c0 01             	add    $0x1,%eax
  8008be:	0f b6 0a             	movzbl (%edx),%ecx
  8008c1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c4:	80 f9 01             	cmp    $0x1,%cl
  8008c7:	83 da ff             	sbb    $0xffffffff,%edx
  8008ca:	eb eb                	jmp    8008b7 <strncpy+0x16>
	}
	return ret;
}
  8008cc:	89 f0                	mov    %esi,%eax
  8008ce:	5b                   	pop    %ebx
  8008cf:	5e                   	pop    %esi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d2:	f3 0f 1e fb          	endbr32 
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 75 08             	mov    0x8(%ebp),%esi
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	8b 55 10             	mov    0x10(%ebp),%edx
  8008e4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e6:	85 d2                	test   %edx,%edx
  8008e8:	74 21                	je     80090b <strlcpy+0x39>
  8008ea:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ee:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008f0:	39 c2                	cmp    %eax,%edx
  8008f2:	74 14                	je     800908 <strlcpy+0x36>
  8008f4:	0f b6 19             	movzbl (%ecx),%ebx
  8008f7:	84 db                	test   %bl,%bl
  8008f9:	74 0b                	je     800906 <strlcpy+0x34>
			*dst++ = *src++;
  8008fb:	83 c1 01             	add    $0x1,%ecx
  8008fe:	83 c2 01             	add    $0x1,%edx
  800901:	88 5a ff             	mov    %bl,-0x1(%edx)
  800904:	eb ea                	jmp    8008f0 <strlcpy+0x1e>
  800906:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800908:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80090b:	29 f0                	sub    %esi,%eax
}
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800911:	f3 0f 1e fb          	endbr32 
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80091e:	0f b6 01             	movzbl (%ecx),%eax
  800921:	84 c0                	test   %al,%al
  800923:	74 0c                	je     800931 <strcmp+0x20>
  800925:	3a 02                	cmp    (%edx),%al
  800927:	75 08                	jne    800931 <strcmp+0x20>
		p++, q++;
  800929:	83 c1 01             	add    $0x1,%ecx
  80092c:	83 c2 01             	add    $0x1,%edx
  80092f:	eb ed                	jmp    80091e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800931:	0f b6 c0             	movzbl %al,%eax
  800934:	0f b6 12             	movzbl (%edx),%edx
  800937:	29 d0                	sub    %edx,%eax
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80093b:	f3 0f 1e fb          	endbr32 
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	53                   	push   %ebx
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 55 0c             	mov    0xc(%ebp),%edx
  800949:	89 c3                	mov    %eax,%ebx
  80094b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80094e:	eb 06                	jmp    800956 <strncmp+0x1b>
		n--, p++, q++;
  800950:	83 c0 01             	add    $0x1,%eax
  800953:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800956:	39 d8                	cmp    %ebx,%eax
  800958:	74 16                	je     800970 <strncmp+0x35>
  80095a:	0f b6 08             	movzbl (%eax),%ecx
  80095d:	84 c9                	test   %cl,%cl
  80095f:	74 04                	je     800965 <strncmp+0x2a>
  800961:	3a 0a                	cmp    (%edx),%cl
  800963:	74 eb                	je     800950 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800965:	0f b6 00             	movzbl (%eax),%eax
  800968:	0f b6 12             	movzbl (%edx),%edx
  80096b:	29 d0                	sub    %edx,%eax
}
  80096d:	5b                   	pop    %ebx
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    
		return 0;
  800970:	b8 00 00 00 00       	mov    $0x0,%eax
  800975:	eb f6                	jmp    80096d <strncmp+0x32>

00800977 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800977:	f3 0f 1e fb          	endbr32 
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	84 d2                	test   %dl,%dl
  80098a:	74 09                	je     800995 <strchr+0x1e>
		if (*s == c)
  80098c:	38 ca                	cmp    %cl,%dl
  80098e:	74 0a                	je     80099a <strchr+0x23>
	for (; *s; s++)
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	eb f0                	jmp    800985 <strchr+0xe>
			return (char *) s;
	return 0;
  800995:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80099c:	f3 0f 1e fb          	endbr32 
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009aa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ad:	38 ca                	cmp    %cl,%dl
  8009af:	74 09                	je     8009ba <strfind+0x1e>
  8009b1:	84 d2                	test   %dl,%dl
  8009b3:	74 05                	je     8009ba <strfind+0x1e>
	for (; *s; s++)
  8009b5:	83 c0 01             	add    $0x1,%eax
  8009b8:	eb f0                	jmp    8009aa <strfind+0xe>
			break;
	return (char *) s;
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009bc:	f3 0f 1e fb          	endbr32 
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	57                   	push   %edi
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
  8009c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009cc:	85 c9                	test   %ecx,%ecx
  8009ce:	74 31                	je     800a01 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d0:	89 f8                	mov    %edi,%eax
  8009d2:	09 c8                	or     %ecx,%eax
  8009d4:	a8 03                	test   $0x3,%al
  8009d6:	75 23                	jne    8009fb <memset+0x3f>
		c &= 0xFF;
  8009d8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009dc:	89 d3                	mov    %edx,%ebx
  8009de:	c1 e3 08             	shl    $0x8,%ebx
  8009e1:	89 d0                	mov    %edx,%eax
  8009e3:	c1 e0 18             	shl    $0x18,%eax
  8009e6:	89 d6                	mov    %edx,%esi
  8009e8:	c1 e6 10             	shl    $0x10,%esi
  8009eb:	09 f0                	or     %esi,%eax
  8009ed:	09 c2                	or     %eax,%edx
  8009ef:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009f1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009f4:	89 d0                	mov    %edx,%eax
  8009f6:	fc                   	cld    
  8009f7:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f9:	eb 06                	jmp    800a01 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	fc                   	cld    
  8009ff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a01:	89 f8                	mov    %edi,%eax
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5f                   	pop    %edi
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a08:	f3 0f 1e fb          	endbr32 
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a1a:	39 c6                	cmp    %eax,%esi
  800a1c:	73 32                	jae    800a50 <memmove+0x48>
  800a1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a21:	39 c2                	cmp    %eax,%edx
  800a23:	76 2b                	jbe    800a50 <memmove+0x48>
		s += n;
		d += n;
  800a25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a28:	89 fe                	mov    %edi,%esi
  800a2a:	09 ce                	or     %ecx,%esi
  800a2c:	09 d6                	or     %edx,%esi
  800a2e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a34:	75 0e                	jne    800a44 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a36:	83 ef 04             	sub    $0x4,%edi
  800a39:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a3c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a3f:	fd                   	std    
  800a40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a42:	eb 09                	jmp    800a4d <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a44:	83 ef 01             	sub    $0x1,%edi
  800a47:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a4a:	fd                   	std    
  800a4b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a4d:	fc                   	cld    
  800a4e:	eb 1a                	jmp    800a6a <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a50:	89 c2                	mov    %eax,%edx
  800a52:	09 ca                	or     %ecx,%edx
  800a54:	09 f2                	or     %esi,%edx
  800a56:	f6 c2 03             	test   $0x3,%dl
  800a59:	75 0a                	jne    800a65 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a5b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a5e:	89 c7                	mov    %eax,%edi
  800a60:	fc                   	cld    
  800a61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a63:	eb 05                	jmp    800a6a <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a65:	89 c7                	mov    %eax,%edi
  800a67:	fc                   	cld    
  800a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a6a:	5e                   	pop    %esi
  800a6b:	5f                   	pop    %edi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a6e:	f3 0f 1e fb          	endbr32 
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a78:	ff 75 10             	pushl  0x10(%ebp)
  800a7b:	ff 75 0c             	pushl  0xc(%ebp)
  800a7e:	ff 75 08             	pushl  0x8(%ebp)
  800a81:	e8 82 ff ff ff       	call   800a08 <memmove>
}
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a88:	f3 0f 1e fb          	endbr32 
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a97:	89 c6                	mov    %eax,%esi
  800a99:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9c:	39 f0                	cmp    %esi,%eax
  800a9e:	74 1c                	je     800abc <memcmp+0x34>
		if (*s1 != *s2)
  800aa0:	0f b6 08             	movzbl (%eax),%ecx
  800aa3:	0f b6 1a             	movzbl (%edx),%ebx
  800aa6:	38 d9                	cmp    %bl,%cl
  800aa8:	75 08                	jne    800ab2 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	83 c2 01             	add    $0x1,%edx
  800ab0:	eb ea                	jmp    800a9c <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ab2:	0f b6 c1             	movzbl %cl,%eax
  800ab5:	0f b6 db             	movzbl %bl,%ebx
  800ab8:	29 d8                	sub    %ebx,%eax
  800aba:	eb 05                	jmp    800ac1 <memcmp+0x39>
	}

	return 0;
  800abc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac5:	f3 0f 1e fb          	endbr32 
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ad2:	89 c2                	mov    %eax,%edx
  800ad4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ad7:	39 d0                	cmp    %edx,%eax
  800ad9:	73 09                	jae    800ae4 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800adb:	38 08                	cmp    %cl,(%eax)
  800add:	74 05                	je     800ae4 <memfind+0x1f>
	for (; s < ends; s++)
  800adf:	83 c0 01             	add    $0x1,%eax
  800ae2:	eb f3                	jmp    800ad7 <memfind+0x12>
			break;
	return (void *) s;
}
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ae6:	f3 0f 1e fb          	endbr32 
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af6:	eb 03                	jmp    800afb <strtol+0x15>
		s++;
  800af8:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800afb:	0f b6 01             	movzbl (%ecx),%eax
  800afe:	3c 20                	cmp    $0x20,%al
  800b00:	74 f6                	je     800af8 <strtol+0x12>
  800b02:	3c 09                	cmp    $0x9,%al
  800b04:	74 f2                	je     800af8 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b06:	3c 2b                	cmp    $0x2b,%al
  800b08:	74 2a                	je     800b34 <strtol+0x4e>
	int neg = 0;
  800b0a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b0f:	3c 2d                	cmp    $0x2d,%al
  800b11:	74 2b                	je     800b3e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b13:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b19:	75 0f                	jne    800b2a <strtol+0x44>
  800b1b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b1e:	74 28                	je     800b48 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b20:	85 db                	test   %ebx,%ebx
  800b22:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b27:	0f 44 d8             	cmove  %eax,%ebx
  800b2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b32:	eb 46                	jmp    800b7a <strtol+0x94>
		s++;
  800b34:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b37:	bf 00 00 00 00       	mov    $0x0,%edi
  800b3c:	eb d5                	jmp    800b13 <strtol+0x2d>
		s++, neg = 1;
  800b3e:	83 c1 01             	add    $0x1,%ecx
  800b41:	bf 01 00 00 00       	mov    $0x1,%edi
  800b46:	eb cb                	jmp    800b13 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b48:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b4c:	74 0e                	je     800b5c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b4e:	85 db                	test   %ebx,%ebx
  800b50:	75 d8                	jne    800b2a <strtol+0x44>
		s++, base = 8;
  800b52:	83 c1 01             	add    $0x1,%ecx
  800b55:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b5a:	eb ce                	jmp    800b2a <strtol+0x44>
		s += 2, base = 16;
  800b5c:	83 c1 02             	add    $0x2,%ecx
  800b5f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b64:	eb c4                	jmp    800b2a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b66:	0f be d2             	movsbl %dl,%edx
  800b69:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b6c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b6f:	7d 3a                	jge    800bab <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b71:	83 c1 01             	add    $0x1,%ecx
  800b74:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b78:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b7a:	0f b6 11             	movzbl (%ecx),%edx
  800b7d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b80:	89 f3                	mov    %esi,%ebx
  800b82:	80 fb 09             	cmp    $0x9,%bl
  800b85:	76 df                	jbe    800b66 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b87:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8a:	89 f3                	mov    %esi,%ebx
  800b8c:	80 fb 19             	cmp    $0x19,%bl
  800b8f:	77 08                	ja     800b99 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b91:	0f be d2             	movsbl %dl,%edx
  800b94:	83 ea 57             	sub    $0x57,%edx
  800b97:	eb d3                	jmp    800b6c <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b99:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9c:	89 f3                	mov    %esi,%ebx
  800b9e:	80 fb 19             	cmp    $0x19,%bl
  800ba1:	77 08                	ja     800bab <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ba3:	0f be d2             	movsbl %dl,%edx
  800ba6:	83 ea 37             	sub    $0x37,%edx
  800ba9:	eb c1                	jmp    800b6c <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800baf:	74 05                	je     800bb6 <strtol+0xd0>
		*endptr = (char *) s;
  800bb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bb6:	89 c2                	mov    %eax,%edx
  800bb8:	f7 da                	neg    %edx
  800bba:	85 ff                	test   %edi,%edi
  800bbc:	0f 45 c2             	cmovne %edx,%eax
}
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bc4:	f3 0f 1e fb          	endbr32 
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bce:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd9:	89 c3                	mov    %eax,%ebx
  800bdb:	89 c7                	mov    %eax,%edi
  800bdd:	89 c6                	mov    %eax,%esi
  800bdf:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800be6:	f3 0f 1e fb          	endbr32 
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bfa:	89 d1                	mov    %edx,%ecx
  800bfc:	89 d3                	mov    %edx,%ebx
  800bfe:	89 d7                	mov    %edx,%edi
  800c00:	89 d6                	mov    %edx,%esi
  800c02:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c09:	f3 0f 1e fb          	endbr32 
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c23:	89 cb                	mov    %ecx,%ebx
  800c25:	89 cf                	mov    %ecx,%edi
  800c27:	89 ce                	mov    %ecx,%esi
  800c29:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	7f 08                	jg     800c37 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	50                   	push   %eax
  800c3b:	6a 03                	push   $0x3
  800c3d:	68 84 17 80 00       	push   $0x801784
  800c42:	6a 23                	push   $0x23
  800c44:	68 a1 17 80 00       	push   $0x8017a1
  800c49:	e8 13 f5 ff ff       	call   800161 <_panic>

00800c4e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c4e:	f3 0f 1e fb          	endbr32 
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c58:	ba 00 00 00 00       	mov    $0x0,%edx
  800c5d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c62:	89 d1                	mov    %edx,%ecx
  800c64:	89 d3                	mov    %edx,%ebx
  800c66:	89 d7                	mov    %edx,%edi
  800c68:	89 d6                	mov    %edx,%esi
  800c6a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_yield>:

void
sys_yield(void)
{
  800c71:	f3 0f 1e fb          	endbr32 
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c80:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c85:	89 d1                	mov    %edx,%ecx
  800c87:	89 d3                	mov    %edx,%ebx
  800c89:	89 d7                	mov    %edx,%edi
  800c8b:	89 d6                	mov    %edx,%esi
  800c8d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c94:	f3 0f 1e fb          	endbr32 
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800ca1:	be 00 00 00 00       	mov    $0x0,%esi
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cac:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb4:	89 f7                	mov    %esi,%edi
  800cb6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb8:	85 c0                	test   %eax,%eax
  800cba:	7f 08                	jg     800cc4 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	83 ec 0c             	sub    $0xc,%esp
  800cc7:	50                   	push   %eax
  800cc8:	6a 04                	push   $0x4
  800cca:	68 84 17 80 00       	push   $0x801784
  800ccf:	6a 23                	push   $0x23
  800cd1:	68 a1 17 80 00       	push   $0x8017a1
  800cd6:	e8 86 f4 ff ff       	call   800161 <_panic>

00800cdb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cdb:	f3 0f 1e fb          	endbr32 
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7f 08                	jg     800d0a <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0a:	83 ec 0c             	sub    $0xc,%esp
  800d0d:	50                   	push   %eax
  800d0e:	6a 05                	push   $0x5
  800d10:	68 84 17 80 00       	push   $0x801784
  800d15:	6a 23                	push   $0x23
  800d17:	68 a1 17 80 00       	push   $0x8017a1
  800d1c:	e8 40 f4 ff ff       	call   800161 <_panic>

00800d21 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d21:	f3 0f 1e fb          	endbr32 
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d33:	8b 55 08             	mov    0x8(%ebp),%edx
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3e:	89 df                	mov    %ebx,%edi
  800d40:	89 de                	mov    %ebx,%esi
  800d42:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7f 08                	jg     800d50 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d50:	83 ec 0c             	sub    $0xc,%esp
  800d53:	50                   	push   %eax
  800d54:	6a 06                	push   $0x6
  800d56:	68 84 17 80 00       	push   $0x801784
  800d5b:	6a 23                	push   $0x23
  800d5d:	68 a1 17 80 00       	push   $0x8017a1
  800d62:	e8 fa f3 ff ff       	call   800161 <_panic>

00800d67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d67:	f3 0f 1e fb          	endbr32 
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	b8 08 00 00 00       	mov    $0x8,%eax
  800d84:	89 df                	mov    %ebx,%edi
  800d86:	89 de                	mov    %ebx,%esi
  800d88:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	7f 08                	jg     800d96 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	50                   	push   %eax
  800d9a:	6a 08                	push   $0x8
  800d9c:	68 84 17 80 00       	push   $0x801784
  800da1:	6a 23                	push   $0x23
  800da3:	68 a1 17 80 00       	push   $0x8017a1
  800da8:	e8 b4 f3 ff ff       	call   800161 <_panic>

00800dad <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dad:	f3 0f 1e fb          	endbr32 
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
  800db7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800dba:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc5:	b8 09 00 00 00       	mov    $0x9,%eax
  800dca:	89 df                	mov    %ebx,%edi
  800dcc:	89 de                	mov    %ebx,%esi
  800dce:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	7f 08                	jg     800ddc <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd7:	5b                   	pop    %ebx
  800dd8:	5e                   	pop    %esi
  800dd9:	5f                   	pop    %edi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	50                   	push   %eax
  800de0:	6a 09                	push   $0x9
  800de2:	68 84 17 80 00       	push   $0x801784
  800de7:	6a 23                	push   $0x23
  800de9:	68 a1 17 80 00       	push   $0x8017a1
  800dee:	e8 6e f3 ff ff       	call   800161 <_panic>

00800df3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800df3:	f3 0f 1e fb          	endbr32 
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e03:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e08:	be 00 00 00 00       	mov    $0x0,%esi
  800e0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e13:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e1a:	f3 0f 1e fb          	endbr32 
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800e27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e34:	89 cb                	mov    %ecx,%ebx
  800e36:	89 cf                	mov    %ecx,%edi
  800e38:	89 ce                	mov    %ecx,%esi
  800e3a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	7f 08                	jg     800e48 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	50                   	push   %eax
  800e4c:	6a 0c                	push   $0xc
  800e4e:	68 84 17 80 00       	push   $0x801784
  800e53:	6a 23                	push   $0x23
  800e55:	68 a1 17 80 00       	push   $0x8017a1
  800e5a:	e8 02 f3 ff ff       	call   800161 <_panic>

00800e5f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e5f:	f3 0f 1e fb          	endbr32 
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	53                   	push   %ebx
  800e67:	83 ec 04             	sub    $0x4,%esp
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e6d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) { 
  800e6f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e73:	74 74                	je     800ee9 <pgfault+0x8a>
  800e75:	89 d8                	mov    %ebx,%eax
  800e77:	c1 e8 0c             	shr    $0xc,%eax
  800e7a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e81:	f6 c4 08             	test   $0x8,%ah
  800e84:	74 63                	je     800ee9 <pgfault+0x8a>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e86:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U|PTE_P)) < 0)		
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	6a 05                	push   $0x5
  800e91:	68 00 f0 7f 00       	push   $0x7ff000
  800e96:	6a 00                	push   $0x0
  800e98:	53                   	push   %ebx
  800e99:	6a 00                	push   $0x0
  800e9b:	e8 3b fe ff ff       	call   800cdb <sys_page_map>
  800ea0:	83 c4 20             	add    $0x20,%esp
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	78 56                	js     800efd <pgfault+0x9e>
		panic("sys_page_map: %e", r);
	if ((r = sys_page_alloc(0, addr, PTE_P|PTE_U|PTE_W)) < 0)	
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	6a 07                	push   $0x7
  800eac:	53                   	push   %ebx
  800ead:	6a 00                	push   $0x0
  800eaf:	e8 e0 fd ff ff       	call   800c94 <sys_page_alloc>
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	78 54                	js     800f0f <pgfault+0xb0>
		panic("sys_page_alloc: %e", r);
	memmove(addr, PFTEMP, PGSIZE);							
  800ebb:	83 ec 04             	sub    $0x4,%esp
  800ebe:	68 00 10 00 00       	push   $0x1000
  800ec3:	68 00 f0 7f 00       	push   $0x7ff000
  800ec8:	53                   	push   %ebx
  800ec9:	e8 3a fb ff ff       	call   800a08 <memmove>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)				
  800ece:	83 c4 08             	add    $0x8,%esp
  800ed1:	68 00 f0 7f 00       	push   $0x7ff000
  800ed6:	6a 00                	push   $0x0
  800ed8:	e8 44 fe ff ff       	call   800d21 <sys_page_unmap>
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	78 3d                	js     800f21 <pgfault+0xc2>
		panic("sys_page_unmap: %e", r);
}
  800ee4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee7:	c9                   	leave  
  800ee8:	c3                   	ret    
		panic("pgfault():not cow");
  800ee9:	83 ec 04             	sub    $0x4,%esp
  800eec:	68 af 17 80 00       	push   $0x8017af
  800ef1:	6a 1d                	push   $0x1d
  800ef3:	68 c1 17 80 00       	push   $0x8017c1
  800ef8:	e8 64 f2 ff ff       	call   800161 <_panic>
		panic("sys_page_map: %e", r);
  800efd:	50                   	push   %eax
  800efe:	68 cc 17 80 00       	push   $0x8017cc
  800f03:	6a 2a                	push   $0x2a
  800f05:	68 c1 17 80 00       	push   $0x8017c1
  800f0a:	e8 52 f2 ff ff       	call   800161 <_panic>
		panic("sys_page_alloc: %e", r);
  800f0f:	50                   	push   %eax
  800f10:	68 dd 17 80 00       	push   $0x8017dd
  800f15:	6a 2c                	push   $0x2c
  800f17:	68 c1 17 80 00       	push   $0x8017c1
  800f1c:	e8 40 f2 ff ff       	call   800161 <_panic>
		panic("sys_page_unmap: %e", r);
  800f21:	50                   	push   %eax
  800f22:	68 f0 17 80 00       	push   $0x8017f0
  800f27:	6a 2f                	push   $0x2f
  800f29:	68 c1 17 80 00       	push   $0x8017c1
  800f2e:	e8 2e f2 ff ff       	call   800161 <_panic>

00800f33 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f33:	f3 0f 1e fb          	endbr32 
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	57                   	push   %edi
  800f3b:	56                   	push   %esi
  800f3c:	53                   	push   %ebx
  800f3d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall(void);
	set_pgfault_handler(pgfault);	
  800f40:	68 5f 0e 80 00       	push   $0x800e5f
  800f45:	e8 be 02 00 00       	call   801208 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f4a:	b8 07 00 00 00       	mov    $0x7,%eax
  800f4f:	cd 30                	int    $0x30
  800f51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();	
	if (envid == 0) {				
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	85 c0                	test   %eax,%eax
  800f59:	74 12                	je     800f6d <fork+0x3a>
  800f5b:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0) {
  800f5d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f61:	78 29                	js     800f8c <fork+0x59>
		panic("sys_exofork: %e", envid);
	}

	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800f63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f68:	e9 80 00 00 00       	jmp    800fed <fork+0xba>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f6d:	e8 dc fc ff ff       	call   800c4e <sys_getenvid>
  800f72:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f77:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800f7d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f82:	a3 60 40 80 00       	mov    %eax,0x804060
		return 0;
  800f87:	e9 27 01 00 00       	jmp    8010b3 <fork+0x180>
		panic("sys_exofork: %e", envid);
  800f8c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f8f:	68 03 18 80 00       	push   $0x801803
  800f94:	6a 6b                	push   $0x6b
  800f96:	68 c1 17 80 00       	push   $0x8017c1
  800f9b:	e8 c1 f1 ff ff       	call   800161 <_panic>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	68 05 08 00 00       	push   $0x805
  800fa8:	56                   	push   %esi
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	6a 00                	push   $0x0
  800fad:	e8 29 fd ff ff       	call   800cdb <sys_page_map>
  800fb2:	83 c4 20             	add    $0x20,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	0f 88 96 00 00 00    	js     801053 <fork+0x120>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	68 05 08 00 00       	push   $0x805
  800fc5:	56                   	push   %esi
  800fc6:	6a 00                	push   $0x0
  800fc8:	56                   	push   %esi
  800fc9:	6a 00                	push   $0x0
  800fcb:	e8 0b fd ff ff       	call   800cdb <sys_page_map>
  800fd0:	83 c4 20             	add    $0x20,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	0f 88 8a 00 00 00    	js     801065 <fork+0x132>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800fdb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fe1:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fe7:	0f 84 8a 00 00 00    	je     801077 <fork+0x144>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) 
  800fed:	89 d8                	mov    %ebx,%eax
  800fef:	c1 e8 16             	shr    $0x16,%eax
  800ff2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff9:	a8 01                	test   $0x1,%al
  800ffb:	74 de                	je     800fdb <fork+0xa8>
  800ffd:	89 d8                	mov    %ebx,%eax
  800fff:	c1 e8 0c             	shr    $0xc,%eax
  801002:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801009:	f6 c2 01             	test   $0x1,%dl
  80100c:	74 cd                	je     800fdb <fork+0xa8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  80100e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801015:	f6 c2 04             	test   $0x4,%dl
  801018:	74 c1                	je     800fdb <fork+0xa8>
	void *addr = (void*) (pn * PGSIZE);
  80101a:	89 c6                	mov    %eax,%esi
  80101c:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) { 
  80101f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801026:	f6 c2 02             	test   $0x2,%dl
  801029:	0f 85 71 ff ff ff    	jne    800fa0 <fork+0x6d>
  80102f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801036:	f6 c4 08             	test   $0x8,%ah
  801039:	0f 85 61 ff ff ff    	jne    800fa0 <fork+0x6d>
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);	
  80103f:	83 ec 0c             	sub    $0xc,%esp
  801042:	6a 05                	push   $0x5
  801044:	56                   	push   %esi
  801045:	57                   	push   %edi
  801046:	56                   	push   %esi
  801047:	6a 00                	push   $0x0
  801049:	e8 8d fc ff ff       	call   800cdb <sys_page_map>
  80104e:	83 c4 20             	add    $0x20,%esp
  801051:	eb 88                	jmp    800fdb <fork+0xa8>
			panic("sys_page_map：%e", r);
  801053:	50                   	push   %eax
  801054:	68 13 18 80 00       	push   $0x801813
  801059:	6a 46                	push   $0x46
  80105b:	68 c1 17 80 00       	push   $0x8017c1
  801060:	e8 fc f0 ff ff       	call   800161 <_panic>
			panic("sys_page_map：%e", r);
  801065:	50                   	push   %eax
  801066:	68 13 18 80 00       	push   $0x801813
  80106b:	6a 48                	push   $0x48
  80106d:	68 c1 17 80 00       	push   $0x8017c1
  801072:	e8 ea f0 ff ff       	call   800161 <_panic>
			duppage(envid, PGNUM(addr));	
		}
	}
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	6a 07                	push   $0x7
  80107c:	68 00 f0 bf ee       	push   $0xeebff000
  801081:	ff 75 e4             	pushl  -0x1c(%ebp)
  801084:	e8 0b fc ff ff       	call   800c94 <sys_page_alloc>
  801089:	83 c4 10             	add    $0x10,%esp
  80108c:	85 c0                	test   %eax,%eax
  80108e:	78 2e                	js     8010be <fork+0x18b>
		panic("sys_page_alloc: %e", r);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  801090:	83 ec 08             	sub    $0x8,%esp
  801093:	68 65 12 80 00       	push   $0x801265
  801098:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80109b:	57                   	push   %edi
  80109c:	e8 0c fd ff ff       	call   800dad <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	
  8010a1:	83 c4 08             	add    $0x8,%esp
  8010a4:	6a 02                	push   $0x2
  8010a6:	57                   	push   %edi
  8010a7:	e8 bb fc ff ff       	call   800d67 <sys_env_set_status>
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	78 1d                	js     8010d0 <fork+0x19d>
		panic("sys_env_set_status: %e", r);
	return envid;
}
  8010b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b9:	5b                   	pop    %ebx
  8010ba:	5e                   	pop    %esi
  8010bb:	5f                   	pop    %edi
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  8010be:	50                   	push   %eax
  8010bf:	68 dd 17 80 00       	push   $0x8017dd
  8010c4:	6a 77                	push   $0x77
  8010c6:	68 c1 17 80 00       	push   $0x8017c1
  8010cb:	e8 91 f0 ff ff       	call   800161 <_panic>
		panic("sys_env_set_status: %e", r);
  8010d0:	50                   	push   %eax
  8010d1:	68 25 18 80 00       	push   $0x801825
  8010d6:	6a 7b                	push   $0x7b
  8010d8:	68 c1 17 80 00       	push   $0x8017c1
  8010dd:	e8 7f f0 ff ff       	call   800161 <_panic>

008010e2 <sfork>:

// Challenge!
int
sfork(void)
{
  8010e2:	f3 0f 1e fb          	endbr32 
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ec:	68 3c 18 80 00       	push   $0x80183c
  8010f1:	68 83 00 00 00       	push   $0x83
  8010f6:	68 c1 17 80 00       	push   $0x8017c1
  8010fb:	e8 61 f0 ff ff       	call   800161 <_panic>

00801100 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801100:	f3 0f 1e fb          	endbr32 
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	56                   	push   %esi
  801108:	53                   	push   %ebx
  801109:	8b 75 08             	mov    0x8(%ebp),%esi
  80110c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *)-1;
  801112:	85 c0                	test   %eax,%eax
  801114:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801119:	0f 44 c2             	cmove  %edx,%eax
	}
	int r = sys_ipc_recv(pg);
  80111c:	83 ec 0c             	sub    $0xc,%esp
  80111f:	50                   	push   %eax
  801120:	e8 f5 fc ff ff       	call   800e1a <sys_ipc_recv>
	if (r < 0) {				
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	85 c0                	test   %eax,%eax
  80112a:	78 2b                	js     801157 <ipc_recv+0x57>
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return r;
	}
	if (from_env_store)
  80112c:	85 f6                	test   %esi,%esi
  80112e:	74 0a                	je     80113a <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801130:	a1 60 40 80 00       	mov    0x804060,%eax
  801135:	8b 40 74             	mov    0x74(%eax),%eax
  801138:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  80113a:	85 db                	test   %ebx,%ebx
  80113c:	74 0a                	je     801148 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  80113e:	a1 60 40 80 00       	mov    0x804060,%eax
  801143:	8b 40 78             	mov    0x78(%eax),%eax
  801146:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801148:	a1 60 40 80 00       	mov    0x804060,%eax
  80114d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801150:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801153:	5b                   	pop    %ebx
  801154:	5e                   	pop    %esi
  801155:	5d                   	pop    %ebp
  801156:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  801157:	85 f6                	test   %esi,%esi
  801159:	74 06                	je     801161 <ipc_recv+0x61>
  80115b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801161:	85 db                	test   %ebx,%ebx
  801163:	74 eb                	je     801150 <ipc_recv+0x50>
  801165:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80116b:	eb e3                	jmp    801150 <ipc_recv+0x50>

0080116d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80116d:	f3 0f 1e fb          	endbr32 
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	57                   	push   %edi
  801175:	56                   	push   %esi
  801176:	53                   	push   %ebx
  801177:	83 ec 0c             	sub    $0xc,%esp
  80117a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801180:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *)-1;
  801183:	85 db                	test   %ebx,%ebx
  801185:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80118a:	0f 44 d8             	cmove  %eax,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80118d:	ff 75 14             	pushl  0x14(%ebp)
  801190:	53                   	push   %ebx
  801191:	56                   	push   %esi
  801192:	57                   	push   %edi
  801193:	e8 5b fc ff ff       	call   800df3 <sys_ipc_try_send>
		if (r == 0) {		
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	74 1e                	je     8011bd <ipc_send+0x50>
			return;
		} else if (r == -E_IPC_NOT_RECV) {
  80119f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011a2:	75 07                	jne    8011ab <ipc_send+0x3e>
			sys_yield();
  8011a4:	e8 c8 fa ff ff       	call   800c71 <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011a9:	eb e2                	jmp    80118d <ipc_send+0x20>
		} else {			
			panic("ipc_send():%e", r);
  8011ab:	50                   	push   %eax
  8011ac:	68 52 18 80 00       	push   $0x801852
  8011b1:	6a 41                	push   $0x41
  8011b3:	68 60 18 80 00       	push   $0x801860
  8011b8:	e8 a4 ef ff ff       	call   800161 <_panic>
		}
	}
}
  8011bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c0:	5b                   	pop    %ebx
  8011c1:	5e                   	pop    %esi
  8011c2:	5f                   	pop    %edi
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011c5:	f3 0f 1e fb          	endbr32 
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011cf:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011d4:	69 d0 84 00 00 00    	imul   $0x84,%eax,%edx
  8011da:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011e0:	8b 52 50             	mov    0x50(%edx),%edx
  8011e3:	39 ca                	cmp    %ecx,%edx
  8011e5:	74 11                	je     8011f8 <ipc_find_env+0x33>
	for (i = 0; i < NENV; i++)
  8011e7:	83 c0 01             	add    $0x1,%eax
  8011ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011ef:	75 e3                	jne    8011d4 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8011f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f6:	eb 0e                	jmp    801206 <ipc_find_env+0x41>
			return envs[i].env_id;
  8011f8:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  8011fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801203:	8b 40 48             	mov    0x48(%eax),%eax
}
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801208:	f3 0f 1e fb          	endbr32 
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801212:	83 3d 64 40 80 00 00 	cmpl   $0x0,0x804064
  801219:	74 0a                	je     801225 <set_pgfault_handler+0x1d>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80121b:	8b 45 08             	mov    0x8(%ebp),%eax
  80121e:	a3 64 40 80 00       	mov    %eax,0x804064
}
  801223:	c9                   	leave  
  801224:	c3                   	ret    
		int r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);	//为当前进程分配异常栈
  801225:	83 ec 04             	sub    $0x4,%esp
  801228:	6a 07                	push   $0x7
  80122a:	68 00 f0 bf ee       	push   $0xeebff000
  80122f:	6a 00                	push   $0x0
  801231:	e8 5e fa ff ff       	call   800c94 <sys_page_alloc>
		if (r < 0) {
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	78 14                	js     801251 <set_pgfault_handler+0x49>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
  80123d:	83 ec 08             	sub    $0x8,%esp
  801240:	68 65 12 80 00       	push   $0x801265
  801245:	6a 00                	push   $0x0
  801247:	e8 61 fb ff ff       	call   800dad <sys_env_set_pgfault_upcall>
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	eb ca                	jmp    80121b <set_pgfault_handler+0x13>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	68 6c 18 80 00       	push   $0x80186c
  801259:	6a 22                	push   $0x22
  80125b:	68 96 18 80 00       	push   $0x801896
  801260:	e8 fc ee ff ff       	call   800161 <_panic>

00801265 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801265:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801266:	a1 64 40 80 00       	mov    0x804064,%eax
	call *%eax				
  80126b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80126d:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp			
  801270:	83 c4 08             	add    $0x8,%esp
	movl 40(%esp), %eax 	
  801273:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 32(%esp), %ecx 	
  801277:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl %ecx, -4(%eax) 	
  80127b:	89 48 fc             	mov    %ecx,-0x4(%eax)
	popal
  80127e:	61                   	popa   
	addl $4, %esp		
  80127f:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popfl
  801282:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801283:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp	
  801284:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  801288:	c3                   	ret    
  801289:	66 90                	xchg   %ax,%ax
  80128b:	66 90                	xchg   %ax,%ax
  80128d:	66 90                	xchg   %ax,%ax
  80128f:	90                   	nop

00801290 <__udivdi3>:
  801290:	f3 0f 1e fb          	endbr32 
  801294:	55                   	push   %ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	83 ec 1c             	sub    $0x1c,%esp
  80129b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80129f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8012a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8012ab:	85 d2                	test   %edx,%edx
  8012ad:	75 19                	jne    8012c8 <__udivdi3+0x38>
  8012af:	39 f3                	cmp    %esi,%ebx
  8012b1:	76 4d                	jbe    801300 <__udivdi3+0x70>
  8012b3:	31 ff                	xor    %edi,%edi
  8012b5:	89 e8                	mov    %ebp,%eax
  8012b7:	89 f2                	mov    %esi,%edx
  8012b9:	f7 f3                	div    %ebx
  8012bb:	89 fa                	mov    %edi,%edx
  8012bd:	83 c4 1c             	add    $0x1c,%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    
  8012c5:	8d 76 00             	lea    0x0(%esi),%esi
  8012c8:	39 f2                	cmp    %esi,%edx
  8012ca:	76 14                	jbe    8012e0 <__udivdi3+0x50>
  8012cc:	31 ff                	xor    %edi,%edi
  8012ce:	31 c0                	xor    %eax,%eax
  8012d0:	89 fa                	mov    %edi,%edx
  8012d2:	83 c4 1c             	add    $0x1c,%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    
  8012da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012e0:	0f bd fa             	bsr    %edx,%edi
  8012e3:	83 f7 1f             	xor    $0x1f,%edi
  8012e6:	75 48                	jne    801330 <__udivdi3+0xa0>
  8012e8:	39 f2                	cmp    %esi,%edx
  8012ea:	72 06                	jb     8012f2 <__udivdi3+0x62>
  8012ec:	31 c0                	xor    %eax,%eax
  8012ee:	39 eb                	cmp    %ebp,%ebx
  8012f0:	77 de                	ja     8012d0 <__udivdi3+0x40>
  8012f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8012f7:	eb d7                	jmp    8012d0 <__udivdi3+0x40>
  8012f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801300:	89 d9                	mov    %ebx,%ecx
  801302:	85 db                	test   %ebx,%ebx
  801304:	75 0b                	jne    801311 <__udivdi3+0x81>
  801306:	b8 01 00 00 00       	mov    $0x1,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	f7 f3                	div    %ebx
  80130f:	89 c1                	mov    %eax,%ecx
  801311:	31 d2                	xor    %edx,%edx
  801313:	89 f0                	mov    %esi,%eax
  801315:	f7 f1                	div    %ecx
  801317:	89 c6                	mov    %eax,%esi
  801319:	89 e8                	mov    %ebp,%eax
  80131b:	89 f7                	mov    %esi,%edi
  80131d:	f7 f1                	div    %ecx
  80131f:	89 fa                	mov    %edi,%edx
  801321:	83 c4 1c             	add    $0x1c,%esp
  801324:	5b                   	pop    %ebx
  801325:	5e                   	pop    %esi
  801326:	5f                   	pop    %edi
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    
  801329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801330:	89 f9                	mov    %edi,%ecx
  801332:	b8 20 00 00 00       	mov    $0x20,%eax
  801337:	29 f8                	sub    %edi,%eax
  801339:	d3 e2                	shl    %cl,%edx
  80133b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80133f:	89 c1                	mov    %eax,%ecx
  801341:	89 da                	mov    %ebx,%edx
  801343:	d3 ea                	shr    %cl,%edx
  801345:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801349:	09 d1                	or     %edx,%ecx
  80134b:	89 f2                	mov    %esi,%edx
  80134d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801351:	89 f9                	mov    %edi,%ecx
  801353:	d3 e3                	shl    %cl,%ebx
  801355:	89 c1                	mov    %eax,%ecx
  801357:	d3 ea                	shr    %cl,%edx
  801359:	89 f9                	mov    %edi,%ecx
  80135b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80135f:	89 eb                	mov    %ebp,%ebx
  801361:	d3 e6                	shl    %cl,%esi
  801363:	89 c1                	mov    %eax,%ecx
  801365:	d3 eb                	shr    %cl,%ebx
  801367:	09 de                	or     %ebx,%esi
  801369:	89 f0                	mov    %esi,%eax
  80136b:	f7 74 24 08          	divl   0x8(%esp)
  80136f:	89 d6                	mov    %edx,%esi
  801371:	89 c3                	mov    %eax,%ebx
  801373:	f7 64 24 0c          	mull   0xc(%esp)
  801377:	39 d6                	cmp    %edx,%esi
  801379:	72 15                	jb     801390 <__udivdi3+0x100>
  80137b:	89 f9                	mov    %edi,%ecx
  80137d:	d3 e5                	shl    %cl,%ebp
  80137f:	39 c5                	cmp    %eax,%ebp
  801381:	73 04                	jae    801387 <__udivdi3+0xf7>
  801383:	39 d6                	cmp    %edx,%esi
  801385:	74 09                	je     801390 <__udivdi3+0x100>
  801387:	89 d8                	mov    %ebx,%eax
  801389:	31 ff                	xor    %edi,%edi
  80138b:	e9 40 ff ff ff       	jmp    8012d0 <__udivdi3+0x40>
  801390:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801393:	31 ff                	xor    %edi,%edi
  801395:	e9 36 ff ff ff       	jmp    8012d0 <__udivdi3+0x40>
  80139a:	66 90                	xchg   %ax,%ax
  80139c:	66 90                	xchg   %ax,%ax
  80139e:	66 90                	xchg   %ax,%ax

008013a0 <__umoddi3>:
  8013a0:	f3 0f 1e fb          	endbr32 
  8013a4:	55                   	push   %ebp
  8013a5:	57                   	push   %edi
  8013a6:	56                   	push   %esi
  8013a7:	53                   	push   %ebx
  8013a8:	83 ec 1c             	sub    $0x1c,%esp
  8013ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8013af:	8b 74 24 30          	mov    0x30(%esp),%esi
  8013b3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8013b7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	75 19                	jne    8013d8 <__umoddi3+0x38>
  8013bf:	39 df                	cmp    %ebx,%edi
  8013c1:	76 5d                	jbe    801420 <__umoddi3+0x80>
  8013c3:	89 f0                	mov    %esi,%eax
  8013c5:	89 da                	mov    %ebx,%edx
  8013c7:	f7 f7                	div    %edi
  8013c9:	89 d0                	mov    %edx,%eax
  8013cb:	31 d2                	xor    %edx,%edx
  8013cd:	83 c4 1c             	add    $0x1c,%esp
  8013d0:	5b                   	pop    %ebx
  8013d1:	5e                   	pop    %esi
  8013d2:	5f                   	pop    %edi
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    
  8013d5:	8d 76 00             	lea    0x0(%esi),%esi
  8013d8:	89 f2                	mov    %esi,%edx
  8013da:	39 d8                	cmp    %ebx,%eax
  8013dc:	76 12                	jbe    8013f0 <__umoddi3+0x50>
  8013de:	89 f0                	mov    %esi,%eax
  8013e0:	89 da                	mov    %ebx,%edx
  8013e2:	83 c4 1c             	add    $0x1c,%esp
  8013e5:	5b                   	pop    %ebx
  8013e6:	5e                   	pop    %esi
  8013e7:	5f                   	pop    %edi
  8013e8:	5d                   	pop    %ebp
  8013e9:	c3                   	ret    
  8013ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013f0:	0f bd e8             	bsr    %eax,%ebp
  8013f3:	83 f5 1f             	xor    $0x1f,%ebp
  8013f6:	75 50                	jne    801448 <__umoddi3+0xa8>
  8013f8:	39 d8                	cmp    %ebx,%eax
  8013fa:	0f 82 e0 00 00 00    	jb     8014e0 <__umoddi3+0x140>
  801400:	89 d9                	mov    %ebx,%ecx
  801402:	39 f7                	cmp    %esi,%edi
  801404:	0f 86 d6 00 00 00    	jbe    8014e0 <__umoddi3+0x140>
  80140a:	89 d0                	mov    %edx,%eax
  80140c:	89 ca                	mov    %ecx,%edx
  80140e:	83 c4 1c             	add    $0x1c,%esp
  801411:	5b                   	pop    %ebx
  801412:	5e                   	pop    %esi
  801413:	5f                   	pop    %edi
  801414:	5d                   	pop    %ebp
  801415:	c3                   	ret    
  801416:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80141d:	8d 76 00             	lea    0x0(%esi),%esi
  801420:	89 fd                	mov    %edi,%ebp
  801422:	85 ff                	test   %edi,%edi
  801424:	75 0b                	jne    801431 <__umoddi3+0x91>
  801426:	b8 01 00 00 00       	mov    $0x1,%eax
  80142b:	31 d2                	xor    %edx,%edx
  80142d:	f7 f7                	div    %edi
  80142f:	89 c5                	mov    %eax,%ebp
  801431:	89 d8                	mov    %ebx,%eax
  801433:	31 d2                	xor    %edx,%edx
  801435:	f7 f5                	div    %ebp
  801437:	89 f0                	mov    %esi,%eax
  801439:	f7 f5                	div    %ebp
  80143b:	89 d0                	mov    %edx,%eax
  80143d:	31 d2                	xor    %edx,%edx
  80143f:	eb 8c                	jmp    8013cd <__umoddi3+0x2d>
  801441:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801448:	89 e9                	mov    %ebp,%ecx
  80144a:	ba 20 00 00 00       	mov    $0x20,%edx
  80144f:	29 ea                	sub    %ebp,%edx
  801451:	d3 e0                	shl    %cl,%eax
  801453:	89 44 24 08          	mov    %eax,0x8(%esp)
  801457:	89 d1                	mov    %edx,%ecx
  801459:	89 f8                	mov    %edi,%eax
  80145b:	d3 e8                	shr    %cl,%eax
  80145d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801461:	89 54 24 04          	mov    %edx,0x4(%esp)
  801465:	8b 54 24 04          	mov    0x4(%esp),%edx
  801469:	09 c1                	or     %eax,%ecx
  80146b:	89 d8                	mov    %ebx,%eax
  80146d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801471:	89 e9                	mov    %ebp,%ecx
  801473:	d3 e7                	shl    %cl,%edi
  801475:	89 d1                	mov    %edx,%ecx
  801477:	d3 e8                	shr    %cl,%eax
  801479:	89 e9                	mov    %ebp,%ecx
  80147b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80147f:	d3 e3                	shl    %cl,%ebx
  801481:	89 c7                	mov    %eax,%edi
  801483:	89 d1                	mov    %edx,%ecx
  801485:	89 f0                	mov    %esi,%eax
  801487:	d3 e8                	shr    %cl,%eax
  801489:	89 e9                	mov    %ebp,%ecx
  80148b:	89 fa                	mov    %edi,%edx
  80148d:	d3 e6                	shl    %cl,%esi
  80148f:	09 d8                	or     %ebx,%eax
  801491:	f7 74 24 08          	divl   0x8(%esp)
  801495:	89 d1                	mov    %edx,%ecx
  801497:	89 f3                	mov    %esi,%ebx
  801499:	f7 64 24 0c          	mull   0xc(%esp)
  80149d:	89 c6                	mov    %eax,%esi
  80149f:	89 d7                	mov    %edx,%edi
  8014a1:	39 d1                	cmp    %edx,%ecx
  8014a3:	72 06                	jb     8014ab <__umoddi3+0x10b>
  8014a5:	75 10                	jne    8014b7 <__umoddi3+0x117>
  8014a7:	39 c3                	cmp    %eax,%ebx
  8014a9:	73 0c                	jae    8014b7 <__umoddi3+0x117>
  8014ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8014af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8014b3:	89 d7                	mov    %edx,%edi
  8014b5:	89 c6                	mov    %eax,%esi
  8014b7:	89 ca                	mov    %ecx,%edx
  8014b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014be:	29 f3                	sub    %esi,%ebx
  8014c0:	19 fa                	sbb    %edi,%edx
  8014c2:	89 d0                	mov    %edx,%eax
  8014c4:	d3 e0                	shl    %cl,%eax
  8014c6:	89 e9                	mov    %ebp,%ecx
  8014c8:	d3 eb                	shr    %cl,%ebx
  8014ca:	d3 ea                	shr    %cl,%edx
  8014cc:	09 d8                	or     %ebx,%eax
  8014ce:	83 c4 1c             	add    $0x1c,%esp
  8014d1:	5b                   	pop    %ebx
  8014d2:	5e                   	pop    %esi
  8014d3:	5f                   	pop    %edi
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    
  8014d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014dd:	8d 76 00             	lea    0x0(%esi),%esi
  8014e0:	29 fe                	sub    %edi,%esi
  8014e2:	19 c3                	sbb    %eax,%ebx
  8014e4:	89 f2                	mov    %esi,%edx
  8014e6:	89 d9                	mov    %ebx,%ecx
  8014e8:	e9 1d ff ff ff       	jmp    80140a <__umoddi3+0x6a>
