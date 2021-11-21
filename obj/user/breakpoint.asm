
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	f3 0f 1e fb          	endbr32 
  80003d:	55                   	push   %ebp
  80003e:	89 e5                	mov    %esp,%ebp
  800040:	56                   	push   %esi
  800041:	53                   	push   %ebx
  800042:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800045:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800048:	e8 d9 00 00 00       	call   800126 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80004d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800052:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800058:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005d:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800062:	85 db                	test   %ebx,%ebx
  800064:	7e 07                	jle    80006d <libmain+0x34>
		binaryname = argv[0];
  800066:	8b 06                	mov    (%esi),%eax
  800068:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006d:	83 ec 08             	sub    $0x8,%esp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	e8 bc ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800077:	e8 0a 00 00 00       	call   800086 <exit>
}
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800082:	5b                   	pop    %ebx
  800083:	5e                   	pop    %esi
  800084:	5d                   	pop    %ebp
  800085:	c3                   	ret    

00800086 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800086:	f3 0f 1e fb          	endbr32 
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800090:	6a 00                	push   $0x0
  800092:	e8 4a 00 00 00       	call   8000e1 <sys_env_destroy>
}
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	c9                   	leave  
  80009b:	c3                   	ret    

0080009c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009c:	f3 0f 1e fb          	endbr32 
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	89 c3                	mov    %eax,%ebx
  8000b3:	89 c7                	mov    %eax,%edi
  8000b5:	89 c6                	mov    %eax,%esi
  8000b7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_cgetc>:

int
sys_cgetc(void)
{
  8000be:	f3 0f 1e fb          	endbr32 
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d2:	89 d1                	mov    %edx,%ecx
  8000d4:	89 d3                	mov    %edx,%ebx
  8000d6:	89 d7                	mov    %edx,%edi
  8000d8:	89 d6                	mov    %edx,%esi
  8000da:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e1:	f3 0f 1e fb          	endbr32 
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fb:	89 cb                	mov    %ecx,%ebx
  8000fd:	89 cf                	mov    %ecx,%edi
  8000ff:	89 ce                	mov    %ecx,%esi
  800101:	cd 30                	int    $0x30
	if(check && ret > 0)
  800103:	85 c0                	test   %eax,%eax
  800105:	7f 08                	jg     80010f <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	50                   	push   %eax
  800113:	6a 03                	push   $0x3
  800115:	68 0a 10 80 00       	push   $0x80100a
  80011a:	6a 23                	push   $0x23
  80011c:	68 27 10 80 00       	push   $0x801027
  800121:	e8 11 02 00 00       	call   800337 <_panic>

00800126 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800126:	f3 0f 1e fb          	endbr32 
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	f3 0f 1e fb          	endbr32 
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800153:	ba 00 00 00 00       	mov    $0x0,%edx
  800158:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015d:	89 d1                	mov    %edx,%ecx
  80015f:	89 d3                	mov    %edx,%ebx
  800161:	89 d7                	mov    %edx,%edi
  800163:	89 d6                	mov    %edx,%esi
  800165:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016c:	f3 0f 1e fb          	endbr32 
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800184:	b8 04 00 00 00       	mov    $0x4,%eax
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7f 08                	jg     80019c <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800197:	5b                   	pop    %ebx
  800198:	5e                   	pop    %esi
  800199:	5f                   	pop    %edi
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	50                   	push   %eax
  8001a0:	6a 04                	push   $0x4
  8001a2:	68 0a 10 80 00       	push   $0x80100a
  8001a7:	6a 23                	push   $0x23
  8001a9:	68 27 10 80 00       	push   $0x801027
  8001ae:	e8 84 01 00 00       	call   800337 <_panic>

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	f3 0f 1e fb          	endbr32 
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	57                   	push   %edi
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8001c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ce:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	7f 08                	jg     8001e2 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001dd:	5b                   	pop    %ebx
  8001de:	5e                   	pop    %esi
  8001df:	5f                   	pop    %edi
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e2:	83 ec 0c             	sub    $0xc,%esp
  8001e5:	50                   	push   %eax
  8001e6:	6a 05                	push   $0x5
  8001e8:	68 0a 10 80 00       	push   $0x80100a
  8001ed:	6a 23                	push   $0x23
  8001ef:	68 27 10 80 00       	push   $0x801027
  8001f4:	e8 3e 01 00 00       	call   800337 <_panic>

008001f9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f9:	f3 0f 1e fb          	endbr32 
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	57                   	push   %edi
  800201:	56                   	push   %esi
  800202:	53                   	push   %ebx
  800203:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800206:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800211:	b8 06 00 00 00       	mov    $0x6,%eax
  800216:	89 df                	mov    %ebx,%edi
  800218:	89 de                	mov    %ebx,%esi
  80021a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80021c:	85 c0                	test   %eax,%eax
  80021e:	7f 08                	jg     800228 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800220:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	5f                   	pop    %edi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800228:	83 ec 0c             	sub    $0xc,%esp
  80022b:	50                   	push   %eax
  80022c:	6a 06                	push   $0x6
  80022e:	68 0a 10 80 00       	push   $0x80100a
  800233:	6a 23                	push   $0x23
  800235:	68 27 10 80 00       	push   $0x801027
  80023a:	e8 f8 00 00 00       	call   800337 <_panic>

0080023f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80023f:	f3 0f 1e fb          	endbr32 
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	57                   	push   %edi
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
  800249:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80024c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800251:	8b 55 08             	mov    0x8(%ebp),%edx
  800254:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800257:	b8 08 00 00 00       	mov    $0x8,%eax
  80025c:	89 df                	mov    %ebx,%edi
  80025e:	89 de                	mov    %ebx,%esi
  800260:	cd 30                	int    $0x30
	if(check && ret > 0)
  800262:	85 c0                	test   %eax,%eax
  800264:	7f 08                	jg     80026e <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800266:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800269:	5b                   	pop    %ebx
  80026a:	5e                   	pop    %esi
  80026b:	5f                   	pop    %edi
  80026c:	5d                   	pop    %ebp
  80026d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80026e:	83 ec 0c             	sub    $0xc,%esp
  800271:	50                   	push   %eax
  800272:	6a 08                	push   $0x8
  800274:	68 0a 10 80 00       	push   $0x80100a
  800279:	6a 23                	push   $0x23
  80027b:	68 27 10 80 00       	push   $0x801027
  800280:	e8 b2 00 00 00       	call   800337 <_panic>

00800285 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800285:	f3 0f 1e fb          	endbr32 
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	57                   	push   %edi
  80028d:	56                   	push   %esi
  80028e:	53                   	push   %ebx
  80028f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800292:	bb 00 00 00 00       	mov    $0x0,%ebx
  800297:	8b 55 08             	mov    0x8(%ebp),%edx
  80029a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029d:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a2:	89 df                	mov    %ebx,%edi
  8002a4:	89 de                	mov    %ebx,%esi
  8002a6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a8:	85 c0                	test   %eax,%eax
  8002aa:	7f 08                	jg     8002b4 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b4:	83 ec 0c             	sub    $0xc,%esp
  8002b7:	50                   	push   %eax
  8002b8:	6a 09                	push   $0x9
  8002ba:	68 0a 10 80 00       	push   $0x80100a
  8002bf:	6a 23                	push   $0x23
  8002c1:	68 27 10 80 00       	push   $0x801027
  8002c6:	e8 6c 00 00 00       	call   800337 <_panic>

008002cb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002cb:	f3 0f 1e fb          	endbr32 
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8002d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002db:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002e0:	be 00 00 00 00       	mov    $0x0,%esi
  8002e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002eb:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ed:	5b                   	pop    %ebx
  8002ee:	5e                   	pop    %esi
  8002ef:	5f                   	pop    %edi
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002f2:	f3 0f 1e fb          	endbr32 
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	57                   	push   %edi
  8002fa:	56                   	push   %esi
  8002fb:	53                   	push   %ebx
  8002fc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8002ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800304:	8b 55 08             	mov    0x8(%ebp),%edx
  800307:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030c:	89 cb                	mov    %ecx,%ebx
  80030e:	89 cf                	mov    %ecx,%edi
  800310:	89 ce                	mov    %ecx,%esi
  800312:	cd 30                	int    $0x30
	if(check && ret > 0)
  800314:	85 c0                	test   %eax,%eax
  800316:	7f 08                	jg     800320 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800318:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	50                   	push   %eax
  800324:	6a 0c                	push   $0xc
  800326:	68 0a 10 80 00       	push   $0x80100a
  80032b:	6a 23                	push   $0x23
  80032d:	68 27 10 80 00       	push   $0x801027
  800332:	e8 00 00 00 00       	call   800337 <_panic>

00800337 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800337:	f3 0f 1e fb          	endbr32 
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800340:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800343:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800349:	e8 d8 fd ff ff       	call   800126 <sys_getenvid>
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	ff 75 0c             	pushl  0xc(%ebp)
  800354:	ff 75 08             	pushl  0x8(%ebp)
  800357:	56                   	push   %esi
  800358:	50                   	push   %eax
  800359:	68 38 10 80 00       	push   $0x801038
  80035e:	e8 bb 00 00 00       	call   80041e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800363:	83 c4 18             	add    $0x18,%esp
  800366:	53                   	push   %ebx
  800367:	ff 75 10             	pushl  0x10(%ebp)
  80036a:	e8 5a 00 00 00       	call   8003c9 <vcprintf>
	cprintf("\n");
  80036f:	c7 04 24 5b 10 80 00 	movl   $0x80105b,(%esp)
  800376:	e8 a3 00 00 00       	call   80041e <cprintf>
  80037b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037e:	cc                   	int3   
  80037f:	eb fd                	jmp    80037e <_panic+0x47>

00800381 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800381:	f3 0f 1e fb          	endbr32 
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	53                   	push   %ebx
  800389:	83 ec 04             	sub    $0x4,%esp
  80038c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038f:	8b 13                	mov    (%ebx),%edx
  800391:	8d 42 01             	lea    0x1(%edx),%eax
  800394:	89 03                	mov    %eax,(%ebx)
  800396:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800399:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a2:	74 09                	je     8003ad <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ab:	c9                   	leave  
  8003ac:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ad:	83 ec 08             	sub    $0x8,%esp
  8003b0:	68 ff 00 00 00       	push   $0xff
  8003b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b8:	50                   	push   %eax
  8003b9:	e8 de fc ff ff       	call   80009c <sys_cputs>
		b->idx = 0;
  8003be:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c4:	83 c4 10             	add    $0x10,%esp
  8003c7:	eb db                	jmp    8003a4 <putch+0x23>

008003c9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c9:	f3 0f 1e fb          	endbr32 
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003dd:	00 00 00 
	b.cnt = 0;
  8003e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ea:	ff 75 0c             	pushl  0xc(%ebp)
  8003ed:	ff 75 08             	pushl  0x8(%ebp)
  8003f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f6:	50                   	push   %eax
  8003f7:	68 81 03 80 00       	push   $0x800381
  8003fc:	e8 20 01 00 00       	call   800521 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800401:	83 c4 08             	add    $0x8,%esp
  800404:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80040a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800410:	50                   	push   %eax
  800411:	e8 86 fc ff ff       	call   80009c <sys_cputs>

	return b.cnt;
}
  800416:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041c:	c9                   	leave  
  80041d:	c3                   	ret    

