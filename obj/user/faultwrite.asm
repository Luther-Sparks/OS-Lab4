
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	f3 0f 1e fb          	endbr32 
  800046:	55                   	push   %ebp
  800047:	89 e5                	mov    %esp,%ebp
  800049:	56                   	push   %esi
  80004a:	53                   	push   %ebx
  80004b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800051:	e8 d9 00 00 00       	call   80012f <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800056:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005b:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800061:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800066:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006b:	85 db                	test   %ebx,%ebx
  80006d:	7e 07                	jle    800076 <libmain+0x34>
		binaryname = argv[0];
  80006f:	8b 06                	mov    (%esi),%eax
  800071:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800076:	83 ec 08             	sub    $0x8,%esp
  800079:	56                   	push   %esi
  80007a:	53                   	push   %ebx
  80007b:	e8 b3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800080:	e8 0a 00 00 00       	call   80008f <exit>
}
  800085:	83 c4 10             	add    $0x10,%esp
  800088:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008b:	5b                   	pop    %ebx
  80008c:	5e                   	pop    %esi
  80008d:	5d                   	pop    %ebp
  80008e:	c3                   	ret    

0080008f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008f:	f3 0f 1e fb          	endbr32 
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800099:	6a 00                	push   $0x0
  80009b:	e8 4a 00 00 00       	call   8000ea <sys_env_destroy>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	c9                   	leave  
  8000a4:	c3                   	ret    

008000a5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a5:	f3 0f 1e fb          	endbr32 
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	57                   	push   %edi
  8000ad:	56                   	push   %esi
  8000ae:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000af:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	89 c3                	mov    %eax,%ebx
  8000bc:	89 c7                	mov    %eax,%edi
  8000be:	89 c6                	mov    %eax,%esi
  8000c0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5f                   	pop    %edi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    

008000c7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c7:	f3 0f 1e fb          	endbr32 
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	57                   	push   %edi
  8000cf:	56                   	push   %esi
  8000d0:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000db:	89 d1                	mov    %edx,%ecx
  8000dd:	89 d3                	mov    %edx,%ebx
  8000df:	89 d7                	mov    %edx,%edi
  8000e1:	89 d6                	mov    %edx,%esi
  8000e3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e5:	5b                   	pop    %ebx
  8000e6:	5e                   	pop    %esi
  8000e7:	5f                   	pop    %edi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ea:	f3 0f 1e fb          	endbr32 
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	89 cb                	mov    %ecx,%ebx
  800106:	89 cf                	mov    %ecx,%edi
  800108:	89 ce                	mov    %ecx,%esi
  80010a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010c:	85 c0                	test   %eax,%eax
  80010e:	7f 08                	jg     800118 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800118:	83 ec 0c             	sub    $0xc,%esp
  80011b:	50                   	push   %eax
  80011c:	6a 03                	push   $0x3
  80011e:	68 2a 10 80 00       	push   $0x80102a
  800123:	6a 23                	push   $0x23
  800125:	68 47 10 80 00       	push   $0x801047
  80012a:	e8 11 02 00 00       	call   800340 <_panic>

0080012f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012f:	f3 0f 1e fb          	endbr32 
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 02 00 00 00       	mov    $0x2,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <sys_yield>:

void
sys_yield(void)
{
  800152:	f3 0f 1e fb          	endbr32 
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80015c:	ba 00 00 00 00       	mov    $0x0,%edx
  800161:	b8 0a 00 00 00       	mov    $0xa,%eax
  800166:	89 d1                	mov    %edx,%ecx
  800168:	89 d3                	mov    %edx,%ebx
  80016a:	89 d7                	mov    %edx,%edi
  80016c:	89 d6                	mov    %edx,%esi
  80016e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800170:	5b                   	pop    %ebx
  800171:	5e                   	pop    %esi
  800172:	5f                   	pop    %edi
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    

00800175 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800175:	f3 0f 1e fb          	endbr32 
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	8b 55 08             	mov    0x8(%ebp),%edx
  80018a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018d:	b8 04 00 00 00       	mov    $0x4,%eax
  800192:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7f 08                	jg     8001a5 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 2a 10 80 00       	push   $0x80102a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 47 10 80 00       	push   $0x801047
  8001b7:	e8 84 01 00 00       	call   800340 <_panic>

008001bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bc:	f3 0f 1e fb          	endbr32 
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8001c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001da:	8b 75 18             	mov    0x18(%ebp),%esi
  8001dd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001df:	85 c0                	test   %eax,%eax
  8001e1:	7f 08                	jg     8001eb <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	50                   	push   %eax
  8001ef:	6a 05                	push   $0x5
  8001f1:	68 2a 10 80 00       	push   $0x80102a
  8001f6:	6a 23                	push   $0x23
  8001f8:	68 47 10 80 00       	push   $0x801047
  8001fd:	e8 3e 01 00 00       	call   800340 <_panic>

00800202 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800202:	f3 0f 1e fb          	endbr32 
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021a:	b8 06 00 00 00       	mov    $0x6,%eax
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7f 08                	jg     800231 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	50                   	push   %eax
  800235:	6a 06                	push   $0x6
  800237:	68 2a 10 80 00       	push   $0x80102a
  80023c:	6a 23                	push   $0x23
  80023e:	68 47 10 80 00       	push   $0x801047
  800243:	e8 f8 00 00 00       	call   800340 <_panic>

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	f3 0f 1e fb          	endbr32 
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
  800252:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800255:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025a:	8b 55 08             	mov    0x8(%ebp),%edx
  80025d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800260:	b8 08 00 00 00       	mov    $0x8,%eax
  800265:	89 df                	mov    %ebx,%edi
  800267:	89 de                	mov    %ebx,%esi
  800269:	cd 30                	int    $0x30
	if(check && ret > 0)
  80026b:	85 c0                	test   %eax,%eax
  80026d:	7f 08                	jg     800277 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	50                   	push   %eax
  80027b:	6a 08                	push   $0x8
  80027d:	68 2a 10 80 00       	push   $0x80102a
  800282:	6a 23                	push   $0x23
  800284:	68 47 10 80 00       	push   $0x801047
  800289:	e8 b2 00 00 00       	call   800340 <_panic>

0080028e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80028e:	f3 0f 1e fb          	endbr32 
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	57                   	push   %edi
  800296:	56                   	push   %esi
  800297:	53                   	push   %ebx
  800298:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80029b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a6:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ab:	89 df                	mov    %ebx,%edi
  8002ad:	89 de                	mov    %ebx,%esi
  8002af:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002b1:	85 c0                	test   %eax,%eax
  8002b3:	7f 08                	jg     8002bd <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b8:	5b                   	pop    %ebx
  8002b9:	5e                   	pop    %esi
  8002ba:	5f                   	pop    %edi
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	50                   	push   %eax
  8002c1:	6a 09                	push   $0x9
  8002c3:	68 2a 10 80 00       	push   $0x80102a
  8002c8:	6a 23                	push   $0x23
  8002ca:	68 47 10 80 00       	push   $0x801047
  8002cf:	e8 6c 00 00 00       	call   800340 <_panic>

008002d4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002d4:	f3 0f 1e fb          	endbr32 
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
  8002db:	57                   	push   %edi
  8002dc:	56                   	push   %esi
  8002dd:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8002de:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002f4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002f6:	5b                   	pop    %ebx
  8002f7:	5e                   	pop    %esi
  8002f8:	5f                   	pop    %edi
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002fb:	f3 0f 1e fb          	endbr32 
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	57                   	push   %edi
  800303:	56                   	push   %esi
  800304:	53                   	push   %ebx
  800305:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800308:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030d:	8b 55 08             	mov    0x8(%ebp),%edx
  800310:	b8 0c 00 00 00       	mov    $0xc,%eax
  800315:	89 cb                	mov    %ecx,%ebx
  800317:	89 cf                	mov    %ecx,%edi
  800319:	89 ce                	mov    %ecx,%esi
  80031b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80031d:	85 c0                	test   %eax,%eax
  80031f:	7f 08                	jg     800329 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800321:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800324:	5b                   	pop    %ebx
  800325:	5e                   	pop    %esi
  800326:	5f                   	pop    %edi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800329:	83 ec 0c             	sub    $0xc,%esp
  80032c:	50                   	push   %eax
  80032d:	6a 0c                	push   $0xc
  80032f:	68 2a 10 80 00       	push   $0x80102a
  800334:	6a 23                	push   $0x23
  800336:	68 47 10 80 00       	push   $0x801047
  80033b:	e8 00 00 00 00       	call   800340 <_panic>

00800340 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800340:	f3 0f 1e fb          	endbr32 
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800349:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80034c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800352:	e8 d8 fd ff ff       	call   80012f <sys_getenvid>
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	ff 75 0c             	pushl  0xc(%ebp)
  80035d:	ff 75 08             	pushl  0x8(%ebp)
  800360:	56                   	push   %esi
  800361:	50                   	push   %eax
  800362:	68 58 10 80 00       	push   $0x801058
  800367:	e8 bb 00 00 00       	call   800427 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036c:	83 c4 18             	add    $0x18,%esp
  80036f:	53                   	push   %ebx
  800370:	ff 75 10             	pushl  0x10(%ebp)
  800373:	e8 5a 00 00 00       	call   8003d2 <vcprintf>
	cprintf("\n");
  800378:	c7 04 24 7b 10 80 00 	movl   $0x80107b,(%esp)
  80037f:	e8 a3 00 00 00       	call   800427 <cprintf>
  800384:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800387:	cc                   	int3   
  800388:	eb fd                	jmp    800387 <_panic+0x47>

0080038a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80038a:	f3 0f 1e fb          	endbr32 
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	53                   	push   %ebx
  800392:	83 ec 04             	sub    $0x4,%esp
  800395:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800398:	8b 13                	mov    (%ebx),%edx
  80039a:	8d 42 01             	lea    0x1(%edx),%eax
  80039d:	89 03                	mov    %eax,(%ebx)
  80039f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ab:	74 09                	je     8003b6 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003ad:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b4:	c9                   	leave  
  8003b5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	68 ff 00 00 00       	push   $0xff
  8003be:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c1:	50                   	push   %eax
  8003c2:	e8 de fc ff ff       	call   8000a5 <sys_cputs>
		b->idx = 0;
  8003c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003cd:	83 c4 10             	add    $0x10,%esp
  8003d0:	eb db                	jmp    8003ad <putch+0x23>

008003d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d2:	f3 0f 1e fb          	endbr32 
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e6:	00 00 00 
	b.cnt = 0;
  8003e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f3:	ff 75 0c             	pushl  0xc(%ebp)
  8003f6:	ff 75 08             	pushl  0x8(%ebp)
  8003f9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ff:	50                   	push   %eax
  800400:	68 8a 03 80 00       	push   $0x80038a
  800405:	e8 20 01 00 00       	call   80052a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80040a:	83 c4 08             	add    $0x8,%esp
  80040d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800413:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800419:	50                   	push   %eax
  80041a:	e8 86 fc ff ff       	call   8000a5 <sys_cputs>

	return b.cnt;
}
  80041f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800425:	c9                   	leave  
  800426:	c3                   	ret    

