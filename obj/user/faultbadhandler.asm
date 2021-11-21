
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 38 00 00 00       	call   800069 <libmain>
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
  80003a:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003d:	6a 07                	push   $0x7
  80003f:	68 00 f0 bf ee       	push   $0xeebff000
  800044:	6a 00                	push   $0x0
  800046:	e8 51 01 00 00       	call   80019c <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	68 ef be ad de       	push   $0xdeadbeef
  800053:	6a 00                	push   $0x0
  800055:	e8 5b 02 00 00       	call   8002b5 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80005a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800061:	00 00 00 
}
  800064:	83 c4 10             	add    $0x10,%esp
  800067:	c9                   	leave  
  800068:	c3                   	ret    

00800069 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800069:	f3 0f 1e fb          	endbr32 
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800078:	e8 d9 00 00 00       	call   800156 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008d:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 db                	test   %ebx,%ebx
  800094:	7e 07                	jle    80009d <libmain+0x34>
		binaryname = argv[0];
  800096:	8b 06                	mov    (%esi),%eax
  800098:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009d:	83 ec 08             	sub    $0x8,%esp
  8000a0:	56                   	push   %esi
  8000a1:	53                   	push   %ebx
  8000a2:	e8 8c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a7:	e8 0a 00 00 00       	call   8000b6 <exit>
}
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5d                   	pop    %ebp
  8000b5:	c3                   	ret    

008000b6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b6:	f3 0f 1e fb          	endbr32 
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000c0:	6a 00                	push   $0x0
  8000c2:	e8 4a 00 00 00       	call   800111 <sys_env_destroy>
}
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000cc:	f3 0f 1e fb          	endbr32 
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	57                   	push   %edi
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000db:	8b 55 08             	mov    0x8(%ebp),%edx
  8000de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e1:	89 c3                	mov    %eax,%ebx
  8000e3:	89 c7                	mov    %eax,%edi
  8000e5:	89 c6                	mov    %eax,%esi
  8000e7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5f                   	pop    %edi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ee:	f3 0f 1e fb          	endbr32 
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	57                   	push   %edi
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000fd:	b8 01 00 00 00       	mov    $0x1,%eax
  800102:	89 d1                	mov    %edx,%ecx
  800104:	89 d3                	mov    %edx,%ebx
  800106:	89 d7                	mov    %edx,%edi
  800108:	89 d6                	mov    %edx,%esi
  80010a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5f                   	pop    %edi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    

00800111 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800111:	f3 0f 1e fb          	endbr32 
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	57                   	push   %edi
  800119:	56                   	push   %esi
  80011a:	53                   	push   %ebx
  80011b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80011e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800123:	8b 55 08             	mov    0x8(%ebp),%edx
  800126:	b8 03 00 00 00       	mov    $0x3,%eax
  80012b:	89 cb                	mov    %ecx,%ebx
  80012d:	89 cf                	mov    %ecx,%edi
  80012f:	89 ce                	mov    %ecx,%esi
  800131:	cd 30                	int    $0x30
	if(check && ret > 0)
  800133:	85 c0                	test   %eax,%eax
  800135:	7f 08                	jg     80013f <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800137:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	50                   	push   %eax
  800143:	6a 03                	push   $0x3
  800145:	68 4a 10 80 00       	push   $0x80104a
  80014a:	6a 23                	push   $0x23
  80014c:	68 67 10 80 00       	push   $0x801067
  800151:	e8 11 02 00 00       	call   800367 <_panic>

00800156 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800156:	f3 0f 1e fb          	endbr32 
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 02 00 00 00       	mov    $0x2,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_yield>:

