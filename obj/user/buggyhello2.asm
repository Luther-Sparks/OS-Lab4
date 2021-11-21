
obj/user/buggyhello2:     file format elf32-i386


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

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003d:	68 00 00 10 00       	push   $0x100000
  800042:	ff 35 00 20 80 00    	pushl  0x802000
  800048:	e8 68 00 00 00       	call   8000b5 <sys_cputs>
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
  800061:	e8 d9 00 00 00       	call   80013f <sys_getenvid>
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
  800081:	a3 04 20 80 00       	mov    %eax,0x802004

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
  8000ab:	e8 4a 00 00 00       	call   8000fa <sys_env_destroy>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b5:	f3 0f 1e fb          	endbr32 
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	57                   	push   %edi
  8000bd:	56                   	push   %esi
  8000be:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ca:	89 c3                	mov    %eax,%ebx
  8000cc:	89 c7                	mov    %eax,%edi
  8000ce:	89 c6                	mov    %eax,%esi
  8000d0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d7:	f3 0f 1e fb          	endbr32 
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	f3 0f 1e fb          	endbr32 
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	57                   	push   %edi
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
  800104:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800107:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	b8 03 00 00 00       	mov    $0x3,%eax
  800114:	89 cb                	mov    %ecx,%ebx
  800116:	89 cf                	mov    %ecx,%edi
  800118:	89 ce                	mov    %ecx,%esi
  80011a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80011c:	85 c0                	test   %eax,%eax
  80011e:	7f 08                	jg     800128 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	50                   	push   %eax
  80012c:	6a 03                	push   $0x3
  80012e:	68 38 10 80 00       	push   $0x801038
  800133:	6a 23                	push   $0x23
  800135:	68 55 10 80 00       	push   $0x801055
  80013a:	e8 11 02 00 00       	call   800350 <_panic>

0080013f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013f:	f3 0f 1e fb          	endbr32 
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	f3 0f 1e fb          	endbr32 
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80016c:	ba 00 00 00 00       	mov    $0x0,%edx
  800171:	b8 0a 00 00 00       	mov    $0xa,%eax
  800176:	89 d1                	mov    %edx,%ecx
  800178:	89 d3                	mov    %edx,%ebx
  80017a:	89 d7                	mov    %edx,%edi
  80017c:	89 d6                	mov    %edx,%esi
  80017e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800185:	f3 0f 1e fb          	endbr32 
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800192:	be 00 00 00 00       	mov    $0x0,%esi
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019d:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a5:	89 f7                	mov    %esi,%edi
  8001a7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	7f 08                	jg     8001b5 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b0:	5b                   	pop    %ebx
  8001b1:	5e                   	pop    %esi
  8001b2:	5f                   	pop    %edi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b5:	83 ec 0c             	sub    $0xc,%esp
  8001b8:	50                   	push   %eax
  8001b9:	6a 04                	push   $0x4
  8001bb:	68 38 10 80 00       	push   $0x801038
  8001c0:	6a 23                	push   $0x23
  8001c2:	68 55 10 80 00       	push   $0x801055
  8001c7:	e8 84 01 00 00       	call   800350 <_panic>

008001cc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cc:	f3 0f 1e fb          	endbr32 
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8001d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001df:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ea:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ed:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ef:	85 c0                	test   %eax,%eax
  8001f1:	7f 08                	jg     8001fb <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f6:	5b                   	pop    %ebx
  8001f7:	5e                   	pop    %esi
  8001f8:	5f                   	pop    %edi
  8001f9:	5d                   	pop    %ebp
  8001fa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fb:	83 ec 0c             	sub    $0xc,%esp
  8001fe:	50                   	push   %eax
  8001ff:	6a 05                	push   $0x5
  800201:	68 38 10 80 00       	push   $0x801038
  800206:	6a 23                	push   $0x23
  800208:	68 55 10 80 00       	push   $0x801055
  80020d:	e8 3e 01 00 00       	call   800350 <_panic>

00800212 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800212:	f3 0f 1e fb          	endbr32 
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	57                   	push   %edi
  80021a:	56                   	push   %esi
  80021b:	53                   	push   %ebx
  80021c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80021f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800224:	8b 55 08             	mov    0x8(%ebp),%edx
  800227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022a:	b8 06 00 00 00       	mov    $0x6,%eax
  80022f:	89 df                	mov    %ebx,%edi
  800231:	89 de                	mov    %ebx,%esi
  800233:	cd 30                	int    $0x30
	if(check && ret > 0)
  800235:	85 c0                	test   %eax,%eax
  800237:	7f 08                	jg     800241 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800239:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023c:	5b                   	pop    %ebx
  80023d:	5e                   	pop    %esi
  80023e:	5f                   	pop    %edi
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800241:	83 ec 0c             	sub    $0xc,%esp
  800244:	50                   	push   %eax
  800245:	6a 06                	push   $0x6
  800247:	68 38 10 80 00       	push   $0x801038
  80024c:	6a 23                	push   $0x23
  80024e:	68 55 10 80 00       	push   $0x801055
  800253:	e8 f8 00 00 00       	call   800350 <_panic>

00800258 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800258:	f3 0f 1e fb          	endbr32 
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026a:	8b 55 08             	mov    0x8(%ebp),%edx
  80026d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800270:	b8 08 00 00 00       	mov    $0x8,%eax
  800275:	89 df                	mov    %ebx,%edi
  800277:	89 de                	mov    %ebx,%esi
  800279:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027b:	85 c0                	test   %eax,%eax
  80027d:	7f 08                	jg     800287 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800282:	5b                   	pop    %ebx
  800283:	5e                   	pop    %esi
  800284:	5f                   	pop    %edi
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	50                   	push   %eax
  80028b:	6a 08                	push   $0x8
  80028d:	68 38 10 80 00       	push   $0x801038
  800292:	6a 23                	push   $0x23
  800294:	68 55 10 80 00       	push   $0x801055
  800299:	e8 b2 00 00 00       	call   800350 <_panic>

