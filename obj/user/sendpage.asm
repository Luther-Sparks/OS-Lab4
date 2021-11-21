
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 77 01 00 00       	call   8001a8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003d:	e8 51 0f 00 00       	call   800f93 <fork>
  800042:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	0f 84 a5 00 00 00    	je     8000f2 <umain+0xbf>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80004d:	a1 60 40 80 00       	mov    0x804060,%eax
  800052:	8b 40 48             	mov    0x48(%eax),%eax
  800055:	83 ec 04             	sub    $0x4,%esp
  800058:	6a 07                	push   $0x7
  80005a:	68 00 00 a0 00       	push   $0xa00000
  80005f:	50                   	push   %eax
  800060:	e8 8f 0c 00 00       	call   800cf4 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800065:	83 c4 04             	add    $0x4,%esp
  800068:	ff 35 04 20 80 00    	pushl  0x802004
  80006e:	e8 fc 07 00 00       	call   80086f <strlen>
  800073:	83 c4 0c             	add    $0xc,%esp
  800076:	83 c0 01             	add    $0x1,%eax
  800079:	50                   	push   %eax
  80007a:	ff 35 04 20 80 00    	pushl  0x802004
  800080:	68 00 00 a0 00       	push   $0xa00000
  800085:	e8 44 0a 00 00       	call   800ace <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80008a:	6a 07                	push   $0x7
  80008c:	68 00 00 a0 00       	push   $0xa00000
  800091:	6a 00                	push   $0x0
  800093:	ff 75 f4             	pushl  -0xc(%ebp)
  800096:	e8 32 11 00 00       	call   8011cd <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80009b:	83 c4 1c             	add    $0x1c,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	68 00 00 a0 00       	push   $0xa00000
  8000a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a8:	50                   	push   %eax
  8000a9:	e8 b2 10 00 00       	call   801160 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8000ae:	83 c4 0c             	add    $0xc,%esp
  8000b1:	68 00 00 a0 00       	push   $0xa00000
  8000b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8000b9:	68 a0 15 80 00       	push   $0x8015a0
  8000be:	e8 e5 01 00 00       	call   8002a8 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000c3:	83 c4 04             	add    $0x4,%esp
  8000c6:	ff 35 00 20 80 00    	pushl  0x802000
  8000cc:	e8 9e 07 00 00       	call   80086f <strlen>
  8000d1:	83 c4 0c             	add    $0xc,%esp
  8000d4:	50                   	push   %eax
  8000d5:	ff 35 00 20 80 00    	pushl  0x802000
  8000db:	68 00 00 a0 00       	push   $0xa00000
  8000e0:	e8 b6 08 00 00       	call   80099b <strncmp>
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	0f 84 a3 00 00 00    	je     800193 <umain+0x160>
		cprintf("parent received correct message\n");
	return;
}
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  8000f2:	83 ec 04             	sub    $0x4,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	68 00 00 b0 00       	push   $0xb00000
  8000fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ff:	50                   	push   %eax
  800100:	e8 5b 10 00 00       	call   801160 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800105:	83 c4 0c             	add    $0xc,%esp
  800108:	68 00 00 b0 00       	push   $0xb00000
  80010d:	ff 75 f4             	pushl  -0xc(%ebp)
  800110:	68 a0 15 80 00       	push   $0x8015a0
  800115:	e8 8e 01 00 00       	call   8002a8 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  80011a:	83 c4 04             	add    $0x4,%esp
  80011d:	ff 35 04 20 80 00    	pushl  0x802004
  800123:	e8 47 07 00 00       	call   80086f <strlen>
  800128:	83 c4 0c             	add    $0xc,%esp
  80012b:	50                   	push   %eax
  80012c:	ff 35 04 20 80 00    	pushl  0x802004
  800132:	68 00 00 b0 00       	push   $0xb00000
  800137:	e8 5f 08 00 00       	call   80099b <strncmp>
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	85 c0                	test   %eax,%eax
  800141:	74 3e                	je     800181 <umain+0x14e>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  800143:	83 ec 0c             	sub    $0xc,%esp
  800146:	ff 35 00 20 80 00    	pushl  0x802000
  80014c:	e8 1e 07 00 00       	call   80086f <strlen>
  800151:	83 c4 0c             	add    $0xc,%esp
  800154:	83 c0 01             	add    $0x1,%eax
  800157:	50                   	push   %eax
  800158:	ff 35 00 20 80 00    	pushl  0x802000
  80015e:	68 00 00 b0 00       	push   $0xb00000
  800163:	e8 66 09 00 00       	call   800ace <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800168:	6a 07                	push   $0x7
  80016a:	68 00 00 b0 00       	push   $0xb00000
  80016f:	6a 00                	push   $0x0
  800171:	ff 75 f4             	pushl  -0xc(%ebp)
  800174:	e8 54 10 00 00       	call   8011cd <ipc_send>
		return;
  800179:	83 c4 20             	add    $0x20,%esp
  80017c:	e9 6f ff ff ff       	jmp    8000f0 <umain+0xbd>
			cprintf("child received correct message\n");
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	68 b4 15 80 00       	push   $0x8015b4
  800189:	e8 1a 01 00 00       	call   8002a8 <cprintf>
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	eb b0                	jmp    800143 <umain+0x110>
		cprintf("parent received correct message\n");
  800193:	83 ec 0c             	sub    $0xc,%esp
  800196:	68 d4 15 80 00       	push   $0x8015d4
  80019b:	e8 08 01 00 00       	call   8002a8 <cprintf>
  8001a0:	83 c4 10             	add    $0x10,%esp
  8001a3:	e9 48 ff ff ff       	jmp    8000f0 <umain+0xbd>

008001a8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001a8:	f3 0f 1e fb          	endbr32 
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001b4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8001b7:	e8 f2 0a 00 00       	call   800cae <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8001bc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001c1:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  8001c7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001cc:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001d1:	85 db                	test   %ebx,%ebx
  8001d3:	7e 07                	jle    8001dc <libmain+0x34>
		binaryname = argv[0];
  8001d5:	8b 06                	mov    (%esi),%eax
  8001d7:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001dc:	83 ec 08             	sub    $0x8,%esp
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	e8 4d fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001e6:	e8 0a 00 00 00       	call   8001f5 <exit>
}
  8001eb:	83 c4 10             	add    $0x10,%esp
  8001ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001f1:	5b                   	pop    %ebx
  8001f2:	5e                   	pop    %esi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001f5:	f3 0f 1e fb          	endbr32 
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001ff:	6a 00                	push   $0x0
  800201:	e8 63 0a 00 00       	call   800c69 <sys_env_destroy>
}
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80020b:	f3 0f 1e fb          	endbr32 
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	53                   	push   %ebx
  800213:	83 ec 04             	sub    $0x4,%esp
  800216:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800219:	8b 13                	mov    (%ebx),%edx
  80021b:	8d 42 01             	lea    0x1(%edx),%eax
  80021e:	89 03                	mov    %eax,(%ebx)
  800220:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800223:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800227:	3d ff 00 00 00       	cmp    $0xff,%eax
  80022c:	74 09                	je     800237 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80022e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800232:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800235:	c9                   	leave  
  800236:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800237:	83 ec 08             	sub    $0x8,%esp
  80023a:	68 ff 00 00 00       	push   $0xff
  80023f:	8d 43 08             	lea    0x8(%ebx),%eax
  800242:	50                   	push   %eax
  800243:	e8 dc 09 00 00       	call   800c24 <sys_cputs>
		b->idx = 0;
  800248:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80024e:	83 c4 10             	add    $0x10,%esp
  800251:	eb db                	jmp    80022e <putch+0x23>