void
sys_yield(void)
{
  800179:	f3 0f 1e fb          	endbr32 
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	57                   	push   %edi
  800181:	56                   	push   %esi
  800182:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800183:	ba 00 00 00 00       	mov    $0x0,%edx
  800188:	b8 0a 00 00 00       	mov    $0xa,%eax
  80018d:	89 d1                	mov    %edx,%ecx
  80018f:	89 d3                	mov    %edx,%ebx
  800191:	89 d7                	mov    %edx,%edi
  800193:	89 d6                	mov    %edx,%esi
  800195:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800197:	5b                   	pop    %ebx
  800198:	5e                   	pop    %esi
  800199:	5f                   	pop    %edi
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    

0080019c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80019c:	f3 0f 1e fb          	endbr32 
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8001a9:	be 00 00 00 00       	mov    $0x0,%esi
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bc:	89 f7                	mov    %esi,%edi
  8001be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7f 08                	jg     8001cc <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5f                   	pop    %edi
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 04                	push   $0x4
  8001d2:	68 4a 10 80 00       	push   $0x80104a
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 67 10 80 00       	push   $0x801067
  8001de:	e8 84 01 00 00       	call   800367 <_panic>

008001e3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e3:	f3 0f 1e fb          	endbr32 
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800201:	8b 75 18             	mov    0x18(%ebp),%esi
  800204:	cd 30                	int    $0x30
	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7f 08                	jg     800212 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5f                   	pop    %edi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 05                	push   $0x5
  800218:	68 4a 10 80 00       	push   $0x80104a
  80021d:	6a 23                	push   $0x23
  80021f:	68 67 10 80 00       	push   $0x801067
  800224:	e8 3e 01 00 00       	call   800367 <_panic>

00800229 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800229:	f3 0f 1e fb          	endbr32 
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800241:	b8 06 00 00 00       	mov    $0x6,%eax
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7f 08                	jg     800258 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800253:	5b                   	pop    %ebx
  800254:	5e                   	pop    %esi
  800255:	5f                   	pop    %edi
  800256:	5d                   	pop    %ebp
  800257:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	50                   	push   %eax
  80025c:	6a 06                	push   $0x6
  80025e:	68 4a 10 80 00       	push   $0x80104a
  800263:	6a 23                	push   $0x23
  800265:	68 67 10 80 00       	push   $0x801067
  80026a:	e8 f8 00 00 00       	call   800367 <_panic>

0080026f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026f:	f3 0f 1e fb          	endbr32 
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	b8 08 00 00 00       	mov    $0x8,%eax
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7f 08                	jg     80029e <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	83 ec 0c             	sub    $0xc,%esp
  8002a1:	50                   	push   %eax
  8002a2:	6a 08                	push   $0x8
  8002a4:	68 4a 10 80 00       	push   $0x80104a
  8002a9:	6a 23                	push   $0x23
  8002ab:	68 67 10 80 00       	push   $0x801067
  8002b0:	e8 b2 00 00 00       	call   800367 <_panic>

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	f3 0f 1e fb          	endbr32 
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	57                   	push   %edi
  8002bd:	56                   	push   %esi
  8002be:	53                   	push   %ebx
  8002bf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8002c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cd:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d2:	89 df                	mov    %ebx,%edi
  8002d4:	89 de                	mov    %ebx,%esi
  8002d6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	7f 08                	jg     8002e4 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002df:	5b                   	pop    %ebx
  8002e0:	5e                   	pop    %esi
  8002e1:	5f                   	pop    %edi
  8002e2:	5d                   	pop    %ebp
  8002e3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e4:	83 ec 0c             	sub    $0xc,%esp
  8002e7:	50                   	push   %eax
  8002e8:	6a 09                	push   $0x9
  8002ea:	68 4a 10 80 00       	push   $0x80104a
  8002ef:	6a 23                	push   $0x23
  8002f1:	68 67 10 80 00       	push   $0x801067
  8002f6:	e8 6c 00 00 00       	call   800367 <_panic>

008002fb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fb:	f3 0f 1e fb          	endbr32 
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	57                   	push   %edi
  800303:	56                   	push   %esi
  800304:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800305:	8b 55 08             	mov    0x8(%ebp),%edx
  800308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800310:	be 00 00 00 00       	mov    $0x0,%esi
  800315:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800318:	8b 7d 14             	mov    0x14(%ebp),%edi
  80031b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800322:	f3 0f 1e fb          	endbr32 
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	57                   	push   %edi
  80032a:	56                   	push   %esi
  80032b:	53                   	push   %ebx
  80032c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80032f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800334:	8b 55 08             	mov    0x8(%ebp),%edx
  800337:	b8 0c 00 00 00       	mov    $0xc,%eax
  80033c:	89 cb                	mov    %ecx,%ebx
  80033e:	89 cf                	mov    %ecx,%edi
  800340:	89 ce                	mov    %ecx,%esi
  800342:	cd 30                	int    $0x30
	if(check && ret > 0)
  800344:	85 c0                	test   %eax,%eax
  800346:	7f 08                	jg     800350 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800348:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034b:	5b                   	pop    %ebx
  80034c:	5e                   	pop    %esi
  80034d:	5f                   	pop    %edi
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	50                   	push   %eax
  800354:	6a 0c                	push   $0xc
  800356:	68 4a 10 80 00       	push   $0x80104a
  80035b:	6a 23                	push   $0x23
  80035d:	68 67 10 80 00       	push   $0x801067
  800362:	e8 00 00 00 00       	call   800367 <_panic>

00800367 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800367:	f3 0f 1e fb          	endbr32 
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800370:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800373:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800379:	e8 d8 fd ff ff       	call   800156 <sys_getenvid>
  80037e:	83 ec 0c             	sub    $0xc,%esp
  800381:	ff 75 0c             	pushl  0xc(%ebp)
  800384:	ff 75 08             	pushl  0x8(%ebp)
  800387:	56                   	push   %esi
  800388:	50                   	push   %eax
  800389:	68 78 10 80 00       	push   $0x801078
  80038e:	e8 bb 00 00 00       	call   80044e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800393:	83 c4 18             	add    $0x18,%esp
  800396:	53                   	push   %ebx
  800397:	ff 75 10             	pushl  0x10(%ebp)
  80039a:	e8 5a 00 00 00       	call   8003f9 <vcprintf>
	cprintf("\n");
  80039f:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  8003a6:	e8 a3 00 00 00       	call   80044e <cprintf>
  8003ab:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003ae:	cc                   	int3   
  8003af:	eb fd                	jmp    8003ae <_panic+0x47>

008003b1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003b1:	f3 0f 1e fb          	endbr32 
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	53                   	push   %ebx
  8003b9:	83 ec 04             	sub    $0x4,%esp
  8003bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003bf:	8b 13                	mov    (%ebx),%edx
  8003c1:	8d 42 01             	lea    0x1(%edx),%eax
  8003c4:	89 03                	mov    %eax,(%ebx)
  8003c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003cd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003d2:	74 09                	je     8003dd <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003d4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003db:	c9                   	leave  
  8003dc:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003dd:	83 ec 08             	sub    $0x8,%esp
  8003e0:	68 ff 00 00 00       	push   $0xff
  8003e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8003e8:	50                   	push   %eax
  8003e9:	e8 de fc ff ff       	call   8000cc <sys_cputs>
		b->idx = 0;
  8003ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003f4:	83 c4 10             	add    $0x10,%esp
  8003f7:	eb db                	jmp    8003d4 <putch+0x23>

008003f9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003f9:	f3 0f 1e fb          	endbr32 
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800406:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80040d:	00 00 00 
	b.cnt = 0;
  800410:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800417:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80041a:	ff 75 0c             	pushl  0xc(%ebp)
  80041d:	ff 75 08             	pushl  0x8(%ebp)
  800420:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800426:	50                   	push   %eax
  800427:	68 b1 03 80 00       	push   $0x8003b1
  80042c:	e8 20 01 00 00       	call   800551 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800431:	83 c4 08             	add    $0x8,%esp
  800434:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80043a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800440:	50                   	push   %eax
  800441:	e8 86 fc ff ff       	call   8000cc <sys_cputs>

	return b.cnt;
}
  800446:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80044c:	c9                   	leave  
  80044d:	c3                   	ret    