0080029e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80029e:	f3 0f 1e fb          	endbr32 
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	57                   	push   %edi
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8002ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	b8 09 00 00 00       	mov    $0x9,%eax
  8002bb:	89 df                	mov    %ebx,%edi
  8002bd:	89 de                	mov    %ebx,%esi
  8002bf:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c1:	85 c0                	test   %eax,%eax
  8002c3:	7f 08                	jg     8002cd <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cd:	83 ec 0c             	sub    $0xc,%esp
  8002d0:	50                   	push   %eax
  8002d1:	6a 09                	push   $0x9
  8002d3:	68 38 10 80 00       	push   $0x801038
  8002d8:	6a 23                	push   $0x23
  8002da:	68 55 10 80 00       	push   $0x801055
  8002df:	e8 6c 00 00 00       	call   800350 <_panic>

008002e4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e4:	f3 0f 1e fb          	endbr32 
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8002ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800301:	8b 7d 14             	mov    0x14(%ebp),%edi
  800304:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5f                   	pop    %edi
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030b:	f3 0f 1e fb          	endbr32 
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800318:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	b8 0c 00 00 00       	mov    $0xc,%eax
  800325:	89 cb                	mov    %ecx,%ebx
  800327:	89 cf                	mov    %ecx,%edi
  800329:	89 ce                	mov    %ecx,%esi
  80032b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80032d:	85 c0                	test   %eax,%eax
  80032f:	7f 08                	jg     800339 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800331:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800334:	5b                   	pop    %ebx
  800335:	5e                   	pop    %esi
  800336:	5f                   	pop    %edi
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	50                   	push   %eax
  80033d:	6a 0c                	push   $0xc
  80033f:	68 38 10 80 00       	push   $0x801038
  800344:	6a 23                	push   $0x23
  800346:	68 55 10 80 00       	push   $0x801055
  80034b:	e8 00 00 00 00       	call   800350 <_panic>

00800350 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800350:	f3 0f 1e fb          	endbr32 
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	56                   	push   %esi
  800358:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800359:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80035c:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800362:	e8 d8 fd ff ff       	call   80013f <sys_getenvid>
  800367:	83 ec 0c             	sub    $0xc,%esp
  80036a:	ff 75 0c             	pushl  0xc(%ebp)
  80036d:	ff 75 08             	pushl  0x8(%ebp)
  800370:	56                   	push   %esi
  800371:	50                   	push   %eax
  800372:	68 64 10 80 00       	push   $0x801064
  800377:	e8 bb 00 00 00       	call   800437 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80037c:	83 c4 18             	add    $0x18,%esp
  80037f:	53                   	push   %ebx
  800380:	ff 75 10             	pushl  0x10(%ebp)
  800383:	e8 5a 00 00 00       	call   8003e2 <vcprintf>
	cprintf("\n");
  800388:	c7 04 24 2c 10 80 00 	movl   $0x80102c,(%esp)
  80038f:	e8 a3 00 00 00       	call   800437 <cprintf>
  800394:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800397:	cc                   	int3   
  800398:	eb fd                	jmp    800397 <_panic+0x47>

0080039a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80039a:	f3 0f 1e fb          	endbr32 
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	53                   	push   %ebx
  8003a2:	83 ec 04             	sub    $0x4,%esp
  8003a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a8:	8b 13                	mov    (%ebx),%edx
  8003aa:	8d 42 01             	lea    0x1(%edx),%eax
  8003ad:	89 03                	mov    %eax,(%ebx)
  8003af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003bb:	74 09                	je     8003c6 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003bd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003c6:	83 ec 08             	sub    $0x8,%esp
  8003c9:	68 ff 00 00 00       	push   $0xff
  8003ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8003d1:	50                   	push   %eax
  8003d2:	e8 de fc ff ff       	call   8000b5 <sys_cputs>
		b->idx = 0;
  8003d7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003dd:	83 c4 10             	add    $0x10,%esp
  8003e0:	eb db                	jmp    8003bd <putch+0x23>

008003e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003e2:	f3 0f 1e fb          	endbr32 
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ef:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003f6:	00 00 00 
	b.cnt = 0;
  8003f9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800400:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800403:	ff 75 0c             	pushl  0xc(%ebp)
  800406:	ff 75 08             	pushl  0x8(%ebp)
  800409:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80040f:	50                   	push   %eax
  800410:	68 9a 03 80 00       	push   $0x80039a
  800415:	e8 20 01 00 00       	call   80053a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80041a:	83 c4 08             	add    $0x8,%esp
  80041d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800423:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800429:	50                   	push   %eax
  80042a:	e8 86 fc ff ff       	call   8000b5 <sys_cputs>

	return b.cnt;
}
  80042f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800435:	c9                   	leave  
  800436:	c3                   	ret    

00800437 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800437:	f3 0f 1e fb          	endbr32 
  80043b:	55                   	push   %ebp
  80043c:	89 e5                	mov    %esp,%ebp
  80043e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800441:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800444:	50                   	push   %eax
  800445:	ff 75 08             	pushl  0x8(%ebp)
  800448:	e8 95 ff ff ff       	call   8003e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80044d:	c9                   	leave  
  80044e:	c3                   	ret    