0080041e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041e:	f3 0f 1e fb          	endbr32 
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800428:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80042b:	50                   	push   %eax
  80042c:	ff 75 08             	pushl  0x8(%ebp)
  80042f:	e8 95 ff ff ff       	call   8003c9 <vcprintf>
	va_end(ap);

	return cnt;
}
  800434:	c9                   	leave  
  800435:	c3                   	ret    

00800436 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	57                   	push   %edi
  80043a:	56                   	push   %esi
  80043b:	53                   	push   %ebx
  80043c:	83 ec 1c             	sub    $0x1c,%esp
  80043f:	89 c7                	mov    %eax,%edi
  800441:	89 d6                	mov    %edx,%esi
  800443:	8b 45 08             	mov    0x8(%ebp),%eax
  800446:	8b 55 0c             	mov    0xc(%ebp),%edx
  800449:	89 d1                	mov    %edx,%ecx
  80044b:	89 c2                	mov    %eax,%edx
  80044d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800450:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800453:	8b 45 10             	mov    0x10(%ebp),%eax
  800456:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800459:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800463:	39 c2                	cmp    %eax,%edx
  800465:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800468:	72 3e                	jb     8004a8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046a:	83 ec 0c             	sub    $0xc,%esp
  80046d:	ff 75 18             	pushl  0x18(%ebp)
  800470:	83 eb 01             	sub    $0x1,%ebx
  800473:	53                   	push   %ebx
  800474:	50                   	push   %eax
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047b:	ff 75 e0             	pushl  -0x20(%ebp)
  80047e:	ff 75 dc             	pushl  -0x24(%ebp)
  800481:	ff 75 d8             	pushl  -0x28(%ebp)
  800484:	e8 17 09 00 00       	call   800da0 <__udivdi3>
  800489:	83 c4 18             	add    $0x18,%esp
  80048c:	52                   	push   %edx
  80048d:	50                   	push   %eax
  80048e:	89 f2                	mov    %esi,%edx
  800490:	89 f8                	mov    %edi,%eax
  800492:	e8 9f ff ff ff       	call   800436 <printnum>
  800497:	83 c4 20             	add    $0x20,%esp
  80049a:	eb 13                	jmp    8004af <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	56                   	push   %esi
  8004a0:	ff 75 18             	pushl  0x18(%ebp)
  8004a3:	ff d7                	call   *%edi
  8004a5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004a8:	83 eb 01             	sub    $0x1,%ebx
  8004ab:	85 db                	test   %ebx,%ebx
  8004ad:	7f ed                	jg     80049c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	56                   	push   %esi
  8004b3:	83 ec 04             	sub    $0x4,%esp
  8004b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8004bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c2:	e8 e9 09 00 00       	call   800eb0 <__umoddi3>
  8004c7:	83 c4 14             	add    $0x14,%esp
  8004ca:	0f be 80 5d 10 80 00 	movsbl 0x80105d(%eax),%eax
  8004d1:	50                   	push   %eax
  8004d2:	ff d7                	call   *%edi
}
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004da:	5b                   	pop    %ebx
  8004db:	5e                   	pop    %esi
  8004dc:	5f                   	pop    %edi
  8004dd:	5d                   	pop    %ebp
  8004de:	c3                   	ret    