0080044e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80044e:	f3 0f 1e fb          	endbr32 
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800458:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80045b:	50                   	push   %eax
  80045c:	ff 75 08             	pushl  0x8(%ebp)
  80045f:	e8 95 ff ff ff       	call   8003f9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	57                   	push   %edi
  80046a:	56                   	push   %esi
  80046b:	53                   	push   %ebx
  80046c:	83 ec 1c             	sub    $0x1c,%esp
  80046f:	89 c7                	mov    %eax,%edi
  800471:	89 d6                	mov    %edx,%esi
  800473:	8b 45 08             	mov    0x8(%ebp),%eax
  800476:	8b 55 0c             	mov    0xc(%ebp),%edx
  800479:	89 d1                	mov    %edx,%ecx
  80047b:	89 c2                	mov    %eax,%edx
  80047d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800480:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800483:	8b 45 10             	mov    0x10(%ebp),%eax
  800486:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800489:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800493:	39 c2                	cmp    %eax,%edx
  800495:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800498:	72 3e                	jb     8004d8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80049a:	83 ec 0c             	sub    $0xc,%esp
  80049d:	ff 75 18             	pushl  0x18(%ebp)
  8004a0:	83 eb 01             	sub    $0x1,%ebx
  8004a3:	53                   	push   %ebx
  8004a4:	50                   	push   %eax
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b4:	e8 17 09 00 00       	call   800dd0 <__udivdi3>
  8004b9:	83 c4 18             	add    $0x18,%esp
  8004bc:	52                   	push   %edx
  8004bd:	50                   	push   %eax
  8004be:	89 f2                	mov    %esi,%edx
  8004c0:	89 f8                	mov    %edi,%eax
  8004c2:	e8 9f ff ff ff       	call   800466 <printnum>
  8004c7:	83 c4 20             	add    $0x20,%esp
  8004ca:	eb 13                	jmp    8004df <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	56                   	push   %esi
  8004d0:	ff 75 18             	pushl  0x18(%ebp)
  8004d3:	ff d7                	call   *%edi
  8004d5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004d8:	83 eb 01             	sub    $0x1,%ebx
  8004db:	85 db                	test   %ebx,%ebx
  8004dd:	7f ed                	jg     8004cc <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	56                   	push   %esi
  8004e3:	83 ec 04             	sub    $0x4,%esp
  8004e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8004f2:	e8 e9 09 00 00       	call   800ee0 <__umoddi3>
  8004f7:	83 c4 14             	add    $0x14,%esp
  8004fa:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  800501:	50                   	push   %eax
  800502:	ff d7                	call   *%edi
}
  800504:	83 c4 10             	add    $0x10,%esp
  800507:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80050a:	5b                   	pop    %ebx
  80050b:	5e                   	pop    %esi
  80050c:	5f                   	pop    %edi
  80050d:	5d                   	pop    %ebp
  80050e:	c3                   	ret    

0080050f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80050f:	f3 0f 1e fb          	endbr32 
  800513:	55                   	push   %ebp
  800514:	89 e5                	mov    %esp,%ebp
  800516:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800519:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80051d:	8b 10                	mov    (%eax),%edx
  80051f:	3b 50 04             	cmp    0x4(%eax),%edx
  800522:	73 0a                	jae    80052e <sprintputch+0x1f>
		*b->buf++ = ch;
  800524:	8d 4a 01             	lea    0x1(%edx),%ecx
  800527:	89 08                	mov    %ecx,(%eax)
  800529:	8b 45 08             	mov    0x8(%ebp),%eax
  80052c:	88 02                	mov    %al,(%edx)
}
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    

00800530 <printfmt>:
{
  800530:	f3 0f 1e fb          	endbr32 
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80053a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80053d:	50                   	push   %eax
  80053e:	ff 75 10             	pushl  0x10(%ebp)
  800541:	ff 75 0c             	pushl  0xc(%ebp)
  800544:	ff 75 08             	pushl  0x8(%ebp)
  800547:	e8 05 00 00 00       	call   800551 <vprintfmt>
}
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	c9                   	leave  
  800550:	c3                   	ret    