0080044f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	57                   	push   %edi
  800453:	56                   	push   %esi
  800454:	53                   	push   %ebx
  800455:	83 ec 1c             	sub    $0x1c,%esp
  800458:	89 c7                	mov    %eax,%edi
  80045a:	89 d6                	mov    %edx,%esi
  80045c:	8b 45 08             	mov    0x8(%ebp),%eax
  80045f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800462:	89 d1                	mov    %edx,%ecx
  800464:	89 c2                	mov    %eax,%edx
  800466:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800469:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80046c:	8b 45 10             	mov    0x10(%ebp),%eax
  80046f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800472:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800475:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80047c:	39 c2                	cmp    %eax,%edx
  80047e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800481:	72 3e                	jb     8004c1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800483:	83 ec 0c             	sub    $0xc,%esp
  800486:	ff 75 18             	pushl  0x18(%ebp)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	53                   	push   %ebx
  80048d:	50                   	push   %eax
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	ff 75 e4             	pushl  -0x1c(%ebp)
  800494:	ff 75 e0             	pushl  -0x20(%ebp)
  800497:	ff 75 dc             	pushl  -0x24(%ebp)
  80049a:	ff 75 d8             	pushl  -0x28(%ebp)
  80049d:	e8 1e 09 00 00       	call   800dc0 <__udivdi3>
  8004a2:	83 c4 18             	add    $0x18,%esp
  8004a5:	52                   	push   %edx
  8004a6:	50                   	push   %eax
  8004a7:	89 f2                	mov    %esi,%edx
  8004a9:	89 f8                	mov    %edi,%eax
  8004ab:	e8 9f ff ff ff       	call   80044f <printnum>
  8004b0:	83 c4 20             	add    $0x20,%esp
  8004b3:	eb 13                	jmp    8004c8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	56                   	push   %esi
  8004b9:	ff 75 18             	pushl  0x18(%ebp)
  8004bc:	ff d7                	call   *%edi
  8004be:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004c1:	83 eb 01             	sub    $0x1,%ebx
  8004c4:	85 db                	test   %ebx,%ebx
  8004c6:	7f ed                	jg     8004b5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c8:	83 ec 08             	sub    $0x8,%esp
  8004cb:	56                   	push   %esi
  8004cc:	83 ec 04             	sub    $0x4,%esp
  8004cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d5:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d8:	ff 75 d8             	pushl  -0x28(%ebp)
  8004db:	e8 f0 09 00 00       	call   800ed0 <__umoddi3>
  8004e0:	83 c4 14             	add    $0x14,%esp
  8004e3:	0f be 80 87 10 80 00 	movsbl 0x801087(%eax),%eax
  8004ea:	50                   	push   %eax
  8004eb:	ff d7                	call   *%edi
}
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5f                   	pop    %edi
  8004f6:	5d                   	pop    %ebp
  8004f7:	c3                   	ret    

008004f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f8:	f3 0f 1e fb          	endbr32 
  8004fc:	55                   	push   %ebp
  8004fd:	89 e5                	mov    %esp,%ebp
  8004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800502:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800506:	8b 10                	mov    (%eax),%edx
  800508:	3b 50 04             	cmp    0x4(%eax),%edx
  80050b:	73 0a                	jae    800517 <sprintputch+0x1f>
		*b->buf++ = ch;
  80050d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800510:	89 08                	mov    %ecx,(%eax)
  800512:	8b 45 08             	mov    0x8(%ebp),%eax
  800515:	88 02                	mov    %al,(%edx)
}
  800517:	5d                   	pop    %ebp
  800518:	c3                   	ret    

00800519 <printfmt>:
{
  800519:	f3 0f 1e fb          	endbr32 
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800523:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800526:	50                   	push   %eax
  800527:	ff 75 10             	pushl  0x10(%ebp)
  80052a:	ff 75 0c             	pushl  0xc(%ebp)
  80052d:	ff 75 08             	pushl  0x8(%ebp)
  800530:	e8 05 00 00 00       	call   80053a <vprintfmt>
}
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	c9                   	leave  
  800539:	c3                   	ret    