00800253 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800253:	f3 0f 1e fb          	endbr32 
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800260:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800267:	00 00 00 
	b.cnt = 0;
  80026a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800271:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800274:	ff 75 0c             	pushl  0xc(%ebp)
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800280:	50                   	push   %eax
  800281:	68 0b 02 80 00       	push   $0x80020b
  800286:	e8 20 01 00 00       	call   8003ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80028b:	83 c4 08             	add    $0x8,%esp
  80028e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800294:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80029a:	50                   	push   %eax
  80029b:	e8 84 09 00 00       	call   800c24 <sys_cputs>

	return b.cnt;
}
  8002a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a8:	f3 0f 1e fb          	endbr32 
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002b5:	50                   	push   %eax
  8002b6:	ff 75 08             	pushl  0x8(%ebp)
  8002b9:	e8 95 ff ff ff       	call   800253 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 1c             	sub    $0x1c,%esp
  8002c9:	89 c7                	mov    %eax,%edi
  8002cb:	89 d6                	mov    %edx,%esi
  8002cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d3:	89 d1                	mov    %edx,%ecx
  8002d5:	89 c2                	mov    %eax,%edx
  8002d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002ed:	39 c2                	cmp    %eax,%edx
  8002ef:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002f2:	72 3e                	jb     800332 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	ff 75 18             	pushl  0x18(%ebp)
  8002fa:	83 eb 01             	sub    $0x1,%ebx
  8002fd:	53                   	push   %ebx
  8002fe:	50                   	push   %eax
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	ff 75 e4             	pushl  -0x1c(%ebp)
  800305:	ff 75 e0             	pushl  -0x20(%ebp)
  800308:	ff 75 dc             	pushl  -0x24(%ebp)
  80030b:	ff 75 d8             	pushl  -0x28(%ebp)
  80030e:	e8 2d 10 00 00       	call   801340 <__udivdi3>
  800313:	83 c4 18             	add    $0x18,%esp
  800316:	52                   	push   %edx
  800317:	50                   	push   %eax
  800318:	89 f2                	mov    %esi,%edx
  80031a:	89 f8                	mov    %edi,%eax
  80031c:	e8 9f ff ff ff       	call   8002c0 <printnum>
  800321:	83 c4 20             	add    $0x20,%esp
  800324:	eb 13                	jmp    800339 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800326:	83 ec 08             	sub    $0x8,%esp
  800329:	56                   	push   %esi
  80032a:	ff 75 18             	pushl  0x18(%ebp)
  80032d:	ff d7                	call   *%edi
  80032f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800332:	83 eb 01             	sub    $0x1,%ebx
  800335:	85 db                	test   %ebx,%ebx
  800337:	7f ed                	jg     800326 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	56                   	push   %esi
  80033d:	83 ec 04             	sub    $0x4,%esp
  800340:	ff 75 e4             	pushl  -0x1c(%ebp)
  800343:	ff 75 e0             	pushl  -0x20(%ebp)
  800346:	ff 75 dc             	pushl  -0x24(%ebp)
  800349:	ff 75 d8             	pushl  -0x28(%ebp)
  80034c:	e8 ff 10 00 00       	call   801450 <__umoddi3>
  800351:	83 c4 14             	add    $0x14,%esp
  800354:	0f be 80 4c 16 80 00 	movsbl 0x80164c(%eax),%eax
  80035b:	50                   	push   %eax
  80035c:	ff d7                	call   *%edi
}
  80035e:	83 c4 10             	add    $0x10,%esp
  800361:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800364:	5b                   	pop    %ebx
  800365:	5e                   	pop    %esi
  800366:	5f                   	pop    %edi
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800369:	f3 0f 1e fb          	endbr32 
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800373:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800377:	8b 10                	mov    (%eax),%edx
  800379:	3b 50 04             	cmp    0x4(%eax),%edx
  80037c:	73 0a                	jae    800388 <sprintputch+0x1f>
		*b->buf++ = ch;
  80037e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800381:	89 08                	mov    %ecx,(%eax)
  800383:	8b 45 08             	mov    0x8(%ebp),%eax
  800386:	88 02                	mov    %al,(%edx)
}
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <printfmt>:
{
  80038a:	f3 0f 1e fb          	endbr32 
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800394:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800397:	50                   	push   %eax
  800398:	ff 75 10             	pushl  0x10(%ebp)
  80039b:	ff 75 0c             	pushl  0xc(%ebp)
  80039e:	ff 75 08             	pushl  0x8(%ebp)
  8003a1:	e8 05 00 00 00       	call   8003ab <vprintfmt>
}
  8003a6:	83 c4 10             	add    $0x10,%esp
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <vprintfmt>:
{
  8003ab:	f3 0f 1e fb          	endbr32 
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	57                   	push   %edi
  8003b3:	56                   	push   %esi
  8003b4:	53                   	push   %ebx
  8003b5:	83 ec 3c             	sub    $0x3c,%esp
  8003b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8003bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c1:	e9 8e 03 00 00       	jmp    800754 <vprintfmt+0x3a9>
		padc = ' ';
  8003c6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003ca:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003d8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003df:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8d 47 01             	lea    0x1(%edi),%eax
  8003e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ea:	0f b6 17             	movzbl (%edi),%edx
  8003ed:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f0:	3c 55                	cmp    $0x55,%al
  8003f2:	0f 87 df 03 00 00    	ja     8007d7 <vprintfmt+0x42c>
  8003f8:	0f b6 c0             	movzbl %al,%eax
  8003fb:	3e ff 24 85 20 17 80 	notrack jmp *0x801720(,%eax,4)
  800402:	00 
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800406:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80040a:	eb d8                	jmp    8003e4 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800413:	eb cf                	jmp    8003e4 <vprintfmt+0x39>
  800415:	0f b6 d2             	movzbl %dl,%edx
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80041b:	b8 00 00 00 00       	mov    $0x0,%eax
  800420:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800423:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800426:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80042a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80042d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800430:	83 f9 09             	cmp    $0x9,%ecx
  800433:	77 55                	ja     80048a <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800435:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800438:	eb e9                	jmp    800423 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8b 00                	mov    (%eax),%eax
  80043f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 40 04             	lea    0x4(%eax),%eax
  800448:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80044e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800452:	79 90                	jns    8003e4 <vprintfmt+0x39>
				width = precision, precision = -1;
  800454:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800461:	eb 81                	jmp    8003e4 <vprintfmt+0x39>
  800463:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800466:	85 c0                	test   %eax,%eax
  800468:	ba 00 00 00 00       	mov    $0x0,%edx
  80046d:	0f 49 d0             	cmovns %eax,%edx
  800470:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800476:	e9 69 ff ff ff       	jmp    8003e4 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80047e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800485:	e9 5a ff ff ff       	jmp    8003e4 <vprintfmt+0x39>
  80048a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80048d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800490:	eb bc                	jmp    80044e <vprintfmt+0xa3>
			lflag++;
  800492:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800498:	e9 47 ff ff ff       	jmp    8003e4 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	8d 78 04             	lea    0x4(%eax),%edi
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	53                   	push   %ebx
  8004a7:	ff 30                	pushl  (%eax)
  8004a9:	ff d6                	call   *%esi
			break;
  8004ab:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004ae:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004b1:	e9 9b 02 00 00       	jmp    800751 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8d 78 04             	lea    0x4(%eax),%edi
  8004bc:	8b 00                	mov    (%eax),%eax
  8004be:	99                   	cltd   
  8004bf:	31 d0                	xor    %edx,%eax
  8004c1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c3:	83 f8 08             	cmp    $0x8,%eax
  8004c6:	7f 23                	jg     8004eb <vprintfmt+0x140>
  8004c8:	8b 14 85 80 18 80 00 	mov    0x801880(,%eax,4),%edx
  8004cf:	85 d2                	test   %edx,%edx
  8004d1:	74 18                	je     8004eb <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8004d3:	52                   	push   %edx
  8004d4:	68 6d 16 80 00       	push   $0x80166d
  8004d9:	53                   	push   %ebx
  8004da:	56                   	push   %esi
  8004db:	e8 aa fe ff ff       	call   80038a <printfmt>
  8004e0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e3:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004e6:	e9 66 02 00 00       	jmp    800751 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8004eb:	50                   	push   %eax
  8004ec:	68 64 16 80 00       	push   $0x801664
  8004f1:	53                   	push   %ebx
  8004f2:	56                   	push   %esi
  8004f3:	e8 92 fe ff ff       	call   80038a <printfmt>
  8004f8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004fb:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004fe:	e9 4e 02 00 00       	jmp    800751 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	83 c0 04             	add    $0x4,%eax
  800509:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80050c:	8b 45 14             	mov    0x14(%ebp),%eax
  80050f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800511:	85 d2                	test   %edx,%edx
  800513:	b8 5d 16 80 00       	mov    $0x80165d,%eax
  800518:	0f 45 c2             	cmovne %edx,%eax
  80051b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80051e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800522:	7e 06                	jle    80052a <vprintfmt+0x17f>
  800524:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800528:	75 0d                	jne    800537 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80052d:	89 c7                	mov    %eax,%edi
  80052f:	03 45 e0             	add    -0x20(%ebp),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800535:	eb 55                	jmp    80058c <vprintfmt+0x1e1>
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 d8             	pushl  -0x28(%ebp)
  80053d:	ff 75 cc             	pushl  -0x34(%ebp)
  800540:	e8 46 03 00 00       	call   80088b <strnlen>
  800545:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800548:	29 c2                	sub    %eax,%edx
  80054a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800552:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800556:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800559:	85 ff                	test   %edi,%edi
  80055b:	7e 11                	jle    80056e <vprintfmt+0x1c3>
					putch(padc, putdat);
  80055d:	83 ec 08             	sub    $0x8,%esp
  800560:	53                   	push   %ebx
  800561:	ff 75 e0             	pushl  -0x20(%ebp)
  800564:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800566:	83 ef 01             	sub    $0x1,%edi
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	eb eb                	jmp    800559 <vprintfmt+0x1ae>
  80056e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	b8 00 00 00 00       	mov    $0x0,%eax
  800578:	0f 49 c2             	cmovns %edx,%eax
  80057b:	29 c2                	sub    %eax,%edx
  80057d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800580:	eb a8                	jmp    80052a <vprintfmt+0x17f>
					putch(ch, putdat);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	53                   	push   %ebx
  800586:	52                   	push   %edx
  800587:	ff d6                	call   *%esi
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80058f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800591:	83 c7 01             	add    $0x1,%edi
  800594:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800598:	0f be d0             	movsbl %al,%edx
  80059b:	85 d2                	test   %edx,%edx
  80059d:	74 4b                	je     8005ea <vprintfmt+0x23f>
  80059f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a3:	78 06                	js     8005ab <vprintfmt+0x200>
  8005a5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005a9:	78 1e                	js     8005c9 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ab:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005af:	74 d1                	je     800582 <vprintfmt+0x1d7>
  8005b1:	0f be c0             	movsbl %al,%eax
  8005b4:	83 e8 20             	sub    $0x20,%eax
  8005b7:	83 f8 5e             	cmp    $0x5e,%eax
  8005ba:	76 c6                	jbe    800582 <vprintfmt+0x1d7>
					putch('?', putdat);
  8005bc:	83 ec 08             	sub    $0x8,%esp
  8005bf:	53                   	push   %ebx
  8005c0:	6a 3f                	push   $0x3f
  8005c2:	ff d6                	call   *%esi
  8005c4:	83 c4 10             	add    $0x10,%esp
  8005c7:	eb c3                	jmp    80058c <vprintfmt+0x1e1>
  8005c9:	89 cf                	mov    %ecx,%edi
  8005cb:	eb 0e                	jmp    8005db <vprintfmt+0x230>
				putch(' ', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	6a 20                	push   $0x20
  8005d3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005d5:	83 ef 01             	sub    $0x1,%edi
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	85 ff                	test   %edi,%edi
  8005dd:	7f ee                	jg     8005cd <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8005df:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e5:	e9 67 01 00 00       	jmp    800751 <vprintfmt+0x3a6>
  8005ea:	89 cf                	mov    %ecx,%edi
  8005ec:	eb ed                	jmp    8005db <vprintfmt+0x230>
	if (lflag >= 2)
  8005ee:	83 f9 01             	cmp    $0x1,%ecx
  8005f1:	7f 1b                	jg     80060e <vprintfmt+0x263>
	else if (lflag)
  8005f3:	85 c9                	test   %ecx,%ecx
  8005f5:	74 63                	je     80065a <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ff:	99                   	cltd   
  800600:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 40 04             	lea    0x4(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
  80060c:	eb 17                	jmp    800625 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8b 50 04             	mov    0x4(%eax),%edx
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 40 08             	lea    0x8(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800625:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800628:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80062b:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800630:	85 c9                	test   %ecx,%ecx
  800632:	0f 89 ff 00 00 00    	jns    800737 <vprintfmt+0x38c>
				putch('-', putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 2d                	push   $0x2d
  80063e:	ff d6                	call   *%esi
				num = -(long long) num;
  800640:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800643:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800646:	f7 da                	neg    %edx
  800648:	83 d1 00             	adc    $0x0,%ecx
  80064b:	f7 d9                	neg    %ecx
  80064d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800650:	b8 0a 00 00 00       	mov    $0xa,%eax
  800655:	e9 dd 00 00 00       	jmp    800737 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800662:	99                   	cltd   
  800663:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 40 04             	lea    0x4(%eax),%eax
  80066c:	89 45 14             	mov    %eax,0x14(%ebp)
  80066f:	eb b4                	jmp    800625 <vprintfmt+0x27a>
	if (lflag >= 2)
  800671:	83 f9 01             	cmp    $0x1,%ecx
  800674:	7f 1e                	jg     800694 <vprintfmt+0x2e9>
	else if (lflag)
  800676:	85 c9                	test   %ecx,%ecx
  800678:	74 32                	je     8006ac <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800684:	8d 40 04             	lea    0x4(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80068f:	e9 a3 00 00 00       	jmp    800737 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 10                	mov    (%eax),%edx
  800699:	8b 48 04             	mov    0x4(%eax),%ecx
  80069c:	8d 40 08             	lea    0x8(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8006a7:	e9 8b 00 00 00       	jmp    800737 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 10                	mov    (%eax),%edx
  8006b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006bc:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8006c1:	eb 74                	jmp    800737 <vprintfmt+0x38c>
	if (lflag >= 2)
  8006c3:	83 f9 01             	cmp    $0x1,%ecx
  8006c6:	7f 1b                	jg     8006e3 <vprintfmt+0x338>
	else if (lflag)
  8006c8:	85 c9                	test   %ecx,%ecx
  8006ca:	74 2c                	je     8006f8 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 10                	mov    (%eax),%edx
  8006d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d6:	8d 40 04             	lea    0x4(%eax),%eax
  8006d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006dc:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8006e1:	eb 54                	jmp    800737 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006eb:	8d 40 08             	lea    0x8(%eax),%eax
  8006ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006f1:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8006f6:	eb 3f                	jmp    800737 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8b 10                	mov    (%eax),%edx
  8006fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800702:	8d 40 04             	lea    0x4(%eax),%eax
  800705:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800708:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80070d:	eb 28                	jmp    800737 <vprintfmt+0x38c>
			putch('0', putdat);
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	6a 30                	push   $0x30
  800715:	ff d6                	call   *%esi
			putch('x', putdat);
  800717:	83 c4 08             	add    $0x8,%esp
  80071a:	53                   	push   %ebx
  80071b:	6a 78                	push   $0x78
  80071d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8b 10                	mov    (%eax),%edx
  800724:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800729:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80072c:	8d 40 04             	lea    0x4(%eax),%eax
  80072f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800732:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800737:	83 ec 0c             	sub    $0xc,%esp
  80073a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80073e:	57                   	push   %edi
  80073f:	ff 75 e0             	pushl  -0x20(%ebp)
  800742:	50                   	push   %eax
  800743:	51                   	push   %ecx
  800744:	52                   	push   %edx
  800745:	89 da                	mov    %ebx,%edx
  800747:	89 f0                	mov    %esi,%eax
  800749:	e8 72 fb ff ff       	call   8002c0 <printnum>
			break;
  80074e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800751:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  800754:	83 c7 01             	add    $0x1,%edi
  800757:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80075b:	83 f8 25             	cmp    $0x25,%eax
  80075e:	0f 84 62 fc ff ff    	je     8003c6 <vprintfmt+0x1b>
			if (ch == '\0')										
  800764:	85 c0                	test   %eax,%eax
  800766:	0f 84 8b 00 00 00    	je     8007f7 <vprintfmt+0x44c>
			putch(ch, putdat);
  80076c:	83 ec 08             	sub    $0x8,%esp
  80076f:	53                   	push   %ebx
  800770:	50                   	push   %eax
  800771:	ff d6                	call   *%esi
  800773:	83 c4 10             	add    $0x10,%esp
  800776:	eb dc                	jmp    800754 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800778:	83 f9 01             	cmp    $0x1,%ecx
  80077b:	7f 1b                	jg     800798 <vprintfmt+0x3ed>
	else if (lflag)
  80077d:	85 c9                	test   %ecx,%ecx
  80077f:	74 2c                	je     8007ad <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8b 10                	mov    (%eax),%edx
  800786:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078b:	8d 40 04             	lea    0x4(%eax),%eax
  80078e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800791:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800796:	eb 9f                	jmp    800737 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8b 10                	mov    (%eax),%edx
  80079d:	8b 48 04             	mov    0x4(%eax),%ecx
  8007a0:	8d 40 08             	lea    0x8(%eax),%eax
  8007a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8007ab:	eb 8a                	jmp    800737 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8b 10                	mov    (%eax),%edx
  8007b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b7:	8d 40 04             	lea    0x4(%eax),%eax
  8007ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007bd:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8007c2:	e9 70 ff ff ff       	jmp    800737 <vprintfmt+0x38c>
			putch(ch, putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 25                	push   $0x25
  8007cd:	ff d6                	call   *%esi
			break;
  8007cf:	83 c4 10             	add    $0x10,%esp
  8007d2:	e9 7a ff ff ff       	jmp    800751 <vprintfmt+0x3a6>
			putch('%', putdat);
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	53                   	push   %ebx
  8007db:	6a 25                	push   $0x25
  8007dd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	89 f8                	mov    %edi,%eax
  8007e4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007e8:	74 05                	je     8007ef <vprintfmt+0x444>
  8007ea:	83 e8 01             	sub    $0x1,%eax
  8007ed:	eb f5                	jmp    8007e4 <vprintfmt+0x439>
  8007ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007f2:	e9 5a ff ff ff       	jmp    800751 <vprintfmt+0x3a6>
}
  8007f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5f                   	pop    %edi
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ff:	f3 0f 1e fb          	endbr32 
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	83 ec 18             	sub    $0x18,%esp
  800809:	8b 45 08             	mov    0x8(%ebp),%eax
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800812:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800816:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800819:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800820:	85 c0                	test   %eax,%eax
  800822:	74 26                	je     80084a <vsnprintf+0x4b>
  800824:	85 d2                	test   %edx,%edx
  800826:	7e 22                	jle    80084a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800828:	ff 75 14             	pushl  0x14(%ebp)
  80082b:	ff 75 10             	pushl  0x10(%ebp)
  80082e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800831:	50                   	push   %eax
  800832:	68 69 03 80 00       	push   $0x800369
  800837:	e8 6f fb ff ff       	call   8003ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800845:	83 c4 10             	add    $0x10,%esp
}
  800848:	c9                   	leave  
  800849:	c3                   	ret    
		return -E_INVAL;
  80084a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084f:	eb f7                	jmp    800848 <vsnprintf+0x49>

00800851 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800851:	f3 0f 1e fb          	endbr32 
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80085e:	50                   	push   %eax
  80085f:	ff 75 10             	pushl  0x10(%ebp)
  800862:	ff 75 0c             	pushl  0xc(%ebp)
  800865:	ff 75 08             	pushl  0x8(%ebp)
  800868:	e8 92 ff ff ff       	call   8007ff <vsnprintf>
	va_end(ap);

	return rc;
}
  80086d:	c9                   	leave  
  80086e:	c3                   	ret    

0080086f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80086f:	f3 0f 1e fb          	endbr32 
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
  80087e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800882:	74 05                	je     800889 <strlen+0x1a>
		n++;
  800884:	83 c0 01             	add    $0x1,%eax
  800887:	eb f5                	jmp    80087e <strlen+0xf>
	return n;
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088b:	f3 0f 1e fb          	endbr32 
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800895:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
  80089d:	39 d0                	cmp    %edx,%eax
  80089f:	74 0d                	je     8008ae <strnlen+0x23>
  8008a1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a5:	74 05                	je     8008ac <strnlen+0x21>
		n++;
  8008a7:	83 c0 01             	add    $0x1,%eax
  8008aa:	eb f1                	jmp    80089d <strnlen+0x12>
  8008ac:	89 c2                	mov    %eax,%edx
	return n;
}
  8008ae:	89 d0                	mov    %edx,%eax
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b2:	f3 0f 1e fb          	endbr32 
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	53                   	push   %ebx
  8008ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008c9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	84 d2                	test   %dl,%dl
  8008d1:	75 f2                	jne    8008c5 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8008d3:	89 c8                	mov    %ecx,%eax
  8008d5:	5b                   	pop    %ebx
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d8:	f3 0f 1e fb          	endbr32 
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	53                   	push   %ebx
  8008e0:	83 ec 10             	sub    $0x10,%esp
  8008e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e6:	53                   	push   %ebx
  8008e7:	e8 83 ff ff ff       	call   80086f <strlen>
  8008ec:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ef:	ff 75 0c             	pushl  0xc(%ebp)
  8008f2:	01 d8                	add    %ebx,%eax
  8008f4:	50                   	push   %eax
  8008f5:	e8 b8 ff ff ff       	call   8008b2 <strcpy>
	return dst;
}
  8008fa:	89 d8                	mov    %ebx,%eax
  8008fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800901:	f3 0f 1e fb          	endbr32 
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
  80090a:	8b 75 08             	mov    0x8(%ebp),%esi
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 f3                	mov    %esi,%ebx
  800912:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800915:	89 f0                	mov    %esi,%eax
  800917:	39 d8                	cmp    %ebx,%eax
  800919:	74 11                	je     80092c <strncpy+0x2b>
		*dst++ = *src;
  80091b:	83 c0 01             	add    $0x1,%eax
  80091e:	0f b6 0a             	movzbl (%edx),%ecx
  800921:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800924:	80 f9 01             	cmp    $0x1,%cl
  800927:	83 da ff             	sbb    $0xffffffff,%edx
  80092a:	eb eb                	jmp    800917 <strncpy+0x16>
	}
	return ret;
}
  80092c:	89 f0                	mov    %esi,%eax
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800932:	f3 0f 1e fb          	endbr32 
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	8b 75 08             	mov    0x8(%ebp),%esi
  80093e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800941:	8b 55 10             	mov    0x10(%ebp),%edx
  800944:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800946:	85 d2                	test   %edx,%edx
  800948:	74 21                	je     80096b <strlcpy+0x39>
  80094a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80094e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800950:	39 c2                	cmp    %eax,%edx
  800952:	74 14                	je     800968 <strlcpy+0x36>
  800954:	0f b6 19             	movzbl (%ecx),%ebx
  800957:	84 db                	test   %bl,%bl
  800959:	74 0b                	je     800966 <strlcpy+0x34>
			*dst++ = *src++;
  80095b:	83 c1 01             	add    $0x1,%ecx
  80095e:	83 c2 01             	add    $0x1,%edx
  800961:	88 5a ff             	mov    %bl,-0x1(%edx)
  800964:	eb ea                	jmp    800950 <strlcpy+0x1e>
  800966:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800968:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80096b:	29 f0                	sub    %esi,%eax
}
  80096d:	5b                   	pop    %ebx
  80096e:	5e                   	pop    %esi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800971:	f3 0f 1e fb          	endbr32 
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80097e:	0f b6 01             	movzbl (%ecx),%eax
  800981:	84 c0                	test   %al,%al
  800983:	74 0c                	je     800991 <strcmp+0x20>
  800985:	3a 02                	cmp    (%edx),%al
  800987:	75 08                	jne    800991 <strcmp+0x20>
		p++, q++;
  800989:	83 c1 01             	add    $0x1,%ecx
  80098c:	83 c2 01             	add    $0x1,%edx
  80098f:	eb ed                	jmp    80097e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800991:	0f b6 c0             	movzbl %al,%eax
  800994:	0f b6 12             	movzbl (%edx),%edx
  800997:	29 d0                	sub    %edx,%eax
}
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099b:	f3 0f 1e fb          	endbr32 
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	89 c3                	mov    %eax,%ebx
  8009ab:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009ae:	eb 06                	jmp    8009b6 <strncmp+0x1b>
		n--, p++, q++;
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009b6:	39 d8                	cmp    %ebx,%eax
  8009b8:	74 16                	je     8009d0 <strncmp+0x35>
  8009ba:	0f b6 08             	movzbl (%eax),%ecx
  8009bd:	84 c9                	test   %cl,%cl
  8009bf:	74 04                	je     8009c5 <strncmp+0x2a>
  8009c1:	3a 0a                	cmp    (%edx),%cl
  8009c3:	74 eb                	je     8009b0 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c5:	0f b6 00             	movzbl (%eax),%eax
  8009c8:	0f b6 12             	movzbl (%edx),%edx
  8009cb:	29 d0                	sub    %edx,%eax
}
  8009cd:	5b                   	pop    %ebx
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    
		return 0;
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d5:	eb f6                	jmp    8009cd <strncmp+0x32>