008004df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004df:	f3 0f 1e fb          	endbr32 
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ed:	8b 10                	mov    (%eax),%edx
  8004ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f2:	73 0a                	jae    8004fe <sprintputch+0x1f>
		*b->buf++ = ch;
  8004f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f7:	89 08                	mov    %ecx,(%eax)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	88 02                	mov    %al,(%edx)
}
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <printfmt>:
{
  800500:	f3 0f 1e fb          	endbr32 
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80050a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050d:	50                   	push   %eax
  80050e:	ff 75 10             	pushl  0x10(%ebp)
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	ff 75 08             	pushl  0x8(%ebp)
  800517:	e8 05 00 00 00       	call   800521 <vprintfmt>
}
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	c9                   	leave  
  800520:	c3                   	ret    

00800521 <vprintfmt>:
{
  800521:	f3 0f 1e fb          	endbr32 
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	57                   	push   %edi
  800529:	56                   	push   %esi
  80052a:	53                   	push   %ebx
  80052b:	83 ec 3c             	sub    $0x3c,%esp
  80052e:	8b 75 08             	mov    0x8(%ebp),%esi
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800534:	8b 7d 10             	mov    0x10(%ebp),%edi
  800537:	e9 8e 03 00 00       	jmp    8008ca <vprintfmt+0x3a9>
		padc = ' ';
  80053c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800540:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800547:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80054e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800555:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8d 47 01             	lea    0x1(%edi),%eax
  80055d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800560:	0f b6 17             	movzbl (%edi),%edx
  800563:	8d 42 dd             	lea    -0x23(%edx),%eax
  800566:	3c 55                	cmp    $0x55,%al
  800568:	0f 87 df 03 00 00    	ja     80094d <vprintfmt+0x42c>
  80056e:	0f b6 c0             	movzbl %al,%eax
  800571:	3e ff 24 85 20 11 80 	notrack jmp *0x801120(,%eax,4)
  800578:	00 
  800579:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80057c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800580:	eb d8                	jmp    80055a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800585:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800589:	eb cf                	jmp    80055a <vprintfmt+0x39>
  80058b:	0f b6 d2             	movzbl %dl,%edx
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800591:	b8 00 00 00 00       	mov    $0x0,%eax
  800596:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800599:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a6:	83 f9 09             	cmp    $0x9,%ecx
  8005a9:	77 55                	ja     800600 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005ae:	eb e9                	jmp    800599 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 40 04             	lea    0x4(%eax),%eax
  8005be:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c8:	79 90                	jns    80055a <vprintfmt+0x39>
				width = precision, precision = -1;
  8005ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d7:	eb 81                	jmp    80055a <vprintfmt+0x39>
  8005d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e3:	0f 49 d0             	cmovns %eax,%edx
  8005e6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005ec:	e9 69 ff ff ff       	jmp    80055a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005fb:	e9 5a ff ff ff       	jmp    80055a <vprintfmt+0x39>
  800600:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	eb bc                	jmp    8005c4 <vprintfmt+0xa3>
			lflag++;
  800608:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80060e:	e9 47 ff ff ff       	jmp    80055a <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8d 78 04             	lea    0x4(%eax),%edi
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	ff 30                	pushl  (%eax)
  80061f:	ff d6                	call   *%esi
			break;
  800621:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800624:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800627:	e9 9b 02 00 00       	jmp    8008c7 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 78 04             	lea    0x4(%eax),%edi
  800632:	8b 00                	mov    (%eax),%eax
  800634:	99                   	cltd   
  800635:	31 d0                	xor    %edx,%eax
  800637:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800639:	83 f8 08             	cmp    $0x8,%eax
  80063c:	7f 23                	jg     800661 <vprintfmt+0x140>
  80063e:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  800645:	85 d2                	test   %edx,%edx
  800647:	74 18                	je     800661 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800649:	52                   	push   %edx
  80064a:	68 7e 10 80 00       	push   $0x80107e
  80064f:	53                   	push   %ebx
  800650:	56                   	push   %esi
  800651:	e8 aa fe ff ff       	call   800500 <printfmt>
  800656:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800659:	89 7d 14             	mov    %edi,0x14(%ebp)
  80065c:	e9 66 02 00 00       	jmp    8008c7 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800661:	50                   	push   %eax
  800662:	68 75 10 80 00       	push   $0x801075
  800667:	53                   	push   %ebx
  800668:	56                   	push   %esi
  800669:	e8 92 fe ff ff       	call   800500 <printfmt>
  80066e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800671:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800674:	e9 4e 02 00 00       	jmp    8008c7 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	83 c0 04             	add    $0x4,%eax
  80067f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800687:	85 d2                	test   %edx,%edx
  800689:	b8 6e 10 80 00       	mov    $0x80106e,%eax
  80068e:	0f 45 c2             	cmovne %edx,%eax
  800691:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800694:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800698:	7e 06                	jle    8006a0 <vprintfmt+0x17f>
  80069a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80069e:	75 0d                	jne    8006ad <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a3:	89 c7                	mov    %eax,%edi
  8006a5:	03 45 e0             	add    -0x20(%ebp),%eax
  8006a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ab:	eb 55                	jmp    800702 <vprintfmt+0x1e1>
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b3:	ff 75 cc             	pushl  -0x34(%ebp)
  8006b6:	e8 46 03 00 00       	call   800a01 <strnlen>
  8006bb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006be:	29 c2                	sub    %eax,%edx
  8006c0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006c8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	85 ff                	test   %edi,%edi
  8006d1:	7e 11                	jle    8006e4 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006da:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dc:	83 ef 01             	sub    $0x1,%edi
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	eb eb                	jmp    8006cf <vprintfmt+0x1ae>
  8006e4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006e7:	85 d2                	test   %edx,%edx
  8006e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ee:	0f 49 c2             	cmovns %edx,%eax
  8006f1:	29 c2                	sub    %eax,%edx
  8006f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006f6:	eb a8                	jmp    8006a0 <vprintfmt+0x17f>
					putch(ch, putdat);
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	53                   	push   %ebx
  8006fc:	52                   	push   %edx
  8006fd:	ff d6                	call   *%esi
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800705:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800707:	83 c7 01             	add    $0x1,%edi
  80070a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070e:	0f be d0             	movsbl %al,%edx
  800711:	85 d2                	test   %edx,%edx
  800713:	74 4b                	je     800760 <vprintfmt+0x23f>
  800715:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800719:	78 06                	js     800721 <vprintfmt+0x200>
  80071b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80071f:	78 1e                	js     80073f <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800721:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800725:	74 d1                	je     8006f8 <vprintfmt+0x1d7>
  800727:	0f be c0             	movsbl %al,%eax
  80072a:	83 e8 20             	sub    $0x20,%eax
  80072d:	83 f8 5e             	cmp    $0x5e,%eax
  800730:	76 c6                	jbe    8006f8 <vprintfmt+0x1d7>
					putch('?', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	53                   	push   %ebx
  800736:	6a 3f                	push   $0x3f
  800738:	ff d6                	call   *%esi
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	eb c3                	jmp    800702 <vprintfmt+0x1e1>
  80073f:	89 cf                	mov    %ecx,%edi
  800741:	eb 0e                	jmp    800751 <vprintfmt+0x230>
				putch(' ', putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	53                   	push   %ebx
  800747:	6a 20                	push   $0x20
  800749:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80074b:	83 ef 01             	sub    $0x1,%edi
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	85 ff                	test   %edi,%edi
  800753:	7f ee                	jg     800743 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800755:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800758:	89 45 14             	mov    %eax,0x14(%ebp)
  80075b:	e9 67 01 00 00       	jmp    8008c7 <vprintfmt+0x3a6>
  800760:	89 cf                	mov    %ecx,%edi
  800762:	eb ed                	jmp    800751 <vprintfmt+0x230>
	if (lflag >= 2)
  800764:	83 f9 01             	cmp    $0x1,%ecx
  800767:	7f 1b                	jg     800784 <vprintfmt+0x263>
	else if (lflag)
  800769:	85 c9                	test   %ecx,%ecx
  80076b:	74 63                	je     8007d0 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80076d:	8b 45 14             	mov    0x14(%ebp),%eax
  800770:	8b 00                	mov    (%eax),%eax
  800772:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800775:	99                   	cltd   
  800776:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8d 40 04             	lea    0x4(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
  800782:	eb 17                	jmp    80079b <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8b 50 04             	mov    0x4(%eax),%edx
  80078a:	8b 00                	mov    (%eax),%eax
  80078c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8d 40 08             	lea    0x8(%eax),%eax
  800798:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80079b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80079e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007a1:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007a6:	85 c9                	test   %ecx,%ecx
  8007a8:	0f 89 ff 00 00 00    	jns    8008ad <vprintfmt+0x38c>
				putch('-', putdat);
  8007ae:	83 ec 08             	sub    $0x8,%esp
  8007b1:	53                   	push   %ebx
  8007b2:	6a 2d                	push   $0x2d
  8007b4:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007bc:	f7 da                	neg    %edx
  8007be:	83 d1 00             	adc    $0x0,%ecx
  8007c1:	f7 d9                	neg    %ecx
  8007c3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007cb:	e9 dd 00 00 00       	jmp    8008ad <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8b 00                	mov    (%eax),%eax
  8007d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d8:	99                   	cltd   
  8007d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8d 40 04             	lea    0x4(%eax),%eax
  8007e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e5:	eb b4                	jmp    80079b <vprintfmt+0x27a>
	if (lflag >= 2)
  8007e7:	83 f9 01             	cmp    $0x1,%ecx
  8007ea:	7f 1e                	jg     80080a <vprintfmt+0x2e9>
	else if (lflag)
  8007ec:	85 c9                	test   %ecx,%ecx
  8007ee:	74 32                	je     800822 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8b 10                	mov    (%eax),%edx
  8007f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fa:	8d 40 04             	lea    0x4(%eax),%eax
  8007fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800800:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800805:	e9 a3 00 00 00       	jmp    8008ad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80080a:	8b 45 14             	mov    0x14(%ebp),%eax
  80080d:	8b 10                	mov    (%eax),%edx
  80080f:	8b 48 04             	mov    0x4(%eax),%ecx
  800812:	8d 40 08             	lea    0x8(%eax),%eax
  800815:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800818:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80081d:	e9 8b 00 00 00       	jmp    8008ad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8b 10                	mov    (%eax),%edx
  800827:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082c:	8d 40 04             	lea    0x4(%eax),%eax
  80082f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800832:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800837:	eb 74                	jmp    8008ad <vprintfmt+0x38c>
	if (lflag >= 2)
  800839:	83 f9 01             	cmp    $0x1,%ecx
  80083c:	7f 1b                	jg     800859 <vprintfmt+0x338>
	else if (lflag)
  80083e:	85 c9                	test   %ecx,%ecx
  800840:	74 2c                	je     80086e <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8b 10                	mov    (%eax),%edx
  800847:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084c:	8d 40 04             	lea    0x4(%eax),%eax
  80084f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800852:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800857:	eb 54                	jmp    8008ad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800859:	8b 45 14             	mov    0x14(%ebp),%eax
  80085c:	8b 10                	mov    (%eax),%edx
  80085e:	8b 48 04             	mov    0x4(%eax),%ecx
  800861:	8d 40 08             	lea    0x8(%eax),%eax
  800864:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800867:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80086c:	eb 3f                	jmp    8008ad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8b 10                	mov    (%eax),%edx
  800873:	b9 00 00 00 00       	mov    $0x0,%ecx
  800878:	8d 40 04             	lea    0x4(%eax),%eax
  80087b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80087e:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800883:	eb 28                	jmp    8008ad <vprintfmt+0x38c>
			putch('0', putdat);
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	53                   	push   %ebx
  800889:	6a 30                	push   $0x30
  80088b:	ff d6                	call   *%esi
			putch('x', putdat);
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	6a 78                	push   $0x78
  800893:	ff d6                	call   *%esi
			num = (unsigned long long)
  800895:	8b 45 14             	mov    0x14(%ebp),%eax
  800898:	8b 10                	mov    (%eax),%edx
  80089a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80089f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008a2:	8d 40 04             	lea    0x4(%eax),%eax
  8008a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008a8:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008ad:	83 ec 0c             	sub    $0xc,%esp
  8008b0:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008b4:	57                   	push   %edi
  8008b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b8:	50                   	push   %eax
  8008b9:	51                   	push   %ecx
  8008ba:	52                   	push   %edx
  8008bb:	89 da                	mov    %ebx,%edx
  8008bd:	89 f0                	mov    %esi,%eax
  8008bf:	e8 72 fb ff ff       	call   800436 <printnum>
			break;
  8008c4:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8008ca:	83 c7 01             	add    $0x1,%edi
  8008cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008d1:	83 f8 25             	cmp    $0x25,%eax
  8008d4:	0f 84 62 fc ff ff    	je     80053c <vprintfmt+0x1b>
			if (ch == '\0')										
  8008da:	85 c0                	test   %eax,%eax
  8008dc:	0f 84 8b 00 00 00    	je     80096d <vprintfmt+0x44c>
			putch(ch, putdat);
  8008e2:	83 ec 08             	sub    $0x8,%esp
  8008e5:	53                   	push   %ebx
  8008e6:	50                   	push   %eax
  8008e7:	ff d6                	call   *%esi
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	eb dc                	jmp    8008ca <vprintfmt+0x3a9>
	if (lflag >= 2)
  8008ee:	83 f9 01             	cmp    $0x1,%ecx
  8008f1:	7f 1b                	jg     80090e <vprintfmt+0x3ed>
	else if (lflag)
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	74 2c                	je     800923 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8008f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fa:	8b 10                	mov    (%eax),%edx
  8008fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800901:	8d 40 04             	lea    0x4(%eax),%eax
  800904:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800907:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80090c:	eb 9f                	jmp    8008ad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80090e:	8b 45 14             	mov    0x14(%ebp),%eax
  800911:	8b 10                	mov    (%eax),%edx
  800913:	8b 48 04             	mov    0x4(%eax),%ecx
  800916:	8d 40 08             	lea    0x8(%eax),%eax
  800919:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800921:	eb 8a                	jmp    8008ad <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8b 10                	mov    (%eax),%edx
  800928:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092d:	8d 40 04             	lea    0x4(%eax),%eax
  800930:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800933:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800938:	e9 70 ff ff ff       	jmp    8008ad <vprintfmt+0x38c>
			putch(ch, putdat);
  80093d:	83 ec 08             	sub    $0x8,%esp
  800940:	53                   	push   %ebx
  800941:	6a 25                	push   $0x25
  800943:	ff d6                	call   *%esi
			break;
  800945:	83 c4 10             	add    $0x10,%esp
  800948:	e9 7a ff ff ff       	jmp    8008c7 <vprintfmt+0x3a6>
			putch('%', putdat);
  80094d:	83 ec 08             	sub    $0x8,%esp
  800950:	53                   	push   %ebx
  800951:	6a 25                	push   $0x25
  800953:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800955:	83 c4 10             	add    $0x10,%esp
  800958:	89 f8                	mov    %edi,%eax
  80095a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80095e:	74 05                	je     800965 <vprintfmt+0x444>
  800960:	83 e8 01             	sub    $0x1,%eax
  800963:	eb f5                	jmp    80095a <vprintfmt+0x439>
  800965:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800968:	e9 5a ff ff ff       	jmp    8008c7 <vprintfmt+0x3a6>
}
  80096d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5f                   	pop    %edi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800975:	f3 0f 1e fb          	endbr32 
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	83 ec 18             	sub    $0x18,%esp
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800985:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800988:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80098c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80098f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800996:	85 c0                	test   %eax,%eax
  800998:	74 26                	je     8009c0 <vsnprintf+0x4b>
  80099a:	85 d2                	test   %edx,%edx
  80099c:	7e 22                	jle    8009c0 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099e:	ff 75 14             	pushl  0x14(%ebp)
  8009a1:	ff 75 10             	pushl  0x10(%ebp)
  8009a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a7:	50                   	push   %eax
  8009a8:	68 df 04 80 00       	push   $0x8004df
  8009ad:	e8 6f fb ff ff       	call   800521 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009bb:	83 c4 10             	add    $0x10,%esp
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    
		return -E_INVAL;
  8009c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c5:	eb f7                	jmp    8009be <vsnprintf+0x49>

008009c7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c7:	f3 0f 1e fb          	endbr32 
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009d1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d4:	50                   	push   %eax
  8009d5:	ff 75 10             	pushl  0x10(%ebp)
  8009d8:	ff 75 0c             	pushl  0xc(%ebp)
  8009db:	ff 75 08             	pushl  0x8(%ebp)
  8009de:	e8 92 ff ff ff       	call   800975 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e5:	f3 0f 1e fb          	endbr32 
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f8:	74 05                	je     8009ff <strlen+0x1a>
		n++;
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	eb f5                	jmp    8009f4 <strlen+0xf>
	return n;
}
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a01:	f3 0f 1e fb          	endbr32 
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a13:	39 d0                	cmp    %edx,%eax
  800a15:	74 0d                	je     800a24 <strnlen+0x23>
  800a17:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a1b:	74 05                	je     800a22 <strnlen+0x21>
		n++;
  800a1d:	83 c0 01             	add    $0x1,%eax
  800a20:	eb f1                	jmp    800a13 <strnlen+0x12>
  800a22:	89 c2                	mov    %eax,%edx
	return n;
}
  800a24:	89 d0                	mov    %edx,%eax
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a28:	f3 0f 1e fb          	endbr32 
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	53                   	push   %ebx
  800a30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a3f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	84 d2                	test   %dl,%dl
  800a47:	75 f2                	jne    800a3b <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a49:	89 c8                	mov    %ecx,%eax
  800a4b:	5b                   	pop    %ebx
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a4e:	f3 0f 1e fb          	endbr32 
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	53                   	push   %ebx
  800a56:	83 ec 10             	sub    $0x10,%esp
  800a59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5c:	53                   	push   %ebx
  800a5d:	e8 83 ff ff ff       	call   8009e5 <strlen>
  800a62:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a65:	ff 75 0c             	pushl  0xc(%ebp)
  800a68:	01 d8                	add    %ebx,%eax
  800a6a:	50                   	push   %eax
  800a6b:	e8 b8 ff ff ff       	call   800a28 <strcpy>
	return dst;
}
  800a70:	89 d8                	mov    %ebx,%eax
  800a72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a75:	c9                   	leave  
  800a76:	c3                   	ret    