0080053a <vprintfmt>:
{
  80053a:	f3 0f 1e fb          	endbr32 
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	57                   	push   %edi
  800542:	56                   	push   %esi
  800543:	53                   	push   %ebx
  800544:	83 ec 3c             	sub    $0x3c,%esp
  800547:	8b 75 08             	mov    0x8(%ebp),%esi
  80054a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800550:	e9 8e 03 00 00       	jmp    8008e3 <vprintfmt+0x3a9>
		padc = ' ';
  800555:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800559:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800560:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800567:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80056e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8d 47 01             	lea    0x1(%edi),%eax
  800576:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800579:	0f b6 17             	movzbl (%edi),%edx
  80057c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80057f:	3c 55                	cmp    $0x55,%al
  800581:	0f 87 df 03 00 00    	ja     800966 <vprintfmt+0x42c>
  800587:	0f b6 c0             	movzbl %al,%eax
  80058a:	3e ff 24 85 40 11 80 	notrack jmp *0x801140(,%eax,4)
  800591:	00 
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800595:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800599:	eb d8                	jmp    800573 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005a2:	eb cf                	jmp    800573 <vprintfmt+0x39>
  8005a4:	0f b6 d2             	movzbl %dl,%edx
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8005af:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005b2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005b9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005bc:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005bf:	83 f9 09             	cmp    $0x9,%ecx
  8005c2:	77 55                	ja     800619 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005c4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005c7:	eb e9                	jmp    8005b2 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 00                	mov    (%eax),%eax
  8005ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 40 04             	lea    0x4(%eax),%eax
  8005d7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005e1:	79 90                	jns    800573 <vprintfmt+0x39>
				width = precision, precision = -1;
  8005e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005f0:	eb 81                	jmp    800573 <vprintfmt+0x39>
  8005f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f5:	85 c0                	test   %eax,%eax
  8005f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fc:	0f 49 d0             	cmovns %eax,%edx
  8005ff:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800602:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800605:	e9 69 ff ff ff       	jmp    800573 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80060d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800614:	e9 5a ff ff ff       	jmp    800573 <vprintfmt+0x39>
  800619:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061f:	eb bc                	jmp    8005dd <vprintfmt+0xa3>
			lflag++;
  800621:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800627:	e9 47 ff ff ff       	jmp    800573 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 78 04             	lea    0x4(%eax),%edi
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	ff 30                	pushl  (%eax)
  800638:	ff d6                	call   *%esi
			break;
  80063a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80063d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800640:	e9 9b 02 00 00       	jmp    8008e0 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8d 78 04             	lea    0x4(%eax),%edi
  80064b:	8b 00                	mov    (%eax),%eax
  80064d:	99                   	cltd   
  80064e:	31 d0                	xor    %edx,%eax
  800650:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800652:	83 f8 08             	cmp    $0x8,%eax
  800655:	7f 23                	jg     80067a <vprintfmt+0x140>
  800657:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  80065e:	85 d2                	test   %edx,%edx
  800660:	74 18                	je     80067a <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800662:	52                   	push   %edx
  800663:	68 a8 10 80 00       	push   $0x8010a8
  800668:	53                   	push   %ebx
  800669:	56                   	push   %esi
  80066a:	e8 aa fe ff ff       	call   800519 <printfmt>
  80066f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800672:	89 7d 14             	mov    %edi,0x14(%ebp)
  800675:	e9 66 02 00 00       	jmp    8008e0 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80067a:	50                   	push   %eax
  80067b:	68 9f 10 80 00       	push   $0x80109f
  800680:	53                   	push   %ebx
  800681:	56                   	push   %esi
  800682:	e8 92 fe ff ff       	call   800519 <printfmt>
  800687:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80068a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80068d:	e9 4e 02 00 00       	jmp    8008e0 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	83 c0 04             	add    $0x4,%eax
  800698:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006a0:	85 d2                	test   %edx,%edx
  8006a2:	b8 98 10 80 00       	mov    $0x801098,%eax
  8006a7:	0f 45 c2             	cmovne %edx,%eax
  8006aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b1:	7e 06                	jle    8006b9 <vprintfmt+0x17f>
  8006b3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006b7:	75 0d                	jne    8006c6 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006bc:	89 c7                	mov    %eax,%edi
  8006be:	03 45 e0             	add    -0x20(%ebp),%eax
  8006c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c4:	eb 55                	jmp    80071b <vprintfmt+0x1e1>
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8006cc:	ff 75 cc             	pushl  -0x34(%ebp)
  8006cf:	e8 46 03 00 00       	call   800a1a <strnlen>
  8006d4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006d7:	29 c2                	sub    %eax,%edx
  8006d9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006e1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e8:	85 ff                	test   %edi,%edi
  8006ea:	7e 11                	jle    8006fd <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	53                   	push   %ebx
  8006f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f5:	83 ef 01             	sub    $0x1,%edi
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	eb eb                	jmp    8006e8 <vprintfmt+0x1ae>
  8006fd:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800700:	85 d2                	test   %edx,%edx
  800702:	b8 00 00 00 00       	mov    $0x0,%eax
  800707:	0f 49 c2             	cmovns %edx,%eax
  80070a:	29 c2                	sub    %eax,%edx
  80070c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80070f:	eb a8                	jmp    8006b9 <vprintfmt+0x17f>
					putch(ch, putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	52                   	push   %edx
  800716:	ff d6                	call   *%esi
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80071e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800720:	83 c7 01             	add    $0x1,%edi
  800723:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800727:	0f be d0             	movsbl %al,%edx
  80072a:	85 d2                	test   %edx,%edx
  80072c:	74 4b                	je     800779 <vprintfmt+0x23f>
  80072e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800732:	78 06                	js     80073a <vprintfmt+0x200>
  800734:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800738:	78 1e                	js     800758 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80073a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80073e:	74 d1                	je     800711 <vprintfmt+0x1d7>
  800740:	0f be c0             	movsbl %al,%eax
  800743:	83 e8 20             	sub    $0x20,%eax
  800746:	83 f8 5e             	cmp    $0x5e,%eax
  800749:	76 c6                	jbe    800711 <vprintfmt+0x1d7>
					putch('?', putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	53                   	push   %ebx
  80074f:	6a 3f                	push   $0x3f
  800751:	ff d6                	call   *%esi
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	eb c3                	jmp    80071b <vprintfmt+0x1e1>
  800758:	89 cf                	mov    %ecx,%edi
  80075a:	eb 0e                	jmp    80076a <vprintfmt+0x230>
				putch(' ', putdat);
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	53                   	push   %ebx
  800760:	6a 20                	push   $0x20
  800762:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800764:	83 ef 01             	sub    $0x1,%edi
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	85 ff                	test   %edi,%edi
  80076c:	7f ee                	jg     80075c <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80076e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800771:	89 45 14             	mov    %eax,0x14(%ebp)
  800774:	e9 67 01 00 00       	jmp    8008e0 <vprintfmt+0x3a6>
  800779:	89 cf                	mov    %ecx,%edi
  80077b:	eb ed                	jmp    80076a <vprintfmt+0x230>
	if (lflag >= 2)
  80077d:	83 f9 01             	cmp    $0x1,%ecx
  800780:	7f 1b                	jg     80079d <vprintfmt+0x263>
	else if (lflag)
  800782:	85 c9                	test   %ecx,%ecx
  800784:	74 63                	je     8007e9 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078e:	99                   	cltd   
  80078f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8d 40 04             	lea    0x4(%eax),%eax
  800798:	89 45 14             	mov    %eax,0x14(%ebp)
  80079b:	eb 17                	jmp    8007b4 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8b 50 04             	mov    0x4(%eax),%edx
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 40 08             	lea    0x8(%eax),%eax
  8007b1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007bf:	85 c9                	test   %ecx,%ecx
  8007c1:	0f 89 ff 00 00 00    	jns    8008c6 <vprintfmt+0x38c>
				putch('-', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	53                   	push   %ebx
  8007cb:	6a 2d                	push   $0x2d
  8007cd:	ff d6                	call   *%esi
				num = -(long long) num;
  8007cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007d5:	f7 da                	neg    %edx
  8007d7:	83 d1 00             	adc    $0x0,%ecx
  8007da:	f7 d9                	neg    %ecx
  8007dc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e4:	e9 dd 00 00 00       	jmp    8008c6 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8b 00                	mov    (%eax),%eax
  8007ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f1:	99                   	cltd   
  8007f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8d 40 04             	lea    0x4(%eax),%eax
  8007fb:	89 45 14             	mov    %eax,0x14(%ebp)
  8007fe:	eb b4                	jmp    8007b4 <vprintfmt+0x27a>
	if (lflag >= 2)
  800800:	83 f9 01             	cmp    $0x1,%ecx
  800803:	7f 1e                	jg     800823 <vprintfmt+0x2e9>
	else if (lflag)
  800805:	85 c9                	test   %ecx,%ecx
  800807:	74 32                	je     80083b <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8b 10                	mov    (%eax),%edx
  80080e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800813:	8d 40 04             	lea    0x4(%eax),%eax
  800816:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800819:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80081e:	e9 a3 00 00 00       	jmp    8008c6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	8b 10                	mov    (%eax),%edx
  800828:	8b 48 04             	mov    0x4(%eax),%ecx
  80082b:	8d 40 08             	lea    0x8(%eax),%eax
  80082e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800831:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800836:	e9 8b 00 00 00       	jmp    8008c6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	8b 10                	mov    (%eax),%edx
  800840:	b9 00 00 00 00       	mov    $0x0,%ecx
  800845:	8d 40 04             	lea    0x4(%eax),%eax
  800848:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80084b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800850:	eb 74                	jmp    8008c6 <vprintfmt+0x38c>
	if (lflag >= 2)
  800852:	83 f9 01             	cmp    $0x1,%ecx
  800855:	7f 1b                	jg     800872 <vprintfmt+0x338>
	else if (lflag)
  800857:	85 c9                	test   %ecx,%ecx
  800859:	74 2c                	je     800887 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	8b 10                	mov    (%eax),%edx
  800860:	b9 00 00 00 00       	mov    $0x0,%ecx
  800865:	8d 40 04             	lea    0x4(%eax),%eax
  800868:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80086b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800870:	eb 54                	jmp    8008c6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8b 10                	mov    (%eax),%edx
  800877:	8b 48 04             	mov    0x4(%eax),%ecx
  80087a:	8d 40 08             	lea    0x8(%eax),%eax
  80087d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800880:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800885:	eb 3f                	jmp    8008c6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800887:	8b 45 14             	mov    0x14(%ebp),%eax
  80088a:	8b 10                	mov    (%eax),%edx
  80088c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800891:	8d 40 04             	lea    0x4(%eax),%eax
  800894:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800897:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80089c:	eb 28                	jmp    8008c6 <vprintfmt+0x38c>
			putch('0', putdat);
  80089e:	83 ec 08             	sub    $0x8,%esp
  8008a1:	53                   	push   %ebx
  8008a2:	6a 30                	push   $0x30
  8008a4:	ff d6                	call   *%esi
			putch('x', putdat);
  8008a6:	83 c4 08             	add    $0x8,%esp
  8008a9:	53                   	push   %ebx
  8008aa:	6a 78                	push   $0x78
  8008ac:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b1:	8b 10                	mov    (%eax),%edx
  8008b3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008b8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008bb:	8d 40 04             	lea    0x4(%eax),%eax
  8008be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008c1:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008c6:	83 ec 0c             	sub    $0xc,%esp
  8008c9:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008cd:	57                   	push   %edi
  8008ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8008d1:	50                   	push   %eax
  8008d2:	51                   	push   %ecx
  8008d3:	52                   	push   %edx
  8008d4:	89 da                	mov    %ebx,%edx
  8008d6:	89 f0                	mov    %esi,%eax
  8008d8:	e8 72 fb ff ff       	call   80044f <printnum>
			break;
  8008dd:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8008e3:	83 c7 01             	add    $0x1,%edi
  8008e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ea:	83 f8 25             	cmp    $0x25,%eax
  8008ed:	0f 84 62 fc ff ff    	je     800555 <vprintfmt+0x1b>
			if (ch == '\0')										
  8008f3:	85 c0                	test   %eax,%eax
  8008f5:	0f 84 8b 00 00 00    	je     800986 <vprintfmt+0x44c>
			putch(ch, putdat);
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	53                   	push   %ebx
  8008ff:	50                   	push   %eax
  800900:	ff d6                	call   *%esi
  800902:	83 c4 10             	add    $0x10,%esp
  800905:	eb dc                	jmp    8008e3 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800907:	83 f9 01             	cmp    $0x1,%ecx
  80090a:	7f 1b                	jg     800927 <vprintfmt+0x3ed>
	else if (lflag)
  80090c:	85 c9                	test   %ecx,%ecx
  80090e:	74 2c                	je     80093c <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800910:	8b 45 14             	mov    0x14(%ebp),%eax
  800913:	8b 10                	mov    (%eax),%edx
  800915:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091a:	8d 40 04             	lea    0x4(%eax),%eax
  80091d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800920:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800925:	eb 9f                	jmp    8008c6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800927:	8b 45 14             	mov    0x14(%ebp),%eax
  80092a:	8b 10                	mov    (%eax),%edx
  80092c:	8b 48 04             	mov    0x4(%eax),%ecx
  80092f:	8d 40 08             	lea    0x8(%eax),%eax
  800932:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800935:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80093a:	eb 8a                	jmp    8008c6 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80093c:	8b 45 14             	mov    0x14(%ebp),%eax
  80093f:	8b 10                	mov    (%eax),%edx
  800941:	b9 00 00 00 00       	mov    $0x0,%ecx
  800946:	8d 40 04             	lea    0x4(%eax),%eax
  800949:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80094c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800951:	e9 70 ff ff ff       	jmp    8008c6 <vprintfmt+0x38c>
			putch(ch, putdat);
  800956:	83 ec 08             	sub    $0x8,%esp
  800959:	53                   	push   %ebx
  80095a:	6a 25                	push   $0x25
  80095c:	ff d6                	call   *%esi
			break;
  80095e:	83 c4 10             	add    $0x10,%esp
  800961:	e9 7a ff ff ff       	jmp    8008e0 <vprintfmt+0x3a6>
			putch('%', putdat);
  800966:	83 ec 08             	sub    $0x8,%esp
  800969:	53                   	push   %ebx
  80096a:	6a 25                	push   $0x25
  80096c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80096e:	83 c4 10             	add    $0x10,%esp
  800971:	89 f8                	mov    %edi,%eax
  800973:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800977:	74 05                	je     80097e <vprintfmt+0x444>
  800979:	83 e8 01             	sub    $0x1,%eax
  80097c:	eb f5                	jmp    800973 <vprintfmt+0x439>
  80097e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800981:	e9 5a ff ff ff       	jmp    8008e0 <vprintfmt+0x3a6>
}
  800986:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80098e:	f3 0f 1e fb          	endbr32 
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 18             	sub    $0x18,%esp
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80099e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009a1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009af:	85 c0                	test   %eax,%eax
  8009b1:	74 26                	je     8009d9 <vsnprintf+0x4b>
  8009b3:	85 d2                	test   %edx,%edx
  8009b5:	7e 22                	jle    8009d9 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b7:	ff 75 14             	pushl  0x14(%ebp)
  8009ba:	ff 75 10             	pushl  0x10(%ebp)
  8009bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009c0:	50                   	push   %eax
  8009c1:	68 f8 04 80 00       	push   $0x8004f8
  8009c6:	e8 6f fb ff ff       	call   80053a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ce:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d4:	83 c4 10             	add    $0x10,%esp
}
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    
		return -E_INVAL;
  8009d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009de:	eb f7                	jmp    8009d7 <vsnprintf+0x49>

008009e0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009e0:	f3 0f 1e fb          	endbr32 
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ed:	50                   	push   %eax
  8009ee:	ff 75 10             	pushl  0x10(%ebp)
  8009f1:	ff 75 0c             	pushl  0xc(%ebp)
  8009f4:	ff 75 08             	pushl  0x8(%ebp)
  8009f7:	e8 92 ff ff ff       	call   80098e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009fc:	c9                   	leave  
  8009fd:	c3                   	ret    

008009fe <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009fe:	f3 0f 1e fb          	endbr32 
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a11:	74 05                	je     800a18 <strlen+0x1a>
		n++;
  800a13:	83 c0 01             	add    $0x1,%eax
  800a16:	eb f5                	jmp    800a0d <strlen+0xf>
	return n;
}
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a1a:	f3 0f 1e fb          	endbr32 
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a24:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2c:	39 d0                	cmp    %edx,%eax
  800a2e:	74 0d                	je     800a3d <strnlen+0x23>
  800a30:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a34:	74 05                	je     800a3b <strnlen+0x21>
		n++;
  800a36:	83 c0 01             	add    $0x1,%eax
  800a39:	eb f1                	jmp    800a2c <strnlen+0x12>
  800a3b:	89 c2                	mov    %eax,%edx
	return n;
}
  800a3d:	89 d0                	mov    %edx,%eax
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a41:	f3 0f 1e fb          	endbr32 
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	53                   	push   %ebx
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a54:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a58:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a5b:	83 c0 01             	add    $0x1,%eax
  800a5e:	84 d2                	test   %dl,%dl
  800a60:	75 f2                	jne    800a54 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a62:	89 c8                	mov    %ecx,%eax
  800a64:	5b                   	pop    %ebx
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a67:	f3 0f 1e fb          	endbr32 
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	53                   	push   %ebx
  800a6f:	83 ec 10             	sub    $0x10,%esp
  800a72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a75:	53                   	push   %ebx
  800a76:	e8 83 ff ff ff       	call   8009fe <strlen>
  800a7b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a7e:	ff 75 0c             	pushl  0xc(%ebp)
  800a81:	01 d8                	add    %ebx,%eax
  800a83:	50                   	push   %eax
  800a84:	e8 b8 ff ff ff       	call   800a41 <strcpy>
	return dst;
}
  800a89:	89 d8                	mov    %ebx,%eax
  800a8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a8e:	c9                   	leave  
  800a8f:	c3                   	ret    