008009d7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d7:	f3 0f 1e fb          	endbr32 
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e5:	0f b6 10             	movzbl (%eax),%edx
  8009e8:	84 d2                	test   %dl,%dl
  8009ea:	74 09                	je     8009f5 <strchr+0x1e>
		if (*s == c)
  8009ec:	38 ca                	cmp    %cl,%dl
  8009ee:	74 0a                	je     8009fa <strchr+0x23>
	for (; *s; s++)
  8009f0:	83 c0 01             	add    $0x1,%eax
  8009f3:	eb f0                	jmp    8009e5 <strchr+0xe>
			return (char *) s;
	return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fc:	f3 0f 1e fb          	endbr32 
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a0d:	38 ca                	cmp    %cl,%dl
  800a0f:	74 09                	je     800a1a <strfind+0x1e>
  800a11:	84 d2                	test   %dl,%dl
  800a13:	74 05                	je     800a1a <strfind+0x1e>
	for (; *s; s++)
  800a15:	83 c0 01             	add    $0x1,%eax
  800a18:	eb f0                	jmp    800a0a <strfind+0xe>
			break;
	return (char *) s;
}
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1c:	f3 0f 1e fb          	endbr32 
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a29:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2c:	85 c9                	test   %ecx,%ecx
  800a2e:	74 31                	je     800a61 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a30:	89 f8                	mov    %edi,%eax
  800a32:	09 c8                	or     %ecx,%eax
  800a34:	a8 03                	test   $0x3,%al
  800a36:	75 23                	jne    800a5b <memset+0x3f>
		c &= 0xFF;
  800a38:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a3c:	89 d3                	mov    %edx,%ebx
  800a3e:	c1 e3 08             	shl    $0x8,%ebx
  800a41:	89 d0                	mov    %edx,%eax
  800a43:	c1 e0 18             	shl    $0x18,%eax
  800a46:	89 d6                	mov    %edx,%esi
  800a48:	c1 e6 10             	shl    $0x10,%esi
  800a4b:	09 f0                	or     %esi,%eax
  800a4d:	09 c2                	or     %eax,%edx
  800a4f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a51:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a54:	89 d0                	mov    %edx,%eax
  800a56:	fc                   	cld    
  800a57:	f3 ab                	rep stos %eax,%es:(%edi)
  800a59:	eb 06                	jmp    800a61 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5e:	fc                   	cld    
  800a5f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a61:	89 f8                	mov    %edi,%eax
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5f                   	pop    %edi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a68:	f3 0f 1e fb          	endbr32 
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a77:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7a:	39 c6                	cmp    %eax,%esi
  800a7c:	73 32                	jae    800ab0 <memmove+0x48>
  800a7e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a81:	39 c2                	cmp    %eax,%edx
  800a83:	76 2b                	jbe    800ab0 <memmove+0x48>
		s += n;
		d += n;
  800a85:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a88:	89 fe                	mov    %edi,%esi
  800a8a:	09 ce                	or     %ecx,%esi
  800a8c:	09 d6                	or     %edx,%esi
  800a8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a94:	75 0e                	jne    800aa4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a96:	83 ef 04             	sub    $0x4,%edi
  800a99:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a9f:	fd                   	std    
  800aa0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa2:	eb 09                	jmp    800aad <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa4:	83 ef 01             	sub    $0x1,%edi
  800aa7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aaa:	fd                   	std    
  800aab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aad:	fc                   	cld    
  800aae:	eb 1a                	jmp    800aca <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab0:	89 c2                	mov    %eax,%edx
  800ab2:	09 ca                	or     %ecx,%edx
  800ab4:	09 f2                	or     %esi,%edx
  800ab6:	f6 c2 03             	test   $0x3,%dl
  800ab9:	75 0a                	jne    800ac5 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800abb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800abe:	89 c7                	mov    %eax,%edi
  800ac0:	fc                   	cld    
  800ac1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac3:	eb 05                	jmp    800aca <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ac5:	89 c7                	mov    %eax,%edi
  800ac7:	fc                   	cld    
  800ac8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ace:	f3 0f 1e fb          	endbr32 
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad8:	ff 75 10             	pushl  0x10(%ebp)
  800adb:	ff 75 0c             	pushl  0xc(%ebp)
  800ade:	ff 75 08             	pushl  0x8(%ebp)
  800ae1:	e8 82 ff ff ff       	call   800a68 <memmove>
}
  800ae6:	c9                   	leave  
  800ae7:	c3                   	ret    