00800a77 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a77:	f3 0f 1e fb          	endbr32 
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 75 08             	mov    0x8(%ebp),%esi
  800a83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a86:	89 f3                	mov    %esi,%ebx
  800a88:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8b:	89 f0                	mov    %esi,%eax
  800a8d:	39 d8                	cmp    %ebx,%eax
  800a8f:	74 11                	je     800aa2 <strncpy+0x2b>
		*dst++ = *src;
  800a91:	83 c0 01             	add    $0x1,%eax
  800a94:	0f b6 0a             	movzbl (%edx),%ecx
  800a97:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a9a:	80 f9 01             	cmp    $0x1,%cl
  800a9d:	83 da ff             	sbb    $0xffffffff,%edx
  800aa0:	eb eb                	jmp    800a8d <strncpy+0x16>
	}
	return ret;
}
  800aa2:	89 f0                	mov    %esi,%eax
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa8:	f3 0f 1e fb          	endbr32 
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab7:	8b 55 10             	mov    0x10(%ebp),%edx
  800aba:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abc:	85 d2                	test   %edx,%edx
  800abe:	74 21                	je     800ae1 <strlcpy+0x39>
  800ac0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ac4:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800ac6:	39 c2                	cmp    %eax,%edx
  800ac8:	74 14                	je     800ade <strlcpy+0x36>
  800aca:	0f b6 19             	movzbl (%ecx),%ebx
  800acd:	84 db                	test   %bl,%bl
  800acf:	74 0b                	je     800adc <strlcpy+0x34>
			*dst++ = *src++;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	83 c2 01             	add    $0x1,%edx
  800ad7:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ada:	eb ea                	jmp    800ac6 <strlcpy+0x1e>
  800adc:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800ade:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ae1:	29 f0                	sub    %esi,%eax
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae7:	f3 0f 1e fb          	endbr32 
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800af4:	0f b6 01             	movzbl (%ecx),%eax
  800af7:	84 c0                	test   %al,%al
  800af9:	74 0c                	je     800b07 <strcmp+0x20>
  800afb:	3a 02                	cmp    (%edx),%al
  800afd:	75 08                	jne    800b07 <strcmp+0x20>
		p++, q++;
  800aff:	83 c1 01             	add    $0x1,%ecx
  800b02:	83 c2 01             	add    $0x1,%edx
  800b05:	eb ed                	jmp    800af4 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b07:	0f b6 c0             	movzbl %al,%eax
  800b0a:	0f b6 12             	movzbl (%edx),%edx
  800b0d:	29 d0                	sub    %edx,%eax
}
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b11:	f3 0f 1e fb          	endbr32 
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	53                   	push   %ebx
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1f:	89 c3                	mov    %eax,%ebx
  800b21:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b24:	eb 06                	jmp    800b2c <strncmp+0x1b>
		n--, p++, q++;
  800b26:	83 c0 01             	add    $0x1,%eax
  800b29:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b2c:	39 d8                	cmp    %ebx,%eax
  800b2e:	74 16                	je     800b46 <strncmp+0x35>
  800b30:	0f b6 08             	movzbl (%eax),%ecx
  800b33:	84 c9                	test   %cl,%cl
  800b35:	74 04                	je     800b3b <strncmp+0x2a>
  800b37:	3a 0a                	cmp    (%edx),%cl
  800b39:	74 eb                	je     800b26 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3b:	0f b6 00             	movzbl (%eax),%eax
  800b3e:	0f b6 12             	movzbl (%edx),%edx
  800b41:	29 d0                	sub    %edx,%eax
}
  800b43:	5b                   	pop    %ebx
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    
		return 0;
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	eb f6                	jmp    800b43 <strncmp+0x32>