00800a90 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a90:	f3 0f 1e fb          	endbr32 
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa4:	89 f0                	mov    %esi,%eax
  800aa6:	39 d8                	cmp    %ebx,%eax
  800aa8:	74 11                	je     800abb <strncpy+0x2b>
		*dst++ = *src;
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	0f b6 0a             	movzbl (%edx),%ecx
  800ab0:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ab3:	80 f9 01             	cmp    $0x1,%cl
  800ab6:	83 da ff             	sbb    $0xffffffff,%edx
  800ab9:	eb eb                	jmp    800aa6 <strncpy+0x16>
	}
	return ret;
}
  800abb:	89 f0                	mov    %esi,%eax
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ac1:	f3 0f 1e fb          	endbr32 
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	8b 75 08             	mov    0x8(%ebp),%esi
  800acd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad0:	8b 55 10             	mov    0x10(%ebp),%edx
  800ad3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad5:	85 d2                	test   %edx,%edx
  800ad7:	74 21                	je     800afa <strlcpy+0x39>
  800ad9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800add:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800adf:	39 c2                	cmp    %eax,%edx
  800ae1:	74 14                	je     800af7 <strlcpy+0x36>
  800ae3:	0f b6 19             	movzbl (%ecx),%ebx
  800ae6:	84 db                	test   %bl,%bl
  800ae8:	74 0b                	je     800af5 <strlcpy+0x34>
			*dst++ = *src++;
  800aea:	83 c1 01             	add    $0x1,%ecx
  800aed:	83 c2 01             	add    $0x1,%edx
  800af0:	88 5a ff             	mov    %bl,-0x1(%edx)
  800af3:	eb ea                	jmp    800adf <strlcpy+0x1e>
  800af5:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800af7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800afa:	29 f0                	sub    %esi,%eax
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b00:	f3 0f 1e fb          	endbr32 
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b0d:	0f b6 01             	movzbl (%ecx),%eax
  800b10:	84 c0                	test   %al,%al
  800b12:	74 0c                	je     800b20 <strcmp+0x20>
  800b14:	3a 02                	cmp    (%edx),%al
  800b16:	75 08                	jne    800b20 <strcmp+0x20>
		p++, q++;
  800b18:	83 c1 01             	add    $0x1,%ecx
  800b1b:	83 c2 01             	add    $0x1,%edx
  800b1e:	eb ed                	jmp    800b0d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b20:	0f b6 c0             	movzbl %al,%eax
  800b23:	0f b6 12             	movzbl (%edx),%edx
  800b26:	29 d0                	sub    %edx,%eax
}
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b2a:	f3 0f 1e fb          	endbr32 
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	53                   	push   %ebx
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b38:	89 c3                	mov    %eax,%ebx
  800b3a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b3d:	eb 06                	jmp    800b45 <strncmp+0x1b>
		n--, p++, q++;
  800b3f:	83 c0 01             	add    $0x1,%eax
  800b42:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b45:	39 d8                	cmp    %ebx,%eax
  800b47:	74 16                	je     800b5f <strncmp+0x35>
  800b49:	0f b6 08             	movzbl (%eax),%ecx
  800b4c:	84 c9                	test   %cl,%cl
  800b4e:	74 04                	je     800b54 <strncmp+0x2a>
  800b50:	3a 0a                	cmp    (%edx),%cl
  800b52:	74 eb                	je     800b3f <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b54:	0f b6 00             	movzbl (%eax),%eax
  800b57:	0f b6 12             	movzbl (%edx),%edx
  800b5a:	29 d0                	sub    %edx,%eax
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    
		return 0;
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b64:	eb f6                	jmp    800b5c <strncmp+0x32>