00800427 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800427:	f3 0f 1e fb          	endbr32 
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800431:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800434:	50                   	push   %eax
  800435:	ff 75 08             	pushl  0x8(%ebp)
  800438:	e8 95 ff ff ff       	call   8003d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80043d:	c9                   	leave  
  80043e:	c3                   	ret    

0080043f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
  800442:	57                   	push   %edi
  800443:	56                   	push   %esi
  800444:	53                   	push   %ebx
  800445:	83 ec 1c             	sub    $0x1c,%esp
  800448:	89 c7                	mov    %eax,%edi
  80044a:	89 d6                	mov    %edx,%esi
  80044c:	8b 45 08             	mov    0x8(%ebp),%eax
  80044f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800452:	89 d1                	mov    %edx,%ecx
  800454:	89 c2                	mov    %eax,%edx
  800456:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800459:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80045c:	8b 45 10             	mov    0x10(%ebp),%eax
  80045f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800462:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800465:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80046c:	39 c2                	cmp    %eax,%edx
  80046e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800471:	72 3e                	jb     8004b1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800473:	83 ec 0c             	sub    $0xc,%esp
  800476:	ff 75 18             	pushl  0x18(%ebp)
  800479:	83 eb 01             	sub    $0x1,%ebx
  80047c:	53                   	push   %ebx
  80047d:	50                   	push   %eax
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	ff 75 e4             	pushl  -0x1c(%ebp)
  800484:	ff 75 e0             	pushl  -0x20(%ebp)
  800487:	ff 75 dc             	pushl  -0x24(%ebp)
  80048a:	ff 75 d8             	pushl  -0x28(%ebp)
  80048d:	e8 1e 09 00 00       	call   800db0 <__udivdi3>
  800492:	83 c4 18             	add    $0x18,%esp
  800495:	52                   	push   %edx
  800496:	50                   	push   %eax
  800497:	89 f2                	mov    %esi,%edx
  800499:	89 f8                	mov    %edi,%eax
  80049b:	e8 9f ff ff ff       	call   80043f <printnum>
  8004a0:	83 c4 20             	add    $0x20,%esp
  8004a3:	eb 13                	jmp    8004b8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	56                   	push   %esi
  8004a9:	ff 75 18             	pushl  0x18(%ebp)
  8004ac:	ff d7                	call   *%edi
  8004ae:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004b1:	83 eb 01             	sub    $0x1,%ebx
  8004b4:	85 db                	test   %ebx,%ebx
  8004b6:	7f ed                	jg     8004a5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	56                   	push   %esi
  8004bc:	83 ec 04             	sub    $0x4,%esp
  8004bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c5:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8004cb:	e8 f0 09 00 00       	call   800ec0 <__umoddi3>
  8004d0:	83 c4 14             	add    $0x14,%esp
  8004d3:	0f be 80 7d 10 80 00 	movsbl 0x80107d(%eax),%eax
  8004da:	50                   	push   %eax
  8004db:	ff d7                	call   *%edi
}
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5e                   	pop    %esi
  8004e5:	5f                   	pop    %edi
  8004e6:	5d                   	pop    %ebp
  8004e7:	c3                   	ret    

008004e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e8:	f3 0f 1e fb          	endbr32 
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f6:	8b 10                	mov    (%eax),%edx
  8004f8:	3b 50 04             	cmp    0x4(%eax),%edx
  8004fb:	73 0a                	jae    800507 <sprintputch+0x1f>
		*b->buf++ = ch;
  8004fd:	8d 4a 01             	lea    0x1(%edx),%ecx
  800500:	89 08                	mov    %ecx,(%eax)
  800502:	8b 45 08             	mov    0x8(%ebp),%eax
  800505:	88 02                	mov    %al,(%edx)
}
  800507:	5d                   	pop    %ebp
  800508:	c3                   	ret    