00800ae8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae8:	f3 0f 1e fb          	endbr32 
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af7:	89 c6                	mov    %eax,%esi
  800af9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afc:	39 f0                	cmp    %esi,%eax
  800afe:	74 1c                	je     800b1c <memcmp+0x34>
		if (*s1 != *s2)
  800b00:	0f b6 08             	movzbl (%eax),%ecx
  800b03:	0f b6 1a             	movzbl (%edx),%ebx
  800b06:	38 d9                	cmp    %bl,%cl
  800b08:	75 08                	jne    800b12 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b0a:	83 c0 01             	add    $0x1,%eax
  800b0d:	83 c2 01             	add    $0x1,%edx
  800b10:	eb ea                	jmp    800afc <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b12:	0f b6 c1             	movzbl %cl,%eax
  800b15:	0f b6 db             	movzbl %bl,%ebx
  800b18:	29 d8                	sub    %ebx,%eax
  800b1a:	eb 05                	jmp    800b21 <memcmp+0x39>
	}

	return 0;
  800b1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b25:	f3 0f 1e fb          	endbr32 
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b32:	89 c2                	mov    %eax,%edx
  800b34:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b37:	39 d0                	cmp    %edx,%eax
  800b39:	73 09                	jae    800b44 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3b:	38 08                	cmp    %cl,(%eax)
  800b3d:	74 05                	je     800b44 <memfind+0x1f>
	for (; s < ends; s++)
  800b3f:	83 c0 01             	add    $0x1,%eax
  800b42:	eb f3                	jmp    800b37 <memfind+0x12>
			break;
	return (void *) s;
}
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b46:	f3 0f 1e fb          	endbr32 
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b56:	eb 03                	jmp    800b5b <strtol+0x15>
		s++;
  800b58:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b5b:	0f b6 01             	movzbl (%ecx),%eax
  800b5e:	3c 20                	cmp    $0x20,%al
  800b60:	74 f6                	je     800b58 <strtol+0x12>
  800b62:	3c 09                	cmp    $0x9,%al
  800b64:	74 f2                	je     800b58 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800b66:	3c 2b                	cmp    $0x2b,%al
  800b68:	74 2a                	je     800b94 <strtol+0x4e>
	int neg = 0;
  800b6a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b6f:	3c 2d                	cmp    $0x2d,%al
  800b71:	74 2b                	je     800b9e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b73:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b79:	75 0f                	jne    800b8a <strtol+0x44>
  800b7b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7e:	74 28                	je     800ba8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b80:	85 db                	test   %ebx,%ebx
  800b82:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b87:	0f 44 d8             	cmove  %eax,%ebx
  800b8a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b92:	eb 46                	jmp    800bda <strtol+0x94>
		s++;
  800b94:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b97:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9c:	eb d5                	jmp    800b73 <strtol+0x2d>
		s++, neg = 1;
  800b9e:	83 c1 01             	add    $0x1,%ecx
  800ba1:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba6:	eb cb                	jmp    800b73 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bac:	74 0e                	je     800bbc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bae:	85 db                	test   %ebx,%ebx
  800bb0:	75 d8                	jne    800b8a <strtol+0x44>
		s++, base = 8;
  800bb2:	83 c1 01             	add    $0x1,%ecx
  800bb5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bba:	eb ce                	jmp    800b8a <strtol+0x44>
		s += 2, base = 16;
  800bbc:	83 c1 02             	add    $0x2,%ecx
  800bbf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc4:	eb c4                	jmp    800b8a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bc6:	0f be d2             	movsbl %dl,%edx
  800bc9:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bcc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bcf:	7d 3a                	jge    800c0b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd1:	83 c1 01             	add    $0x1,%ecx
  800bd4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bda:	0f b6 11             	movzbl (%ecx),%edx
  800bdd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be0:	89 f3                	mov    %esi,%ebx
  800be2:	80 fb 09             	cmp    $0x9,%bl
  800be5:	76 df                	jbe    800bc6 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800be7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bea:	89 f3                	mov    %esi,%ebx
  800bec:	80 fb 19             	cmp    $0x19,%bl
  800bef:	77 08                	ja     800bf9 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bf1:	0f be d2             	movsbl %dl,%edx
  800bf4:	83 ea 57             	sub    $0x57,%edx
  800bf7:	eb d3                	jmp    800bcc <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800bf9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bfc:	89 f3                	mov    %esi,%ebx
  800bfe:	80 fb 19             	cmp    $0x19,%bl
  800c01:	77 08                	ja     800c0b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c03:	0f be d2             	movsbl %dl,%edx
  800c06:	83 ea 37             	sub    $0x37,%edx
  800c09:	eb c1                	jmp    800bcc <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0f:	74 05                	je     800c16 <strtol+0xd0>
		*endptr = (char *) s;
  800c11:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c14:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c16:	89 c2                	mov    %eax,%edx
  800c18:	f7 da                	neg    %edx
  800c1a:	85 ff                	test   %edi,%edi
  800c1c:	0f 45 c2             	cmovne %edx,%eax
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c24:	f3 0f 1e fb          	endbr32 
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c39:	89 c3                	mov    %eax,%ebx
  800c3b:	89 c7                	mov    %eax,%edi
  800c3d:	89 c6                	mov    %eax,%esi
  800c3f:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c46:	f3 0f 1e fb          	endbr32 
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c50:	ba 00 00 00 00       	mov    $0x0,%edx
  800c55:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5a:	89 d1                	mov    %edx,%ecx
  800c5c:	89 d3                	mov    %edx,%ebx
  800c5e:	89 d7                	mov    %edx,%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c69:	f3 0f 1e fb          	endbr32 
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c83:	89 cb                	mov    %ecx,%ebx
  800c85:	89 cf                	mov    %ecx,%edi
  800c87:	89 ce                	mov    %ecx,%esi
  800c89:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	7f 08                	jg     800c97 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	50                   	push   %eax
  800c9b:	6a 03                	push   $0x3
  800c9d:	68 a4 18 80 00       	push   $0x8018a4
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 c1 18 80 00       	push   $0x8018c1
  800ca9:	e8 ba 05 00 00       	call   801268 <_panic>