00800b66 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b66:	f3 0f 1e fb          	endbr32 
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b74:	0f b6 10             	movzbl (%eax),%edx
  800b77:	84 d2                	test   %dl,%dl
  800b79:	74 09                	je     800b84 <strchr+0x1e>
		if (*s == c)
  800b7b:	38 ca                	cmp    %cl,%dl
  800b7d:	74 0a                	je     800b89 <strchr+0x23>
	for (; *s; s++)
  800b7f:	83 c0 01             	add    $0x1,%eax
  800b82:	eb f0                	jmp    800b74 <strchr+0xe>
			return (char *) s;
	return 0;
  800b84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b8b:	f3 0f 1e fb          	endbr32 
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
  800b95:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b99:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b9c:	38 ca                	cmp    %cl,%dl
  800b9e:	74 09                	je     800ba9 <strfind+0x1e>
  800ba0:	84 d2                	test   %dl,%dl
  800ba2:	74 05                	je     800ba9 <strfind+0x1e>
	for (; *s; s++)
  800ba4:	83 c0 01             	add    $0x1,%eax
  800ba7:	eb f0                	jmp    800b99 <strfind+0xe>
			break;
	return (char *) s;
}
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bab:	f3 0f 1e fb          	endbr32 
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bbb:	85 c9                	test   %ecx,%ecx
  800bbd:	74 31                	je     800bf0 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bbf:	89 f8                	mov    %edi,%eax
  800bc1:	09 c8                	or     %ecx,%eax
  800bc3:	a8 03                	test   $0x3,%al
  800bc5:	75 23                	jne    800bea <memset+0x3f>
		c &= 0xFF;
  800bc7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bcb:	89 d3                	mov    %edx,%ebx
  800bcd:	c1 e3 08             	shl    $0x8,%ebx
  800bd0:	89 d0                	mov    %edx,%eax
  800bd2:	c1 e0 18             	shl    $0x18,%eax
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	c1 e6 10             	shl    $0x10,%esi
  800bda:	09 f0                	or     %esi,%eax
  800bdc:	09 c2                	or     %eax,%edx
  800bde:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800be0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800be3:	89 d0                	mov    %edx,%eax
  800be5:	fc                   	cld    
  800be6:	f3 ab                	rep stos %eax,%es:(%edi)
  800be8:	eb 06                	jmp    800bf0 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bed:	fc                   	cld    
  800bee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bf0:	89 f8                	mov    %edi,%eax
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf7:	f3 0f 1e fb          	endbr32 
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
  800c03:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c09:	39 c6                	cmp    %eax,%esi
  800c0b:	73 32                	jae    800c3f <memmove+0x48>
  800c0d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c10:	39 c2                	cmp    %eax,%edx
  800c12:	76 2b                	jbe    800c3f <memmove+0x48>
		s += n;
		d += n;
  800c14:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c17:	89 fe                	mov    %edi,%esi
  800c19:	09 ce                	or     %ecx,%esi
  800c1b:	09 d6                	or     %edx,%esi
  800c1d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c23:	75 0e                	jne    800c33 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c25:	83 ef 04             	sub    $0x4,%edi
  800c28:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c2b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c2e:	fd                   	std    
  800c2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c31:	eb 09                	jmp    800c3c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c33:	83 ef 01             	sub    $0x1,%edi
  800c36:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c39:	fd                   	std    
  800c3a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c3c:	fc                   	cld    
  800c3d:	eb 1a                	jmp    800c59 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3f:	89 c2                	mov    %eax,%edx
  800c41:	09 ca                	or     %ecx,%edx
  800c43:	09 f2                	or     %esi,%edx
  800c45:	f6 c2 03             	test   $0x3,%dl
  800c48:	75 0a                	jne    800c54 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c4a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c4d:	89 c7                	mov    %eax,%edi
  800c4f:	fc                   	cld    
  800c50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c52:	eb 05                	jmp    800c59 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c54:	89 c7                	mov    %eax,%edi
  800c56:	fc                   	cld    
  800c57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c5d:	f3 0f 1e fb          	endbr32 
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c67:	ff 75 10             	pushl  0x10(%ebp)
  800c6a:	ff 75 0c             	pushl  0xc(%ebp)
  800c6d:	ff 75 08             	pushl  0x8(%ebp)
  800c70:	e8 82 ff ff ff       	call   800bf7 <memmove>
}
  800c75:	c9                   	leave  
  800c76:	c3                   	ret    