00800509 <printfmt>:
{
  800509:	f3 0f 1e fb          	endbr32 
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800513:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800516:	50                   	push   %eax
  800517:	ff 75 10             	pushl  0x10(%ebp)
  80051a:	ff 75 0c             	pushl  0xc(%ebp)
  80051d:	ff 75 08             	pushl  0x8(%ebp)
  800520:	e8 05 00 00 00       	call   80052a <vprintfmt>
}
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	c9                   	leave  
  800529:	c3                   	ret    

0080052a <vprintfmt>:
{
  80052a:	f3 0f 1e fb          	endbr32 
  80052e:	55                   	push   %ebp
  80052f:	89 e5                	mov    %esp,%ebp
  800531:	57                   	push   %edi
  800532:	56                   	push   %esi
  800533:	53                   	push   %ebx
  800534:	83 ec 3c             	sub    $0x3c,%esp
  800537:	8b 75 08             	mov    0x8(%ebp),%esi
  80053a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800540:	e9 8e 03 00 00       	jmp    8008d3 <vprintfmt+0x3a9>
		padc = ' ';
  800545:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800549:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800550:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800557:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80055e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800563:	8d 47 01             	lea    0x1(%edi),%eax
  800566:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800569:	0f b6 17             	movzbl (%edi),%edx
  80056c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80056f:	3c 55                	cmp    $0x55,%al
  800571:	0f 87 df 03 00 00    	ja     800956 <vprintfmt+0x42c>
  800577:	0f b6 c0             	movzbl %al,%eax
  80057a:	3e ff 24 85 40 11 80 	notrack jmp *0x801140(,%eax,4)
  800581:	00 
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800585:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800589:	eb d8                	jmp    800563 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800592:	eb cf                	jmp    800563 <vprintfmt+0x39>
  800594:	0f b6 d2             	movzbl %dl,%edx
  800597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80059a:	b8 00 00 00 00       	mov    $0x0,%eax
  80059f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005a2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005ac:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005af:	83 f9 09             	cmp    $0x9,%ecx
  8005b2:	77 55                	ja     800609 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005b4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005b7:	eb e9                	jmp    8005a2 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 40 04             	lea    0x4(%eax),%eax
  8005c7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	79 90                	jns    800563 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005e0:	eb 81                	jmp    800563 <vprintfmt+0x39>
  8005e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e5:	85 c0                	test   %eax,%eax
  8005e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ec:	0f 49 d0             	cmovns %eax,%edx
  8005ef:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005f5:	e9 69 ff ff ff       	jmp    800563 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005fd:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800604:	e9 5a ff ff ff       	jmp    800563 <vprintfmt+0x39>
  800609:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80060c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060f:	eb bc                	jmp    8005cd <vprintfmt+0xa3>
			lflag++;
  800611:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800614:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800617:	e9 47 ff ff ff       	jmp    800563 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 78 04             	lea    0x4(%eax),%edi
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	ff 30                	pushl  (%eax)
  800628:	ff d6                	call   *%esi
			break;
  80062a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80062d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800630:	e9 9b 02 00 00       	jmp    8008d0 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8d 78 04             	lea    0x4(%eax),%edi
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	99                   	cltd   
  80063e:	31 d0                	xor    %edx,%eax
  800640:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800642:	83 f8 08             	cmp    $0x8,%eax
  800645:	7f 23                	jg     80066a <vprintfmt+0x140>
  800647:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  80064e:	85 d2                	test   %edx,%edx
  800650:	74 18                	je     80066a <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800652:	52                   	push   %edx
  800653:	68 9e 10 80 00       	push   $0x80109e
  800658:	53                   	push   %ebx
  800659:	56                   	push   %esi
  80065a:	e8 aa fe ff ff       	call   800509 <printfmt>
  80065f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800662:	89 7d 14             	mov    %edi,0x14(%ebp)
  800665:	e9 66 02 00 00       	jmp    8008d0 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80066a:	50                   	push   %eax
  80066b:	68 95 10 80 00       	push   $0x801095
  800670:	53                   	push   %ebx
  800671:	56                   	push   %esi
  800672:	e8 92 fe ff ff       	call   800509 <printfmt>
  800677:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80067a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80067d:	e9 4e 02 00 00       	jmp    8008d0 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	83 c0 04             	add    $0x4,%eax
  800688:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800690:	85 d2                	test   %edx,%edx
  800692:	b8 8e 10 80 00       	mov    $0x80108e,%eax
  800697:	0f 45 c2             	cmovne %edx,%eax
  80069a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80069d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a1:	7e 06                	jle    8006a9 <vprintfmt+0x17f>
  8006a3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006a7:	75 0d                	jne    8006b6 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006ac:	89 c7                	mov    %eax,%edi
  8006ae:	03 45 e0             	add    -0x20(%ebp),%eax
  8006b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b4:	eb 55                	jmp    80070b <vprintfmt+0x1e1>
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8006bc:	ff 75 cc             	pushl  -0x34(%ebp)
  8006bf:	e8 46 03 00 00       	call   800a0a <strnlen>
  8006c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006c7:	29 c2                	sub    %eax,%edx
  8006c9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006d1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d8:	85 ff                	test   %edi,%edi
  8006da:	7e 11                	jle    8006ed <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006dc:	83 ec 08             	sub    $0x8,%esp
  8006df:	53                   	push   %ebx
  8006e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e5:	83 ef 01             	sub    $0x1,%edi
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	eb eb                	jmp    8006d8 <vprintfmt+0x1ae>
  8006ed:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006f0:	85 d2                	test   %edx,%edx
  8006f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f7:	0f 49 c2             	cmovns %edx,%eax
  8006fa:	29 c2                	sub    %eax,%edx
  8006fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006ff:	eb a8                	jmp    8006a9 <vprintfmt+0x17f>
					putch(ch, putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	53                   	push   %ebx
  800705:	52                   	push   %edx
  800706:	ff d6                	call   *%esi
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80070e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800710:	83 c7 01             	add    $0x1,%edi
  800713:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800717:	0f be d0             	movsbl %al,%edx
  80071a:	85 d2                	test   %edx,%edx
  80071c:	74 4b                	je     800769 <vprintfmt+0x23f>
  80071e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800722:	78 06                	js     80072a <vprintfmt+0x200>
  800724:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800728:	78 1e                	js     800748 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80072a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80072e:	74 d1                	je     800701 <vprintfmt+0x1d7>
  800730:	0f be c0             	movsbl %al,%eax
  800733:	83 e8 20             	sub    $0x20,%eax
  800736:	83 f8 5e             	cmp    $0x5e,%eax
  800739:	76 c6                	jbe    800701 <vprintfmt+0x1d7>
					putch('?', putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	6a 3f                	push   $0x3f
  800741:	ff d6                	call   *%esi
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	eb c3                	jmp    80070b <vprintfmt+0x1e1>
  800748:	89 cf                	mov    %ecx,%edi
  80074a:	eb 0e                	jmp    80075a <vprintfmt+0x230>
				putch(' ', putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	53                   	push   %ebx
  800750:	6a 20                	push   $0x20
  800752:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800754:	83 ef 01             	sub    $0x1,%edi
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	85 ff                	test   %edi,%edi
  80075c:	7f ee                	jg     80074c <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80075e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800761:	89 45 14             	mov    %eax,0x14(%ebp)
  800764:	e9 67 01 00 00       	jmp    8008d0 <vprintfmt+0x3a6>
  800769:	89 cf                	mov    %ecx,%edi
  80076b:	eb ed                	jmp    80075a <vprintfmt+0x230>
	if (lflag >= 2)
  80076d:	83 f9 01             	cmp    $0x1,%ecx
  800770:	7f 1b                	jg     80078d <vprintfmt+0x263>
	else if (lflag)
  800772:	85 c9                	test   %ecx,%ecx
  800774:	74 63                	je     8007d9 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800776:	8b 45 14             	mov    0x14(%ebp),%eax
  800779:	8b 00                	mov    (%eax),%eax
  80077b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077e:	99                   	cltd   
  80077f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8d 40 04             	lea    0x4(%eax),%eax
  800788:	89 45 14             	mov    %eax,0x14(%ebp)
  80078b:	eb 17                	jmp    8007a4 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8b 50 04             	mov    0x4(%eax),%edx
  800793:	8b 00                	mov    (%eax),%eax
  800795:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800798:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8d 40 08             	lea    0x8(%eax),%eax
  8007a1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007aa:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007af:	85 c9                	test   %ecx,%ecx
  8007b1:	0f 89 ff 00 00 00    	jns    8008b6 <vprintfmt+0x38c>
				putch('-', putdat);
  8007b7:	83 ec 08             	sub    $0x8,%esp
  8007ba:	53                   	push   %ebx
  8007bb:	6a 2d                	push   $0x2d
  8007bd:	ff d6                	call   *%esi
				num = -(long long) num;
  8007bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007c5:	f7 da                	neg    %edx
  8007c7:	83 d1 00             	adc    $0x0,%ecx
  8007ca:	f7 d9                	neg    %ecx
  8007cc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d4:	e9 dd 00 00 00       	jmp    8008b6 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dc:	8b 00                	mov    (%eax),%eax
  8007de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e1:	99                   	cltd   
  8007e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8d 40 04             	lea    0x4(%eax),%eax
  8007eb:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ee:	eb b4                	jmp    8007a4 <vprintfmt+0x27a>
	if (lflag >= 2)
  8007f0:	83 f9 01             	cmp    $0x1,%ecx
  8007f3:	7f 1e                	jg     800813 <vprintfmt+0x2e9>
	else if (lflag)
  8007f5:	85 c9                	test   %ecx,%ecx
  8007f7:	74 32                	je     80082b <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8b 10                	mov    (%eax),%edx
  8007fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800803:	8d 40 04             	lea    0x4(%eax),%eax
  800806:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800809:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80080e:	e9 a3 00 00 00       	jmp    8008b6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800813:	8b 45 14             	mov    0x14(%ebp),%eax
  800816:	8b 10                	mov    (%eax),%edx
  800818:	8b 48 04             	mov    0x4(%eax),%ecx
  80081b:	8d 40 08             	lea    0x8(%eax),%eax
  80081e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800821:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800826:	e9 8b 00 00 00       	jmp    8008b6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80082b:	8b 45 14             	mov    0x14(%ebp),%eax
  80082e:	8b 10                	mov    (%eax),%edx
  800830:	b9 00 00 00 00       	mov    $0x0,%ecx
  800835:	8d 40 04             	lea    0x4(%eax),%eax
  800838:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80083b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800840:	eb 74                	jmp    8008b6 <vprintfmt+0x38c>
	if (lflag >= 2)
  800842:	83 f9 01             	cmp    $0x1,%ecx
  800845:	7f 1b                	jg     800862 <vprintfmt+0x338>
	else if (lflag)
  800847:	85 c9                	test   %ecx,%ecx
  800849:	74 2c                	je     800877 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80084b:	8b 45 14             	mov    0x14(%ebp),%eax
  80084e:	8b 10                	mov    (%eax),%edx
  800850:	b9 00 00 00 00       	mov    $0x0,%ecx
  800855:	8d 40 04             	lea    0x4(%eax),%eax
  800858:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80085b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800860:	eb 54                	jmp    8008b6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800862:	8b 45 14             	mov    0x14(%ebp),%eax
  800865:	8b 10                	mov    (%eax),%edx
  800867:	8b 48 04             	mov    0x4(%eax),%ecx
  80086a:	8d 40 08             	lea    0x8(%eax),%eax
  80086d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800870:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800875:	eb 3f                	jmp    8008b6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800877:	8b 45 14             	mov    0x14(%ebp),%eax
  80087a:	8b 10                	mov    (%eax),%edx
  80087c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800881:	8d 40 04             	lea    0x4(%eax),%eax
  800884:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800887:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80088c:	eb 28                	jmp    8008b6 <vprintfmt+0x38c>
			putch('0', putdat);
  80088e:	83 ec 08             	sub    $0x8,%esp
  800891:	53                   	push   %ebx
  800892:	6a 30                	push   $0x30
  800894:	ff d6                	call   *%esi
			putch('x', putdat);
  800896:	83 c4 08             	add    $0x8,%esp
  800899:	53                   	push   %ebx
  80089a:	6a 78                	push   $0x78
  80089c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80089e:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a1:	8b 10                	mov    (%eax),%edx
  8008a3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008a8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008ab:	8d 40 04             	lea    0x4(%eax),%eax
  8008ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b1:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008b6:	83 ec 0c             	sub    $0xc,%esp
  8008b9:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008bd:	57                   	push   %edi
  8008be:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c1:	50                   	push   %eax
  8008c2:	51                   	push   %ecx
  8008c3:	52                   	push   %edx
  8008c4:	89 da                	mov    %ebx,%edx
  8008c6:	89 f0                	mov    %esi,%eax
  8008c8:	e8 72 fb ff ff       	call   80043f <printnum>
			break;
  8008cd:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8008d3:	83 c7 01             	add    $0x1,%edi
  8008d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008da:	83 f8 25             	cmp    $0x25,%eax
  8008dd:	0f 84 62 fc ff ff    	je     800545 <vprintfmt+0x1b>
			if (ch == '\0')										
  8008e3:	85 c0                	test   %eax,%eax
  8008e5:	0f 84 8b 00 00 00    	je     800976 <vprintfmt+0x44c>
			putch(ch, putdat);
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	53                   	push   %ebx
  8008ef:	50                   	push   %eax
  8008f0:	ff d6                	call   *%esi
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	eb dc                	jmp    8008d3 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8008f7:	83 f9 01             	cmp    $0x1,%ecx
  8008fa:	7f 1b                	jg     800917 <vprintfmt+0x3ed>
	else if (lflag)
  8008fc:	85 c9                	test   %ecx,%ecx
  8008fe:	74 2c                	je     80092c <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800900:	8b 45 14             	mov    0x14(%ebp),%eax
  800903:	8b 10                	mov    (%eax),%edx
  800905:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090a:	8d 40 04             	lea    0x4(%eax),%eax
  80090d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800910:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800915:	eb 9f                	jmp    8008b6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800917:	8b 45 14             	mov    0x14(%ebp),%eax
  80091a:	8b 10                	mov    (%eax),%edx
  80091c:	8b 48 04             	mov    0x4(%eax),%ecx
  80091f:	8d 40 08             	lea    0x8(%eax),%eax
  800922:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800925:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80092a:	eb 8a                	jmp    8008b6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	8b 10                	mov    (%eax),%edx
  800931:	b9 00 00 00 00       	mov    $0x0,%ecx
  800936:	8d 40 04             	lea    0x4(%eax),%eax
  800939:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80093c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800941:	e9 70 ff ff ff       	jmp    8008b6 <vprintfmt+0x38c>
			putch(ch, putdat);
  800946:	83 ec 08             	sub    $0x8,%esp
  800949:	53                   	push   %ebx
  80094a:	6a 25                	push   $0x25
  80094c:	ff d6                	call   *%esi
			break;
  80094e:	83 c4 10             	add    $0x10,%esp
  800951:	e9 7a ff ff ff       	jmp    8008d0 <vprintfmt+0x3a6>
			putch('%', putdat);
  800956:	83 ec 08             	sub    $0x8,%esp
  800959:	53                   	push   %ebx
  80095a:	6a 25                	push   $0x25
  80095c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80095e:	83 c4 10             	add    $0x10,%esp
  800961:	89 f8                	mov    %edi,%eax
  800963:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800967:	74 05                	je     80096e <vprintfmt+0x444>
  800969:	83 e8 01             	sub    $0x1,%eax
  80096c:	eb f5                	jmp    800963 <vprintfmt+0x439>
  80096e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800971:	e9 5a ff ff ff       	jmp    8008d0 <vprintfmt+0x3a6>
}
  800976:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800979:	5b                   	pop    %ebx
  80097a:	5e                   	pop    %esi
  80097b:	5f                   	pop    %edi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80097e:	f3 0f 1e fb          	endbr32 
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 18             	sub    $0x18,%esp
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800991:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800995:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800998:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099f:	85 c0                	test   %eax,%eax
  8009a1:	74 26                	je     8009c9 <vsnprintf+0x4b>
  8009a3:	85 d2                	test   %edx,%edx
  8009a5:	7e 22                	jle    8009c9 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a7:	ff 75 14             	pushl  0x14(%ebp)
  8009aa:	ff 75 10             	pushl  0x10(%ebp)
  8009ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b0:	50                   	push   %eax
  8009b1:	68 e8 04 80 00       	push   $0x8004e8
  8009b6:	e8 6f fb ff ff       	call   80052a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009be:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c4:	83 c4 10             	add    $0x10,%esp
}
  8009c7:	c9                   	leave  
  8009c8:	c3                   	ret    
		return -E_INVAL;
  8009c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009ce:	eb f7                	jmp    8009c7 <vsnprintf+0x49>

008009d0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d0:	f3 0f 1e fb          	endbr32 
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009da:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009dd:	50                   	push   %eax
  8009de:	ff 75 10             	pushl  0x10(%ebp)
  8009e1:	ff 75 0c             	pushl  0xc(%ebp)
  8009e4:	ff 75 08             	pushl  0x8(%ebp)
  8009e7:	e8 92 ff ff ff       	call   80097e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009ee:	f3 0f 1e fb          	endbr32 
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a01:	74 05                	je     800a08 <strlen+0x1a>
		n++;
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	eb f5                	jmp    8009fd <strlen+0xf>
	return n;
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a0a:	f3 0f 1e fb          	endbr32 
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a14:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1c:	39 d0                	cmp    %edx,%eax
  800a1e:	74 0d                	je     800a2d <strnlen+0x23>
  800a20:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a24:	74 05                	je     800a2b <strnlen+0x21>
		n++;
  800a26:	83 c0 01             	add    $0x1,%eax
  800a29:	eb f1                	jmp    800a1c <strnlen+0x12>
  800a2b:	89 c2                	mov    %eax,%edx
	return n;
}
  800a2d:	89 d0                	mov    %edx,%eax
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a31:	f3 0f 1e fb          	endbr32 
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	53                   	push   %ebx
  800a39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a44:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a48:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	84 d2                	test   %dl,%dl
  800a50:	75 f2                	jne    800a44 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a52:	89 c8                	mov    %ecx,%eax
  800a54:	5b                   	pop    %ebx
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a57:	f3 0f 1e fb          	endbr32 
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	83 ec 10             	sub    $0x10,%esp
  800a62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a65:	53                   	push   %ebx
  800a66:	e8 83 ff ff ff       	call   8009ee <strlen>
  800a6b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a6e:	ff 75 0c             	pushl  0xc(%ebp)
  800a71:	01 d8                	add    %ebx,%eax
  800a73:	50                   	push   %eax
  800a74:	e8 b8 ff ff ff       	call   800a31 <strcpy>
	return dst;
}
  800a79:	89 d8                	mov    %ebx,%eax
  800a7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a80:	f3 0f 1e fb          	endbr32 
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8f:	89 f3                	mov    %esi,%ebx
  800a91:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a94:	89 f0                	mov    %esi,%eax
  800a96:	39 d8                	cmp    %ebx,%eax
  800a98:	74 11                	je     800aab <strncpy+0x2b>
		*dst++ = *src;
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	0f b6 0a             	movzbl (%edx),%ecx
  800aa0:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aa3:	80 f9 01             	cmp    $0x1,%cl
  800aa6:	83 da ff             	sbb    $0xffffffff,%edx
  800aa9:	eb eb                	jmp    800a96 <strncpy+0x16>
	}
	return ret;
}
  800aab:	89 f0                	mov    %esi,%eax
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ab1:	f3 0f 1e fb          	endbr32 
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	8b 75 08             	mov    0x8(%ebp),%esi
  800abd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac0:	8b 55 10             	mov    0x10(%ebp),%edx
  800ac3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac5:	85 d2                	test   %edx,%edx
  800ac7:	74 21                	je     800aea <strlcpy+0x39>
  800ac9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800acd:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800acf:	39 c2                	cmp    %eax,%edx
  800ad1:	74 14                	je     800ae7 <strlcpy+0x36>
  800ad3:	0f b6 19             	movzbl (%ecx),%ebx
  800ad6:	84 db                	test   %bl,%bl
  800ad8:	74 0b                	je     800ae5 <strlcpy+0x34>
			*dst++ = *src++;
  800ada:	83 c1 01             	add    $0x1,%ecx
  800add:	83 c2 01             	add    $0x1,%edx
  800ae0:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ae3:	eb ea                	jmp    800acf <strlcpy+0x1e>
  800ae5:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800ae7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aea:	29 f0                	sub    %esi,%eax
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800af0:	f3 0f 1e fb          	endbr32 
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afa:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800afd:	0f b6 01             	movzbl (%ecx),%eax
  800b00:	84 c0                	test   %al,%al
  800b02:	74 0c                	je     800b10 <strcmp+0x20>
  800b04:	3a 02                	cmp    (%edx),%al
  800b06:	75 08                	jne    800b10 <strcmp+0x20>
		p++, q++;
  800b08:	83 c1 01             	add    $0x1,%ecx
  800b0b:	83 c2 01             	add    $0x1,%edx
  800b0e:	eb ed                	jmp    800afd <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b10:	0f b6 c0             	movzbl %al,%eax
  800b13:	0f b6 12             	movzbl (%edx),%edx
  800b16:	29 d0                	sub    %edx,%eax
}
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b1a:	f3 0f 1e fb          	endbr32 
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	53                   	push   %ebx
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b28:	89 c3                	mov    %eax,%ebx
  800b2a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b2d:	eb 06                	jmp    800b35 <strncmp+0x1b>
		n--, p++, q++;
  800b2f:	83 c0 01             	add    $0x1,%eax
  800b32:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b35:	39 d8                	cmp    %ebx,%eax
  800b37:	74 16                	je     800b4f <strncmp+0x35>
  800b39:	0f b6 08             	movzbl (%eax),%ecx
  800b3c:	84 c9                	test   %cl,%cl
  800b3e:	74 04                	je     800b44 <strncmp+0x2a>
  800b40:	3a 0a                	cmp    (%edx),%cl
  800b42:	74 eb                	je     800b2f <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b44:	0f b6 00             	movzbl (%eax),%eax
  800b47:	0f b6 12             	movzbl (%edx),%edx
  800b4a:	29 d0                	sub    %edx,%eax
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    
		return 0;
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b54:	eb f6                	jmp    800b4c <strncmp+0x32>