00800cae <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cae:	f3 0f 1e fb          	endbr32 
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbd:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc2:	89 d1                	mov    %edx,%ecx
  800cc4:	89 d3                	mov    %edx,%ebx
  800cc6:	89 d7                	mov    %edx,%edi
  800cc8:	89 d6                	mov    %edx,%esi
  800cca:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_yield>:

void
sys_yield(void)
{
  800cd1:	f3 0f 1e fb          	endbr32 
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce5:	89 d1                	mov    %edx,%ecx
  800ce7:	89 d3                	mov    %edx,%ebx
  800ce9:	89 d7                	mov    %edx,%edi
  800ceb:	89 d6                	mov    %edx,%esi
  800ced:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf4:	f3 0f 1e fb          	endbr32 
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d01:	be 00 00 00 00       	mov    $0x0,%esi
  800d06:	8b 55 08             	mov    0x8(%ebp),%edx
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d14:	89 f7                	mov    %esi,%edi
  800d16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7f 08                	jg     800d24 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 04                	push   $0x4
  800d2a:	68 a4 18 80 00       	push   $0x8018a4
  800d2f:	6a 23                	push   $0x23
  800d31:	68 c1 18 80 00       	push   $0x8018c1
  800d36:	e8 2d 05 00 00       	call   801268 <_panic>

00800d3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d3b:	f3 0f 1e fb          	endbr32 
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d56:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d59:	8b 75 18             	mov    0x18(%ebp),%esi
  800d5c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7f 08                	jg     800d6a <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	50                   	push   %eax
  800d6e:	6a 05                	push   $0x5
  800d70:	68 a4 18 80 00       	push   $0x8018a4
  800d75:	6a 23                	push   $0x23
  800d77:	68 c1 18 80 00       	push   $0x8018c1
  800d7c:	e8 e7 04 00 00       	call   801268 <_panic>

00800d81 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d81:	f3 0f 1e fb          	endbr32 
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9e:	89 df                	mov    %ebx,%edi
  800da0:	89 de                	mov    %ebx,%esi
  800da2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da4:	85 c0                	test   %eax,%eax
  800da6:	7f 08                	jg     800db0 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800da8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	83 ec 0c             	sub    $0xc,%esp
  800db3:	50                   	push   %eax
  800db4:	6a 06                	push   $0x6
  800db6:	68 a4 18 80 00       	push   $0x8018a4
  800dbb:	6a 23                	push   $0x23
  800dbd:	68 c1 18 80 00       	push   $0x8018c1
  800dc2:	e8 a1 04 00 00       	call   801268 <_panic>

00800dc7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc7:	f3 0f 1e fb          	endbr32 
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800dd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddf:	b8 08 00 00 00       	mov    $0x8,%eax
  800de4:	89 df                	mov    %ebx,%edi
  800de6:	89 de                	mov    %ebx,%esi
  800de8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dea:	85 c0                	test   %eax,%eax
  800dec:	7f 08                	jg     800df6 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df6:	83 ec 0c             	sub    $0xc,%esp
  800df9:	50                   	push   %eax
  800dfa:	6a 08                	push   $0x8
  800dfc:	68 a4 18 80 00       	push   $0x8018a4
  800e01:	6a 23                	push   $0x23
  800e03:	68 c1 18 80 00       	push   $0x8018c1
  800e08:	e8 5b 04 00 00       	call   801268 <_panic>

00800e0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e0d:	f3 0f 1e fb          	endbr32 
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	57                   	push   %edi
  800e15:	56                   	push   %esi
  800e16:	53                   	push   %ebx
  800e17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800e1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e25:	b8 09 00 00 00       	mov    $0x9,%eax
  800e2a:	89 df                	mov    %ebx,%edi
  800e2c:	89 de                	mov    %ebx,%esi
  800e2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e30:	85 c0                	test   %eax,%eax
  800e32:	7f 08                	jg     800e3c <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5f                   	pop    %edi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3c:	83 ec 0c             	sub    $0xc,%esp
  800e3f:	50                   	push   %eax
  800e40:	6a 09                	push   $0x9
  800e42:	68 a4 18 80 00       	push   $0x8018a4
  800e47:	6a 23                	push   $0x23
  800e49:	68 c1 18 80 00       	push   $0x8018c1
  800e4e:	e8 15 04 00 00       	call   801268 <_panic>

00800e53 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e53:	f3 0f 1e fb          	endbr32 
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	57                   	push   %edi
  800e5b:	56                   	push   %esi
  800e5c:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e68:	be 00 00 00 00       	mov    $0x0,%esi
  800e6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e70:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e73:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e7a:	f3 0f 1e fb          	endbr32 
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800e87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e94:	89 cb                	mov    %ecx,%ebx
  800e96:	89 cf                	mov    %ecx,%edi
  800e98:	89 ce                	mov    %ecx,%esi
  800e9a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	7f 08                	jg     800ea8 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	50                   	push   %eax
  800eac:	6a 0c                	push   $0xc
  800eae:	68 a4 18 80 00       	push   $0x8018a4
  800eb3:	6a 23                	push   $0x23
  800eb5:	68 c1 18 80 00       	push   $0x8018c1
  800eba:	e8 a9 03 00 00       	call   801268 <_panic>

00800ebf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ebf:	f3 0f 1e fb          	endbr32 
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	53                   	push   %ebx
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ecd:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) { 
  800ecf:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ed3:	74 74                	je     800f49 <pgfault+0x8a>
  800ed5:	89 d8                	mov    %ebx,%eax
  800ed7:	c1 e8 0c             	shr    $0xc,%eax
  800eda:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ee1:	f6 c4 08             	test   $0x8,%ah
  800ee4:	74 63                	je     800f49 <pgfault+0x8a>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800ee6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U|PTE_P)) < 0)		
  800eec:	83 ec 0c             	sub    $0xc,%esp
  800eef:	6a 05                	push   $0x5
  800ef1:	68 00 f0 7f 00       	push   $0x7ff000
  800ef6:	6a 00                	push   $0x0
  800ef8:	53                   	push   %ebx
  800ef9:	6a 00                	push   $0x0
  800efb:	e8 3b fe ff ff       	call   800d3b <sys_page_map>
  800f00:	83 c4 20             	add    $0x20,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	78 56                	js     800f5d <pgfault+0x9e>
		panic("sys_page_map: %e", r);
	if ((r = sys_page_alloc(0, addr, PTE_P|PTE_U|PTE_W)) < 0)	
  800f07:	83 ec 04             	sub    $0x4,%esp
  800f0a:	6a 07                	push   $0x7
  800f0c:	53                   	push   %ebx
  800f0d:	6a 00                	push   $0x0
  800f0f:	e8 e0 fd ff ff       	call   800cf4 <sys_page_alloc>
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	78 54                	js     800f6f <pgfault+0xb0>
		panic("sys_page_alloc: %e", r);
	memmove(addr, PFTEMP, PGSIZE);							
  800f1b:	83 ec 04             	sub    $0x4,%esp
  800f1e:	68 00 10 00 00       	push   $0x1000
  800f23:	68 00 f0 7f 00       	push   $0x7ff000
  800f28:	53                   	push   %ebx
  800f29:	e8 3a fb ff ff       	call   800a68 <memmove>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)				
  800f2e:	83 c4 08             	add    $0x8,%esp
  800f31:	68 00 f0 7f 00       	push   $0x7ff000
  800f36:	6a 00                	push   $0x0
  800f38:	e8 44 fe ff ff       	call   800d81 <sys_page_unmap>
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	78 3d                	js     800f81 <pgfault+0xc2>
		panic("sys_page_unmap: %e", r);
}
  800f44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f47:	c9                   	leave  
  800f48:	c3                   	ret    
		panic("pgfault():not cow");
  800f49:	83 ec 04             	sub    $0x4,%esp
  800f4c:	68 cf 18 80 00       	push   $0x8018cf
  800f51:	6a 1d                	push   $0x1d
  800f53:	68 e1 18 80 00       	push   $0x8018e1
  800f58:	e8 0b 03 00 00       	call   801268 <_panic>
		panic("sys_page_map: %e", r);
  800f5d:	50                   	push   %eax
  800f5e:	68 ec 18 80 00       	push   $0x8018ec
  800f63:	6a 2a                	push   $0x2a
  800f65:	68 e1 18 80 00       	push   $0x8018e1
  800f6a:	e8 f9 02 00 00       	call   801268 <_panic>
		panic("sys_page_alloc: %e", r);
  800f6f:	50                   	push   %eax
  800f70:	68 fd 18 80 00       	push   $0x8018fd
  800f75:	6a 2c                	push   $0x2c
  800f77:	68 e1 18 80 00       	push   $0x8018e1
  800f7c:	e8 e7 02 00 00       	call   801268 <_panic>
		panic("sys_page_unmap: %e", r);
  800f81:	50                   	push   %eax
  800f82:	68 10 19 80 00       	push   $0x801910
  800f87:	6a 2f                	push   $0x2f
  800f89:	68 e1 18 80 00       	push   $0x8018e1
  800f8e:	e8 d5 02 00 00       	call   801268 <_panic>