00800b4d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b4d:	f3 0f 1e fb          	endbr32 
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5b:	0f b6 10             	movzbl (%eax),%edx
  800b5e:	84 d2                	test   %dl,%dl
  800b60:	74 09                	je     800b6b <strchr+0x1e>
		if (*s == c)
  800b62:	38 ca                	cmp    %cl,%dl
  800b64:	74 0a                	je     800b70 <strchr+0x23>
	for (; *s; s++)
  800b66:	83 c0 01             	add    $0x1,%eax
  800b69:	eb f0                	jmp    800b5b <strchr+0xe>
			return (char *) s;
	return 0;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b72:	f3 0f 1e fb          	endbr32 
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b80:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b83:	38 ca                	cmp    %cl,%dl
  800b85:	74 09                	je     800b90 <strfind+0x1e>
  800b87:	84 d2                	test   %dl,%dl
  800b89:	74 05                	je     800b90 <strfind+0x1e>
	for (; *s; s++)
  800b8b:	83 c0 01             	add    $0x1,%eax
  800b8e:	eb f0                	jmp    800b80 <strfind+0xe>
			break;
	return (char *) s;
}
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b92:	f3 0f 1e fb          	endbr32 
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba2:	85 c9                	test   %ecx,%ecx
  800ba4:	74 31                	je     800bd7 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba6:	89 f8                	mov    %edi,%eax
  800ba8:	09 c8                	or     %ecx,%eax
  800baa:	a8 03                	test   $0x3,%al
  800bac:	75 23                	jne    800bd1 <memset+0x3f>
		c &= 0xFF;
  800bae:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bb2:	89 d3                	mov    %edx,%ebx
  800bb4:	c1 e3 08             	shl    $0x8,%ebx
  800bb7:	89 d0                	mov    %edx,%eax
  800bb9:	c1 e0 18             	shl    $0x18,%eax
  800bbc:	89 d6                	mov    %edx,%esi
  800bbe:	c1 e6 10             	shl    $0x10,%esi
  800bc1:	09 f0                	or     %esi,%eax
  800bc3:	09 c2                	or     %eax,%edx
  800bc5:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bc7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bca:	89 d0                	mov    %edx,%eax
  800bcc:	fc                   	cld    
  800bcd:	f3 ab                	rep stos %eax,%es:(%edi)
  800bcf:	eb 06                	jmp    800bd7 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd4:	fc                   	cld    
  800bd5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bd7:	89 f8                	mov    %edi,%eax
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bde:	f3 0f 1e fb          	endbr32 
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bea:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bf0:	39 c6                	cmp    %eax,%esi
  800bf2:	73 32                	jae    800c26 <memmove+0x48>
  800bf4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf7:	39 c2                	cmp    %eax,%edx
  800bf9:	76 2b                	jbe    800c26 <memmove+0x48>
		s += n;
		d += n;
  800bfb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfe:	89 fe                	mov    %edi,%esi
  800c00:	09 ce                	or     %ecx,%esi
  800c02:	09 d6                	or     %edx,%esi
  800c04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c0a:	75 0e                	jne    800c1a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c0c:	83 ef 04             	sub    $0x4,%edi
  800c0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c12:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c15:	fd                   	std    
  800c16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c18:	eb 09                	jmp    800c23 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c1a:	83 ef 01             	sub    $0x1,%edi
  800c1d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c20:	fd                   	std    
  800c21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c23:	fc                   	cld    
  800c24:	eb 1a                	jmp    800c40 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c26:	89 c2                	mov    %eax,%edx
  800c28:	09 ca                	or     %ecx,%edx
  800c2a:	09 f2                	or     %esi,%edx
  800c2c:	f6 c2 03             	test   $0x3,%dl
  800c2f:	75 0a                	jne    800c3b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c31:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c34:	89 c7                	mov    %eax,%edi
  800c36:	fc                   	cld    
  800c37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c39:	eb 05                	jmp    800c40 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c3b:	89 c7                	mov    %eax,%edi
  800c3d:	fc                   	cld    
  800c3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c44:	f3 0f 1e fb          	endbr32 
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c4e:	ff 75 10             	pushl  0x10(%ebp)
  800c51:	ff 75 0c             	pushl  0xc(%ebp)
  800c54:	ff 75 08             	pushl  0x8(%ebp)
  800c57:	e8 82 ff ff ff       	call   800bde <memmove>
}
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c5e:	f3 0f 1e fb          	endbr32 
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6d:	89 c6                	mov    %eax,%esi
  800c6f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c72:	39 f0                	cmp    %esi,%eax
  800c74:	74 1c                	je     800c92 <memcmp+0x34>
		if (*s1 != *s2)
  800c76:	0f b6 08             	movzbl (%eax),%ecx
  800c79:	0f b6 1a             	movzbl (%edx),%ebx
  800c7c:	38 d9                	cmp    %bl,%cl
  800c7e:	75 08                	jne    800c88 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c80:	83 c0 01             	add    $0x1,%eax
  800c83:	83 c2 01             	add    $0x1,%edx
  800c86:	eb ea                	jmp    800c72 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800c88:	0f b6 c1             	movzbl %cl,%eax
  800c8b:	0f b6 db             	movzbl %bl,%ebx
  800c8e:	29 d8                	sub    %ebx,%eax
  800c90:	eb 05                	jmp    800c97 <memcmp+0x39>
	}

	return 0;
  800c92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c9b:	f3 0f 1e fb          	endbr32 
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ca8:	89 c2                	mov    %eax,%edx
  800caa:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cad:	39 d0                	cmp    %edx,%eax
  800caf:	73 09                	jae    800cba <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb1:	38 08                	cmp    %cl,(%eax)
  800cb3:	74 05                	je     800cba <memfind+0x1f>
	for (; s < ends; s++)
  800cb5:	83 c0 01             	add    $0x1,%eax
  800cb8:	eb f3                	jmp    800cad <memfind+0x12>
			break;
	return (void *) s;
}
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cbc:	f3 0f 1e fb          	endbr32 
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccc:	eb 03                	jmp    800cd1 <strtol+0x15>
		s++;
  800cce:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800cd1:	0f b6 01             	movzbl (%ecx),%eax
  800cd4:	3c 20                	cmp    $0x20,%al
  800cd6:	74 f6                	je     800cce <strtol+0x12>
  800cd8:	3c 09                	cmp    $0x9,%al
  800cda:	74 f2                	je     800cce <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800cdc:	3c 2b                	cmp    $0x2b,%al
  800cde:	74 2a                	je     800d0a <strtol+0x4e>
	int neg = 0;
  800ce0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ce5:	3c 2d                	cmp    $0x2d,%al
  800ce7:	74 2b                	je     800d14 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cef:	75 0f                	jne    800d00 <strtol+0x44>
  800cf1:	80 39 30             	cmpb   $0x30,(%ecx)
  800cf4:	74 28                	je     800d1e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cf6:	85 db                	test   %ebx,%ebx
  800cf8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfd:	0f 44 d8             	cmove  %eax,%ebx
  800d00:	b8 00 00 00 00       	mov    $0x0,%eax
  800d05:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d08:	eb 46                	jmp    800d50 <strtol+0x94>
		s++;
  800d0a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d0d:	bf 00 00 00 00       	mov    $0x0,%edi
  800d12:	eb d5                	jmp    800ce9 <strtol+0x2d>
		s++, neg = 1;
  800d14:	83 c1 01             	add    $0x1,%ecx
  800d17:	bf 01 00 00 00       	mov    $0x1,%edi
  800d1c:	eb cb                	jmp    800ce9 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d1e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d22:	74 0e                	je     800d32 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d24:	85 db                	test   %ebx,%ebx
  800d26:	75 d8                	jne    800d00 <strtol+0x44>
		s++, base = 8;
  800d28:	83 c1 01             	add    $0x1,%ecx
  800d2b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d30:	eb ce                	jmp    800d00 <strtol+0x44>
		s += 2, base = 16;
  800d32:	83 c1 02             	add    $0x2,%ecx
  800d35:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3a:	eb c4                	jmp    800d00 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d3c:	0f be d2             	movsbl %dl,%edx
  800d3f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d42:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d45:	7d 3a                	jge    800d81 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d47:	83 c1 01             	add    $0x1,%ecx
  800d4a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d4e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d50:	0f b6 11             	movzbl (%ecx),%edx
  800d53:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d56:	89 f3                	mov    %esi,%ebx
  800d58:	80 fb 09             	cmp    $0x9,%bl
  800d5b:	76 df                	jbe    800d3c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d5d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d60:	89 f3                	mov    %esi,%ebx
  800d62:	80 fb 19             	cmp    $0x19,%bl
  800d65:	77 08                	ja     800d6f <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d67:	0f be d2             	movsbl %dl,%edx
  800d6a:	83 ea 57             	sub    $0x57,%edx
  800d6d:	eb d3                	jmp    800d42 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d6f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d72:	89 f3                	mov    %esi,%ebx
  800d74:	80 fb 19             	cmp    $0x19,%bl
  800d77:	77 08                	ja     800d81 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d79:	0f be d2             	movsbl %dl,%edx
  800d7c:	83 ea 37             	sub    $0x37,%edx
  800d7f:	eb c1                	jmp    800d42 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d81:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d85:	74 05                	je     800d8c <strtol+0xd0>
		*endptr = (char *) s;
  800d87:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d8c:	89 c2                	mov    %eax,%edx
  800d8e:	f7 da                	neg    %edx
  800d90:	85 ff                	test   %edi,%edi
  800d92:	0f 45 c2             	cmovne %edx,%eax
}
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    
  800d9a:	66 90                	xchg   %ax,%ax
  800d9c:	66 90                	xchg   %ax,%ax
  800d9e:	66 90                	xchg   %ax,%ax