00800551 <vprintfmt>:
{
  800551:	f3 0f 1e fb          	endbr32 
  800555:	55                   	push   %ebp
  800556:	89 e5                	mov    %esp,%ebp
  800558:	57                   	push   %edi
  800559:	56                   	push   %esi
  80055a:	53                   	push   %ebx
  80055b:	83 ec 3c             	sub    $0x3c,%esp
  80055e:	8b 75 08             	mov    0x8(%ebp),%esi
  800561:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800564:	8b 7d 10             	mov    0x10(%ebp),%edi
  800567:	e9 8e 03 00 00       	jmp    8008fa <vprintfmt+0x3a9>
		padc = ' ';
  80056c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800570:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800577:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80057e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800585:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8d 47 01             	lea    0x1(%edi),%eax
  80058d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800590:	0f b6 17             	movzbl (%edi),%edx
  800593:	8d 42 dd             	lea    -0x23(%edx),%eax
  800596:	3c 55                	cmp    $0x55,%al
  800598:	0f 87 df 03 00 00    	ja     80097d <vprintfmt+0x42c>
  80059e:	0f b6 c0             	movzbl %al,%eax
  8005a1:	3e ff 24 85 60 11 80 	notrack jmp *0x801160(,%eax,4)
  8005a8:	00 
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005ac:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005b0:	eb d8                	jmp    80058a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b5:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005b9:	eb cf                	jmp    80058a <vprintfmt+0x39>
  8005bb:	0f b6 d2             	movzbl %dl,%edx
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005c9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005cc:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005d0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005d3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005d6:	83 f9 09             	cmp    $0x9,%ecx
  8005d9:	77 55                	ja     800630 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005db:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005de:	eb e9                	jmp    8005c9 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ee:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f8:	79 90                	jns    80058a <vprintfmt+0x39>
				width = precision, precision = -1;
  8005fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800600:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800607:	eb 81                	jmp    80058a <vprintfmt+0x39>
  800609:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060c:	85 c0                	test   %eax,%eax
  80060e:	ba 00 00 00 00       	mov    $0x0,%edx
  800613:	0f 49 d0             	cmovns %eax,%edx
  800616:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80061c:	e9 69 ff ff ff       	jmp    80058a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800624:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80062b:	e9 5a ff ff ff       	jmp    80058a <vprintfmt+0x39>
  800630:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800633:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800636:	eb bc                	jmp    8005f4 <vprintfmt+0xa3>
			lflag++;
  800638:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80063e:	e9 47 ff ff ff       	jmp    80058a <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 78 04             	lea    0x4(%eax),%edi
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	ff 30                	pushl  (%eax)
  80064f:	ff d6                	call   *%esi
			break;
  800651:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800654:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800657:	e9 9b 02 00 00       	jmp    8008f7 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 78 04             	lea    0x4(%eax),%edi
  800662:	8b 00                	mov    (%eax),%eax
  800664:	99                   	cltd   
  800665:	31 d0                	xor    %edx,%eax
  800667:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800669:	83 f8 08             	cmp    $0x8,%eax
  80066c:	7f 23                	jg     800691 <vprintfmt+0x140>
  80066e:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  800675:	85 d2                	test   %edx,%edx
  800677:	74 18                	je     800691 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800679:	52                   	push   %edx
  80067a:	68 be 10 80 00       	push   $0x8010be
  80067f:	53                   	push   %ebx
  800680:	56                   	push   %esi
  800681:	e8 aa fe ff ff       	call   800530 <printfmt>
  800686:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800689:	89 7d 14             	mov    %edi,0x14(%ebp)
  80068c:	e9 66 02 00 00       	jmp    8008f7 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800691:	50                   	push   %eax
  800692:	68 b5 10 80 00       	push   $0x8010b5
  800697:	53                   	push   %ebx
  800698:	56                   	push   %esi
  800699:	e8 92 fe ff ff       	call   800530 <printfmt>
  80069e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006a1:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006a4:	e9 4e 02 00 00       	jmp    8008f7 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	83 c0 04             	add    $0x4,%eax
  8006af:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006b7:	85 d2                	test   %edx,%edx
  8006b9:	b8 ae 10 80 00       	mov    $0x8010ae,%eax
  8006be:	0f 45 c2             	cmovne %edx,%eax
  8006c1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c8:	7e 06                	jle    8006d0 <vprintfmt+0x17f>
  8006ca:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006ce:	75 0d                	jne    8006dd <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006d3:	89 c7                	mov    %eax,%edi
  8006d5:	03 45 e0             	add    -0x20(%ebp),%eax
  8006d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006db:	eb 55                	jmp    800732 <vprintfmt+0x1e1>
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e3:	ff 75 cc             	pushl  -0x34(%ebp)
  8006e6:	e8 46 03 00 00       	call   800a31 <strnlen>
  8006eb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006ee:	29 c2                	sub    %eax,%edx
  8006f0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006f3:	83 c4 10             	add    $0x10,%esp
  8006f6:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006f8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ff:	85 ff                	test   %edi,%edi
  800701:	7e 11                	jle    800714 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	53                   	push   %ebx
  800707:	ff 75 e0             	pushl  -0x20(%ebp)
  80070a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80070c:	83 ef 01             	sub    $0x1,%edi
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	eb eb                	jmp    8006ff <vprintfmt+0x1ae>
  800714:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800717:	85 d2                	test   %edx,%edx
  800719:	b8 00 00 00 00       	mov    $0x0,%eax
  80071e:	0f 49 c2             	cmovns %edx,%eax
  800721:	29 c2                	sub    %eax,%edx
  800723:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800726:	eb a8                	jmp    8006d0 <vprintfmt+0x17f>
					putch(ch, putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	53                   	push   %ebx
  80072c:	52                   	push   %edx
  80072d:	ff d6                	call   *%esi
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800735:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800737:	83 c7 01             	add    $0x1,%edi
  80073a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073e:	0f be d0             	movsbl %al,%edx
  800741:	85 d2                	test   %edx,%edx
  800743:	74 4b                	je     800790 <vprintfmt+0x23f>
  800745:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800749:	78 06                	js     800751 <vprintfmt+0x200>
  80074b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80074f:	78 1e                	js     80076f <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800751:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800755:	74 d1                	je     800728 <vprintfmt+0x1d7>
  800757:	0f be c0             	movsbl %al,%eax
  80075a:	83 e8 20             	sub    $0x20,%eax
  80075d:	83 f8 5e             	cmp    $0x5e,%eax
  800760:	76 c6                	jbe    800728 <vprintfmt+0x1d7>
					putch('?', putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	53                   	push   %ebx
  800766:	6a 3f                	push   $0x3f
  800768:	ff d6                	call   *%esi
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	eb c3                	jmp    800732 <vprintfmt+0x1e1>
  80076f:	89 cf                	mov    %ecx,%edi
  800771:	eb 0e                	jmp    800781 <vprintfmt+0x230>
				putch(' ', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 20                	push   $0x20
  800779:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80077b:	83 ef 01             	sub    $0x1,%edi
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	85 ff                	test   %edi,%edi
  800783:	7f ee                	jg     800773 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800785:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800788:	89 45 14             	mov    %eax,0x14(%ebp)
  80078b:	e9 67 01 00 00       	jmp    8008f7 <vprintfmt+0x3a6>
  800790:	89 cf                	mov    %ecx,%edi
  800792:	eb ed                	jmp    800781 <vprintfmt+0x230>
	if (lflag >= 2)
  800794:	83 f9 01             	cmp    $0x1,%ecx
  800797:	7f 1b                	jg     8007b4 <vprintfmt+0x263>
	else if (lflag)
  800799:	85 c9                	test   %ecx,%ecx
  80079b:	74 63                	je     800800 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8b 00                	mov    (%eax),%eax
  8007a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a5:	99                   	cltd   
  8007a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ac:	8d 40 04             	lea    0x4(%eax),%eax
  8007af:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b2:	eb 17                	jmp    8007cb <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8b 50 04             	mov    0x4(%eax),%edx
  8007ba:	8b 00                	mov    (%eax),%eax
  8007bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 40 08             	lea    0x8(%eax),%eax
  8007c8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ce:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007d1:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007d6:	85 c9                	test   %ecx,%ecx
  8007d8:	0f 89 ff 00 00 00    	jns    8008dd <vprintfmt+0x38c>
				putch('-', putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	53                   	push   %ebx
  8007e2:	6a 2d                	push   $0x2d
  8007e4:	ff d6                	call   *%esi
				num = -(long long) num;
  8007e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ec:	f7 da                	neg    %edx
  8007ee:	83 d1 00             	adc    $0x0,%ecx
  8007f1:	f7 d9                	neg    %ecx
  8007f3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fb:	e9 dd 00 00 00       	jmp    8008dd <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8b 00                	mov    (%eax),%eax
  800805:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800808:	99                   	cltd   
  800809:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	8d 40 04             	lea    0x4(%eax),%eax
  800812:	89 45 14             	mov    %eax,0x14(%ebp)
  800815:	eb b4                	jmp    8007cb <vprintfmt+0x27a>
	if (lflag >= 2)
  800817:	83 f9 01             	cmp    $0x1,%ecx
  80081a:	7f 1e                	jg     80083a <vprintfmt+0x2e9>
	else if (lflag)
  80081c:	85 c9                	test   %ecx,%ecx
  80081e:	74 32                	je     800852 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800820:	8b 45 14             	mov    0x14(%ebp),%eax
  800823:	8b 10                	mov    (%eax),%edx
  800825:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082a:	8d 40 04             	lea    0x4(%eax),%eax
  80082d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800830:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800835:	e9 a3 00 00 00       	jmp    8008dd <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80083a:	8b 45 14             	mov    0x14(%ebp),%eax
  80083d:	8b 10                	mov    (%eax),%edx
  80083f:	8b 48 04             	mov    0x4(%eax),%ecx
  800842:	8d 40 08             	lea    0x8(%eax),%eax
  800845:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800848:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80084d:	e9 8b 00 00 00       	jmp    8008dd <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800852:	8b 45 14             	mov    0x14(%ebp),%eax
  800855:	8b 10                	mov    (%eax),%edx
  800857:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085c:	8d 40 04             	lea    0x4(%eax),%eax
  80085f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800862:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800867:	eb 74                	jmp    8008dd <vprintfmt+0x38c>
	if (lflag >= 2)
  800869:	83 f9 01             	cmp    $0x1,%ecx
  80086c:	7f 1b                	jg     800889 <vprintfmt+0x338>
	else if (lflag)
  80086e:	85 c9                	test   %ecx,%ecx
  800870:	74 2c                	je     80089e <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8b 10                	mov    (%eax),%edx
  800877:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087c:	8d 40 04             	lea    0x4(%eax),%eax
  80087f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800882:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800887:	eb 54                	jmp    8008dd <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800889:	8b 45 14             	mov    0x14(%ebp),%eax
  80088c:	8b 10                	mov    (%eax),%edx
  80088e:	8b 48 04             	mov    0x4(%eax),%ecx
  800891:	8d 40 08             	lea    0x8(%eax),%eax
  800894:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800897:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80089c:	eb 3f                	jmp    8008dd <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80089e:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a1:	8b 10                	mov    (%eax),%edx
  8008a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008a8:	8d 40 04             	lea    0x4(%eax),%eax
  8008ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008ae:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8008b3:	eb 28                	jmp    8008dd <vprintfmt+0x38c>
			putch('0', putdat);
  8008b5:	83 ec 08             	sub    $0x8,%esp
  8008b8:	53                   	push   %ebx
  8008b9:	6a 30                	push   $0x30
  8008bb:	ff d6                	call   *%esi
			putch('x', putdat);
  8008bd:	83 c4 08             	add    $0x8,%esp
  8008c0:	53                   	push   %ebx
  8008c1:	6a 78                	push   $0x78
  8008c3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	8b 10                	mov    (%eax),%edx
  8008ca:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008cf:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008d2:	8d 40 04             	lea    0x4(%eax),%eax
  8008d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008d8:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008dd:	83 ec 0c             	sub    $0xc,%esp
  8008e0:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008e4:	57                   	push   %edi
  8008e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8008e8:	50                   	push   %eax
  8008e9:	51                   	push   %ecx
  8008ea:	52                   	push   %edx
  8008eb:	89 da                	mov    %ebx,%edx
  8008ed:	89 f0                	mov    %esi,%eax
  8008ef:	e8 72 fb ff ff       	call   800466 <printnum>
			break;
  8008f4:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8008fa:	83 c7 01             	add    $0x1,%edi
  8008fd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800901:	83 f8 25             	cmp    $0x25,%eax
  800904:	0f 84 62 fc ff ff    	je     80056c <vprintfmt+0x1b>
			if (ch == '\0')										
  80090a:	85 c0                	test   %eax,%eax
  80090c:	0f 84 8b 00 00 00    	je     80099d <vprintfmt+0x44c>
			putch(ch, putdat);
  800912:	83 ec 08             	sub    $0x8,%esp
  800915:	53                   	push   %ebx
  800916:	50                   	push   %eax
  800917:	ff d6                	call   *%esi
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	eb dc                	jmp    8008fa <vprintfmt+0x3a9>
	if (lflag >= 2)
  80091e:	83 f9 01             	cmp    $0x1,%ecx
  800921:	7f 1b                	jg     80093e <vprintfmt+0x3ed>
	else if (lflag)
  800923:	85 c9                	test   %ecx,%ecx
  800925:	74 2c                	je     800953 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800927:	8b 45 14             	mov    0x14(%ebp),%eax
  80092a:	8b 10                	mov    (%eax),%edx
  80092c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800931:	8d 40 04             	lea    0x4(%eax),%eax
  800934:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800937:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80093c:	eb 9f                	jmp    8008dd <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8b 10                	mov    (%eax),%edx
  800943:	8b 48 04             	mov    0x4(%eax),%ecx
  800946:	8d 40 08             	lea    0x8(%eax),%eax
  800949:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80094c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800951:	eb 8a                	jmp    8008dd <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800953:	8b 45 14             	mov    0x14(%ebp),%eax
  800956:	8b 10                	mov    (%eax),%edx
  800958:	b9 00 00 00 00       	mov    $0x0,%ecx
  80095d:	8d 40 04             	lea    0x4(%eax),%eax
  800960:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800963:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800968:	e9 70 ff ff ff       	jmp    8008dd <vprintfmt+0x38c>
			putch(ch, putdat);
  80096d:	83 ec 08             	sub    $0x8,%esp
  800970:	53                   	push   %ebx
  800971:	6a 25                	push   $0x25
  800973:	ff d6                	call   *%esi
			break;
  800975:	83 c4 10             	add    $0x10,%esp
  800978:	e9 7a ff ff ff       	jmp    8008f7 <vprintfmt+0x3a6>
			putch('%', putdat);
  80097d:	83 ec 08             	sub    $0x8,%esp
  800980:	53                   	push   %ebx
  800981:	6a 25                	push   $0x25
  800983:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800985:	83 c4 10             	add    $0x10,%esp
  800988:	89 f8                	mov    %edi,%eax
  80098a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80098e:	74 05                	je     800995 <vprintfmt+0x444>
  800990:	83 e8 01             	sub    $0x1,%eax
  800993:	eb f5                	jmp    80098a <vprintfmt+0x439>
  800995:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800998:	e9 5a ff ff ff       	jmp    8008f7 <vprintfmt+0x3a6>
}
  80099d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009a5:	f3 0f 1e fb          	endbr32 
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 18             	sub    $0x18,%esp
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009b8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009bc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009c6:	85 c0                	test   %eax,%eax
  8009c8:	74 26                	je     8009f0 <vsnprintf+0x4b>
  8009ca:	85 d2                	test   %edx,%edx
  8009cc:	7e 22                	jle    8009f0 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ce:	ff 75 14             	pushl  0x14(%ebp)
  8009d1:	ff 75 10             	pushl  0x10(%ebp)
  8009d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009d7:	50                   	push   %eax
  8009d8:	68 0f 05 80 00       	push   $0x80050f
  8009dd:	e8 6f fb ff ff       	call   800551 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009e5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009eb:	83 c4 10             	add    $0x10,%esp
}
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    
		return -E_INVAL;
  8009f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009f5:	eb f7                	jmp    8009ee <vsnprintf+0x49>

008009f7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009f7:	f3 0f 1e fb          	endbr32 
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a01:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a04:	50                   	push   %eax
  800a05:	ff 75 10             	pushl  0x10(%ebp)
  800a08:	ff 75 0c             	pushl  0xc(%ebp)
  800a0b:	ff 75 08             	pushl  0x8(%ebp)
  800a0e:	e8 92 ff ff ff       	call   8009a5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a15:	f3 0f 1e fb          	endbr32 
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a28:	74 05                	je     800a2f <strlen+0x1a>
		n++;
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	eb f5                	jmp    800a24 <strlen+0xf>
	return n;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a31:	f3 0f 1e fb          	endbr32 
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a43:	39 d0                	cmp    %edx,%eax
  800a45:	74 0d                	je     800a54 <strnlen+0x23>
  800a47:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a4b:	74 05                	je     800a52 <strnlen+0x21>
		n++;
  800a4d:	83 c0 01             	add    $0x1,%eax
  800a50:	eb f1                	jmp    800a43 <strnlen+0x12>
  800a52:	89 c2                	mov    %eax,%edx
	return n;
}
  800a54:	89 d0                	mov    %edx,%eax
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a58:	f3 0f 1e fb          	endbr32 
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	53                   	push   %ebx
  800a60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a6f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a72:	83 c0 01             	add    $0x1,%eax
  800a75:	84 d2                	test   %dl,%dl
  800a77:	75 f2                	jne    800a6b <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a79:	89 c8                	mov    %ecx,%eax
  800a7b:	5b                   	pop    %ebx
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7e:	f3 0f 1e fb          	endbr32 
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	53                   	push   %ebx
  800a86:	83 ec 10             	sub    $0x10,%esp
  800a89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a8c:	53                   	push   %ebx
  800a8d:	e8 83 ff ff ff       	call   800a15 <strlen>
  800a92:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a95:	ff 75 0c             	pushl  0xc(%ebp)
  800a98:	01 d8                	add    %ebx,%eax
  800a9a:	50                   	push   %eax
  800a9b:	e8 b8 ff ff ff       	call   800a58 <strcpy>
	return dst;
}
  800aa0:	89 d8                	mov    %ebx,%eax
  800aa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa5:	c9                   	leave  
  800aa6:	c3                   	ret    

00800aa7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa7:	f3 0f 1e fb          	endbr32 
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab6:	89 f3                	mov    %esi,%ebx
  800ab8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800abb:	89 f0                	mov    %esi,%eax
  800abd:	39 d8                	cmp    %ebx,%eax
  800abf:	74 11                	je     800ad2 <strncpy+0x2b>
		*dst++ = *src;
  800ac1:	83 c0 01             	add    $0x1,%eax
  800ac4:	0f b6 0a             	movzbl (%edx),%ecx
  800ac7:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aca:	80 f9 01             	cmp    $0x1,%cl
  800acd:	83 da ff             	sbb    $0xffffffff,%edx
  800ad0:	eb eb                	jmp    800abd <strncpy+0x16>
	}
	return ret;
}
  800ad2:	89 f0                	mov    %esi,%eax
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad8:	f3 0f 1e fb          	endbr32 
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ae4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae7:	8b 55 10             	mov    0x10(%ebp),%edx
  800aea:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aec:	85 d2                	test   %edx,%edx
  800aee:	74 21                	je     800b11 <strlcpy+0x39>
  800af0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800af4:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800af6:	39 c2                	cmp    %eax,%edx
  800af8:	74 14                	je     800b0e <strlcpy+0x36>
  800afa:	0f b6 19             	movzbl (%ecx),%ebx
  800afd:	84 db                	test   %bl,%bl
  800aff:	74 0b                	je     800b0c <strlcpy+0x34>
			*dst++ = *src++;
  800b01:	83 c1 01             	add    $0x1,%ecx
  800b04:	83 c2 01             	add    $0x1,%edx
  800b07:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b0a:	eb ea                	jmp    800af6 <strlcpy+0x1e>
  800b0c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b0e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b11:	29 f0                	sub    %esi,%eax
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b17:	f3 0f 1e fb          	endbr32 
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b21:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b24:	0f b6 01             	movzbl (%ecx),%eax
  800b27:	84 c0                	test   %al,%al
  800b29:	74 0c                	je     800b37 <strcmp+0x20>
  800b2b:	3a 02                	cmp    (%edx),%al
  800b2d:	75 08                	jne    800b37 <strcmp+0x20>
		p++, q++;
  800b2f:	83 c1 01             	add    $0x1,%ecx
  800b32:	83 c2 01             	add    $0x1,%edx
  800b35:	eb ed                	jmp    800b24 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b37:	0f b6 c0             	movzbl %al,%eax
  800b3a:	0f b6 12             	movzbl (%edx),%edx
  800b3d:	29 d0                	sub    %edx,%eax
}
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b41:	f3 0f 1e fb          	endbr32 
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	53                   	push   %ebx
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4f:	89 c3                	mov    %eax,%ebx
  800b51:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b54:	eb 06                	jmp    800b5c <strncmp+0x1b>
		n--, p++, q++;
  800b56:	83 c0 01             	add    $0x1,%eax
  800b59:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b5c:	39 d8                	cmp    %ebx,%eax
  800b5e:	74 16                	je     800b76 <strncmp+0x35>
  800b60:	0f b6 08             	movzbl (%eax),%ecx
  800b63:	84 c9                	test   %cl,%cl
  800b65:	74 04                	je     800b6b <strncmp+0x2a>
  800b67:	3a 0a                	cmp    (%edx),%cl
  800b69:	74 eb                	je     800b56 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6b:	0f b6 00             	movzbl (%eax),%eax
  800b6e:	0f b6 12             	movzbl (%edx),%edx
  800b71:	29 d0                	sub    %edx,%eax
}
  800b73:	5b                   	pop    %ebx
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    
		return 0;
  800b76:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7b:	eb f6                	jmp    800b73 <strncmp+0x32>