00800b56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b56:	f3 0f 1e fb          	endbr32 
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b64:	0f b6 10             	movzbl (%eax),%edx
  800b67:	84 d2                	test   %dl,%dl
  800b69:	74 09                	je     800b74 <strchr+0x1e>
		if (*s == c)
  800b6b:	38 ca                	cmp    %cl,%dl
  800b6d:	74 0a                	je     800b79 <strchr+0x23>
	for (; *s; s++)
  800b6f:	83 c0 01             	add    $0x1,%eax
  800b72:	eb f0                	jmp    800b64 <strchr+0xe>
			return (char *) s;
	return 0;
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7b:	f3 0f 1e fb          	endbr32 
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	8b 45 08             	mov    0x8(%ebp),%eax
  800b85:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b89:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b8c:	38 ca                	cmp    %cl,%dl
  800b8e:	74 09                	je     800b99 <strfind+0x1e>
  800b90:	84 d2                	test   %dl,%dl
  800b92:	74 05                	je     800b99 <strfind+0x1e>
	for (; *s; s++)
  800b94:	83 c0 01             	add    $0x1,%eax
  800b97:	eb f0                	jmp    800b89 <strfind+0xe>
			break;
	return (char *) s;
}
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b9b:	f3 0f 1e fb          	endbr32 
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bab:	85 c9                	test   %ecx,%ecx
  800bad:	74 31                	je     800be0 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800baf:	89 f8                	mov    %edi,%eax
  800bb1:	09 c8                	or     %ecx,%eax
  800bb3:	a8 03                	test   $0x3,%al
  800bb5:	75 23                	jne    800bda <memset+0x3f>
		c &= 0xFF;
  800bb7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bbb:	89 d3                	mov    %edx,%ebx
  800bbd:	c1 e3 08             	shl    $0x8,%ebx
  800bc0:	89 d0                	mov    %edx,%eax
  800bc2:	c1 e0 18             	shl    $0x18,%eax
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	c1 e6 10             	shl    $0x10,%esi
  800bca:	09 f0                	or     %esi,%eax
  800bcc:	09 c2                	or     %eax,%edx
  800bce:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bd0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bd3:	89 d0                	mov    %edx,%eax
  800bd5:	fc                   	cld    
  800bd6:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd8:	eb 06                	jmp    800be0 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdd:	fc                   	cld    
  800bde:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800be0:	89 f8                	mov    %edi,%eax
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800be7:	f3 0f 1e fb          	endbr32 
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bf9:	39 c6                	cmp    %eax,%esi
  800bfb:	73 32                	jae    800c2f <memmove+0x48>
  800bfd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c00:	39 c2                	cmp    %eax,%edx
  800c02:	76 2b                	jbe    800c2f <memmove+0x48>
		s += n;
		d += n;
  800c04:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c07:	89 fe                	mov    %edi,%esi
  800c09:	09 ce                	or     %ecx,%esi
  800c0b:	09 d6                	or     %edx,%esi
  800c0d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c13:	75 0e                	jne    800c23 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c15:	83 ef 04             	sub    $0x4,%edi
  800c18:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c1b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c1e:	fd                   	std    
  800c1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c21:	eb 09                	jmp    800c2c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c23:	83 ef 01             	sub    $0x1,%edi
  800c26:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c29:	fd                   	std    
  800c2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c2c:	fc                   	cld    
  800c2d:	eb 1a                	jmp    800c49 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2f:	89 c2                	mov    %eax,%edx
  800c31:	09 ca                	or     %ecx,%edx
  800c33:	09 f2                	or     %esi,%edx
  800c35:	f6 c2 03             	test   $0x3,%dl
  800c38:	75 0a                	jne    800c44 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c3a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c3d:	89 c7                	mov    %eax,%edi
  800c3f:	fc                   	cld    
  800c40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c42:	eb 05                	jmp    800c49 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c44:	89 c7                	mov    %eax,%edi
  800c46:	fc                   	cld    
  800c47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c4d:	f3 0f 1e fb          	endbr32 
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c57:	ff 75 10             	pushl  0x10(%ebp)
  800c5a:	ff 75 0c             	pushl  0xc(%ebp)
  800c5d:	ff 75 08             	pushl  0x8(%ebp)
  800c60:	e8 82 ff ff ff       	call   800be7 <memmove>
}
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    