00800f93 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f93:	f3 0f 1e fb          	endbr32 
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	57                   	push   %edi
  800f9b:	56                   	push   %esi
  800f9c:	53                   	push   %ebx
  800f9d:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall(void);
	set_pgfault_handler(pgfault);	
  800fa0:	68 bf 0e 80 00       	push   $0x800ebf
  800fa5:	e8 08 03 00 00       	call   8012b2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800faa:	b8 07 00 00 00       	mov    $0x7,%eax
  800faf:	cd 30                	int    $0x30
  800fb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();	
	if (envid == 0) {				
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	74 12                	je     800fcd <fork+0x3a>
  800fbb:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0) {
  800fbd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fc1:	78 29                	js     800fec <fork+0x59>
		panic("sys_exofork: %e", envid);
	}

	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800fc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc8:	e9 80 00 00 00       	jmp    80104d <fork+0xba>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fcd:	e8 dc fc ff ff       	call   800cae <sys_getenvid>
  800fd2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fd7:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800fdd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fe2:	a3 60 40 80 00       	mov    %eax,0x804060
		return 0;
  800fe7:	e9 27 01 00 00       	jmp    801113 <fork+0x180>
		panic("sys_exofork: %e", envid);
  800fec:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fef:	68 23 19 80 00       	push   $0x801923
  800ff4:	6a 6b                	push   $0x6b
  800ff6:	68 e1 18 80 00       	push   $0x8018e1
  800ffb:	e8 68 02 00 00       	call   801268 <_panic>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	68 05 08 00 00       	push   $0x805
  801008:	56                   	push   %esi
  801009:	57                   	push   %edi
  80100a:	56                   	push   %esi
  80100b:	6a 00                	push   $0x0
  80100d:	e8 29 fd ff ff       	call   800d3b <sys_page_map>
  801012:	83 c4 20             	add    $0x20,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	0f 88 96 00 00 00    	js     8010b3 <fork+0x120>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  80101d:	83 ec 0c             	sub    $0xc,%esp
  801020:	68 05 08 00 00       	push   $0x805
  801025:	56                   	push   %esi
  801026:	6a 00                	push   $0x0
  801028:	56                   	push   %esi
  801029:	6a 00                	push   $0x0
  80102b:	e8 0b fd ff ff       	call   800d3b <sys_page_map>
  801030:	83 c4 20             	add    $0x20,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	0f 88 8a 00 00 00    	js     8010c5 <fork+0x132>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  80103b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801041:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801047:	0f 84 8a 00 00 00    	je     8010d7 <fork+0x144>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) 
  80104d:	89 d8                	mov    %ebx,%eax
  80104f:	c1 e8 16             	shr    $0x16,%eax
  801052:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801059:	a8 01                	test   $0x1,%al
  80105b:	74 de                	je     80103b <fork+0xa8>
  80105d:	89 d8                	mov    %ebx,%eax
  80105f:	c1 e8 0c             	shr    $0xc,%eax
  801062:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801069:	f6 c2 01             	test   $0x1,%dl
  80106c:	74 cd                	je     80103b <fork+0xa8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  80106e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801075:	f6 c2 04             	test   $0x4,%dl
  801078:	74 c1                	je     80103b <fork+0xa8>
	void *addr = (void*) (pn * PGSIZE);
  80107a:	89 c6                	mov    %eax,%esi
  80107c:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) { 
  80107f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801086:	f6 c2 02             	test   $0x2,%dl
  801089:	0f 85 71 ff ff ff    	jne    801000 <fork+0x6d>
  80108f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801096:	f6 c4 08             	test   $0x8,%ah
  801099:	0f 85 61 ff ff ff    	jne    801000 <fork+0x6d>
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);	
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	6a 05                	push   $0x5
  8010a4:	56                   	push   %esi
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 8d fc ff ff       	call   800d3b <sys_page_map>
  8010ae:	83 c4 20             	add    $0x20,%esp
  8010b1:	eb 88                	jmp    80103b <fork+0xa8>
			panic("sys_page_map：%e", r);
  8010b3:	50                   	push   %eax
  8010b4:	68 33 19 80 00       	push   $0x801933
  8010b9:	6a 46                	push   $0x46
  8010bb:	68 e1 18 80 00       	push   $0x8018e1
  8010c0:	e8 a3 01 00 00       	call   801268 <_panic>
			panic("sys_page_map：%e", r);
  8010c5:	50                   	push   %eax
  8010c6:	68 33 19 80 00       	push   $0x801933
  8010cb:	6a 48                	push   $0x48
  8010cd:	68 e1 18 80 00       	push   $0x8018e1
  8010d2:	e8 91 01 00 00       	call   801268 <_panic>
			duppage(envid, PGNUM(addr));	
		}
	}
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  8010d7:	83 ec 04             	sub    $0x4,%esp
  8010da:	6a 07                	push   $0x7
  8010dc:	68 00 f0 bf ee       	push   $0xeebff000
  8010e1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010e4:	e8 0b fc ff ff       	call   800cf4 <sys_page_alloc>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	78 2e                	js     80111e <fork+0x18b>
		panic("sys_page_alloc: %e", r);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  8010f0:	83 ec 08             	sub    $0x8,%esp
  8010f3:	68 0f 13 80 00       	push   $0x80130f
  8010f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010fb:	57                   	push   %edi
  8010fc:	e8 0c fd ff ff       	call   800e0d <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	
  801101:	83 c4 08             	add    $0x8,%esp
  801104:	6a 02                	push   $0x2
  801106:	57                   	push   %edi
  801107:	e8 bb fc ff ff       	call   800dc7 <sys_env_set_status>
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	78 1d                	js     801130 <fork+0x19d>
		panic("sys_env_set_status: %e", r);
	return envid;
}
  801113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80111e:	50                   	push   %eax
  80111f:	68 fd 18 80 00       	push   $0x8018fd
  801124:	6a 77                	push   $0x77
  801126:	68 e1 18 80 00       	push   $0x8018e1
  80112b:	e8 38 01 00 00       	call   801268 <_panic>
		panic("sys_env_set_status: %e", r);
  801130:	50                   	push   %eax
  801131:	68 45 19 80 00       	push   $0x801945
  801136:	6a 7b                	push   $0x7b
  801138:	68 e1 18 80 00       	push   $0x8018e1
  80113d:	e8 26 01 00 00       	call   801268 <_panic>

00801142 <sfork>:

// Challenge!
int
sfork(void)
{
  801142:	f3 0f 1e fb          	endbr32 
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80114c:	68 5c 19 80 00       	push   $0x80195c
  801151:	68 83 00 00 00       	push   $0x83
  801156:	68 e1 18 80 00       	push   $0x8018e1
  80115b:	e8 08 01 00 00       	call   801268 <_panic>

00801160 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801160:	f3 0f 1e fb          	endbr32 
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	56                   	push   %esi
  801168:	53                   	push   %ebx
  801169:	8b 75 08             	mov    0x8(%ebp),%esi
  80116c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *)-1;
  801172:	85 c0                	test   %eax,%eax
  801174:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801179:	0f 44 c2             	cmove  %edx,%eax
	}
	int r = sys_ipc_recv(pg);
  80117c:	83 ec 0c             	sub    $0xc,%esp
  80117f:	50                   	push   %eax
  801180:	e8 f5 fc ff ff       	call   800e7a <sys_ipc_recv>
	if (r < 0) {				
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 2b                	js     8011b7 <ipc_recv+0x57>
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return r;
	}
	if (from_env_store)
  80118c:	85 f6                	test   %esi,%esi
  80118e:	74 0a                	je     80119a <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  801190:	a1 60 40 80 00       	mov    0x804060,%eax
  801195:	8b 40 74             	mov    0x74(%eax),%eax
  801198:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  80119a:	85 db                	test   %ebx,%ebx
  80119c:	74 0a                	je     8011a8 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  80119e:	a1 60 40 80 00       	mov    0x804060,%eax
  8011a3:	8b 40 78             	mov    0x78(%eax),%eax
  8011a6:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8011a8:	a1 60 40 80 00       	mov    0x804060,%eax
  8011ad:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011b3:	5b                   	pop    %ebx
  8011b4:	5e                   	pop    %esi
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8011b7:	85 f6                	test   %esi,%esi
  8011b9:	74 06                	je     8011c1 <ipc_recv+0x61>
  8011bb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8011c1:	85 db                	test   %ebx,%ebx
  8011c3:	74 eb                	je     8011b0 <ipc_recv+0x50>
  8011c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011cb:	eb e3                	jmp    8011b0 <ipc_recv+0x50>

008011cd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011cd:	f3 0f 1e fb          	endbr32 
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	57                   	push   %edi
  8011d5:	56                   	push   %esi
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 0c             	sub    $0xc,%esp
  8011da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *)-1;
  8011e3:	85 db                	test   %ebx,%ebx
  8011e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011ea:	0f 44 d8             	cmove  %eax,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8011ed:	ff 75 14             	pushl  0x14(%ebp)
  8011f0:	53                   	push   %ebx
  8011f1:	56                   	push   %esi
  8011f2:	57                   	push   %edi
  8011f3:	e8 5b fc ff ff       	call   800e53 <sys_ipc_try_send>
		if (r == 0) {		
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	74 1e                	je     80121d <ipc_send+0x50>
			return;
		} else if (r == -E_IPC_NOT_RECV) {
  8011ff:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801202:	75 07                	jne    80120b <ipc_send+0x3e>
			sys_yield();
  801204:	e8 c8 fa ff ff       	call   800cd1 <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801209:	eb e2                	jmp    8011ed <ipc_send+0x20>
		} else {			
			panic("ipc_send():%e", r);
  80120b:	50                   	push   %eax
  80120c:	68 72 19 80 00       	push   $0x801972
  801211:	6a 41                	push   $0x41
  801213:	68 80 19 80 00       	push   $0x801980
  801218:	e8 4b 00 00 00       	call   801268 <_panic>
		}
	}
}
  80121d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801220:	5b                   	pop    %ebx
  801221:	5e                   	pop    %esi
  801222:	5f                   	pop    %edi
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801225:	f3 0f 1e fb          	endbr32 
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80122f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801234:	69 d0 84 00 00 00    	imul   $0x84,%eax,%edx
  80123a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801240:	8b 52 50             	mov    0x50(%edx),%edx
  801243:	39 ca                	cmp    %ecx,%edx
  801245:	74 11                	je     801258 <ipc_find_env+0x33>
	for (i = 0; i < NENV; i++)
  801247:	83 c0 01             	add    $0x1,%eax
  80124a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80124f:	75 e3                	jne    801234 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801251:	b8 00 00 00 00       	mov    $0x0,%eax
  801256:	eb 0e                	jmp    801266 <ipc_find_env+0x41>
			return envs[i].env_id;
  801258:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  80125e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801263:	8b 40 48             	mov    0x48(%eax),%eax
}
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801268:	f3 0f 1e fb          	endbr32 
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	56                   	push   %esi
  801270:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801271:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801274:	8b 35 08 20 80 00    	mov    0x802008,%esi
  80127a:	e8 2f fa ff ff       	call   800cae <sys_getenvid>
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	ff 75 0c             	pushl  0xc(%ebp)
  801285:	ff 75 08             	pushl  0x8(%ebp)
  801288:	56                   	push   %esi
  801289:	50                   	push   %eax
  80128a:	68 8c 19 80 00       	push   $0x80198c
  80128f:	e8 14 f0 ff ff       	call   8002a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801294:	83 c4 18             	add    $0x18,%esp
  801297:	53                   	push   %ebx
  801298:	ff 75 10             	pushl  0x10(%ebp)
  80129b:	e8 b3 ef ff ff       	call   800253 <vcprintf>
	cprintf("\n");
  8012a0:	c7 04 24 b2 15 80 00 	movl   $0x8015b2,(%esp)
  8012a7:	e8 fc ef ff ff       	call   8002a8 <cprintf>
  8012ac:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012af:	cc                   	int3   
  8012b0:	eb fd                	jmp    8012af <_panic+0x47>