00800b7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b7d:	f3 0f 1e fb          	endbr32 
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b8b:	0f b6 10             	movzbl (%eax),%edx
  800b8e:	84 d2                	test   %dl,%dl
  800b90:	74 09                	je     800b9b <strchr+0x1e>
		if (*s == c)
  800b92:	38 ca                	cmp    %cl,%dl
  800b94:	74 0a                	je     800ba0 <strchr+0x23>
	for (; *s; s++)
  800b96:	83 c0 01             	add    $0x1,%eax
  800b99:	eb f0                	jmp    800b8b <strchr+0xe>
			return (char *) s;
	return 0;
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ba2:	f3 0f 1e fb          	endbr32 
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bb3:	38 ca                	cmp    %cl,%dl
  800bb5:	74 09                	je     800bc0 <strfind+0x1e>
  800bb7:	84 d2                	test   %dl,%dl
  800bb9:	74 05                	je     800bc0 <strfind+0x1e>
	for (; *s; s++)
  800bbb:	83 c0 01             	add    $0x1,%eax
  800bbe:	eb f0                	jmp    800bb0 <strfind+0xe>
			break;
	return (char *) s;
}
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bc2:	f3 0f 1e fb          	endbr32 
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bd2:	85 c9                	test   %ecx,%ecx
  800bd4:	74 31                	je     800c07 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bd6:	89 f8                	mov    %edi,%eax
  800bd8:	09 c8                	or     %ecx,%eax
  800bda:	a8 03                	test   $0x3,%al
  800bdc:	75 23                	jne    800c01 <memset+0x3f>
		c &= 0xFF;
  800bde:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800be2:	89 d3                	mov    %edx,%ebx
  800be4:	c1 e3 08             	shl    $0x8,%ebx
  800be7:	89 d0                	mov    %edx,%eax
  800be9:	c1 e0 18             	shl    $0x18,%eax
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	c1 e6 10             	shl    $0x10,%esi
  800bf1:	09 f0                	or     %esi,%eax
  800bf3:	09 c2                	or     %eax,%edx
  800bf5:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bf7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bfa:	89 d0                	mov    %edx,%eax
  800bfc:	fc                   	cld    
  800bfd:	f3 ab                	rep stos %eax,%es:(%edi)
  800bff:	eb 06                	jmp    800c07 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c04:	fc                   	cld    
  800c05:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c07:	89 f8                	mov    %edi,%eax
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c0e:	f3 0f 1e fb          	endbr32 
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c20:	39 c6                	cmp    %eax,%esi
  800c22:	73 32                	jae    800c56 <memmove+0x48>
  800c24:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c27:	39 c2                	cmp    %eax,%edx
  800c29:	76 2b                	jbe    800c56 <memmove+0x48>
		s += n;
		d += n;
  800c2b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2e:	89 fe                	mov    %edi,%esi
  800c30:	09 ce                	or     %ecx,%esi
  800c32:	09 d6                	or     %edx,%esi
  800c34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c3a:	75 0e                	jne    800c4a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c3c:	83 ef 04             	sub    $0x4,%edi
  800c3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c42:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c45:	fd                   	std    
  800c46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c48:	eb 09                	jmp    800c53 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c4a:	83 ef 01             	sub    $0x1,%edi
  800c4d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c50:	fd                   	std    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c53:	fc                   	cld    
  800c54:	eb 1a                	jmp    800c70 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c56:	89 c2                	mov    %eax,%edx
  800c58:	09 ca                	or     %ecx,%edx
  800c5a:	09 f2                	or     %esi,%edx
  800c5c:	f6 c2 03             	test   $0x3,%dl
  800c5f:	75 0a                	jne    800c6b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c61:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c64:	89 c7                	mov    %eax,%edi
  800c66:	fc                   	cld    
  800c67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c69:	eb 05                	jmp    800c70 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c6b:	89 c7                	mov    %eax,%edi
  800c6d:	fc                   	cld    
  800c6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c74:	f3 0f 1e fb          	endbr32 
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c7e:	ff 75 10             	pushl  0x10(%ebp)
  800c81:	ff 75 0c             	pushl  0xc(%ebp)
  800c84:	ff 75 08             	pushl  0x8(%ebp)
  800c87:	e8 82 ff ff ff       	call   800c0e <memmove>
}
  800c8c:	c9                   	leave  
  800c8d:	c3                   	ret    