00800c77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c77:	f3 0f 1e fb          	endbr32 
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
  800c83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c86:	89 c6                	mov    %eax,%esi
  800c88:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c8b:	39 f0                	cmp    %esi,%eax
  800c8d:	74 1c                	je     800cab <memcmp+0x34>
		if (*s1 != *s2)
  800c8f:	0f b6 08             	movzbl (%eax),%ecx
  800c92:	0f b6 1a             	movzbl (%edx),%ebx
  800c95:	38 d9                	cmp    %bl,%cl
  800c97:	75 08                	jne    800ca1 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c99:	83 c0 01             	add    $0x1,%eax
  800c9c:	83 c2 01             	add    $0x1,%edx
  800c9f:	eb ea                	jmp    800c8b <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ca1:	0f b6 c1             	movzbl %cl,%eax
  800ca4:	0f b6 db             	movzbl %bl,%ebx
  800ca7:	29 d8                	sub    %ebx,%eax
  800ca9:	eb 05                	jmp    800cb0 <memcmp+0x39>
	}

	return 0;
  800cab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cb4:	f3 0f 1e fb          	endbr32 
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cc1:	89 c2                	mov    %eax,%edx
  800cc3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cc6:	39 d0                	cmp    %edx,%eax
  800cc8:	73 09                	jae    800cd3 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cca:	38 08                	cmp    %cl,(%eax)
  800ccc:	74 05                	je     800cd3 <memfind+0x1f>
	for (; s < ends; s++)
  800cce:	83 c0 01             	add    $0x1,%eax
  800cd1:	eb f3                	jmp    800cc6 <memfind+0x12>
			break;
	return (void *) s;
}
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cd5:	f3 0f 1e fb          	endbr32 
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce5:	eb 03                	jmp    800cea <strtol+0x15>
		s++;
  800ce7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800cea:	0f b6 01             	movzbl (%ecx),%eax
  800ced:	3c 20                	cmp    $0x20,%al
  800cef:	74 f6                	je     800ce7 <strtol+0x12>
  800cf1:	3c 09                	cmp    $0x9,%al
  800cf3:	74 f2                	je     800ce7 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800cf5:	3c 2b                	cmp    $0x2b,%al
  800cf7:	74 2a                	je     800d23 <strtol+0x4e>
	int neg = 0;
  800cf9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800cfe:	3c 2d                	cmp    $0x2d,%al
  800d00:	74 2b                	je     800d2d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d02:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d08:	75 0f                	jne    800d19 <strtol+0x44>
  800d0a:	80 39 30             	cmpb   $0x30,(%ecx)
  800d0d:	74 28                	je     800d37 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d0f:	85 db                	test   %ebx,%ebx
  800d11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d16:	0f 44 d8             	cmove  %eax,%ebx
  800d19:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d21:	eb 46                	jmp    800d69 <strtol+0x94>
		s++;
  800d23:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d26:	bf 00 00 00 00       	mov    $0x0,%edi
  800d2b:	eb d5                	jmp    800d02 <strtol+0x2d>
		s++, neg = 1;
  800d2d:	83 c1 01             	add    $0x1,%ecx
  800d30:	bf 01 00 00 00       	mov    $0x1,%edi
  800d35:	eb cb                	jmp    800d02 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d37:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d3b:	74 0e                	je     800d4b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d3d:	85 db                	test   %ebx,%ebx
  800d3f:	75 d8                	jne    800d19 <strtol+0x44>
		s++, base = 8;
  800d41:	83 c1 01             	add    $0x1,%ecx
  800d44:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d49:	eb ce                	jmp    800d19 <strtol+0x44>
		s += 2, base = 16;
  800d4b:	83 c1 02             	add    $0x2,%ecx
  800d4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d53:	eb c4                	jmp    800d19 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d55:	0f be d2             	movsbl %dl,%edx
  800d58:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d5b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d5e:	7d 3a                	jge    800d9a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d60:	83 c1 01             	add    $0x1,%ecx
  800d63:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d67:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d69:	0f b6 11             	movzbl (%ecx),%edx
  800d6c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d6f:	89 f3                	mov    %esi,%ebx
  800d71:	80 fb 09             	cmp    $0x9,%bl
  800d74:	76 df                	jbe    800d55 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d76:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d79:	89 f3                	mov    %esi,%ebx
  800d7b:	80 fb 19             	cmp    $0x19,%bl
  800d7e:	77 08                	ja     800d88 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d80:	0f be d2             	movsbl %dl,%edx
  800d83:	83 ea 57             	sub    $0x57,%edx
  800d86:	eb d3                	jmp    800d5b <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d88:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d8b:	89 f3                	mov    %esi,%ebx
  800d8d:	80 fb 19             	cmp    $0x19,%bl
  800d90:	77 08                	ja     800d9a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d92:	0f be d2             	movsbl %dl,%edx
  800d95:	83 ea 37             	sub    $0x37,%edx
  800d98:	eb c1                	jmp    800d5b <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d9a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d9e:	74 05                	je     800da5 <strtol+0xd0>
		*endptr = (char *) s;
  800da0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800da3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800da5:	89 c2                	mov    %eax,%edx
  800da7:	f7 da                	neg    %edx
  800da9:	85 ff                	test   %edi,%edi
  800dab:	0f 45 c2             	cmovne %edx,%eax
}
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    
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