008012b2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012b2:	f3 0f 1e fb          	endbr32 
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012bc:	83 3d 64 40 80 00 00 	cmpl   $0x0,0x804064
  8012c3:	74 0a                	je     8012cf <set_pgfault_handler+0x1d>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c8:	a3 64 40 80 00       	mov    %eax,0x804064
}
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    
		int r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);	//为当前进程分配异常栈
  8012cf:	83 ec 04             	sub    $0x4,%esp
  8012d2:	6a 07                	push   $0x7
  8012d4:	68 00 f0 bf ee       	push   $0xeebff000
  8012d9:	6a 00                	push   $0x0
  8012db:	e8 14 fa ff ff       	call   800cf4 <sys_page_alloc>
		if (r < 0) {
  8012e0:	83 c4 10             	add    $0x10,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 14                	js     8012fb <set_pgfault_handler+0x49>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	68 0f 13 80 00       	push   $0x80130f
  8012ef:	6a 00                	push   $0x0
  8012f1:	e8 17 fb ff ff       	call   800e0d <sys_env_set_pgfault_upcall>
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	eb ca                	jmp    8012c5 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  8012fb:	83 ec 04             	sub    $0x4,%esp
  8012fe:	68 b0 19 80 00       	push   $0x8019b0
  801303:	6a 22                	push   $0x22
  801305:	68 da 19 80 00       	push   $0x8019da
  80130a:	e8 59 ff ff ff       	call   801268 <_panic>

0080130f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80130f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801310:	a1 64 40 80 00       	mov    0x804064,%eax
	call *%eax				
  801315:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801317:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp			
  80131a:	83 c4 08             	add    $0x8,%esp
	movl 40(%esp), %eax 	
  80131d:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 32(%esp), %ecx 	
  801321:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl %ecx, -4(%eax) 	
  801325:	89 48 fc             	mov    %ecx,-0x4(%eax)
	popal
  801328:	61                   	popa   
	addl $4, %esp		
  801329:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popfl
  80132c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80132d:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp	
  80132e:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  801332:	c3                   	ret    
  801333:	66 90                	xchg   %ax,%ax
  801335:	66 90                	xchg   %ax,%ax
  801337:	66 90                	xchg   %ax,%ax
  801339:	66 90                	xchg   %ax,%ax
  80133b:	66 90                	xchg   %ax,%ax
  80133d:	66 90                	xchg   %ax,%ax
  80133f:	90                   	nop

00801340 <__udivdi3>:
  801340:	f3 0f 1e fb          	endbr32 
  801344:	55                   	push   %ebp
  801345:	57                   	push   %edi
  801346:	56                   	push   %esi
  801347:	53                   	push   %ebx
  801348:	83 ec 1c             	sub    $0x1c,%esp
  80134b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80134f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801353:	8b 74 24 34          	mov    0x34(%esp),%esi
  801357:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80135b:	85 d2                	test   %edx,%edx
  80135d:	75 19                	jne    801378 <__udivdi3+0x38>
  80135f:	39 f3                	cmp    %esi,%ebx
  801361:	76 4d                	jbe    8013b0 <__udivdi3+0x70>
  801363:	31 ff                	xor    %edi,%edi
  801365:	89 e8                	mov    %ebp,%eax
  801367:	89 f2                	mov    %esi,%edx
  801369:	f7 f3                	div    %ebx
  80136b:	89 fa                	mov    %edi,%edx
  80136d:	83 c4 1c             	add    $0x1c,%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5f                   	pop    %edi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    
  801375:	8d 76 00             	lea    0x0(%esi),%esi
  801378:	39 f2                	cmp    %esi,%edx
  80137a:	76 14                	jbe    801390 <__udivdi3+0x50>
  80137c:	31 ff                	xor    %edi,%edi
  80137e:	31 c0                	xor    %eax,%eax
  801380:	89 fa                	mov    %edi,%edx
  801382:	83 c4 1c             	add    $0x1c,%esp
  801385:	5b                   	pop    %ebx
  801386:	5e                   	pop    %esi
  801387:	5f                   	pop    %edi
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    
  80138a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801390:	0f bd fa             	bsr    %edx,%edi
  801393:	83 f7 1f             	xor    $0x1f,%edi
  801396:	75 48                	jne    8013e0 <__udivdi3+0xa0>
  801398:	39 f2                	cmp    %esi,%edx
  80139a:	72 06                	jb     8013a2 <__udivdi3+0x62>
  80139c:	31 c0                	xor    %eax,%eax
  80139e:	39 eb                	cmp    %ebp,%ebx
  8013a0:	77 de                	ja     801380 <__udivdi3+0x40>
  8013a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8013a7:	eb d7                	jmp    801380 <__udivdi3+0x40>
  8013a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	89 d9                	mov    %ebx,%ecx
  8013b2:	85 db                	test   %ebx,%ebx
  8013b4:	75 0b                	jne    8013c1 <__udivdi3+0x81>
  8013b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013bb:	31 d2                	xor    %edx,%edx
  8013bd:	f7 f3                	div    %ebx
  8013bf:	89 c1                	mov    %eax,%ecx
  8013c1:	31 d2                	xor    %edx,%edx
  8013c3:	89 f0                	mov    %esi,%eax
  8013c5:	f7 f1                	div    %ecx
  8013c7:	89 c6                	mov    %eax,%esi
  8013c9:	89 e8                	mov    %ebp,%eax
  8013cb:	89 f7                	mov    %esi,%edi
  8013cd:	f7 f1                	div    %ecx
  8013cf:	89 fa                	mov    %edi,%edx
  8013d1:	83 c4 1c             	add    $0x1c,%esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5e                   	pop    %esi
  8013d6:	5f                   	pop    %edi
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    
  8013d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013e0:	89 f9                	mov    %edi,%ecx
  8013e2:	b8 20 00 00 00       	mov    $0x20,%eax
  8013e7:	29 f8                	sub    %edi,%eax
  8013e9:	d3 e2                	shl    %cl,%edx
  8013eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013ef:	89 c1                	mov    %eax,%ecx
  8013f1:	89 da                	mov    %ebx,%edx
  8013f3:	d3 ea                	shr    %cl,%edx
  8013f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8013f9:	09 d1                	or     %edx,%ecx
  8013fb:	89 f2                	mov    %esi,%edx
  8013fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801401:	89 f9                	mov    %edi,%ecx
  801403:	d3 e3                	shl    %cl,%ebx
  801405:	89 c1                	mov    %eax,%ecx
  801407:	d3 ea                	shr    %cl,%edx
  801409:	89 f9                	mov    %edi,%ecx
  80140b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80140f:	89 eb                	mov    %ebp,%ebx
  801411:	d3 e6                	shl    %cl,%esi
  801413:	89 c1                	mov    %eax,%ecx
  801415:	d3 eb                	shr    %cl,%ebx
  801417:	09 de                	or     %ebx,%esi
  801419:	89 f0                	mov    %esi,%eax
  80141b:	f7 74 24 08          	divl   0x8(%esp)
  80141f:	89 d6                	mov    %edx,%esi
  801421:	89 c3                	mov    %eax,%ebx
  801423:	f7 64 24 0c          	mull   0xc(%esp)
  801427:	39 d6                	cmp    %edx,%esi
  801429:	72 15                	jb     801440 <__udivdi3+0x100>
  80142b:	89 f9                	mov    %edi,%ecx
  80142d:	d3 e5                	shl    %cl,%ebp
  80142f:	39 c5                	cmp    %eax,%ebp
  801431:	73 04                	jae    801437 <__udivdi3+0xf7>
  801433:	39 d6                	cmp    %edx,%esi
  801435:	74 09                	je     801440 <__udivdi3+0x100>
  801437:	89 d8                	mov    %ebx,%eax
  801439:	31 ff                	xor    %edi,%edi
  80143b:	e9 40 ff ff ff       	jmp    801380 <__udivdi3+0x40>
  801440:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801443:	31 ff                	xor    %edi,%edi
  801445:	e9 36 ff ff ff       	jmp    801380 <__udivdi3+0x40>
  80144a:	66 90                	xchg   %ax,%ax
  80144c:	66 90                	xchg   %ax,%ax
  80144e:	66 90                	xchg   %ax,%ax

00801450 <__umoddi3>:
  801450:	f3 0f 1e fb          	endbr32 
  801454:	55                   	push   %ebp
  801455:	57                   	push   %edi
  801456:	56                   	push   %esi
  801457:	53                   	push   %ebx
  801458:	83 ec 1c             	sub    $0x1c,%esp
  80145b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80145f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801463:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801467:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80146b:	85 c0                	test   %eax,%eax
  80146d:	75 19                	jne    801488 <__umoddi3+0x38>
  80146f:	39 df                	cmp    %ebx,%edi
  801471:	76 5d                	jbe    8014d0 <__umoddi3+0x80>
  801473:	89 f0                	mov    %esi,%eax
  801475:	89 da                	mov    %ebx,%edx
  801477:	f7 f7                	div    %edi
  801479:	89 d0                	mov    %edx,%eax
  80147b:	31 d2                	xor    %edx,%edx
  80147d:	83 c4 1c             	add    $0x1c,%esp
  801480:	5b                   	pop    %ebx
  801481:	5e                   	pop    %esi
  801482:	5f                   	pop    %edi
  801483:	5d                   	pop    %ebp
  801484:	c3                   	ret    
  801485:	8d 76 00             	lea    0x0(%esi),%esi
  801488:	89 f2                	mov    %esi,%edx
  80148a:	39 d8                	cmp    %ebx,%eax
  80148c:	76 12                	jbe    8014a0 <__umoddi3+0x50>
  80148e:	89 f0                	mov    %esi,%eax
  801490:	89 da                	mov    %ebx,%edx
  801492:	83 c4 1c             	add    $0x1c,%esp
  801495:	5b                   	pop    %ebx
  801496:	5e                   	pop    %esi
  801497:	5f                   	pop    %edi
  801498:	5d                   	pop    %ebp
  801499:	c3                   	ret    
  80149a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014a0:	0f bd e8             	bsr    %eax,%ebp
  8014a3:	83 f5 1f             	xor    $0x1f,%ebp
  8014a6:	75 50                	jne    8014f8 <__umoddi3+0xa8>
  8014a8:	39 d8                	cmp    %ebx,%eax
  8014aa:	0f 82 e0 00 00 00    	jb     801590 <__umoddi3+0x140>
  8014b0:	89 d9                	mov    %ebx,%ecx
  8014b2:	39 f7                	cmp    %esi,%edi
  8014b4:	0f 86 d6 00 00 00    	jbe    801590 <__umoddi3+0x140>
  8014ba:	89 d0                	mov    %edx,%eax
  8014bc:	89 ca                	mov    %ecx,%edx
  8014be:	83 c4 1c             	add    $0x1c,%esp
  8014c1:	5b                   	pop    %ebx
  8014c2:	5e                   	pop    %esi
  8014c3:	5f                   	pop    %edi
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    
  8014c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014cd:	8d 76 00             	lea    0x0(%esi),%esi
  8014d0:	89 fd                	mov    %edi,%ebp
  8014d2:	85 ff                	test   %edi,%edi
  8014d4:	75 0b                	jne    8014e1 <__umoddi3+0x91>
  8014d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014db:	31 d2                	xor    %edx,%edx
  8014dd:	f7 f7                	div    %edi
  8014df:	89 c5                	mov    %eax,%ebp
  8014e1:	89 d8                	mov    %ebx,%eax
  8014e3:	31 d2                	xor    %edx,%edx
  8014e5:	f7 f5                	div    %ebp
  8014e7:	89 f0                	mov    %esi,%eax
  8014e9:	f7 f5                	div    %ebp
  8014eb:	89 d0                	mov    %edx,%eax
  8014ed:	31 d2                	xor    %edx,%edx
  8014ef:	eb 8c                	jmp    80147d <__umoddi3+0x2d>
  8014f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014f8:	89 e9                	mov    %ebp,%ecx
  8014fa:	ba 20 00 00 00       	mov    $0x20,%edx
  8014ff:	29 ea                	sub    %ebp,%edx
  801501:	d3 e0                	shl    %cl,%eax
  801503:	89 44 24 08          	mov    %eax,0x8(%esp)
  801507:	89 d1                	mov    %edx,%ecx
  801509:	89 f8                	mov    %edi,%eax
  80150b:	d3 e8                	shr    %cl,%eax
  80150d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801511:	89 54 24 04          	mov    %edx,0x4(%esp)
  801515:	8b 54 24 04          	mov    0x4(%esp),%edx
  801519:	09 c1                	or     %eax,%ecx
  80151b:	89 d8                	mov    %ebx,%eax
  80151d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801521:	89 e9                	mov    %ebp,%ecx
  801523:	d3 e7                	shl    %cl,%edi
  801525:	89 d1                	mov    %edx,%ecx
  801527:	d3 e8                	shr    %cl,%eax
  801529:	89 e9                	mov    %ebp,%ecx
  80152b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80152f:	d3 e3                	shl    %cl,%ebx
  801531:	89 c7                	mov    %eax,%edi
  801533:	89 d1                	mov    %edx,%ecx
  801535:	89 f0                	mov    %esi,%eax
  801537:	d3 e8                	shr    %cl,%eax
  801539:	89 e9                	mov    %ebp,%ecx
  80153b:	89 fa                	mov    %edi,%edx
  80153d:	d3 e6                	shl    %cl,%esi
  80153f:	09 d8                	or     %ebx,%eax
  801541:	f7 74 24 08          	divl   0x8(%esp)
  801545:	89 d1                	mov    %edx,%ecx
  801547:	89 f3                	mov    %esi,%ebx
  801549:	f7 64 24 0c          	mull   0xc(%esp)
  80154d:	89 c6                	mov    %eax,%esi
  80154f:	89 d7                	mov    %edx,%edi
  801551:	39 d1                	cmp    %edx,%ecx
  801553:	72 06                	jb     80155b <__umoddi3+0x10b>
  801555:	75 10                	jne    801567 <__umoddi3+0x117>
  801557:	39 c3                	cmp    %eax,%ebx
  801559:	73 0c                	jae    801567 <__umoddi3+0x117>
  80155b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80155f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801563:	89 d7                	mov    %edx,%edi
  801565:	89 c6                	mov    %eax,%esi
  801567:	89 ca                	mov    %ecx,%edx
  801569:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80156e:	29 f3                	sub    %esi,%ebx
  801570:	19 fa                	sbb    %edi,%edx
  801572:	89 d0                	mov    %edx,%eax
  801574:	d3 e0                	shl    %cl,%eax
  801576:	89 e9                	mov    %ebp,%ecx
  801578:	d3 eb                	shr    %cl,%ebx
  80157a:	d3 ea                	shr    %cl,%edx
  80157c:	09 d8                	or     %ebx,%eax
  80157e:	83 c4 1c             	add    $0x1c,%esp
  801581:	5b                   	pop    %ebx
  801582:	5e                   	pop    %esi
  801583:	5f                   	pop    %edi
  801584:	5d                   	pop    %ebp
  801585:	c3                   	ret    
  801586:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80158d:	8d 76 00             	lea    0x0(%esi),%esi
  801590:	29 fe                	sub    %edi,%esi
  801592:	19 c3                	sbb    %eax,%ebx
  801594:	89 f2                	mov    %esi,%edx
  801596:	89 d9                	mov    %ebx,%ecx
  801598:	e9 1d ff ff ff       	jmp    8014ba <__umoddi3+0x6a>