00800da0 <__udivdi3>:
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 1c             	sub    $0x1c,%esp
  800dab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800daf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800db3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800db7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dbb:	85 d2                	test   %edx,%edx
  800dbd:	75 19                	jne    800dd8 <__udivdi3+0x38>
  800dbf:	39 f3                	cmp    %esi,%ebx
  800dc1:	76 4d                	jbe    800e10 <__udivdi3+0x70>
  800dc3:	31 ff                	xor    %edi,%edi
  800dc5:	89 e8                	mov    %ebp,%eax
  800dc7:	89 f2                	mov    %esi,%edx
  800dc9:	f7 f3                	div    %ebx
  800dcb:	89 fa                	mov    %edi,%edx
  800dcd:	83 c4 1c             	add    $0x1c,%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
  800dd8:	39 f2                	cmp    %esi,%edx
  800dda:	76 14                	jbe    800df0 <__udivdi3+0x50>
  800ddc:	31 ff                	xor    %edi,%edi
  800dde:	31 c0                	xor    %eax,%eax
  800de0:	89 fa                	mov    %edi,%edx
  800de2:	83 c4 1c             	add    $0x1c,%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
  800dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df0:	0f bd fa             	bsr    %edx,%edi
  800df3:	83 f7 1f             	xor    $0x1f,%edi
  800df6:	75 48                	jne    800e40 <__udivdi3+0xa0>
  800df8:	39 f2                	cmp    %esi,%edx
  800dfa:	72 06                	jb     800e02 <__udivdi3+0x62>
  800dfc:	31 c0                	xor    %eax,%eax
  800dfe:	39 eb                	cmp    %ebp,%ebx
  800e00:	77 de                	ja     800de0 <__udivdi3+0x40>
  800e02:	b8 01 00 00 00       	mov    $0x1,%eax
  800e07:	eb d7                	jmp    800de0 <__udivdi3+0x40>
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d9                	mov    %ebx,%ecx
  800e12:	85 db                	test   %ebx,%ebx
  800e14:	75 0b                	jne    800e21 <__udivdi3+0x81>
  800e16:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	f7 f3                	div    %ebx
  800e1f:	89 c1                	mov    %eax,%ecx
  800e21:	31 d2                	xor    %edx,%edx
  800e23:	89 f0                	mov    %esi,%eax
  800e25:	f7 f1                	div    %ecx
  800e27:	89 c6                	mov    %eax,%esi
  800e29:	89 e8                	mov    %ebp,%eax
  800e2b:	89 f7                	mov    %esi,%edi
  800e2d:	f7 f1                	div    %ecx
  800e2f:	89 fa                	mov    %edi,%edx
  800e31:	83 c4 1c             	add    $0x1c,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 f9                	mov    %edi,%ecx
  800e42:	b8 20 00 00 00       	mov    $0x20,%eax
  800e47:	29 f8                	sub    %edi,%eax
  800e49:	d3 e2                	shl    %cl,%edx
  800e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	89 da                	mov    %ebx,%edx
  800e53:	d3 ea                	shr    %cl,%edx
  800e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e59:	09 d1                	or     %edx,%ecx
  800e5b:	89 f2                	mov    %esi,%edx
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e3                	shl    %cl,%ebx
  800e65:	89 c1                	mov    %eax,%ecx
  800e67:	d3 ea                	shr    %cl,%edx
  800e69:	89 f9                	mov    %edi,%ecx
  800e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e6f:	89 eb                	mov    %ebp,%ebx
  800e71:	d3 e6                	shl    %cl,%esi
  800e73:	89 c1                	mov    %eax,%ecx
  800e75:	d3 eb                	shr    %cl,%ebx
  800e77:	09 de                	or     %ebx,%esi
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	f7 74 24 08          	divl   0x8(%esp)
  800e7f:	89 d6                	mov    %edx,%esi
  800e81:	89 c3                	mov    %eax,%ebx
  800e83:	f7 64 24 0c          	mull   0xc(%esp)
  800e87:	39 d6                	cmp    %edx,%esi
  800e89:	72 15                	jb     800ea0 <__udivdi3+0x100>
  800e8b:	89 f9                	mov    %edi,%ecx
  800e8d:	d3 e5                	shl    %cl,%ebp
  800e8f:	39 c5                	cmp    %eax,%ebp
  800e91:	73 04                	jae    800e97 <__udivdi3+0xf7>
  800e93:	39 d6                	cmp    %edx,%esi
  800e95:	74 09                	je     800ea0 <__udivdi3+0x100>
  800e97:	89 d8                	mov    %ebx,%eax
  800e99:	31 ff                	xor    %edi,%edi
  800e9b:	e9 40 ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800ea0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ea3:	31 ff                	xor    %edi,%edi
  800ea5:	e9 36 ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800eaa:	66 90                	xchg   %ax,%ax
  800eac:	66 90                	xchg   %ax,%ax
  800eae:	66 90                	xchg   %ax,%ax