00800c67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c67:	f3 0f 1e fb          	endbr32 
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	8b 45 08             	mov    0x8(%ebp),%eax
  800c73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c76:	89 c6                	mov    %eax,%esi
  800c78:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7b:	39 f0                	cmp    %esi,%eax
  800c7d:	74 1c                	je     800c9b <memcmp+0x34>
		if (*s1 != *s2)
  800c7f:	0f b6 08             	movzbl (%eax),%ecx
  800c82:	0f b6 1a             	movzbl (%edx),%ebx
  800c85:	38 d9                	cmp    %bl,%cl
  800c87:	75 08                	jne    800c91 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c89:	83 c0 01             	add    $0x1,%eax
  800c8c:	83 c2 01             	add    $0x1,%edx
  800c8f:	eb ea                	jmp    800c7b <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800c91:	0f b6 c1             	movzbl %cl,%eax
  800c94:	0f b6 db             	movzbl %bl,%ebx
  800c97:	29 d8                	sub    %ebx,%eax
  800c99:	eb 05                	jmp    800ca0 <memcmp+0x39>
	}

	return 0;
  800c9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca4:	f3 0f 1e fb          	endbr32 
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cb1:	89 c2                	mov    %eax,%edx
  800cb3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb6:	39 d0                	cmp    %edx,%eax
  800cb8:	73 09                	jae    800cc3 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cba:	38 08                	cmp    %cl,(%eax)
  800cbc:	74 05                	je     800cc3 <memfind+0x1f>
	for (; s < ends; s++)
  800cbe:	83 c0 01             	add    $0x1,%eax
  800cc1:	eb f3                	jmp    800cb6 <memfind+0x12>
			break;
	return (void *) s;
}
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc5:	f3 0f 1e fb          	endbr32 
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd5:	eb 03                	jmp    800cda <strtol+0x15>
		s++;
  800cd7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800cda:	0f b6 01             	movzbl (%ecx),%eax
  800cdd:	3c 20                	cmp    $0x20,%al
  800cdf:	74 f6                	je     800cd7 <strtol+0x12>
  800ce1:	3c 09                	cmp    $0x9,%al
  800ce3:	74 f2                	je     800cd7 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ce5:	3c 2b                	cmp    $0x2b,%al
  800ce7:	74 2a                	je     800d13 <strtol+0x4e>
	int neg = 0;
  800ce9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800cee:	3c 2d                	cmp    $0x2d,%al
  800cf0:	74 2b                	je     800d1d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cf8:	75 0f                	jne    800d09 <strtol+0x44>
  800cfa:	80 39 30             	cmpb   $0x30,(%ecx)
  800cfd:	74 28                	je     800d27 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cff:	85 db                	test   %ebx,%ebx
  800d01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d06:	0f 44 d8             	cmove  %eax,%ebx
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d11:	eb 46                	jmp    800d59 <strtol+0x94>
		s++;
  800d13:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d16:	bf 00 00 00 00       	mov    $0x0,%edi
  800d1b:	eb d5                	jmp    800cf2 <strtol+0x2d>
		s++, neg = 1;
  800d1d:	83 c1 01             	add    $0x1,%ecx
  800d20:	bf 01 00 00 00       	mov    $0x1,%edi
  800d25:	eb cb                	jmp    800cf2 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d2b:	74 0e                	je     800d3b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d2d:	85 db                	test   %ebx,%ebx
  800d2f:	75 d8                	jne    800d09 <strtol+0x44>
		s++, base = 8;
  800d31:	83 c1 01             	add    $0x1,%ecx
  800d34:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d39:	eb ce                	jmp    800d09 <strtol+0x44>
		s += 2, base = 16;
  800d3b:	83 c1 02             	add    $0x2,%ecx
  800d3e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d43:	eb c4                	jmp    800d09 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d45:	0f be d2             	movsbl %dl,%edx
  800d48:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d4b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d4e:	7d 3a                	jge    800d8a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d50:	83 c1 01             	add    $0x1,%ecx
  800d53:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d57:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d59:	0f b6 11             	movzbl (%ecx),%edx
  800d5c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d5f:	89 f3                	mov    %esi,%ebx
  800d61:	80 fb 09             	cmp    $0x9,%bl
  800d64:	76 df                	jbe    800d45 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d66:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d69:	89 f3                	mov    %esi,%ebx
  800d6b:	80 fb 19             	cmp    $0x19,%bl
  800d6e:	77 08                	ja     800d78 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d70:	0f be d2             	movsbl %dl,%edx
  800d73:	83 ea 57             	sub    $0x57,%edx
  800d76:	eb d3                	jmp    800d4b <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d78:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d7b:	89 f3                	mov    %esi,%ebx
  800d7d:	80 fb 19             	cmp    $0x19,%bl
  800d80:	77 08                	ja     800d8a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d82:	0f be d2             	movsbl %dl,%edx
  800d85:	83 ea 37             	sub    $0x37,%edx
  800d88:	eb c1                	jmp    800d4b <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d8e:	74 05                	je     800d95 <strtol+0xd0>
		*endptr = (char *) s;
  800d90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d93:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d95:	89 c2                	mov    %eax,%edx
  800d97:	f7 da                	neg    %edx
  800d99:	85 ff                	test   %edi,%edi
  800d9b:	0f 45 c2             	cmovne %edx,%eax
}
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    
  800da3:	66 90                	xchg   %ax,%ax
  800da5:	66 90                	xchg   %ax,%ax
  800da7:	66 90                	xchg   %ax,%ax
  800da9:	66 90                	xchg   %ax,%ax
  800dab:	66 90                	xchg   %ax,%ax
  800dad:	66 90                	xchg   %ax,%ax
  800daf:	90                   	nop