00800c8e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c8e:	f3 0f 1e fb          	endbr32 
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9d:	89 c6                	mov    %eax,%esi
  800c9f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ca2:	39 f0                	cmp    %esi,%eax
  800ca4:	74 1c                	je     800cc2 <memcmp+0x34>
		if (*s1 != *s2)
  800ca6:	0f b6 08             	movzbl (%eax),%ecx
  800ca9:	0f b6 1a             	movzbl (%edx),%ebx
  800cac:	38 d9                	cmp    %bl,%cl
  800cae:	75 08                	jne    800cb8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cb0:	83 c0 01             	add    $0x1,%eax
  800cb3:	83 c2 01             	add    $0x1,%edx
  800cb6:	eb ea                	jmp    800ca2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cb8:	0f b6 c1             	movzbl %cl,%eax
  800cbb:	0f b6 db             	movzbl %bl,%ebx
  800cbe:	29 d8                	sub    %ebx,%eax
  800cc0:	eb 05                	jmp    800cc7 <memcmp+0x39>
	}

	return 0;
  800cc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ccb:	f3 0f 1e fb          	endbr32 
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cd8:	89 c2                	mov    %eax,%edx
  800cda:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cdd:	39 d0                	cmp    %edx,%eax
  800cdf:	73 09                	jae    800cea <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ce1:	38 08                	cmp    %cl,(%eax)
  800ce3:	74 05                	je     800cea <memfind+0x1f>
	for (; s < ends; s++)
  800ce5:	83 c0 01             	add    $0x1,%eax
  800ce8:	eb f3                	jmp    800cdd <memfind+0x12>
			break;
	return (void *) s;
}
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cec:	f3 0f 1e fb          	endbr32 
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cfc:	eb 03                	jmp    800d01 <strtol+0x15>
		s++;
  800cfe:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d01:	0f b6 01             	movzbl (%ecx),%eax
  800d04:	3c 20                	cmp    $0x20,%al
  800d06:	74 f6                	je     800cfe <strtol+0x12>
  800d08:	3c 09                	cmp    $0x9,%al
  800d0a:	74 f2                	je     800cfe <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d0c:	3c 2b                	cmp    $0x2b,%al
  800d0e:	74 2a                	je     800d3a <strtol+0x4e>
	int neg = 0;
  800d10:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d15:	3c 2d                	cmp    $0x2d,%al
  800d17:	74 2b                	je     800d44 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d19:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d1f:	75 0f                	jne    800d30 <strtol+0x44>
  800d21:	80 39 30             	cmpb   $0x30,(%ecx)
  800d24:	74 28                	je     800d4e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d26:	85 db                	test   %ebx,%ebx
  800d28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d2d:	0f 44 d8             	cmove  %eax,%ebx
  800d30:	b8 00 00 00 00       	mov    $0x0,%eax
  800d35:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d38:	eb 46                	jmp    800d80 <strtol+0x94>
		s++;
  800d3a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d3d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d42:	eb d5                	jmp    800d19 <strtol+0x2d>
		s++, neg = 1;
  800d44:	83 c1 01             	add    $0x1,%ecx
  800d47:	bf 01 00 00 00       	mov    $0x1,%edi
  800d4c:	eb cb                	jmp    800d19 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d4e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d52:	74 0e                	je     800d62 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d54:	85 db                	test   %ebx,%ebx
  800d56:	75 d8                	jne    800d30 <strtol+0x44>
		s++, base = 8;
  800d58:	83 c1 01             	add    $0x1,%ecx
  800d5b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d60:	eb ce                	jmp    800d30 <strtol+0x44>
		s += 2, base = 16;
  800d62:	83 c1 02             	add    $0x2,%ecx
  800d65:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d6a:	eb c4                	jmp    800d30 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d6c:	0f be d2             	movsbl %dl,%edx
  800d6f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d72:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d75:	7d 3a                	jge    800db1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d77:	83 c1 01             	add    $0x1,%ecx
  800d7a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d7e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d80:	0f b6 11             	movzbl (%ecx),%edx
  800d83:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d86:	89 f3                	mov    %esi,%ebx
  800d88:	80 fb 09             	cmp    $0x9,%bl
  800d8b:	76 df                	jbe    800d6c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d8d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d90:	89 f3                	mov    %esi,%ebx
  800d92:	80 fb 19             	cmp    $0x19,%bl
  800d95:	77 08                	ja     800d9f <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d97:	0f be d2             	movsbl %dl,%edx
  800d9a:	83 ea 57             	sub    $0x57,%edx
  800d9d:	eb d3                	jmp    800d72 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d9f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800da2:	89 f3                	mov    %esi,%ebx
  800da4:	80 fb 19             	cmp    $0x19,%bl
  800da7:	77 08                	ja     800db1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800da9:	0f be d2             	movsbl %dl,%edx
  800dac:	83 ea 37             	sub    $0x37,%edx
  800daf:	eb c1                	jmp    800d72 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800db1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800db5:	74 05                	je     800dbc <strtol+0xd0>
		*endptr = (char *) s;
  800db7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dba:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dbc:	89 c2                	mov    %eax,%edx
  800dbe:	f7 da                	neg    %edx
  800dc0:	85 ff                	test   %edi,%edi
  800dc2:	0f 45 c2             	cmovne %edx,%eax
}
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    
  800dca:	66 90                	xchg   %ax,%ax
  800dcc:	66 90                	xchg   %ax,%ax
  800dce:	66 90                	xchg   %ax,%ax

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