00800eb0 <__umoddi3>:
  800eb0:	f3 0f 1e fb          	endbr32 
  800eb4:	55                   	push   %ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 1c             	sub    $0x1c,%esp
  800ebb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800ebf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ec3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ec7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	75 19                	jne    800ee8 <__umoddi3+0x38>
  800ecf:	39 df                	cmp    %ebx,%edi
  800ed1:	76 5d                	jbe    800f30 <__umoddi3+0x80>
  800ed3:	89 f0                	mov    %esi,%eax
  800ed5:	89 da                	mov    %ebx,%edx
  800ed7:	f7 f7                	div    %edi
  800ed9:	89 d0                	mov    %edx,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	83 c4 1c             	add    $0x1c,%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
  800ee8:	89 f2                	mov    %esi,%edx
  800eea:	39 d8                	cmp    %ebx,%eax
  800eec:	76 12                	jbe    800f00 <__umoddi3+0x50>
  800eee:	89 f0                	mov    %esi,%eax
  800ef0:	89 da                	mov    %ebx,%edx
  800ef2:	83 c4 1c             	add    $0x1c,%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    
  800efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f00:	0f bd e8             	bsr    %eax,%ebp
  800f03:	83 f5 1f             	xor    $0x1f,%ebp
  800f06:	75 50                	jne    800f58 <__umoddi3+0xa8>
  800f08:	39 d8                	cmp    %ebx,%eax
  800f0a:	0f 82 e0 00 00 00    	jb     800ff0 <__umoddi3+0x140>
  800f10:	89 d9                	mov    %ebx,%ecx
  800f12:	39 f7                	cmp    %esi,%edi
  800f14:	0f 86 d6 00 00 00    	jbe    800ff0 <__umoddi3+0x140>
  800f1a:	89 d0                	mov    %edx,%eax
  800f1c:	89 ca                	mov    %ecx,%edx
  800f1e:	83 c4 1c             	add    $0x1c,%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    
  800f26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f2d:	8d 76 00             	lea    0x0(%esi),%esi
  800f30:	89 fd                	mov    %edi,%ebp
  800f32:	85 ff                	test   %edi,%edi
  800f34:	75 0b                	jne    800f41 <__umoddi3+0x91>
  800f36:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	f7 f7                	div    %edi
  800f3f:	89 c5                	mov    %eax,%ebp
  800f41:	89 d8                	mov    %ebx,%eax
  800f43:	31 d2                	xor    %edx,%edx
  800f45:	f7 f5                	div    %ebp
  800f47:	89 f0                	mov    %esi,%eax
  800f49:	f7 f5                	div    %ebp
  800f4b:	89 d0                	mov    %edx,%eax
  800f4d:	31 d2                	xor    %edx,%edx
  800f4f:	eb 8c                	jmp    800edd <__umoddi3+0x2d>
  800f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f58:	89 e9                	mov    %ebp,%ecx
  800f5a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f5f:	29 ea                	sub    %ebp,%edx
  800f61:	d3 e0                	shl    %cl,%eax
  800f63:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 f8                	mov    %edi,%eax
  800f6b:	d3 e8                	shr    %cl,%eax
  800f6d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f71:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f75:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f79:	09 c1                	or     %eax,%ecx
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f81:	89 e9                	mov    %ebp,%ecx
  800f83:	d3 e7                	shl    %cl,%edi
  800f85:	89 d1                	mov    %edx,%ecx
  800f87:	d3 e8                	shr    %cl,%eax
  800f89:	89 e9                	mov    %ebp,%ecx
  800f8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f8f:	d3 e3                	shl    %cl,%ebx
  800f91:	89 c7                	mov    %eax,%edi
  800f93:	89 d1                	mov    %edx,%ecx
  800f95:	89 f0                	mov    %esi,%eax
  800f97:	d3 e8                	shr    %cl,%eax
  800f99:	89 e9                	mov    %ebp,%ecx
  800f9b:	89 fa                	mov    %edi,%edx
  800f9d:	d3 e6                	shl    %cl,%esi
  800f9f:	09 d8                	or     %ebx,%eax
  800fa1:	f7 74 24 08          	divl   0x8(%esp)
  800fa5:	89 d1                	mov    %edx,%ecx
  800fa7:	89 f3                	mov    %esi,%ebx
  800fa9:	f7 64 24 0c          	mull   0xc(%esp)
  800fad:	89 c6                	mov    %eax,%esi
  800faf:	89 d7                	mov    %edx,%edi
  800fb1:	39 d1                	cmp    %edx,%ecx
  800fb3:	72 06                	jb     800fbb <__umoddi3+0x10b>
  800fb5:	75 10                	jne    800fc7 <__umoddi3+0x117>
  800fb7:	39 c3                	cmp    %eax,%ebx
  800fb9:	73 0c                	jae    800fc7 <__umoddi3+0x117>
  800fbb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fbf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fc3:	89 d7                	mov    %edx,%edi
  800fc5:	89 c6                	mov    %eax,%esi
  800fc7:	89 ca                	mov    %ecx,%edx
  800fc9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fce:	29 f3                	sub    %esi,%ebx
  800fd0:	19 fa                	sbb    %edi,%edx
  800fd2:	89 d0                	mov    %edx,%eax
  800fd4:	d3 e0                	shl    %cl,%eax
  800fd6:	89 e9                	mov    %ebp,%ecx
  800fd8:	d3 eb                	shr    %cl,%ebx
  800fda:	d3 ea                	shr    %cl,%edx
  800fdc:	09 d8                	or     %ebx,%eax
  800fde:	83 c4 1c             	add    $0x1c,%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    
  800fe6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fed:	8d 76 00             	lea    0x0(%esi),%esi
  800ff0:	29 fe                	sub    %edi,%esi
  800ff2:	19 c3                	sbb    %eax,%ebx
  800ff4:	89 f2                	mov    %esi,%edx
  800ff6:	89 d9                	mov    %ebx,%ecx
  800ff8:	e9 1d ff ff ff       	jmp    800f1a <__umoddi3+0x6a>