00800db0 <__udivdi3>:
  800db0:	f3 0f 1e fb          	endbr32 
  800db4:	55                   	push   %ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	83 ec 1c             	sub    $0x1c,%esp
  800dbb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dbf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800dc3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800dc7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dcb:	85 d2                	test   %edx,%edx
  800dcd:	75 19                	jne    800de8 <__udivdi3+0x38>
  800dcf:	39 f3                	cmp    %esi,%ebx
  800dd1:	76 4d                	jbe    800e20 <__udivdi3+0x70>
  800dd3:	31 ff                	xor    %edi,%edi
  800dd5:	89 e8                	mov    %ebp,%eax
  800dd7:	89 f2                	mov    %esi,%edx
  800dd9:	f7 f3                	div    %ebx
  800ddb:	89 fa                	mov    %edi,%edx
  800ddd:	83 c4 1c             	add    $0x1c,%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    
  800de5:	8d 76 00             	lea    0x0(%esi),%esi
  800de8:	39 f2                	cmp    %esi,%edx
  800dea:	76 14                	jbe    800e00 <__udivdi3+0x50>
  800dec:	31 ff                	xor    %edi,%edi
  800dee:	31 c0                	xor    %eax,%eax
  800df0:	89 fa                	mov    %edi,%edx
  800df2:	83 c4 1c             	add    $0x1c,%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    
  800dfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e00:	0f bd fa             	bsr    %edx,%edi
  800e03:	83 f7 1f             	xor    $0x1f,%edi
  800e06:	75 48                	jne    800e50 <__udivdi3+0xa0>
  800e08:	39 f2                	cmp    %esi,%edx
  800e0a:	72 06                	jb     800e12 <__udivdi3+0x62>
  800e0c:	31 c0                	xor    %eax,%eax
  800e0e:	39 eb                	cmp    %ebp,%ebx
  800e10:	77 de                	ja     800df0 <__udivdi3+0x40>
  800e12:	b8 01 00 00 00       	mov    $0x1,%eax
  800e17:	eb d7                	jmp    800df0 <__udivdi3+0x40>
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	89 d9                	mov    %ebx,%ecx
  800e22:	85 db                	test   %ebx,%ebx
  800e24:	75 0b                	jne    800e31 <__udivdi3+0x81>
  800e26:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	f7 f3                	div    %ebx
  800e2f:	89 c1                	mov    %eax,%ecx
  800e31:	31 d2                	xor    %edx,%edx
  800e33:	89 f0                	mov    %esi,%eax
  800e35:	f7 f1                	div    %ecx
  800e37:	89 c6                	mov    %eax,%esi
  800e39:	89 e8                	mov    %ebp,%eax
  800e3b:	89 f7                	mov    %esi,%edi
  800e3d:	f7 f1                	div    %ecx
  800e3f:	89 fa                	mov    %edi,%edx
  800e41:	83 c4 1c             	add    $0x1c,%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	89 f9                	mov    %edi,%ecx
  800e52:	b8 20 00 00 00       	mov    $0x20,%eax
  800e57:	29 f8                	sub    %edi,%eax
  800e59:	d3 e2                	shl    %cl,%edx
  800e5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e5f:	89 c1                	mov    %eax,%ecx
  800e61:	89 da                	mov    %ebx,%edx
  800e63:	d3 ea                	shr    %cl,%edx
  800e65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e69:	09 d1                	or     %edx,%ecx
  800e6b:	89 f2                	mov    %esi,%edx
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f9                	mov    %edi,%ecx
  800e73:	d3 e3                	shl    %cl,%ebx
  800e75:	89 c1                	mov    %eax,%ecx
  800e77:	d3 ea                	shr    %cl,%edx
  800e79:	89 f9                	mov    %edi,%ecx
  800e7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e7f:	89 eb                	mov    %ebp,%ebx
  800e81:	d3 e6                	shl    %cl,%esi
  800e83:	89 c1                	mov    %eax,%ecx
  800e85:	d3 eb                	shr    %cl,%ebx
  800e87:	09 de                	or     %ebx,%esi
  800e89:	89 f0                	mov    %esi,%eax
  800e8b:	f7 74 24 08          	divl   0x8(%esp)
  800e8f:	89 d6                	mov    %edx,%esi
  800e91:	89 c3                	mov    %eax,%ebx
  800e93:	f7 64 24 0c          	mull   0xc(%esp)
  800e97:	39 d6                	cmp    %edx,%esi
  800e99:	72 15                	jb     800eb0 <__udivdi3+0x100>
  800e9b:	89 f9                	mov    %edi,%ecx
  800e9d:	d3 e5                	shl    %cl,%ebp
  800e9f:	39 c5                	cmp    %eax,%ebp
  800ea1:	73 04                	jae    800ea7 <__udivdi3+0xf7>
  800ea3:	39 d6                	cmp    %edx,%esi
  800ea5:	74 09                	je     800eb0 <__udivdi3+0x100>
  800ea7:	89 d8                	mov    %ebx,%eax
  800ea9:	31 ff                	xor    %edi,%edi
  800eab:	e9 40 ff ff ff       	jmp    800df0 <__udivdi3+0x40>
  800eb0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eb3:	31 ff                	xor    %edi,%edi
  800eb5:	e9 36 ff ff ff       	jmp    800df0 <__udivdi3+0x40>
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__umoddi3>:
  800ec0:	f3 0f 1e fb          	endbr32 
  800ec4:	55                   	push   %ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 1c             	sub    $0x1c,%esp
  800ecb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800ecf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ed3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ed7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800edb:	85 c0                	test   %eax,%eax
  800edd:	75 19                	jne    800ef8 <__umoddi3+0x38>
  800edf:	39 df                	cmp    %ebx,%edi
  800ee1:	76 5d                	jbe    800f40 <__umoddi3+0x80>
  800ee3:	89 f0                	mov    %esi,%eax
  800ee5:	89 da                	mov    %ebx,%edx
  800ee7:	f7 f7                	div    %edi
  800ee9:	89 d0                	mov    %edx,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	83 c4 1c             	add    $0x1c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	89 f2                	mov    %esi,%edx
  800efa:	39 d8                	cmp    %ebx,%eax
  800efc:	76 12                	jbe    800f10 <__umoddi3+0x50>
  800efe:	89 f0                	mov    %esi,%eax
  800f00:	89 da                	mov    %ebx,%edx
  800f02:	83 c4 1c             	add    $0x1c,%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    
  800f0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f10:	0f bd e8             	bsr    %eax,%ebp
  800f13:	83 f5 1f             	xor    $0x1f,%ebp
  800f16:	75 50                	jne    800f68 <__umoddi3+0xa8>
  800f18:	39 d8                	cmp    %ebx,%eax
  800f1a:	0f 82 e0 00 00 00    	jb     801000 <__umoddi3+0x140>
  800f20:	89 d9                	mov    %ebx,%ecx
  800f22:	39 f7                	cmp    %esi,%edi
  800f24:	0f 86 d6 00 00 00    	jbe    801000 <__umoddi3+0x140>
  800f2a:	89 d0                	mov    %edx,%eax
  800f2c:	89 ca                	mov    %ecx,%edx
  800f2e:	83 c4 1c             	add    $0x1c,%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5f                   	pop    %edi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    
  800f36:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f3d:	8d 76 00             	lea    0x0(%esi),%esi
  800f40:	89 fd                	mov    %edi,%ebp
  800f42:	85 ff                	test   %edi,%edi
  800f44:	75 0b                	jne    800f51 <__umoddi3+0x91>
  800f46:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	f7 f7                	div    %edi
  800f4f:	89 c5                	mov    %eax,%ebp
  800f51:	89 d8                	mov    %ebx,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 f5                	div    %ebp
  800f57:	89 f0                	mov    %esi,%eax
  800f59:	f7 f5                	div    %ebp
  800f5b:	89 d0                	mov    %edx,%eax
  800f5d:	31 d2                	xor    %edx,%edx
  800f5f:	eb 8c                	jmp    800eed <__umoddi3+0x2d>
  800f61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f68:	89 e9                	mov    %ebp,%ecx
  800f6a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f6f:	29 ea                	sub    %ebp,%edx
  800f71:	d3 e0                	shl    %cl,%eax
  800f73:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f77:	89 d1                	mov    %edx,%ecx
  800f79:	89 f8                	mov    %edi,%eax
  800f7b:	d3 e8                	shr    %cl,%eax
  800f7d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f81:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f85:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f89:	09 c1                	or     %eax,%ecx
  800f8b:	89 d8                	mov    %ebx,%eax
  800f8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f91:	89 e9                	mov    %ebp,%ecx
  800f93:	d3 e7                	shl    %cl,%edi
  800f95:	89 d1                	mov    %edx,%ecx
  800f97:	d3 e8                	shr    %cl,%eax
  800f99:	89 e9                	mov    %ebp,%ecx
  800f9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f9f:	d3 e3                	shl    %cl,%ebx
  800fa1:	89 c7                	mov    %eax,%edi
  800fa3:	89 d1                	mov    %edx,%ecx
  800fa5:	89 f0                	mov    %esi,%eax
  800fa7:	d3 e8                	shr    %cl,%eax
  800fa9:	89 e9                	mov    %ebp,%ecx
  800fab:	89 fa                	mov    %edi,%edx
  800fad:	d3 e6                	shl    %cl,%esi
  800faf:	09 d8                	or     %ebx,%eax
  800fb1:	f7 74 24 08          	divl   0x8(%esp)
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	89 f3                	mov    %esi,%ebx
  800fb9:	f7 64 24 0c          	mull   0xc(%esp)
  800fbd:	89 c6                	mov    %eax,%esi
  800fbf:	89 d7                	mov    %edx,%edi
  800fc1:	39 d1                	cmp    %edx,%ecx
  800fc3:	72 06                	jb     800fcb <__umoddi3+0x10b>
  800fc5:	75 10                	jne    800fd7 <__umoddi3+0x117>
  800fc7:	39 c3                	cmp    %eax,%ebx
  800fc9:	73 0c                	jae    800fd7 <__umoddi3+0x117>
  800fcb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fcf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fd3:	89 d7                	mov    %edx,%edi
  800fd5:	89 c6                	mov    %eax,%esi
  800fd7:	89 ca                	mov    %ecx,%edx
  800fd9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fde:	29 f3                	sub    %esi,%ebx
  800fe0:	19 fa                	sbb    %edi,%edx
  800fe2:	89 d0                	mov    %edx,%eax
  800fe4:	d3 e0                	shl    %cl,%eax
  800fe6:	89 e9                	mov    %ebp,%ecx
  800fe8:	d3 eb                	shr    %cl,%ebx
  800fea:	d3 ea                	shr    %cl,%edx
  800fec:	09 d8                	or     %ebx,%eax
  800fee:	83 c4 1c             	add    $0x1c,%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    
  800ff6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ffd:	8d 76 00             	lea    0x0(%esi),%esi
  801000:	29 fe                	sub    %edi,%esi
  801002:	19 c3                	sbb    %eax,%ebx
  801004:	89 f2                	mov    %esi,%edx
  801006:	89 d9                	mov    %ebx,%ecx
  801008:	e9 1d ff ff ff       	jmp    800f2a <__umoddi3+0x6a>
