
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	86013103          	ld	sp,-1952(sp) # 80008860 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	b3478793          	addi	a5,a5,-1228 # 80005b90 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e1878793          	addi	a5,a5,-488 # 80000ebe <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	b04080e7          	jalr	-1276(ra) # 80000c10 <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305b63          	blez	s3,8000016a <consolewrite+0x7e>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	37c080e7          	jalr	892(ra) # 800024a2 <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	7aa080e7          	jalr	1962(ra) # 800008e0 <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	b76080e7          	jalr	-1162(ra) # 80000cc4 <release>

  return i;
}
    80000156:	854a                	mv	a0,s2
    80000158:	60a6                	ld	ra,72(sp)
    8000015a:	6406                	ld	s0,64(sp)
    8000015c:	74e2                	ld	s1,56(sp)
    8000015e:	7942                	ld	s2,48(sp)
    80000160:	79a2                	ld	s3,40(sp)
    80000162:	7a02                	ld	s4,32(sp)
    80000164:	6ae2                	ld	s5,24(sp)
    80000166:	6161                	addi	sp,sp,80
    80000168:	8082                	ret
  for(i = 0; i < n; i++){
    8000016a:	4901                	li	s2,0
    8000016c:	bfe9                	j	80000146 <consolewrite+0x5a>

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	7119                	addi	sp,sp,-128
    80000170:	fc86                	sd	ra,120(sp)
    80000172:	f8a2                	sd	s0,112(sp)
    80000174:	f4a6                	sd	s1,104(sp)
    80000176:	f0ca                	sd	s2,96(sp)
    80000178:	ecce                	sd	s3,88(sp)
    8000017a:	e8d2                	sd	s4,80(sp)
    8000017c:	e4d6                	sd	s5,72(sp)
    8000017e:	e0da                	sd	s6,64(sp)
    80000180:	fc5e                	sd	s7,56(sp)
    80000182:	f862                	sd	s8,48(sp)
    80000184:	f466                	sd	s9,40(sp)
    80000186:	f06a                	sd	s10,32(sp)
    80000188:	ec6e                	sd	s11,24(sp)
    8000018a:	0100                	addi	s0,sp,128
    8000018c:	8b2a                	mv	s6,a0
    8000018e:	8aae                	mv	s5,a1
    80000190:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80000196:	00011517          	auipc	a0,0x11
    8000019a:	69a50513          	addi	a0,a0,1690 # 80011830 <cons>
    8000019e:	00001097          	auipc	ra,0x1
    800001a2:	a72080e7          	jalr	-1422(ra) # 80000c10 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a6:	00011497          	auipc	s1,0x11
    800001aa:	68a48493          	addi	s1,s1,1674 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ae:	89a6                	mv	s3,s1
    800001b0:	00011917          	auipc	s2,0x11
    800001b4:	71890913          	addi	s2,s2,1816 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b8:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ba:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001bc:	4da9                	li	s11,10
  while(n > 0){
    800001be:	07405863          	blez	s4,8000022e <consoleread+0xc0>
    while(cons.r == cons.w){
    800001c2:	0984a783          	lw	a5,152(s1)
    800001c6:	09c4a703          	lw	a4,156(s1)
    800001ca:	02f71463          	bne	a4,a5,800001f2 <consoleread+0x84>
      if(myproc()->killed){
    800001ce:	00002097          	auipc	ra,0x2
    800001d2:	810080e7          	jalr	-2032(ra) # 800019de <myproc>
    800001d6:	591c                	lw	a5,48(a0)
    800001d8:	e7b5                	bnez	a5,80000244 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001da:	85ce                	mv	a1,s3
    800001dc:	854a                	mv	a0,s2
    800001de:	00002097          	auipc	ra,0x2
    800001e2:	00c080e7          	jalr	12(ra) # 800021ea <sleep>
    while(cons.r == cons.w){
    800001e6:	0984a783          	lw	a5,152(s1)
    800001ea:	09c4a703          	lw	a4,156(s1)
    800001ee:	fef700e3          	beq	a4,a5,800001ce <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f2:	0017871b          	addiw	a4,a5,1
    800001f6:	08e4ac23          	sw	a4,152(s1)
    800001fa:	07f7f713          	andi	a4,a5,127
    800001fe:	9726                	add	a4,a4,s1
    80000200:	01874703          	lbu	a4,24(a4)
    80000204:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000208:	079c0663          	beq	s8,s9,80000274 <consoleread+0x106>
    cbuf = c;
    8000020c:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	f8f40613          	addi	a2,s0,-113
    80000216:	85d6                	mv	a1,s5
    80000218:	855a                	mv	a0,s6
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	232080e7          	jalr	562(ra) # 8000244c <either_copyout>
    80000222:	01a50663          	beq	a0,s10,8000022e <consoleread+0xc0>
    dst++;
    80000226:	0a85                	addi	s5,s5,1
    --n;
    80000228:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000022a:	f9bc1ae3          	bne	s8,s11,800001be <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022e:	00011517          	auipc	a0,0x11
    80000232:	60250513          	addi	a0,a0,1538 # 80011830 <cons>
    80000236:	00001097          	auipc	ra,0x1
    8000023a:	a8e080e7          	jalr	-1394(ra) # 80000cc4 <release>

  return target - n;
    8000023e:	414b853b          	subw	a0,s7,s4
    80000242:	a811                	j	80000256 <consoleread+0xe8>
        release(&cons.lock);
    80000244:	00011517          	auipc	a0,0x11
    80000248:	5ec50513          	addi	a0,a0,1516 # 80011830 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	a78080e7          	jalr	-1416(ra) # 80000cc4 <release>
        return -1;
    80000254:	557d                	li	a0,-1
}
    80000256:	70e6                	ld	ra,120(sp)
    80000258:	7446                	ld	s0,112(sp)
    8000025a:	74a6                	ld	s1,104(sp)
    8000025c:	7906                	ld	s2,96(sp)
    8000025e:	69e6                	ld	s3,88(sp)
    80000260:	6a46                	ld	s4,80(sp)
    80000262:	6aa6                	ld	s5,72(sp)
    80000264:	6b06                	ld	s6,64(sp)
    80000266:	7be2                	ld	s7,56(sp)
    80000268:	7c42                	ld	s8,48(sp)
    8000026a:	7ca2                	ld	s9,40(sp)
    8000026c:	7d02                	ld	s10,32(sp)
    8000026e:	6de2                	ld	s11,24(sp)
    80000270:	6109                	addi	sp,sp,128
    80000272:	8082                	ret
      if(n < target){
    80000274:	000a071b          	sext.w	a4,s4
    80000278:	fb777be3          	bgeu	a4,s7,8000022e <consoleread+0xc0>
        cons.r--;
    8000027c:	00011717          	auipc	a4,0x11
    80000280:	64f72623          	sw	a5,1612(a4) # 800118c8 <cons+0x98>
    80000284:	b76d                	j	8000022e <consoleread+0xc0>

0000000080000286 <consputc>:
{
    80000286:	1141                	addi	sp,sp,-16
    80000288:	e406                	sd	ra,8(sp)
    8000028a:	e022                	sd	s0,0(sp)
    8000028c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028e:	10000793          	li	a5,256
    80000292:	00f50a63          	beq	a0,a5,800002a6 <consputc+0x20>
    uartputc_sync(c);
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	564080e7          	jalr	1380(ra) # 800007fa <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	552080e7          	jalr	1362(ra) # 800007fa <uartputc_sync>
    800002b0:	02000513          	li	a0,32
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	546080e7          	jalr	1350(ra) # 800007fa <uartputc_sync>
    800002bc:	4521                	li	a0,8
    800002be:	00000097          	auipc	ra,0x0
    800002c2:	53c080e7          	jalr	1340(ra) # 800007fa <uartputc_sync>
    800002c6:	bfe1                	j	8000029e <consputc+0x18>

00000000800002c8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c8:	1101                	addi	sp,sp,-32
    800002ca:	ec06                	sd	ra,24(sp)
    800002cc:	e822                	sd	s0,16(sp)
    800002ce:	e426                	sd	s1,8(sp)
    800002d0:	e04a                	sd	s2,0(sp)
    800002d2:	1000                	addi	s0,sp,32
    800002d4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d6:	00011517          	auipc	a0,0x11
    800002da:	55a50513          	addi	a0,a0,1370 # 80011830 <cons>
    800002de:	00001097          	auipc	ra,0x1
    800002e2:	932080e7          	jalr	-1742(ra) # 80000c10 <acquire>

  switch(c){
    800002e6:	47d5                	li	a5,21
    800002e8:	0af48663          	beq	s1,a5,80000394 <consoleintr+0xcc>
    800002ec:	0297ca63          	blt	a5,s1,80000320 <consoleintr+0x58>
    800002f0:	47a1                	li	a5,8
    800002f2:	0ef48763          	beq	s1,a5,800003e0 <consoleintr+0x118>
    800002f6:	47c1                	li	a5,16
    800002f8:	10f49a63          	bne	s1,a5,8000040c <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002fc:	00002097          	auipc	ra,0x2
    80000300:	1fc080e7          	jalr	508(ra) # 800024f8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	52c50513          	addi	a0,a0,1324 # 80011830 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	9b8080e7          	jalr	-1608(ra) # 80000cc4 <release>
}
    80000314:	60e2                	ld	ra,24(sp)
    80000316:	6442                	ld	s0,16(sp)
    80000318:	64a2                	ld	s1,8(sp)
    8000031a:	6902                	ld	s2,0(sp)
    8000031c:	6105                	addi	sp,sp,32
    8000031e:	8082                	ret
  switch(c){
    80000320:	07f00793          	li	a5,127
    80000324:	0af48e63          	beq	s1,a5,800003e0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000328:	00011717          	auipc	a4,0x11
    8000032c:	50870713          	addi	a4,a4,1288 # 80011830 <cons>
    80000330:	0a072783          	lw	a5,160(a4)
    80000334:	09872703          	lw	a4,152(a4)
    80000338:	9f99                	subw	a5,a5,a4
    8000033a:	07f00713          	li	a4,127
    8000033e:	fcf763e3          	bltu	a4,a5,80000304 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000342:	47b5                	li	a5,13
    80000344:	0cf48763          	beq	s1,a5,80000412 <consoleintr+0x14a>
      consputc(c);
    80000348:	8526                	mv	a0,s1
    8000034a:	00000097          	auipc	ra,0x0
    8000034e:	f3c080e7          	jalr	-196(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000352:	00011797          	auipc	a5,0x11
    80000356:	4de78793          	addi	a5,a5,1246 # 80011830 <cons>
    8000035a:	0a07a703          	lw	a4,160(a5)
    8000035e:	0017069b          	addiw	a3,a4,1
    80000362:	0006861b          	sext.w	a2,a3
    80000366:	0ad7a023          	sw	a3,160(a5)
    8000036a:	07f77713          	andi	a4,a4,127
    8000036e:	97ba                	add	a5,a5,a4
    80000370:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000374:	47a9                	li	a5,10
    80000376:	0cf48563          	beq	s1,a5,80000440 <consoleintr+0x178>
    8000037a:	4791                	li	a5,4
    8000037c:	0cf48263          	beq	s1,a5,80000440 <consoleintr+0x178>
    80000380:	00011797          	auipc	a5,0x11
    80000384:	5487a783          	lw	a5,1352(a5) # 800118c8 <cons+0x98>
    80000388:	0807879b          	addiw	a5,a5,128
    8000038c:	f6f61ce3          	bne	a2,a5,80000304 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000390:	863e                	mv	a2,a5
    80000392:	a07d                	j	80000440 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000394:	00011717          	auipc	a4,0x11
    80000398:	49c70713          	addi	a4,a4,1180 # 80011830 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a4:	00011497          	auipc	s1,0x11
    800003a8:	48c48493          	addi	s1,s1,1164 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003ac:	4929                	li	s2,10
    800003ae:	f4f70be3          	beq	a4,a5,80000304 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b2:	37fd                	addiw	a5,a5,-1
    800003b4:	07f7f713          	andi	a4,a5,127
    800003b8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ba:	01874703          	lbu	a4,24(a4)
    800003be:	f52703e3          	beq	a4,s2,80000304 <consoleintr+0x3c>
      cons.e--;
    800003c2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c6:	10000513          	li	a0,256
    800003ca:	00000097          	auipc	ra,0x0
    800003ce:	ebc080e7          	jalr	-324(ra) # 80000286 <consputc>
    while(cons.e != cons.w &&
    800003d2:	0a04a783          	lw	a5,160(s1)
    800003d6:	09c4a703          	lw	a4,156(s1)
    800003da:	fcf71ce3          	bne	a4,a5,800003b2 <consoleintr+0xea>
    800003de:	b71d                	j	80000304 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e0:	00011717          	auipc	a4,0x11
    800003e4:	45070713          	addi	a4,a4,1104 # 80011830 <cons>
    800003e8:	0a072783          	lw	a5,160(a4)
    800003ec:	09c72703          	lw	a4,156(a4)
    800003f0:	f0f70ae3          	beq	a4,a5,80000304 <consoleintr+0x3c>
      cons.e--;
    800003f4:	37fd                	addiw	a5,a5,-1
    800003f6:	00011717          	auipc	a4,0x11
    800003fa:	4cf72d23          	sw	a5,1242(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fe:	10000513          	li	a0,256
    80000402:	00000097          	auipc	ra,0x0
    80000406:	e84080e7          	jalr	-380(ra) # 80000286 <consputc>
    8000040a:	bded                	j	80000304 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000040c:	ee048ce3          	beqz	s1,80000304 <consoleintr+0x3c>
    80000410:	bf21                	j	80000328 <consoleintr+0x60>
      consputc(c);
    80000412:	4529                	li	a0,10
    80000414:	00000097          	auipc	ra,0x0
    80000418:	e72080e7          	jalr	-398(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000041c:	00011797          	auipc	a5,0x11
    80000420:	41478793          	addi	a5,a5,1044 # 80011830 <cons>
    80000424:	0a07a703          	lw	a4,160(a5)
    80000428:	0017069b          	addiw	a3,a4,1
    8000042c:	0006861b          	sext.w	a2,a3
    80000430:	0ad7a023          	sw	a3,160(a5)
    80000434:	07f77713          	andi	a4,a4,127
    80000438:	97ba                	add	a5,a5,a4
    8000043a:	4729                	li	a4,10
    8000043c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000440:	00011797          	auipc	a5,0x11
    80000444:	48c7a623          	sw	a2,1164(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000448:	00011517          	auipc	a0,0x11
    8000044c:	48050513          	addi	a0,a0,1152 # 800118c8 <cons+0x98>
    80000450:	00002097          	auipc	ra,0x2
    80000454:	f20080e7          	jalr	-224(ra) # 80002370 <wakeup>
    80000458:	b575                	j	80000304 <consoleintr+0x3c>

000000008000045a <consoleinit>:

void
consoleinit(void)
{
    8000045a:	1141                	addi	sp,sp,-16
    8000045c:	e406                	sd	ra,8(sp)
    8000045e:	e022                	sd	s0,0(sp)
    80000460:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000462:	00008597          	auipc	a1,0x8
    80000466:	bae58593          	addi	a1,a1,-1106 # 80008010 <etext+0x10>
    8000046a:	00011517          	auipc	a0,0x11
    8000046e:	3c650513          	addi	a0,a0,966 # 80011830 <cons>
    80000472:	00000097          	auipc	ra,0x0
    80000476:	70e080e7          	jalr	1806(ra) # 80000b80 <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	330080e7          	jalr	816(ra) # 800007aa <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00021797          	auipc	a5,0x21
    80000486:	52e78793          	addi	a5,a5,1326 # 800219b0 <devsw>
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	ce470713          	addi	a4,a4,-796 # 8000016e <consoleread>
    80000492:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000494:	00000717          	auipc	a4,0x0
    80000498:	c5870713          	addi	a4,a4,-936 # 800000ec <consolewrite>
    8000049c:	ef98                	sd	a4,24(a5)
}
    8000049e:	60a2                	ld	ra,8(sp)
    800004a0:	6402                	ld	s0,0(sp)
    800004a2:	0141                	addi	sp,sp,16
    800004a4:	8082                	ret

00000000800004a6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a6:	7179                	addi	sp,sp,-48
    800004a8:	f406                	sd	ra,40(sp)
    800004aa:	f022                	sd	s0,32(sp)
    800004ac:	ec26                	sd	s1,24(sp)
    800004ae:	e84a                	sd	s2,16(sp)
    800004b0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b2:	c219                	beqz	a2,800004b8 <printint+0x12>
    800004b4:	08054663          	bltz	a0,80000540 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b8:	2501                	sext.w	a0,a0
    800004ba:	4881                	li	a7,0
    800004bc:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c2:	2581                	sext.w	a1,a1
    800004c4:	00008617          	auipc	a2,0x8
    800004c8:	b7c60613          	addi	a2,a2,-1156 # 80008040 <digits>
    800004cc:	883a                	mv	a6,a4
    800004ce:	2705                	addiw	a4,a4,1
    800004d0:	02b577bb          	remuw	a5,a0,a1
    800004d4:	1782                	slli	a5,a5,0x20
    800004d6:	9381                	srli	a5,a5,0x20
    800004d8:	97b2                	add	a5,a5,a2
    800004da:	0007c783          	lbu	a5,0(a5)
    800004de:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e2:	0005079b          	sext.w	a5,a0
    800004e6:	02b5553b          	divuw	a0,a0,a1
    800004ea:	0685                	addi	a3,a3,1
    800004ec:	feb7f0e3          	bgeu	a5,a1,800004cc <printint+0x26>

  if(sign)
    800004f0:	00088b63          	beqz	a7,80000506 <printint+0x60>
    buf[i++] = '-';
    800004f4:	fe040793          	addi	a5,s0,-32
    800004f8:	973e                	add	a4,a4,a5
    800004fa:	02d00793          	li	a5,45
    800004fe:	fef70823          	sb	a5,-16(a4)
    80000502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000506:	02e05763          	blez	a4,80000534 <printint+0x8e>
    8000050a:	fd040793          	addi	a5,s0,-48
    8000050e:	00e784b3          	add	s1,a5,a4
    80000512:	fff78913          	addi	s2,a5,-1
    80000516:	993a                	add	s2,s2,a4
    80000518:	377d                	addiw	a4,a4,-1
    8000051a:	1702                	slli	a4,a4,0x20
    8000051c:	9301                	srli	a4,a4,0x20
    8000051e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000522:	fff4c503          	lbu	a0,-1(s1)
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	d60080e7          	jalr	-672(ra) # 80000286 <consputc>
  while(--i >= 0)
    8000052e:	14fd                	addi	s1,s1,-1
    80000530:	ff2499e3          	bne	s1,s2,80000522 <printint+0x7c>
}
    80000534:	70a2                	ld	ra,40(sp)
    80000536:	7402                	ld	s0,32(sp)
    80000538:	64e2                	ld	s1,24(sp)
    8000053a:	6942                	ld	s2,16(sp)
    8000053c:	6145                	addi	sp,sp,48
    8000053e:	8082                	ret
    x = -xx;
    80000540:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000544:	4885                	li	a7,1
    x = -xx;
    80000546:	bf9d                	j	800004bc <printint+0x16>

0000000080000548 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
    80000552:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000554:	00011797          	auipc	a5,0x11
    80000558:	3807ae23          	sw	zero,924(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	abc50513          	addi	a0,a0,-1348 # 80008018 <etext+0x18>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
  printf("\n");
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	b5250513          	addi	a0,a0,-1198 # 800080c8 <digits+0x88>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	014080e7          	jalr	20(ra) # 80000592 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000586:	4785                	li	a5,1
    80000588:	00009717          	auipc	a4,0x9
    8000058c:	a6f72c23          	sw	a5,-1416(a4) # 80009000 <panicked>
  for(;;)
    80000590:	a001                	j	80000590 <panic+0x48>

0000000080000592 <printf>:
{
    80000592:	7131                	addi	sp,sp,-192
    80000594:	fc86                	sd	ra,120(sp)
    80000596:	f8a2                	sd	s0,112(sp)
    80000598:	f4a6                	sd	s1,104(sp)
    8000059a:	f0ca                	sd	s2,96(sp)
    8000059c:	ecce                	sd	s3,88(sp)
    8000059e:	e8d2                	sd	s4,80(sp)
    800005a0:	e4d6                	sd	s5,72(sp)
    800005a2:	e0da                	sd	s6,64(sp)
    800005a4:	fc5e                	sd	s7,56(sp)
    800005a6:	f862                	sd	s8,48(sp)
    800005a8:	f466                	sd	s9,40(sp)
    800005aa:	f06a                	sd	s10,32(sp)
    800005ac:	ec6e                	sd	s11,24(sp)
    800005ae:	0100                	addi	s0,sp,128
    800005b0:	8a2a                	mv	s4,a0
    800005b2:	e40c                	sd	a1,8(s0)
    800005b4:	e810                	sd	a2,16(s0)
    800005b6:	ec14                	sd	a3,24(s0)
    800005b8:	f018                	sd	a4,32(s0)
    800005ba:	f41c                	sd	a5,40(s0)
    800005bc:	03043823          	sd	a6,48(s0)
    800005c0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c4:	00011d97          	auipc	s11,0x11
    800005c8:	32cdad83          	lw	s11,812(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005cc:	020d9b63          	bnez	s11,80000602 <printf+0x70>
  if (fmt == 0)
    800005d0:	040a0263          	beqz	s4,80000614 <printf+0x82>
  va_start(ap, fmt);
    800005d4:	00840793          	addi	a5,s0,8
    800005d8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005dc:	000a4503          	lbu	a0,0(s4)
    800005e0:	16050263          	beqz	a0,80000744 <printf+0x1b2>
    800005e4:	4481                	li	s1,0
    if(c != '%'){
    800005e6:	02500a93          	li	s5,37
    switch(c){
    800005ea:	07000b13          	li	s6,112
  consputc('x');
    800005ee:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f0:	00008b97          	auipc	s7,0x8
    800005f4:	a50b8b93          	addi	s7,s7,-1456 # 80008040 <digits>
    switch(c){
    800005f8:	07300c93          	li	s9,115
    800005fc:	06400c13          	li	s8,100
    80000600:	a82d                	j	8000063a <printf+0xa8>
    acquire(&pr.lock);
    80000602:	00011517          	auipc	a0,0x11
    80000606:	2d650513          	addi	a0,a0,726 # 800118d8 <pr>
    8000060a:	00000097          	auipc	ra,0x0
    8000060e:	606080e7          	jalr	1542(ra) # 80000c10 <acquire>
    80000612:	bf7d                	j	800005d0 <printf+0x3e>
    panic("null fmt");
    80000614:	00008517          	auipc	a0,0x8
    80000618:	a1450513          	addi	a0,a0,-1516 # 80008028 <etext+0x28>
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	f2c080e7          	jalr	-212(ra) # 80000548 <panic>
      consputc(c);
    80000624:	00000097          	auipc	ra,0x0
    80000628:	c62080e7          	jalr	-926(ra) # 80000286 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062c:	2485                	addiw	s1,s1,1
    8000062e:	009a07b3          	add	a5,s4,s1
    80000632:	0007c503          	lbu	a0,0(a5)
    80000636:	10050763          	beqz	a0,80000744 <printf+0x1b2>
    if(c != '%'){
    8000063a:	ff5515e3          	bne	a0,s5,80000624 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063e:	2485                	addiw	s1,s1,1
    80000640:	009a07b3          	add	a5,s4,s1
    80000644:	0007c783          	lbu	a5,0(a5)
    80000648:	0007891b          	sext.w	s2,a5
    if(c == 0)
    8000064c:	cfe5                	beqz	a5,80000744 <printf+0x1b2>
    switch(c){
    8000064e:	05678a63          	beq	a5,s6,800006a2 <printf+0x110>
    80000652:	02fb7663          	bgeu	s6,a5,8000067e <printf+0xec>
    80000656:	09978963          	beq	a5,s9,800006e8 <printf+0x156>
    8000065a:	07800713          	li	a4,120
    8000065e:	0ce79863          	bne	a5,a4,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000662:	f8843783          	ld	a5,-120(s0)
    80000666:	00878713          	addi	a4,a5,8
    8000066a:	f8e43423          	sd	a4,-120(s0)
    8000066e:	4605                	li	a2,1
    80000670:	85ea                	mv	a1,s10
    80000672:	4388                	lw	a0,0(a5)
    80000674:	00000097          	auipc	ra,0x0
    80000678:	e32080e7          	jalr	-462(ra) # 800004a6 <printint>
      break;
    8000067c:	bf45                	j	8000062c <printf+0x9a>
    switch(c){
    8000067e:	0b578263          	beq	a5,s5,80000722 <printf+0x190>
    80000682:	0b879663          	bne	a5,s8,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4605                	li	a2,1
    80000694:	45a9                	li	a1,10
    80000696:	4388                	lw	a0,0(a5)
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	e0e080e7          	jalr	-498(ra) # 800004a6 <printint>
      break;
    800006a0:	b771                	j	8000062c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006b2:	03000513          	li	a0,48
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bd0080e7          	jalr	-1072(ra) # 80000286 <consputc>
  consputc('x');
    800006be:	07800513          	li	a0,120
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	bc4080e7          	jalr	-1084(ra) # 80000286 <consputc>
    800006ca:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006cc:	03c9d793          	srli	a5,s3,0x3c
    800006d0:	97de                	add	a5,a5,s7
    800006d2:	0007c503          	lbu	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	bb0080e7          	jalr	-1104(ra) # 80000286 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006de:	0992                	slli	s3,s3,0x4
    800006e0:	397d                	addiw	s2,s2,-1
    800006e2:	fe0915e3          	bnez	s2,800006cc <printf+0x13a>
    800006e6:	b799                	j	8000062c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	0007b903          	ld	s2,0(a5)
    800006f8:	00090e63          	beqz	s2,80000714 <printf+0x182>
      for(; *s; s++)
    800006fc:	00094503          	lbu	a0,0(s2)
    80000700:	d515                	beqz	a0,8000062c <printf+0x9a>
        consputc(*s);
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b84080e7          	jalr	-1148(ra) # 80000286 <consputc>
      for(; *s; s++)
    8000070a:	0905                	addi	s2,s2,1
    8000070c:	00094503          	lbu	a0,0(s2)
    80000710:	f96d                	bnez	a0,80000702 <printf+0x170>
    80000712:	bf29                	j	8000062c <printf+0x9a>
        s = "(null)";
    80000714:	00008917          	auipc	s2,0x8
    80000718:	90c90913          	addi	s2,s2,-1780 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000071c:	02800513          	li	a0,40
    80000720:	b7cd                	j	80000702 <printf+0x170>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b62080e7          	jalr	-1182(ra) # 80000286 <consputc>
      break;
    8000072c:	b701                	j	8000062c <printf+0x9a>
      consputc('%');
    8000072e:	8556                	mv	a0,s5
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b56080e7          	jalr	-1194(ra) # 80000286 <consputc>
      consputc(c);
    80000738:	854a                	mv	a0,s2
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	b4c080e7          	jalr	-1204(ra) # 80000286 <consputc>
      break;
    80000742:	b5ed                	j	8000062c <printf+0x9a>
  if(locking)
    80000744:	020d9163          	bnez	s11,80000766 <printf+0x1d4>
}
    80000748:	70e6                	ld	ra,120(sp)
    8000074a:	7446                	ld	s0,112(sp)
    8000074c:	74a6                	ld	s1,104(sp)
    8000074e:	7906                	ld	s2,96(sp)
    80000750:	69e6                	ld	s3,88(sp)
    80000752:	6a46                	ld	s4,80(sp)
    80000754:	6aa6                	ld	s5,72(sp)
    80000756:	6b06                	ld	s6,64(sp)
    80000758:	7be2                	ld	s7,56(sp)
    8000075a:	7c42                	ld	s8,48(sp)
    8000075c:	7ca2                	ld	s9,40(sp)
    8000075e:	7d02                	ld	s10,32(sp)
    80000760:	6de2                	ld	s11,24(sp)
    80000762:	6129                	addi	sp,sp,192
    80000764:	8082                	ret
    release(&pr.lock);
    80000766:	00011517          	auipc	a0,0x11
    8000076a:	17250513          	addi	a0,a0,370 # 800118d8 <pr>
    8000076e:	00000097          	auipc	ra,0x0
    80000772:	556080e7          	jalr	1366(ra) # 80000cc4 <release>
}
    80000776:	bfc9                	j	80000748 <printf+0x1b6>

0000000080000778 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000778:	1101                	addi	sp,sp,-32
    8000077a:	ec06                	sd	ra,24(sp)
    8000077c:	e822                	sd	s0,16(sp)
    8000077e:	e426                	sd	s1,8(sp)
    80000780:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000782:	00011497          	auipc	s1,0x11
    80000786:	15648493          	addi	s1,s1,342 # 800118d8 <pr>
    8000078a:	00008597          	auipc	a1,0x8
    8000078e:	8ae58593          	addi	a1,a1,-1874 # 80008038 <etext+0x38>
    80000792:	8526                	mv	a0,s1
    80000794:	00000097          	auipc	ra,0x0
    80000798:	3ec080e7          	jalr	1004(ra) # 80000b80 <initlock>
  pr.locking = 1;
    8000079c:	4785                	li	a5,1
    8000079e:	cc9c                	sw	a5,24(s1)
}
    800007a0:	60e2                	ld	ra,24(sp)
    800007a2:	6442                	ld	s0,16(sp)
    800007a4:	64a2                	ld	s1,8(sp)
    800007a6:	6105                	addi	sp,sp,32
    800007a8:	8082                	ret

00000000800007aa <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007aa:	1141                	addi	sp,sp,-16
    800007ac:	e406                	sd	ra,8(sp)
    800007ae:	e022                	sd	s0,0(sp)
    800007b0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b2:	100007b7          	lui	a5,0x10000
    800007b6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ba:	f8000713          	li	a4,-128
    800007be:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c2:	470d                	li	a4,3
    800007c4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007cc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d0:	469d                	li	a3,7
    800007d2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007da:	00008597          	auipc	a1,0x8
    800007de:	87e58593          	addi	a1,a1,-1922 # 80008058 <digits+0x18>
    800007e2:	00011517          	auipc	a0,0x11
    800007e6:	11650513          	addi	a0,a0,278 # 800118f8 <uart_tx_lock>
    800007ea:	00000097          	auipc	ra,0x0
    800007ee:	396080e7          	jalr	918(ra) # 80000b80 <initlock>
}
    800007f2:	60a2                	ld	ra,8(sp)
    800007f4:	6402                	ld	s0,0(sp)
    800007f6:	0141                	addi	sp,sp,16
    800007f8:	8082                	ret

00000000800007fa <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fa:	1101                	addi	sp,sp,-32
    800007fc:	ec06                	sd	ra,24(sp)
    800007fe:	e822                	sd	s0,16(sp)
    80000800:	e426                	sd	s1,8(sp)
    80000802:	1000                	addi	s0,sp,32
    80000804:	84aa                	mv	s1,a0
  push_off();
    80000806:	00000097          	auipc	ra,0x0
    8000080a:	3be080e7          	jalr	958(ra) # 80000bc4 <push_off>

  if(panicked){
    8000080e:	00008797          	auipc	a5,0x8
    80000812:	7f27a783          	lw	a5,2034(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000816:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081a:	c391                	beqz	a5,8000081e <uartputc_sync+0x24>
    for(;;)
    8000081c:	a001                	j	8000081c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000822:	0ff7f793          	andi	a5,a5,255
    80000826:	0207f793          	andi	a5,a5,32
    8000082a:	dbf5                	beqz	a5,8000081e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082c:	0ff4f793          	andi	a5,s1,255
    80000830:	10000737          	lui	a4,0x10000
    80000834:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	42c080e7          	jalr	1068(ra) # 80000c64 <pop_off>
}
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	7ba7a783          	lw	a5,1978(a5) # 80009004 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	7b672703          	lw	a4,1974(a4) # 80009008 <uart_tx_w>
    8000085a:	08f70263          	beq	a4,a5,800008de <uartstart+0x94>
{
    8000085e:	7139                	addi	sp,sp,-64
    80000860:	fc06                	sd	ra,56(sp)
    80000862:	f822                	sd	s0,48(sp)
    80000864:	f426                	sd	s1,40(sp)
    80000866:	f04a                	sd	s2,32(sp)
    80000868:	ec4e                	sd	s3,24(sp)
    8000086a:	e852                	sd	s4,16(sp)
    8000086c:	e456                	sd	s5,8(sp)
    8000086e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000870:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000874:	00011a17          	auipc	s4,0x11
    80000878:	084a0a13          	addi	s4,s4,132 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	78848493          	addi	s1,s1,1928 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	78498993          	addi	s3,s3,1924 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000890:	0ff77713          	andi	a4,a4,255
    80000894:	02077713          	andi	a4,a4,32
    80000898:	cb15                	beqz	a4,800008cc <uartstart+0x82>
    int c = uart_tx_buf[uart_tx_r];
    8000089a:	00fa0733          	add	a4,s4,a5
    8000089e:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008a2:	2785                	addiw	a5,a5,1
    800008a4:	41f7d71b          	sraiw	a4,a5,0x1f
    800008a8:	01b7571b          	srliw	a4,a4,0x1b
    800008ac:	9fb9                	addw	a5,a5,a4
    800008ae:	8bfd                	andi	a5,a5,31
    800008b0:	9f99                	subw	a5,a5,a4
    800008b2:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008b4:	8526                	mv	a0,s1
    800008b6:	00002097          	auipc	ra,0x2
    800008ba:	aba080e7          	jalr	-1350(ra) # 80002370 <wakeup>
    
    WriteReg(THR, c);
    800008be:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008c2:	409c                	lw	a5,0(s1)
    800008c4:	0009a703          	lw	a4,0(s3)
    800008c8:	fcf712e3          	bne	a4,a5,8000088c <uartstart+0x42>
  }
}
    800008cc:	70e2                	ld	ra,56(sp)
    800008ce:	7442                	ld	s0,48(sp)
    800008d0:	74a2                	ld	s1,40(sp)
    800008d2:	7902                	ld	s2,32(sp)
    800008d4:	69e2                	ld	s3,24(sp)
    800008d6:	6a42                	ld	s4,16(sp)
    800008d8:	6aa2                	ld	s5,8(sp)
    800008da:	6121                	addi	sp,sp,64
    800008dc:	8082                	ret
    800008de:	8082                	ret

00000000800008e0 <uartputc>:
{
    800008e0:	7179                	addi	sp,sp,-48
    800008e2:	f406                	sd	ra,40(sp)
    800008e4:	f022                	sd	s0,32(sp)
    800008e6:	ec26                	sd	s1,24(sp)
    800008e8:	e84a                	sd	s2,16(sp)
    800008ea:	e44e                	sd	s3,8(sp)
    800008ec:	e052                	sd	s4,0(sp)
    800008ee:	1800                	addi	s0,sp,48
    800008f0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008f2:	00011517          	auipc	a0,0x11
    800008f6:	00650513          	addi	a0,a0,6 # 800118f8 <uart_tx_lock>
    800008fa:	00000097          	auipc	ra,0x0
    800008fe:	316080e7          	jalr	790(ra) # 80000c10 <acquire>
  if(panicked){
    80000902:	00008797          	auipc	a5,0x8
    80000906:	6fe7a783          	lw	a5,1790(a5) # 80009000 <panicked>
    8000090a:	c391                	beqz	a5,8000090e <uartputc+0x2e>
    for(;;)
    8000090c:	a001                	j	8000090c <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000090e:	00008717          	auipc	a4,0x8
    80000912:	6fa72703          	lw	a4,1786(a4) # 80009008 <uart_tx_w>
    80000916:	0017079b          	addiw	a5,a4,1
    8000091a:	41f7d69b          	sraiw	a3,a5,0x1f
    8000091e:	01b6d69b          	srliw	a3,a3,0x1b
    80000922:	9fb5                	addw	a5,a5,a3
    80000924:	8bfd                	andi	a5,a5,31
    80000926:	9f95                	subw	a5,a5,a3
    80000928:	00008697          	auipc	a3,0x8
    8000092c:	6dc6a683          	lw	a3,1756(a3) # 80009004 <uart_tx_r>
    80000930:	04f69263          	bne	a3,a5,80000974 <uartputc+0x94>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000934:	00011a17          	auipc	s4,0x11
    80000938:	fc4a0a13          	addi	s4,s4,-60 # 800118f8 <uart_tx_lock>
    8000093c:	00008497          	auipc	s1,0x8
    80000940:	6c848493          	addi	s1,s1,1736 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000944:	00008917          	auipc	s2,0x8
    80000948:	6c490913          	addi	s2,s2,1732 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000094c:	85d2                	mv	a1,s4
    8000094e:	8526                	mv	a0,s1
    80000950:	00002097          	auipc	ra,0x2
    80000954:	89a080e7          	jalr	-1894(ra) # 800021ea <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000958:	00092703          	lw	a4,0(s2)
    8000095c:	0017079b          	addiw	a5,a4,1
    80000960:	41f7d69b          	sraiw	a3,a5,0x1f
    80000964:	01b6d69b          	srliw	a3,a3,0x1b
    80000968:	9fb5                	addw	a5,a5,a3
    8000096a:	8bfd                	andi	a5,a5,31
    8000096c:	9f95                	subw	a5,a5,a3
    8000096e:	4094                	lw	a3,0(s1)
    80000970:	fcf68ee3          	beq	a3,a5,8000094c <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000974:	00011497          	auipc	s1,0x11
    80000978:	f8448493          	addi	s1,s1,-124 # 800118f8 <uart_tx_lock>
    8000097c:	9726                	add	a4,a4,s1
    8000097e:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000982:	00008717          	auipc	a4,0x8
    80000986:	68f72323          	sw	a5,1670(a4) # 80009008 <uart_tx_w>
      uartstart();
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	ec0080e7          	jalr	-320(ra) # 8000084a <uartstart>
      release(&uart_tx_lock);
    80000992:	8526                	mv	a0,s1
    80000994:	00000097          	auipc	ra,0x0
    80000998:	330080e7          	jalr	816(ra) # 80000cc4 <release>
}
    8000099c:	70a2                	ld	ra,40(sp)
    8000099e:	7402                	ld	s0,32(sp)
    800009a0:	64e2                	ld	s1,24(sp)
    800009a2:	6942                	ld	s2,16(sp)
    800009a4:	69a2                	ld	s3,8(sp)
    800009a6:	6a02                	ld	s4,0(sp)
    800009a8:	6145                	addi	sp,sp,48
    800009aa:	8082                	ret

00000000800009ac <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009ac:	1141                	addi	sp,sp,-16
    800009ae:	e422                	sd	s0,8(sp)
    800009b0:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009b2:	100007b7          	lui	a5,0x10000
    800009b6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ba:	8b85                	andi	a5,a5,1
    800009bc:	cb91                	beqz	a5,800009d0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009be:	100007b7          	lui	a5,0x10000
    800009c2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009c6:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009ca:	6422                	ld	s0,8(sp)
    800009cc:	0141                	addi	sp,sp,16
    800009ce:	8082                	ret
    return -1;
    800009d0:	557d                	li	a0,-1
    800009d2:	bfe5                	j	800009ca <uartgetc+0x1e>

00000000800009d4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009d4:	1101                	addi	sp,sp,-32
    800009d6:	ec06                	sd	ra,24(sp)
    800009d8:	e822                	sd	s0,16(sp)
    800009da:	e426                	sd	s1,8(sp)
    800009dc:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009de:	54fd                	li	s1,-1
    int c = uartgetc();
    800009e0:	00000097          	auipc	ra,0x0
    800009e4:	fcc080e7          	jalr	-52(ra) # 800009ac <uartgetc>
    if(c == -1)
    800009e8:	00950763          	beq	a0,s1,800009f6 <uartintr+0x22>
      break;
    consoleintr(c);
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	8dc080e7          	jalr	-1828(ra) # 800002c8 <consoleintr>
  while(1){
    800009f4:	b7f5                	j	800009e0 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009f6:	00011497          	auipc	s1,0x11
    800009fa:	f0248493          	addi	s1,s1,-254 # 800118f8 <uart_tx_lock>
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	210080e7          	jalr	528(ra) # 80000c10 <acquire>
  uartstart();
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	e42080e7          	jalr	-446(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    80000a10:	8526                	mv	a0,s1
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	2b2080e7          	jalr	690(ra) # 80000cc4 <release>
}
    80000a1a:	60e2                	ld	ra,24(sp)
    80000a1c:	6442                	ld	s0,16(sp)
    80000a1e:	64a2                	ld	s1,8(sp)
    80000a20:	6105                	addi	sp,sp,32
    80000a22:	8082                	ret

0000000080000a24 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a24:	1101                	addi	sp,sp,-32
    80000a26:	ec06                	sd	ra,24(sp)
    80000a28:	e822                	sd	s0,16(sp)
    80000a2a:	e426                	sd	s1,8(sp)
    80000a2c:	e04a                	sd	s2,0(sp)
    80000a2e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a30:	03451793          	slli	a5,a0,0x34
    80000a34:	ebb9                	bnez	a5,80000a8a <kfree+0x66>
    80000a36:	84aa                	mv	s1,a0
    80000a38:	00025797          	auipc	a5,0x25
    80000a3c:	5c878793          	addi	a5,a5,1480 # 80026000 <end>
    80000a40:	04f56563          	bltu	a0,a5,80000a8a <kfree+0x66>
    80000a44:	47c5                	li	a5,17
    80000a46:	07ee                	slli	a5,a5,0x1b
    80000a48:	04f57163          	bgeu	a0,a5,80000a8a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a4c:	6605                	lui	a2,0x1
    80000a4e:	4585                	li	a1,1
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	2bc080e7          	jalr	700(ra) # 80000d0c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a58:	00011917          	auipc	s2,0x11
    80000a5c:	ed890913          	addi	s2,s2,-296 # 80011930 <kmem>
    80000a60:	854a                	mv	a0,s2
    80000a62:	00000097          	auipc	ra,0x0
    80000a66:	1ae080e7          	jalr	430(ra) # 80000c10 <acquire>
  r->next = kmem.freelist;
    80000a6a:	01893783          	ld	a5,24(s2)
    80000a6e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a70:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a74:	854a                	mv	a0,s2
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	24e080e7          	jalr	590(ra) # 80000cc4 <release>
}
    80000a7e:	60e2                	ld	ra,24(sp)
    80000a80:	6442                	ld	s0,16(sp)
    80000a82:	64a2                	ld	s1,8(sp)
    80000a84:	6902                	ld	s2,0(sp)
    80000a86:	6105                	addi	sp,sp,32
    80000a88:	8082                	ret
    panic("kfree");
    80000a8a:	00007517          	auipc	a0,0x7
    80000a8e:	5d650513          	addi	a0,a0,1494 # 80008060 <digits+0x20>
    80000a92:	00000097          	auipc	ra,0x0
    80000a96:	ab6080e7          	jalr	-1354(ra) # 80000548 <panic>

0000000080000a9a <freerange>:
{
    80000a9a:	7179                	addi	sp,sp,-48
    80000a9c:	f406                	sd	ra,40(sp)
    80000a9e:	f022                	sd	s0,32(sp)
    80000aa0:	ec26                	sd	s1,24(sp)
    80000aa2:	e84a                	sd	s2,16(sp)
    80000aa4:	e44e                	sd	s3,8(sp)
    80000aa6:	e052                	sd	s4,0(sp)
    80000aa8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aaa:	6785                	lui	a5,0x1
    80000aac:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000ab0:	94aa                	add	s1,s1,a0
    80000ab2:	757d                	lui	a0,0xfffff
    80000ab4:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab6:	94be                	add	s1,s1,a5
    80000ab8:	0095ee63          	bltu	a1,s1,80000ad4 <freerange+0x3a>
    80000abc:	892e                	mv	s2,a1
    kfree(p);
    80000abe:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	6985                	lui	s3,0x1
    kfree(p);
    80000ac2:	01448533          	add	a0,s1,s4
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	f5e080e7          	jalr	-162(ra) # 80000a24 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ace:	94ce                	add	s1,s1,s3
    80000ad0:	fe9979e3          	bgeu	s2,s1,80000ac2 <freerange+0x28>
}
    80000ad4:	70a2                	ld	ra,40(sp)
    80000ad6:	7402                	ld	s0,32(sp)
    80000ad8:	64e2                	ld	s1,24(sp)
    80000ada:	6942                	ld	s2,16(sp)
    80000adc:	69a2                	ld	s3,8(sp)
    80000ade:	6a02                	ld	s4,0(sp)
    80000ae0:	6145                	addi	sp,sp,48
    80000ae2:	8082                	ret

0000000080000ae4 <kinit>:
{
    80000ae4:	1141                	addi	sp,sp,-16
    80000ae6:	e406                	sd	ra,8(sp)
    80000ae8:	e022                	sd	s0,0(sp)
    80000aea:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aec:	00007597          	auipc	a1,0x7
    80000af0:	57c58593          	addi	a1,a1,1404 # 80008068 <digits+0x28>
    80000af4:	00011517          	auipc	a0,0x11
    80000af8:	e3c50513          	addi	a0,a0,-452 # 80011930 <kmem>
    80000afc:	00000097          	auipc	ra,0x0
    80000b00:	084080e7          	jalr	132(ra) # 80000b80 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b04:	45c5                	li	a1,17
    80000b06:	05ee                	slli	a1,a1,0x1b
    80000b08:	00025517          	auipc	a0,0x25
    80000b0c:	4f850513          	addi	a0,a0,1272 # 80026000 <end>
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	f8a080e7          	jalr	-118(ra) # 80000a9a <freerange>
}
    80000b18:	60a2                	ld	ra,8(sp)
    80000b1a:	6402                	ld	s0,0(sp)
    80000b1c:	0141                	addi	sp,sp,16
    80000b1e:	8082                	ret

0000000080000b20 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b20:	1101                	addi	sp,sp,-32
    80000b22:	ec06                	sd	ra,24(sp)
    80000b24:	e822                	sd	s0,16(sp)
    80000b26:	e426                	sd	s1,8(sp)
    80000b28:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2a:	00011497          	auipc	s1,0x11
    80000b2e:	e0648493          	addi	s1,s1,-506 # 80011930 <kmem>
    80000b32:	8526                	mv	a0,s1
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	0dc080e7          	jalr	220(ra) # 80000c10 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c885                	beqz	s1,80000b6e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00011517          	auipc	a0,0x11
    80000b46:	dee50513          	addi	a0,a0,-530 # 80011930 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	00000097          	auipc	ra,0x0
    80000b50:	178080e7          	jalr	376(ra) # 80000cc4 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b54:	6605                	lui	a2,0x1
    80000b56:	4595                	li	a1,5
    80000b58:	8526                	mv	a0,s1
    80000b5a:	00000097          	auipc	ra,0x0
    80000b5e:	1b2080e7          	jalr	434(ra) # 80000d0c <memset>
  return (void*)r;
}
    80000b62:	8526                	mv	a0,s1
    80000b64:	60e2                	ld	ra,24(sp)
    80000b66:	6442                	ld	s0,16(sp)
    80000b68:	64a2                	ld	s1,8(sp)
    80000b6a:	6105                	addi	sp,sp,32
    80000b6c:	8082                	ret
  release(&kmem.lock);
    80000b6e:	00011517          	auipc	a0,0x11
    80000b72:	dc250513          	addi	a0,a0,-574 # 80011930 <kmem>
    80000b76:	00000097          	auipc	ra,0x0
    80000b7a:	14e080e7          	jalr	334(ra) # 80000cc4 <release>
  if(r)
    80000b7e:	b7d5                	j	80000b62 <kalloc+0x42>

0000000080000b80 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b80:	1141                	addi	sp,sp,-16
    80000b82:	e422                	sd	s0,8(sp)
    80000b84:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b86:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b88:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b8c:	00053823          	sd	zero,16(a0)
}
    80000b90:	6422                	ld	s0,8(sp)
    80000b92:	0141                	addi	sp,sp,16
    80000b94:	8082                	ret

0000000080000b96 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b96:	411c                	lw	a5,0(a0)
    80000b98:	e399                	bnez	a5,80000b9e <holding+0x8>
    80000b9a:	4501                	li	a0,0
  return r;
}
    80000b9c:	8082                	ret
{
    80000b9e:	1101                	addi	sp,sp,-32
    80000ba0:	ec06                	sd	ra,24(sp)
    80000ba2:	e822                	sd	s0,16(sp)
    80000ba4:	e426                	sd	s1,8(sp)
    80000ba6:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ba8:	6904                	ld	s1,16(a0)
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	e18080e7          	jalr	-488(ra) # 800019c2 <mycpu>
    80000bb2:	40a48533          	sub	a0,s1,a0
    80000bb6:	00153513          	seqz	a0,a0
}
    80000bba:	60e2                	ld	ra,24(sp)
    80000bbc:	6442                	ld	s0,16(sp)
    80000bbe:	64a2                	ld	s1,8(sp)
    80000bc0:	6105                	addi	sp,sp,32
    80000bc2:	8082                	ret

0000000080000bc4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bc4:	1101                	addi	sp,sp,-32
    80000bc6:	ec06                	sd	ra,24(sp)
    80000bc8:	e822                	sd	s0,16(sp)
    80000bca:	e426                	sd	s1,8(sp)
    80000bcc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bce:	100024f3          	csrr	s1,sstatus
    80000bd2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bd6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bd8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bdc:	00001097          	auipc	ra,0x1
    80000be0:	de6080e7          	jalr	-538(ra) # 800019c2 <mycpu>
    80000be4:	5d3c                	lw	a5,120(a0)
    80000be6:	cf89                	beqz	a5,80000c00 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000be8:	00001097          	auipc	ra,0x1
    80000bec:	dda080e7          	jalr	-550(ra) # 800019c2 <mycpu>
    80000bf0:	5d3c                	lw	a5,120(a0)
    80000bf2:	2785                	addiw	a5,a5,1
    80000bf4:	dd3c                	sw	a5,120(a0)
}
    80000bf6:	60e2                	ld	ra,24(sp)
    80000bf8:	6442                	ld	s0,16(sp)
    80000bfa:	64a2                	ld	s1,8(sp)
    80000bfc:	6105                	addi	sp,sp,32
    80000bfe:	8082                	ret
    mycpu()->intena = old;
    80000c00:	00001097          	auipc	ra,0x1
    80000c04:	dc2080e7          	jalr	-574(ra) # 800019c2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c08:	8085                	srli	s1,s1,0x1
    80000c0a:	8885                	andi	s1,s1,1
    80000c0c:	dd64                	sw	s1,124(a0)
    80000c0e:	bfe9                	j	80000be8 <push_off+0x24>

0000000080000c10 <acquire>:
{
    80000c10:	1101                	addi	sp,sp,-32
    80000c12:	ec06                	sd	ra,24(sp)
    80000c14:	e822                	sd	s0,16(sp)
    80000c16:	e426                	sd	s1,8(sp)
    80000c18:	1000                	addi	s0,sp,32
    80000c1a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c1c:	00000097          	auipc	ra,0x0
    80000c20:	fa8080e7          	jalr	-88(ra) # 80000bc4 <push_off>
  if(holding(lk))
    80000c24:	8526                	mv	a0,s1
    80000c26:	00000097          	auipc	ra,0x0
    80000c2a:	f70080e7          	jalr	-144(ra) # 80000b96 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c2e:	4705                	li	a4,1
  if(holding(lk))
    80000c30:	e115                	bnez	a0,80000c54 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c32:	87ba                	mv	a5,a4
    80000c34:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c38:	2781                	sext.w	a5,a5
    80000c3a:	ffe5                	bnez	a5,80000c32 <acquire+0x22>
  __sync_synchronize();
    80000c3c:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c40:	00001097          	auipc	ra,0x1
    80000c44:	d82080e7          	jalr	-638(ra) # 800019c2 <mycpu>
    80000c48:	e888                	sd	a0,16(s1)
}
    80000c4a:	60e2                	ld	ra,24(sp)
    80000c4c:	6442                	ld	s0,16(sp)
    80000c4e:	64a2                	ld	s1,8(sp)
    80000c50:	6105                	addi	sp,sp,32
    80000c52:	8082                	ret
    panic("acquire");
    80000c54:	00007517          	auipc	a0,0x7
    80000c58:	41c50513          	addi	a0,a0,1052 # 80008070 <digits+0x30>
    80000c5c:	00000097          	auipc	ra,0x0
    80000c60:	8ec080e7          	jalr	-1812(ra) # 80000548 <panic>

0000000080000c64 <pop_off>:

void
pop_off(void)
{
    80000c64:	1141                	addi	sp,sp,-16
    80000c66:	e406                	sd	ra,8(sp)
    80000c68:	e022                	sd	s0,0(sp)
    80000c6a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c6c:	00001097          	auipc	ra,0x1
    80000c70:	d56080e7          	jalr	-682(ra) # 800019c2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c74:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c78:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c7a:	e78d                	bnez	a5,80000ca4 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c7c:	5d3c                	lw	a5,120(a0)
    80000c7e:	02f05b63          	blez	a5,80000cb4 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c82:	37fd                	addiw	a5,a5,-1
    80000c84:	0007871b          	sext.w	a4,a5
    80000c88:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c8a:	eb09                	bnez	a4,80000c9c <pop_off+0x38>
    80000c8c:	5d7c                	lw	a5,124(a0)
    80000c8e:	c799                	beqz	a5,80000c9c <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c94:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c98:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c9c:	60a2                	ld	ra,8(sp)
    80000c9e:	6402                	ld	s0,0(sp)
    80000ca0:	0141                	addi	sp,sp,16
    80000ca2:	8082                	ret
    panic("pop_off - interruptible");
    80000ca4:	00007517          	auipc	a0,0x7
    80000ca8:	3d450513          	addi	a0,a0,980 # 80008078 <digits+0x38>
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	89c080e7          	jalr	-1892(ra) # 80000548 <panic>
    panic("pop_off");
    80000cb4:	00007517          	auipc	a0,0x7
    80000cb8:	3dc50513          	addi	a0,a0,988 # 80008090 <digits+0x50>
    80000cbc:	00000097          	auipc	ra,0x0
    80000cc0:	88c080e7          	jalr	-1908(ra) # 80000548 <panic>

0000000080000cc4 <release>:
{
    80000cc4:	1101                	addi	sp,sp,-32
    80000cc6:	ec06                	sd	ra,24(sp)
    80000cc8:	e822                	sd	s0,16(sp)
    80000cca:	e426                	sd	s1,8(sp)
    80000ccc:	1000                	addi	s0,sp,32
    80000cce:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cd0:	00000097          	auipc	ra,0x0
    80000cd4:	ec6080e7          	jalr	-314(ra) # 80000b96 <holding>
    80000cd8:	c115                	beqz	a0,80000cfc <release+0x38>
  lk->cpu = 0;
    80000cda:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cde:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ce2:	0f50000f          	fence	iorw,ow
    80000ce6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cea:	00000097          	auipc	ra,0x0
    80000cee:	f7a080e7          	jalr	-134(ra) # 80000c64 <pop_off>
}
    80000cf2:	60e2                	ld	ra,24(sp)
    80000cf4:	6442                	ld	s0,16(sp)
    80000cf6:	64a2                	ld	s1,8(sp)
    80000cf8:	6105                	addi	sp,sp,32
    80000cfa:	8082                	ret
    panic("release");
    80000cfc:	00007517          	auipc	a0,0x7
    80000d00:	39c50513          	addi	a0,a0,924 # 80008098 <digits+0x58>
    80000d04:	00000097          	auipc	ra,0x0
    80000d08:	844080e7          	jalr	-1980(ra) # 80000548 <panic>

0000000080000d0c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e422                	sd	s0,8(sp)
    80000d10:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d12:	ce09                	beqz	a2,80000d2c <memset+0x20>
    80000d14:	87aa                	mv	a5,a0
    80000d16:	fff6071b          	addiw	a4,a2,-1
    80000d1a:	1702                	slli	a4,a4,0x20
    80000d1c:	9301                	srli	a4,a4,0x20
    80000d1e:	0705                	addi	a4,a4,1
    80000d20:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d22:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d26:	0785                	addi	a5,a5,1
    80000d28:	fee79de3          	bne	a5,a4,80000d22 <memset+0x16>
  }
  return dst;
}
    80000d2c:	6422                	ld	s0,8(sp)
    80000d2e:	0141                	addi	sp,sp,16
    80000d30:	8082                	ret

0000000080000d32 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d32:	1141                	addi	sp,sp,-16
    80000d34:	e422                	sd	s0,8(sp)
    80000d36:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d38:	ca05                	beqz	a2,80000d68 <memcmp+0x36>
    80000d3a:	fff6069b          	addiw	a3,a2,-1
    80000d3e:	1682                	slli	a3,a3,0x20
    80000d40:	9281                	srli	a3,a3,0x20
    80000d42:	0685                	addi	a3,a3,1
    80000d44:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d46:	00054783          	lbu	a5,0(a0)
    80000d4a:	0005c703          	lbu	a4,0(a1)
    80000d4e:	00e79863          	bne	a5,a4,80000d5e <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d52:	0505                	addi	a0,a0,1
    80000d54:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d56:	fed518e3          	bne	a0,a3,80000d46 <memcmp+0x14>
  }

  return 0;
    80000d5a:	4501                	li	a0,0
    80000d5c:	a019                	j	80000d62 <memcmp+0x30>
      return *s1 - *s2;
    80000d5e:	40e7853b          	subw	a0,a5,a4
}
    80000d62:	6422                	ld	s0,8(sp)
    80000d64:	0141                	addi	sp,sp,16
    80000d66:	8082                	ret
  return 0;
    80000d68:	4501                	li	a0,0
    80000d6a:	bfe5                	j	80000d62 <memcmp+0x30>

0000000080000d6c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d6c:	1141                	addi	sp,sp,-16
    80000d6e:	e422                	sd	s0,8(sp)
    80000d70:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d72:	00a5f963          	bgeu	a1,a0,80000d84 <memmove+0x18>
    80000d76:	02061713          	slli	a4,a2,0x20
    80000d7a:	9301                	srli	a4,a4,0x20
    80000d7c:	00e587b3          	add	a5,a1,a4
    80000d80:	02f56563          	bltu	a0,a5,80000daa <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d84:	fff6069b          	addiw	a3,a2,-1
    80000d88:	ce11                	beqz	a2,80000da4 <memmove+0x38>
    80000d8a:	1682                	slli	a3,a3,0x20
    80000d8c:	9281                	srli	a3,a3,0x20
    80000d8e:	0685                	addi	a3,a3,1
    80000d90:	96ae                	add	a3,a3,a1
    80000d92:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d94:	0585                	addi	a1,a1,1
    80000d96:	0785                	addi	a5,a5,1
    80000d98:	fff5c703          	lbu	a4,-1(a1)
    80000d9c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000da0:	fed59ae3          	bne	a1,a3,80000d94 <memmove+0x28>

  return dst;
}
    80000da4:	6422                	ld	s0,8(sp)
    80000da6:	0141                	addi	sp,sp,16
    80000da8:	8082                	ret
    d += n;
    80000daa:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000dac:	fff6069b          	addiw	a3,a2,-1
    80000db0:	da75                	beqz	a2,80000da4 <memmove+0x38>
    80000db2:	02069613          	slli	a2,a3,0x20
    80000db6:	9201                	srli	a2,a2,0x20
    80000db8:	fff64613          	not	a2,a2
    80000dbc:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000dbe:	17fd                	addi	a5,a5,-1
    80000dc0:	177d                	addi	a4,a4,-1
    80000dc2:	0007c683          	lbu	a3,0(a5)
    80000dc6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000dca:	fec79ae3          	bne	a5,a2,80000dbe <memmove+0x52>
    80000dce:	bfd9                	j	80000da4 <memmove+0x38>

0000000080000dd0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dd0:	1141                	addi	sp,sp,-16
    80000dd2:	e406                	sd	ra,8(sp)
    80000dd4:	e022                	sd	s0,0(sp)
    80000dd6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dd8:	00000097          	auipc	ra,0x0
    80000ddc:	f94080e7          	jalr	-108(ra) # 80000d6c <memmove>
}
    80000de0:	60a2                	ld	ra,8(sp)
    80000de2:	6402                	ld	s0,0(sp)
    80000de4:	0141                	addi	sp,sp,16
    80000de6:	8082                	ret

0000000080000de8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000de8:	1141                	addi	sp,sp,-16
    80000dea:	e422                	sd	s0,8(sp)
    80000dec:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dee:	ce11                	beqz	a2,80000e0a <strncmp+0x22>
    80000df0:	00054783          	lbu	a5,0(a0)
    80000df4:	cf89                	beqz	a5,80000e0e <strncmp+0x26>
    80000df6:	0005c703          	lbu	a4,0(a1)
    80000dfa:	00f71a63          	bne	a4,a5,80000e0e <strncmp+0x26>
    n--, p++, q++;
    80000dfe:	367d                	addiw	a2,a2,-1
    80000e00:	0505                	addi	a0,a0,1
    80000e02:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e04:	f675                	bnez	a2,80000df0 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e06:	4501                	li	a0,0
    80000e08:	a809                	j	80000e1a <strncmp+0x32>
    80000e0a:	4501                	li	a0,0
    80000e0c:	a039                	j	80000e1a <strncmp+0x32>
  if(n == 0)
    80000e0e:	ca09                	beqz	a2,80000e20 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e10:	00054503          	lbu	a0,0(a0)
    80000e14:	0005c783          	lbu	a5,0(a1)
    80000e18:	9d1d                	subw	a0,a0,a5
}
    80000e1a:	6422                	ld	s0,8(sp)
    80000e1c:	0141                	addi	sp,sp,16
    80000e1e:	8082                	ret
    return 0;
    80000e20:	4501                	li	a0,0
    80000e22:	bfe5                	j	80000e1a <strncmp+0x32>

0000000080000e24 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e24:	1141                	addi	sp,sp,-16
    80000e26:	e422                	sd	s0,8(sp)
    80000e28:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e2a:	872a                	mv	a4,a0
    80000e2c:	8832                	mv	a6,a2
    80000e2e:	367d                	addiw	a2,a2,-1
    80000e30:	01005963          	blez	a6,80000e42 <strncpy+0x1e>
    80000e34:	0705                	addi	a4,a4,1
    80000e36:	0005c783          	lbu	a5,0(a1)
    80000e3a:	fef70fa3          	sb	a5,-1(a4)
    80000e3e:	0585                	addi	a1,a1,1
    80000e40:	f7f5                	bnez	a5,80000e2c <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e42:	00c05d63          	blez	a2,80000e5c <strncpy+0x38>
    80000e46:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e48:	0685                	addi	a3,a3,1
    80000e4a:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e4e:	fff6c793          	not	a5,a3
    80000e52:	9fb9                	addw	a5,a5,a4
    80000e54:	010787bb          	addw	a5,a5,a6
    80000e58:	fef048e3          	bgtz	a5,80000e48 <strncpy+0x24>
  return os;
}
    80000e5c:	6422                	ld	s0,8(sp)
    80000e5e:	0141                	addi	sp,sp,16
    80000e60:	8082                	ret

0000000080000e62 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e422                	sd	s0,8(sp)
    80000e66:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e68:	02c05363          	blez	a2,80000e8e <safestrcpy+0x2c>
    80000e6c:	fff6069b          	addiw	a3,a2,-1
    80000e70:	1682                	slli	a3,a3,0x20
    80000e72:	9281                	srli	a3,a3,0x20
    80000e74:	96ae                	add	a3,a3,a1
    80000e76:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e78:	00d58963          	beq	a1,a3,80000e8a <safestrcpy+0x28>
    80000e7c:	0585                	addi	a1,a1,1
    80000e7e:	0785                	addi	a5,a5,1
    80000e80:	fff5c703          	lbu	a4,-1(a1)
    80000e84:	fee78fa3          	sb	a4,-1(a5)
    80000e88:	fb65                	bnez	a4,80000e78 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e8a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e8e:	6422                	ld	s0,8(sp)
    80000e90:	0141                	addi	sp,sp,16
    80000e92:	8082                	ret

0000000080000e94 <strlen>:

int
strlen(const char *s)
{
    80000e94:	1141                	addi	sp,sp,-16
    80000e96:	e422                	sd	s0,8(sp)
    80000e98:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e9a:	00054783          	lbu	a5,0(a0)
    80000e9e:	cf91                	beqz	a5,80000eba <strlen+0x26>
    80000ea0:	0505                	addi	a0,a0,1
    80000ea2:	87aa                	mv	a5,a0
    80000ea4:	4685                	li	a3,1
    80000ea6:	9e89                	subw	a3,a3,a0
    80000ea8:	00f6853b          	addw	a0,a3,a5
    80000eac:	0785                	addi	a5,a5,1
    80000eae:	fff7c703          	lbu	a4,-1(a5)
    80000eb2:	fb7d                	bnez	a4,80000ea8 <strlen+0x14>
    ;
  return n;
}
    80000eb4:	6422                	ld	s0,8(sp)
    80000eb6:	0141                	addi	sp,sp,16
    80000eb8:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eba:	4501                	li	a0,0
    80000ebc:	bfe5                	j	80000eb4 <strlen+0x20>

0000000080000ebe <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ebe:	1141                	addi	sp,sp,-16
    80000ec0:	e406                	sd	ra,8(sp)
    80000ec2:	e022                	sd	s0,0(sp)
    80000ec4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ec6:	00001097          	auipc	ra,0x1
    80000eca:	aec080e7          	jalr	-1300(ra) # 800019b2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ece:	00008717          	auipc	a4,0x8
    80000ed2:	13e70713          	addi	a4,a4,318 # 8000900c <started>
  if(cpuid() == 0){
    80000ed6:	c139                	beqz	a0,80000f1c <main+0x5e>
    while(started == 0)
    80000ed8:	431c                	lw	a5,0(a4)
    80000eda:	2781                	sext.w	a5,a5
    80000edc:	dff5                	beqz	a5,80000ed8 <main+0x1a>
      ;
    __sync_synchronize();
    80000ede:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ee2:	00001097          	auipc	ra,0x1
    80000ee6:	ad0080e7          	jalr	-1328(ra) # 800019b2 <cpuid>
    80000eea:	85aa                	mv	a1,a0
    80000eec:	00007517          	auipc	a0,0x7
    80000ef0:	1cc50513          	addi	a0,a0,460 # 800080b8 <digits+0x78>
    80000ef4:	fffff097          	auipc	ra,0xfffff
    80000ef8:	69e080e7          	jalr	1694(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    80000efc:	00000097          	auipc	ra,0x0
    80000f00:	0d8080e7          	jalr	216(ra) # 80000fd4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f04:	00001097          	auipc	ra,0x1
    80000f08:	734080e7          	jalr	1844(ra) # 80002638 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f0c:	00005097          	auipc	ra,0x5
    80000f10:	cc4080e7          	jalr	-828(ra) # 80005bd0 <plicinithart>
  }

  scheduler();        
    80000f14:	00001097          	auipc	ra,0x1
    80000f18:	ffa080e7          	jalr	-6(ra) # 80001f0e <scheduler>
    consoleinit();
    80000f1c:	fffff097          	auipc	ra,0xfffff
    80000f20:	53e080e7          	jalr	1342(ra) # 8000045a <consoleinit>
    printfinit();
    80000f24:	00000097          	auipc	ra,0x0
    80000f28:	854080e7          	jalr	-1964(ra) # 80000778 <printfinit>
    printf("\n");
    80000f2c:	00007517          	auipc	a0,0x7
    80000f30:	19c50513          	addi	a0,a0,412 # 800080c8 <digits+0x88>
    80000f34:	fffff097          	auipc	ra,0xfffff
    80000f38:	65e080e7          	jalr	1630(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    80000f3c:	00007517          	auipc	a0,0x7
    80000f40:	16450513          	addi	a0,a0,356 # 800080a0 <digits+0x60>
    80000f44:	fffff097          	auipc	ra,0xfffff
    80000f48:	64e080e7          	jalr	1614(ra) # 80000592 <printf>
    printf("\n");
    80000f4c:	00007517          	auipc	a0,0x7
    80000f50:	17c50513          	addi	a0,a0,380 # 800080c8 <digits+0x88>
    80000f54:	fffff097          	auipc	ra,0xfffff
    80000f58:	63e080e7          	jalr	1598(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    80000f5c:	00000097          	auipc	ra,0x0
    80000f60:	b88080e7          	jalr	-1144(ra) # 80000ae4 <kinit>
    kvminit();       // create kernel page table
    80000f64:	00000097          	auipc	ra,0x0
    80000f68:	2a0080e7          	jalr	672(ra) # 80001204 <kvminit>
    kvminithart();   // turn on paging
    80000f6c:	00000097          	auipc	ra,0x0
    80000f70:	068080e7          	jalr	104(ra) # 80000fd4 <kvminithart>
    procinit();      // process table
    80000f74:	00001097          	auipc	ra,0x1
    80000f78:	96e080e7          	jalr	-1682(ra) # 800018e2 <procinit>
    trapinit();      // trap vectors
    80000f7c:	00001097          	auipc	ra,0x1
    80000f80:	694080e7          	jalr	1684(ra) # 80002610 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f84:	00001097          	auipc	ra,0x1
    80000f88:	6b4080e7          	jalr	1716(ra) # 80002638 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f8c:	00005097          	auipc	ra,0x5
    80000f90:	c2e080e7          	jalr	-978(ra) # 80005bba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f94:	00005097          	auipc	ra,0x5
    80000f98:	c3c080e7          	jalr	-964(ra) # 80005bd0 <plicinithart>
    binit();         // buffer cache
    80000f9c:	00002097          	auipc	ra,0x2
    80000fa0:	dde080e7          	jalr	-546(ra) # 80002d7a <binit>
    iinit();         // inode cache
    80000fa4:	00002097          	auipc	ra,0x2
    80000fa8:	46e080e7          	jalr	1134(ra) # 80003412 <iinit>
    fileinit();      // file table
    80000fac:	00003097          	auipc	ra,0x3
    80000fb0:	408080e7          	jalr	1032(ra) # 800043b4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fb4:	00005097          	auipc	ra,0x5
    80000fb8:	d24080e7          	jalr	-732(ra) # 80005cd8 <virtio_disk_init>
    userinit();      // first user process
    80000fbc:	00001097          	auipc	ra,0x1
    80000fc0:	cec080e7          	jalr	-788(ra) # 80001ca8 <userinit>
    __sync_synchronize();
    80000fc4:	0ff0000f          	fence
    started = 1;
    80000fc8:	4785                	li	a5,1
    80000fca:	00008717          	auipc	a4,0x8
    80000fce:	04f72123          	sw	a5,66(a4) # 8000900c <started>
    80000fd2:	b789                	j	80000f14 <main+0x56>

0000000080000fd4 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fd4:	1141                	addi	sp,sp,-16
    80000fd6:	e422                	sd	s0,8(sp)
    80000fd8:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fda:	00008797          	auipc	a5,0x8
    80000fde:	0367b783          	ld	a5,54(a5) # 80009010 <kernel_pagetable>
    80000fe2:	83b1                	srli	a5,a5,0xc
    80000fe4:	577d                	li	a4,-1
    80000fe6:	177e                	slli	a4,a4,0x3f
    80000fe8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fea:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fee:	12000073          	sfence.vma
  sfence_vma();
}
    80000ff2:	6422                	ld	s0,8(sp)
    80000ff4:	0141                	addi	sp,sp,16
    80000ff6:	8082                	ret

0000000080000ff8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000ff8:	7139                	addi	sp,sp,-64
    80000ffa:	fc06                	sd	ra,56(sp)
    80000ffc:	f822                	sd	s0,48(sp)
    80000ffe:	f426                	sd	s1,40(sp)
    80001000:	f04a                	sd	s2,32(sp)
    80001002:	ec4e                	sd	s3,24(sp)
    80001004:	e852                	sd	s4,16(sp)
    80001006:	e456                	sd	s5,8(sp)
    80001008:	e05a                	sd	s6,0(sp)
    8000100a:	0080                	addi	s0,sp,64
    8000100c:	84aa                	mv	s1,a0
    8000100e:	89ae                	mv	s3,a1
    80001010:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001012:	57fd                	li	a5,-1
    80001014:	83e9                	srli	a5,a5,0x1a
    80001016:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001018:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000101a:	04b7f263          	bgeu	a5,a1,8000105e <walk+0x66>
    panic("walk");
    8000101e:	00007517          	auipc	a0,0x7
    80001022:	0b250513          	addi	a0,a0,178 # 800080d0 <digits+0x90>
    80001026:	fffff097          	auipc	ra,0xfffff
    8000102a:	522080e7          	jalr	1314(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000102e:	060a8663          	beqz	s5,8000109a <walk+0xa2>
    80001032:	00000097          	auipc	ra,0x0
    80001036:	aee080e7          	jalr	-1298(ra) # 80000b20 <kalloc>
    8000103a:	84aa                	mv	s1,a0
    8000103c:	c529                	beqz	a0,80001086 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000103e:	6605                	lui	a2,0x1
    80001040:	4581                	li	a1,0
    80001042:	00000097          	auipc	ra,0x0
    80001046:	cca080e7          	jalr	-822(ra) # 80000d0c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000104a:	00c4d793          	srli	a5,s1,0xc
    8000104e:	07aa                	slli	a5,a5,0xa
    80001050:	0017e793          	ori	a5,a5,1
    80001054:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001058:	3a5d                	addiw	s4,s4,-9
    8000105a:	036a0063          	beq	s4,s6,8000107a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000105e:	0149d933          	srl	s2,s3,s4
    80001062:	1ff97913          	andi	s2,s2,511
    80001066:	090e                	slli	s2,s2,0x3
    80001068:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000106a:	00093483          	ld	s1,0(s2)
    8000106e:	0014f793          	andi	a5,s1,1
    80001072:	dfd5                	beqz	a5,8000102e <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001074:	80a9                	srli	s1,s1,0xa
    80001076:	04b2                	slli	s1,s1,0xc
    80001078:	b7c5                	j	80001058 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000107a:	00c9d513          	srli	a0,s3,0xc
    8000107e:	1ff57513          	andi	a0,a0,511
    80001082:	050e                	slli	a0,a0,0x3
    80001084:	9526                	add	a0,a0,s1
}
    80001086:	70e2                	ld	ra,56(sp)
    80001088:	7442                	ld	s0,48(sp)
    8000108a:	74a2                	ld	s1,40(sp)
    8000108c:	7902                	ld	s2,32(sp)
    8000108e:	69e2                	ld	s3,24(sp)
    80001090:	6a42                	ld	s4,16(sp)
    80001092:	6aa2                	ld	s5,8(sp)
    80001094:	6b02                	ld	s6,0(sp)
    80001096:	6121                	addi	sp,sp,64
    80001098:	8082                	ret
        return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7ed                	j	80001086 <walk+0x8e>

000000008000109e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000109e:	57fd                	li	a5,-1
    800010a0:	83e9                	srli	a5,a5,0x1a
    800010a2:	00b7f463          	bgeu	a5,a1,800010aa <walkaddr+0xc>
    return 0;
    800010a6:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010a8:	8082                	ret
{
    800010aa:	1141                	addi	sp,sp,-16
    800010ac:	e406                	sd	ra,8(sp)
    800010ae:	e022                	sd	s0,0(sp)
    800010b0:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010b2:	4601                	li	a2,0
    800010b4:	00000097          	auipc	ra,0x0
    800010b8:	f44080e7          	jalr	-188(ra) # 80000ff8 <walk>
  if(pte == 0)
    800010bc:	c105                	beqz	a0,800010dc <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010be:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010c0:	0117f693          	andi	a3,a5,17
    800010c4:	4745                	li	a4,17
    return 0;
    800010c6:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010c8:	00e68663          	beq	a3,a4,800010d4 <walkaddr+0x36>
}
    800010cc:	60a2                	ld	ra,8(sp)
    800010ce:	6402                	ld	s0,0(sp)
    800010d0:	0141                	addi	sp,sp,16
    800010d2:	8082                	ret
  pa = PTE2PA(*pte);
    800010d4:	00a7d513          	srli	a0,a5,0xa
    800010d8:	0532                	slli	a0,a0,0xc
  return pa;
    800010da:	bfcd                	j	800010cc <walkaddr+0x2e>
    return 0;
    800010dc:	4501                	li	a0,0
    800010de:	b7fd                	j	800010cc <walkaddr+0x2e>

00000000800010e0 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    800010e0:	1101                	addi	sp,sp,-32
    800010e2:	ec06                	sd	ra,24(sp)
    800010e4:	e822                	sd	s0,16(sp)
    800010e6:	e426                	sd	s1,8(sp)
    800010e8:	1000                	addi	s0,sp,32
    800010ea:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800010ec:	1552                	slli	a0,a0,0x34
    800010ee:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    800010f2:	4601                	li	a2,0
    800010f4:	00008517          	auipc	a0,0x8
    800010f8:	f1c53503          	ld	a0,-228(a0) # 80009010 <kernel_pagetable>
    800010fc:	00000097          	auipc	ra,0x0
    80001100:	efc080e7          	jalr	-260(ra) # 80000ff8 <walk>
  if(pte == 0)
    80001104:	cd09                	beqz	a0,8000111e <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    80001106:	6108                	ld	a0,0(a0)
    80001108:	00157793          	andi	a5,a0,1
    8000110c:	c38d                	beqz	a5,8000112e <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    8000110e:	8129                	srli	a0,a0,0xa
    80001110:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001112:	9526                	add	a0,a0,s1
    80001114:	60e2                	ld	ra,24(sp)
    80001116:	6442                	ld	s0,16(sp)
    80001118:	64a2                	ld	s1,8(sp)
    8000111a:	6105                	addi	sp,sp,32
    8000111c:	8082                	ret
    panic("kvmpa");
    8000111e:	00007517          	auipc	a0,0x7
    80001122:	fba50513          	addi	a0,a0,-70 # 800080d8 <digits+0x98>
    80001126:	fffff097          	auipc	ra,0xfffff
    8000112a:	422080e7          	jalr	1058(ra) # 80000548 <panic>
    panic("kvmpa");
    8000112e:	00007517          	auipc	a0,0x7
    80001132:	faa50513          	addi	a0,a0,-86 # 800080d8 <digits+0x98>
    80001136:	fffff097          	auipc	ra,0xfffff
    8000113a:	412080e7          	jalr	1042(ra) # 80000548 <panic>

000000008000113e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000113e:	715d                	addi	sp,sp,-80
    80001140:	e486                	sd	ra,72(sp)
    80001142:	e0a2                	sd	s0,64(sp)
    80001144:	fc26                	sd	s1,56(sp)
    80001146:	f84a                	sd	s2,48(sp)
    80001148:	f44e                	sd	s3,40(sp)
    8000114a:	f052                	sd	s4,32(sp)
    8000114c:	ec56                	sd	s5,24(sp)
    8000114e:	e85a                	sd	s6,16(sp)
    80001150:	e45e                	sd	s7,8(sp)
    80001152:	0880                	addi	s0,sp,80
    80001154:	8aaa                	mv	s5,a0
    80001156:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001158:	777d                	lui	a4,0xfffff
    8000115a:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000115e:	167d                	addi	a2,a2,-1
    80001160:	00b609b3          	add	s3,a2,a1
    80001164:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001168:	893e                	mv	s2,a5
    8000116a:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000116e:	6b85                	lui	s7,0x1
    80001170:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001174:	4605                	li	a2,1
    80001176:	85ca                	mv	a1,s2
    80001178:	8556                	mv	a0,s5
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	e7e080e7          	jalr	-386(ra) # 80000ff8 <walk>
    80001182:	c51d                	beqz	a0,800011b0 <mappages+0x72>
    if(*pte & PTE_V)
    80001184:	611c                	ld	a5,0(a0)
    80001186:	8b85                	andi	a5,a5,1
    80001188:	ef81                	bnez	a5,800011a0 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000118a:	80b1                	srli	s1,s1,0xc
    8000118c:	04aa                	slli	s1,s1,0xa
    8000118e:	0164e4b3          	or	s1,s1,s6
    80001192:	0014e493          	ori	s1,s1,1
    80001196:	e104                	sd	s1,0(a0)
    if(a == last)
    80001198:	03390863          	beq	s2,s3,800011c8 <mappages+0x8a>
    a += PGSIZE;
    8000119c:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000119e:	bfc9                	j	80001170 <mappages+0x32>
      panic("remap");
    800011a0:	00007517          	auipc	a0,0x7
    800011a4:	f4050513          	addi	a0,a0,-192 # 800080e0 <digits+0xa0>
    800011a8:	fffff097          	auipc	ra,0xfffff
    800011ac:	3a0080e7          	jalr	928(ra) # 80000548 <panic>
      return -1;
    800011b0:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011b2:	60a6                	ld	ra,72(sp)
    800011b4:	6406                	ld	s0,64(sp)
    800011b6:	74e2                	ld	s1,56(sp)
    800011b8:	7942                	ld	s2,48(sp)
    800011ba:	79a2                	ld	s3,40(sp)
    800011bc:	7a02                	ld	s4,32(sp)
    800011be:	6ae2                	ld	s5,24(sp)
    800011c0:	6b42                	ld	s6,16(sp)
    800011c2:	6ba2                	ld	s7,8(sp)
    800011c4:	6161                	addi	sp,sp,80
    800011c6:	8082                	ret
  return 0;
    800011c8:	4501                	li	a0,0
    800011ca:	b7e5                	j	800011b2 <mappages+0x74>

00000000800011cc <kvmmap>:
{
    800011cc:	1141                	addi	sp,sp,-16
    800011ce:	e406                	sd	ra,8(sp)
    800011d0:	e022                	sd	s0,0(sp)
    800011d2:	0800                	addi	s0,sp,16
    800011d4:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800011d6:	86ae                	mv	a3,a1
    800011d8:	85aa                	mv	a1,a0
    800011da:	00008517          	auipc	a0,0x8
    800011de:	e3653503          	ld	a0,-458(a0) # 80009010 <kernel_pagetable>
    800011e2:	00000097          	auipc	ra,0x0
    800011e6:	f5c080e7          	jalr	-164(ra) # 8000113e <mappages>
    800011ea:	e509                	bnez	a0,800011f4 <kvmmap+0x28>
}
    800011ec:	60a2                	ld	ra,8(sp)
    800011ee:	6402                	ld	s0,0(sp)
    800011f0:	0141                	addi	sp,sp,16
    800011f2:	8082                	ret
    panic("kvmmap");
    800011f4:	00007517          	auipc	a0,0x7
    800011f8:	ef450513          	addi	a0,a0,-268 # 800080e8 <digits+0xa8>
    800011fc:	fffff097          	auipc	ra,0xfffff
    80001200:	34c080e7          	jalr	844(ra) # 80000548 <panic>

0000000080001204 <kvminit>:
{
    80001204:	1101                	addi	sp,sp,-32
    80001206:	ec06                	sd	ra,24(sp)
    80001208:	e822                	sd	s0,16(sp)
    8000120a:	e426                	sd	s1,8(sp)
    8000120c:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	912080e7          	jalr	-1774(ra) # 80000b20 <kalloc>
    80001216:	00008797          	auipc	a5,0x8
    8000121a:	dea7bd23          	sd	a0,-518(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    8000121e:	6605                	lui	a2,0x1
    80001220:	4581                	li	a1,0
    80001222:	00000097          	auipc	ra,0x0
    80001226:	aea080e7          	jalr	-1302(ra) # 80000d0c <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000122a:	4699                	li	a3,6
    8000122c:	6605                	lui	a2,0x1
    8000122e:	100005b7          	lui	a1,0x10000
    80001232:	10000537          	lui	a0,0x10000
    80001236:	00000097          	auipc	ra,0x0
    8000123a:	f96080e7          	jalr	-106(ra) # 800011cc <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000123e:	4699                	li	a3,6
    80001240:	6605                	lui	a2,0x1
    80001242:	100015b7          	lui	a1,0x10001
    80001246:	10001537          	lui	a0,0x10001
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	f82080e7          	jalr	-126(ra) # 800011cc <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001252:	4699                	li	a3,6
    80001254:	6641                	lui	a2,0x10
    80001256:	020005b7          	lui	a1,0x2000
    8000125a:	02000537          	lui	a0,0x2000
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f6e080e7          	jalr	-146(ra) # 800011cc <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001266:	4699                	li	a3,6
    80001268:	00400637          	lui	a2,0x400
    8000126c:	0c0005b7          	lui	a1,0xc000
    80001270:	0c000537          	lui	a0,0xc000
    80001274:	00000097          	auipc	ra,0x0
    80001278:	f58080e7          	jalr	-168(ra) # 800011cc <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000127c:	00007497          	auipc	s1,0x7
    80001280:	d8448493          	addi	s1,s1,-636 # 80008000 <etext>
    80001284:	46a9                	li	a3,10
    80001286:	80007617          	auipc	a2,0x80007
    8000128a:	d7a60613          	addi	a2,a2,-646 # 8000 <_entry-0x7fff8000>
    8000128e:	4585                	li	a1,1
    80001290:	05fe                	slli	a1,a1,0x1f
    80001292:	852e                	mv	a0,a1
    80001294:	00000097          	auipc	ra,0x0
    80001298:	f38080e7          	jalr	-200(ra) # 800011cc <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000129c:	4699                	li	a3,6
    8000129e:	4645                	li	a2,17
    800012a0:	066e                	slli	a2,a2,0x1b
    800012a2:	8e05                	sub	a2,a2,s1
    800012a4:	85a6                	mv	a1,s1
    800012a6:	8526                	mv	a0,s1
    800012a8:	00000097          	auipc	ra,0x0
    800012ac:	f24080e7          	jalr	-220(ra) # 800011cc <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012b0:	46a9                	li	a3,10
    800012b2:	6605                	lui	a2,0x1
    800012b4:	00006597          	auipc	a1,0x6
    800012b8:	d4c58593          	addi	a1,a1,-692 # 80007000 <_trampoline>
    800012bc:	04000537          	lui	a0,0x4000
    800012c0:	157d                	addi	a0,a0,-1
    800012c2:	0532                	slli	a0,a0,0xc
    800012c4:	00000097          	auipc	ra,0x0
    800012c8:	f08080e7          	jalr	-248(ra) # 800011cc <kvmmap>
}
    800012cc:	60e2                	ld	ra,24(sp)
    800012ce:	6442                	ld	s0,16(sp)
    800012d0:	64a2                	ld	s1,8(sp)
    800012d2:	6105                	addi	sp,sp,32
    800012d4:	8082                	ret

00000000800012d6 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012d6:	715d                	addi	sp,sp,-80
    800012d8:	e486                	sd	ra,72(sp)
    800012da:	e0a2                	sd	s0,64(sp)
    800012dc:	fc26                	sd	s1,56(sp)
    800012de:	f84a                	sd	s2,48(sp)
    800012e0:	f44e                	sd	s3,40(sp)
    800012e2:	f052                	sd	s4,32(sp)
    800012e4:	ec56                	sd	s5,24(sp)
    800012e6:	e85a                	sd	s6,16(sp)
    800012e8:	e45e                	sd	s7,8(sp)
    800012ea:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012ec:	03459793          	slli	a5,a1,0x34
    800012f0:	e795                	bnez	a5,8000131c <uvmunmap+0x46>
    800012f2:	8a2a                	mv	s4,a0
    800012f4:	892e                	mv	s2,a1
    800012f6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f8:	0632                	slli	a2,a2,0xc
    800012fa:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012fe:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001300:	6b05                	lui	s6,0x1
    80001302:	0735e863          	bltu	a1,s3,80001372 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001306:	60a6                	ld	ra,72(sp)
    80001308:	6406                	ld	s0,64(sp)
    8000130a:	74e2                	ld	s1,56(sp)
    8000130c:	7942                	ld	s2,48(sp)
    8000130e:	79a2                	ld	s3,40(sp)
    80001310:	7a02                	ld	s4,32(sp)
    80001312:	6ae2                	ld	s5,24(sp)
    80001314:	6b42                	ld	s6,16(sp)
    80001316:	6ba2                	ld	s7,8(sp)
    80001318:	6161                	addi	sp,sp,80
    8000131a:	8082                	ret
    panic("uvmunmap: not aligned");
    8000131c:	00007517          	auipc	a0,0x7
    80001320:	dd450513          	addi	a0,a0,-556 # 800080f0 <digits+0xb0>
    80001324:	fffff097          	auipc	ra,0xfffff
    80001328:	224080e7          	jalr	548(ra) # 80000548 <panic>
      panic("uvmunmap: walk");
    8000132c:	00007517          	auipc	a0,0x7
    80001330:	ddc50513          	addi	a0,a0,-548 # 80008108 <digits+0xc8>
    80001334:	fffff097          	auipc	ra,0xfffff
    80001338:	214080e7          	jalr	532(ra) # 80000548 <panic>
      panic("uvmunmap: not mapped");
    8000133c:	00007517          	auipc	a0,0x7
    80001340:	ddc50513          	addi	a0,a0,-548 # 80008118 <digits+0xd8>
    80001344:	fffff097          	auipc	ra,0xfffff
    80001348:	204080e7          	jalr	516(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    8000134c:	00007517          	auipc	a0,0x7
    80001350:	de450513          	addi	a0,a0,-540 # 80008130 <digits+0xf0>
    80001354:	fffff097          	auipc	ra,0xfffff
    80001358:	1f4080e7          	jalr	500(ra) # 80000548 <panic>
      uint64 pa = PTE2PA(*pte);
    8000135c:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000135e:	0532                	slli	a0,a0,0xc
    80001360:	fffff097          	auipc	ra,0xfffff
    80001364:	6c4080e7          	jalr	1732(ra) # 80000a24 <kfree>
    *pte = 0;
    80001368:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000136c:	995a                	add	s2,s2,s6
    8000136e:	f9397ce3          	bgeu	s2,s3,80001306 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001372:	4601                	li	a2,0
    80001374:	85ca                	mv	a1,s2
    80001376:	8552                	mv	a0,s4
    80001378:	00000097          	auipc	ra,0x0
    8000137c:	c80080e7          	jalr	-896(ra) # 80000ff8 <walk>
    80001380:	84aa                	mv	s1,a0
    80001382:	d54d                	beqz	a0,8000132c <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001384:	6108                	ld	a0,0(a0)
    80001386:	00157793          	andi	a5,a0,1
    8000138a:	dbcd                	beqz	a5,8000133c <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000138c:	3ff57793          	andi	a5,a0,1023
    80001390:	fb778ee3          	beq	a5,s7,8000134c <uvmunmap+0x76>
    if(do_free){
    80001394:	fc0a8ae3          	beqz	s5,80001368 <uvmunmap+0x92>
    80001398:	b7d1                	j	8000135c <uvmunmap+0x86>

000000008000139a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000139a:	1101                	addi	sp,sp,-32
    8000139c:	ec06                	sd	ra,24(sp)
    8000139e:	e822                	sd	s0,16(sp)
    800013a0:	e426                	sd	s1,8(sp)
    800013a2:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013a4:	fffff097          	auipc	ra,0xfffff
    800013a8:	77c080e7          	jalr	1916(ra) # 80000b20 <kalloc>
    800013ac:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013ae:	c519                	beqz	a0,800013bc <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013b0:	6605                	lui	a2,0x1
    800013b2:	4581                	li	a1,0
    800013b4:	00000097          	auipc	ra,0x0
    800013b8:	958080e7          	jalr	-1704(ra) # 80000d0c <memset>
  return pagetable;
}
    800013bc:	8526                	mv	a0,s1
    800013be:	60e2                	ld	ra,24(sp)
    800013c0:	6442                	ld	s0,16(sp)
    800013c2:	64a2                	ld	s1,8(sp)
    800013c4:	6105                	addi	sp,sp,32
    800013c6:	8082                	ret

00000000800013c8 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013c8:	7179                	addi	sp,sp,-48
    800013ca:	f406                	sd	ra,40(sp)
    800013cc:	f022                	sd	s0,32(sp)
    800013ce:	ec26                	sd	s1,24(sp)
    800013d0:	e84a                	sd	s2,16(sp)
    800013d2:	e44e                	sd	s3,8(sp)
    800013d4:	e052                	sd	s4,0(sp)
    800013d6:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013d8:	6785                	lui	a5,0x1
    800013da:	04f67863          	bgeu	a2,a5,8000142a <uvminit+0x62>
    800013de:	8a2a                	mv	s4,a0
    800013e0:	89ae                	mv	s3,a1
    800013e2:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013e4:	fffff097          	auipc	ra,0xfffff
    800013e8:	73c080e7          	jalr	1852(ra) # 80000b20 <kalloc>
    800013ec:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013ee:	6605                	lui	a2,0x1
    800013f0:	4581                	li	a1,0
    800013f2:	00000097          	auipc	ra,0x0
    800013f6:	91a080e7          	jalr	-1766(ra) # 80000d0c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013fa:	4779                	li	a4,30
    800013fc:	86ca                	mv	a3,s2
    800013fe:	6605                	lui	a2,0x1
    80001400:	4581                	li	a1,0
    80001402:	8552                	mv	a0,s4
    80001404:	00000097          	auipc	ra,0x0
    80001408:	d3a080e7          	jalr	-710(ra) # 8000113e <mappages>
  memmove(mem, src, sz);
    8000140c:	8626                	mv	a2,s1
    8000140e:	85ce                	mv	a1,s3
    80001410:	854a                	mv	a0,s2
    80001412:	00000097          	auipc	ra,0x0
    80001416:	95a080e7          	jalr	-1702(ra) # 80000d6c <memmove>
}
    8000141a:	70a2                	ld	ra,40(sp)
    8000141c:	7402                	ld	s0,32(sp)
    8000141e:	64e2                	ld	s1,24(sp)
    80001420:	6942                	ld	s2,16(sp)
    80001422:	69a2                	ld	s3,8(sp)
    80001424:	6a02                	ld	s4,0(sp)
    80001426:	6145                	addi	sp,sp,48
    80001428:	8082                	ret
    panic("inituvm: more than a page");
    8000142a:	00007517          	auipc	a0,0x7
    8000142e:	d1e50513          	addi	a0,a0,-738 # 80008148 <digits+0x108>
    80001432:	fffff097          	auipc	ra,0xfffff
    80001436:	116080e7          	jalr	278(ra) # 80000548 <panic>

000000008000143a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000143a:	1101                	addi	sp,sp,-32
    8000143c:	ec06                	sd	ra,24(sp)
    8000143e:	e822                	sd	s0,16(sp)
    80001440:	e426                	sd	s1,8(sp)
    80001442:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001444:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001446:	00b67d63          	bgeu	a2,a1,80001460 <uvmdealloc+0x26>
    8000144a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000144c:	6785                	lui	a5,0x1
    8000144e:	17fd                	addi	a5,a5,-1
    80001450:	00f60733          	add	a4,a2,a5
    80001454:	767d                	lui	a2,0xfffff
    80001456:	8f71                	and	a4,a4,a2
    80001458:	97ae                	add	a5,a5,a1
    8000145a:	8ff1                	and	a5,a5,a2
    8000145c:	00f76863          	bltu	a4,a5,8000146c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001460:	8526                	mv	a0,s1
    80001462:	60e2                	ld	ra,24(sp)
    80001464:	6442                	ld	s0,16(sp)
    80001466:	64a2                	ld	s1,8(sp)
    80001468:	6105                	addi	sp,sp,32
    8000146a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000146c:	8f99                	sub	a5,a5,a4
    8000146e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001470:	4685                	li	a3,1
    80001472:	0007861b          	sext.w	a2,a5
    80001476:	85ba                	mv	a1,a4
    80001478:	00000097          	auipc	ra,0x0
    8000147c:	e5e080e7          	jalr	-418(ra) # 800012d6 <uvmunmap>
    80001480:	b7c5                	j	80001460 <uvmdealloc+0x26>

0000000080001482 <uvmalloc>:
  if(newsz < oldsz)
    80001482:	0ab66163          	bltu	a2,a1,80001524 <uvmalloc+0xa2>
{
    80001486:	7139                	addi	sp,sp,-64
    80001488:	fc06                	sd	ra,56(sp)
    8000148a:	f822                	sd	s0,48(sp)
    8000148c:	f426                	sd	s1,40(sp)
    8000148e:	f04a                	sd	s2,32(sp)
    80001490:	ec4e                	sd	s3,24(sp)
    80001492:	e852                	sd	s4,16(sp)
    80001494:	e456                	sd	s5,8(sp)
    80001496:	0080                	addi	s0,sp,64
    80001498:	8aaa                	mv	s5,a0
    8000149a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000149c:	6985                	lui	s3,0x1
    8000149e:	19fd                	addi	s3,s3,-1
    800014a0:	95ce                	add	a1,a1,s3
    800014a2:	79fd                	lui	s3,0xfffff
    800014a4:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014a8:	08c9f063          	bgeu	s3,a2,80001528 <uvmalloc+0xa6>
    800014ac:	894e                	mv	s2,s3
    mem = kalloc();
    800014ae:	fffff097          	auipc	ra,0xfffff
    800014b2:	672080e7          	jalr	1650(ra) # 80000b20 <kalloc>
    800014b6:	84aa                	mv	s1,a0
    if(mem == 0){
    800014b8:	c51d                	beqz	a0,800014e6 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014ba:	6605                	lui	a2,0x1
    800014bc:	4581                	li	a1,0
    800014be:	00000097          	auipc	ra,0x0
    800014c2:	84e080e7          	jalr	-1970(ra) # 80000d0c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014c6:	4779                	li	a4,30
    800014c8:	86a6                	mv	a3,s1
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ca                	mv	a1,s2
    800014ce:	8556                	mv	a0,s5
    800014d0:	00000097          	auipc	ra,0x0
    800014d4:	c6e080e7          	jalr	-914(ra) # 8000113e <mappages>
    800014d8:	e905                	bnez	a0,80001508 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014da:	6785                	lui	a5,0x1
    800014dc:	993e                	add	s2,s2,a5
    800014de:	fd4968e3          	bltu	s2,s4,800014ae <uvmalloc+0x2c>
  return newsz;
    800014e2:	8552                	mv	a0,s4
    800014e4:	a809                	j	800014f6 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800014e6:	864e                	mv	a2,s3
    800014e8:	85ca                	mv	a1,s2
    800014ea:	8556                	mv	a0,s5
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	f4e080e7          	jalr	-178(ra) # 8000143a <uvmdealloc>
      return 0;
    800014f4:	4501                	li	a0,0
}
    800014f6:	70e2                	ld	ra,56(sp)
    800014f8:	7442                	ld	s0,48(sp)
    800014fa:	74a2                	ld	s1,40(sp)
    800014fc:	7902                	ld	s2,32(sp)
    800014fe:	69e2                	ld	s3,24(sp)
    80001500:	6a42                	ld	s4,16(sp)
    80001502:	6aa2                	ld	s5,8(sp)
    80001504:	6121                	addi	sp,sp,64
    80001506:	8082                	ret
      kfree(mem);
    80001508:	8526                	mv	a0,s1
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	51a080e7          	jalr	1306(ra) # 80000a24 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001512:	864e                	mv	a2,s3
    80001514:	85ca                	mv	a1,s2
    80001516:	8556                	mv	a0,s5
    80001518:	00000097          	auipc	ra,0x0
    8000151c:	f22080e7          	jalr	-222(ra) # 8000143a <uvmdealloc>
      return 0;
    80001520:	4501                	li	a0,0
    80001522:	bfd1                	j	800014f6 <uvmalloc+0x74>
    return oldsz;
    80001524:	852e                	mv	a0,a1
}
    80001526:	8082                	ret
  return newsz;
    80001528:	8532                	mv	a0,a2
    8000152a:	b7f1                	j	800014f6 <uvmalloc+0x74>

000000008000152c <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000152c:	7179                	addi	sp,sp,-48
    8000152e:	f406                	sd	ra,40(sp)
    80001530:	f022                	sd	s0,32(sp)
    80001532:	ec26                	sd	s1,24(sp)
    80001534:	e84a                	sd	s2,16(sp)
    80001536:	e44e                	sd	s3,8(sp)
    80001538:	e052                	sd	s4,0(sp)
    8000153a:	1800                	addi	s0,sp,48
    8000153c:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000153e:	84aa                	mv	s1,a0
    80001540:	6905                	lui	s2,0x1
    80001542:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001544:	4985                	li	s3,1
    80001546:	a821                	j	8000155e <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001548:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000154a:	0532                	slli	a0,a0,0xc
    8000154c:	00000097          	auipc	ra,0x0
    80001550:	fe0080e7          	jalr	-32(ra) # 8000152c <freewalk>
      pagetable[i] = 0;
    80001554:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001558:	04a1                	addi	s1,s1,8
    8000155a:	03248163          	beq	s1,s2,8000157c <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000155e:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001560:	00f57793          	andi	a5,a0,15
    80001564:	ff3782e3          	beq	a5,s3,80001548 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001568:	8905                	andi	a0,a0,1
    8000156a:	d57d                	beqz	a0,80001558 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000156c:	00007517          	auipc	a0,0x7
    80001570:	bfc50513          	addi	a0,a0,-1028 # 80008168 <digits+0x128>
    80001574:	fffff097          	auipc	ra,0xfffff
    80001578:	fd4080e7          	jalr	-44(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    8000157c:	8552                	mv	a0,s4
    8000157e:	fffff097          	auipc	ra,0xfffff
    80001582:	4a6080e7          	jalr	1190(ra) # 80000a24 <kfree>
}
    80001586:	70a2                	ld	ra,40(sp)
    80001588:	7402                	ld	s0,32(sp)
    8000158a:	64e2                	ld	s1,24(sp)
    8000158c:	6942                	ld	s2,16(sp)
    8000158e:	69a2                	ld	s3,8(sp)
    80001590:	6a02                	ld	s4,0(sp)
    80001592:	6145                	addi	sp,sp,48
    80001594:	8082                	ret

0000000080001596 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001596:	1101                	addi	sp,sp,-32
    80001598:	ec06                	sd	ra,24(sp)
    8000159a:	e822                	sd	s0,16(sp)
    8000159c:	e426                	sd	s1,8(sp)
    8000159e:	1000                	addi	s0,sp,32
    800015a0:	84aa                	mv	s1,a0
  if(sz > 0)
    800015a2:	e999                	bnez	a1,800015b8 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015a4:	8526                	mv	a0,s1
    800015a6:	00000097          	auipc	ra,0x0
    800015aa:	f86080e7          	jalr	-122(ra) # 8000152c <freewalk>
}
    800015ae:	60e2                	ld	ra,24(sp)
    800015b0:	6442                	ld	s0,16(sp)
    800015b2:	64a2                	ld	s1,8(sp)
    800015b4:	6105                	addi	sp,sp,32
    800015b6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	167d                	addi	a2,a2,-1
    800015bc:	962e                	add	a2,a2,a1
    800015be:	4685                	li	a3,1
    800015c0:	8231                	srli	a2,a2,0xc
    800015c2:	4581                	li	a1,0
    800015c4:	00000097          	auipc	ra,0x0
    800015c8:	d12080e7          	jalr	-750(ra) # 800012d6 <uvmunmap>
    800015cc:	bfe1                	j	800015a4 <uvmfree+0xe>

00000000800015ce <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015ce:	c679                	beqz	a2,8000169c <uvmcopy+0xce>
{
    800015d0:	715d                	addi	sp,sp,-80
    800015d2:	e486                	sd	ra,72(sp)
    800015d4:	e0a2                	sd	s0,64(sp)
    800015d6:	fc26                	sd	s1,56(sp)
    800015d8:	f84a                	sd	s2,48(sp)
    800015da:	f44e                	sd	s3,40(sp)
    800015dc:	f052                	sd	s4,32(sp)
    800015de:	ec56                	sd	s5,24(sp)
    800015e0:	e85a                	sd	s6,16(sp)
    800015e2:	e45e                	sd	s7,8(sp)
    800015e4:	0880                	addi	s0,sp,80
    800015e6:	8b2a                	mv	s6,a0
    800015e8:	8aae                	mv	s5,a1
    800015ea:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015ec:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015ee:	4601                	li	a2,0
    800015f0:	85ce                	mv	a1,s3
    800015f2:	855a                	mv	a0,s6
    800015f4:	00000097          	auipc	ra,0x0
    800015f8:	a04080e7          	jalr	-1532(ra) # 80000ff8 <walk>
    800015fc:	c531                	beqz	a0,80001648 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015fe:	6118                	ld	a4,0(a0)
    80001600:	00177793          	andi	a5,a4,1
    80001604:	cbb1                	beqz	a5,80001658 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001606:	00a75593          	srli	a1,a4,0xa
    8000160a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000160e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001612:	fffff097          	auipc	ra,0xfffff
    80001616:	50e080e7          	jalr	1294(ra) # 80000b20 <kalloc>
    8000161a:	892a                	mv	s2,a0
    8000161c:	c939                	beqz	a0,80001672 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000161e:	6605                	lui	a2,0x1
    80001620:	85de                	mv	a1,s7
    80001622:	fffff097          	auipc	ra,0xfffff
    80001626:	74a080e7          	jalr	1866(ra) # 80000d6c <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000162a:	8726                	mv	a4,s1
    8000162c:	86ca                	mv	a3,s2
    8000162e:	6605                	lui	a2,0x1
    80001630:	85ce                	mv	a1,s3
    80001632:	8556                	mv	a0,s5
    80001634:	00000097          	auipc	ra,0x0
    80001638:	b0a080e7          	jalr	-1270(ra) # 8000113e <mappages>
    8000163c:	e515                	bnez	a0,80001668 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000163e:	6785                	lui	a5,0x1
    80001640:	99be                	add	s3,s3,a5
    80001642:	fb49e6e3          	bltu	s3,s4,800015ee <uvmcopy+0x20>
    80001646:	a081                	j	80001686 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001648:	00007517          	auipc	a0,0x7
    8000164c:	b3050513          	addi	a0,a0,-1232 # 80008178 <digits+0x138>
    80001650:	fffff097          	auipc	ra,0xfffff
    80001654:	ef8080e7          	jalr	-264(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b4050513          	addi	a0,a0,-1216 # 80008198 <digits+0x158>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ee8080e7          	jalr	-280(ra) # 80000548 <panic>
      kfree(mem);
    80001668:	854a                	mv	a0,s2
    8000166a:	fffff097          	auipc	ra,0xfffff
    8000166e:	3ba080e7          	jalr	954(ra) # 80000a24 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001672:	4685                	li	a3,1
    80001674:	00c9d613          	srli	a2,s3,0xc
    80001678:	4581                	li	a1,0
    8000167a:	8556                	mv	a0,s5
    8000167c:	00000097          	auipc	ra,0x0
    80001680:	c5a080e7          	jalr	-934(ra) # 800012d6 <uvmunmap>
  return -1;
    80001684:	557d                	li	a0,-1
}
    80001686:	60a6                	ld	ra,72(sp)
    80001688:	6406                	ld	s0,64(sp)
    8000168a:	74e2                	ld	s1,56(sp)
    8000168c:	7942                	ld	s2,48(sp)
    8000168e:	79a2                	ld	s3,40(sp)
    80001690:	7a02                	ld	s4,32(sp)
    80001692:	6ae2                	ld	s5,24(sp)
    80001694:	6b42                	ld	s6,16(sp)
    80001696:	6ba2                	ld	s7,8(sp)
    80001698:	6161                	addi	sp,sp,80
    8000169a:	8082                	ret
  return 0;
    8000169c:	4501                	li	a0,0
}
    8000169e:	8082                	ret

00000000800016a0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016a0:	1141                	addi	sp,sp,-16
    800016a2:	e406                	sd	ra,8(sp)
    800016a4:	e022                	sd	s0,0(sp)
    800016a6:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016a8:	4601                	li	a2,0
    800016aa:	00000097          	auipc	ra,0x0
    800016ae:	94e080e7          	jalr	-1714(ra) # 80000ff8 <walk>
  if(pte == 0)
    800016b2:	c901                	beqz	a0,800016c2 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016b4:	611c                	ld	a5,0(a0)
    800016b6:	9bbd                	andi	a5,a5,-17
    800016b8:	e11c                	sd	a5,0(a0)
}
    800016ba:	60a2                	ld	ra,8(sp)
    800016bc:	6402                	ld	s0,0(sp)
    800016be:	0141                	addi	sp,sp,16
    800016c0:	8082                	ret
    panic("uvmclear");
    800016c2:	00007517          	auipc	a0,0x7
    800016c6:	af650513          	addi	a0,a0,-1290 # 800081b8 <digits+0x178>
    800016ca:	fffff097          	auipc	ra,0xfffff
    800016ce:	e7e080e7          	jalr	-386(ra) # 80000548 <panic>

00000000800016d2 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016d2:	c6bd                	beqz	a3,80001740 <copyout+0x6e>
{
    800016d4:	715d                	addi	sp,sp,-80
    800016d6:	e486                	sd	ra,72(sp)
    800016d8:	e0a2                	sd	s0,64(sp)
    800016da:	fc26                	sd	s1,56(sp)
    800016dc:	f84a                	sd	s2,48(sp)
    800016de:	f44e                	sd	s3,40(sp)
    800016e0:	f052                	sd	s4,32(sp)
    800016e2:	ec56                	sd	s5,24(sp)
    800016e4:	e85a                	sd	s6,16(sp)
    800016e6:	e45e                	sd	s7,8(sp)
    800016e8:	e062                	sd	s8,0(sp)
    800016ea:	0880                	addi	s0,sp,80
    800016ec:	8b2a                	mv	s6,a0
    800016ee:	8c2e                	mv	s8,a1
    800016f0:	8a32                	mv	s4,a2
    800016f2:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016f4:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016f6:	6a85                	lui	s5,0x1
    800016f8:	a015                	j	8000171c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016fa:	9562                	add	a0,a0,s8
    800016fc:	0004861b          	sext.w	a2,s1
    80001700:	85d2                	mv	a1,s4
    80001702:	41250533          	sub	a0,a0,s2
    80001706:	fffff097          	auipc	ra,0xfffff
    8000170a:	666080e7          	jalr	1638(ra) # 80000d6c <memmove>

    len -= n;
    8000170e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001712:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001714:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001718:	02098263          	beqz	s3,8000173c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000171c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001720:	85ca                	mv	a1,s2
    80001722:	855a                	mv	a0,s6
    80001724:	00000097          	auipc	ra,0x0
    80001728:	97a080e7          	jalr	-1670(ra) # 8000109e <walkaddr>
    if(pa0 == 0)
    8000172c:	cd01                	beqz	a0,80001744 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000172e:	418904b3          	sub	s1,s2,s8
    80001732:	94d6                	add	s1,s1,s5
    if(n > len)
    80001734:	fc99f3e3          	bgeu	s3,s1,800016fa <copyout+0x28>
    80001738:	84ce                	mv	s1,s3
    8000173a:	b7c1                	j	800016fa <copyout+0x28>
  }
  return 0;
    8000173c:	4501                	li	a0,0
    8000173e:	a021                	j	80001746 <copyout+0x74>
    80001740:	4501                	li	a0,0
}
    80001742:	8082                	ret
      return -1;
    80001744:	557d                	li	a0,-1
}
    80001746:	60a6                	ld	ra,72(sp)
    80001748:	6406                	ld	s0,64(sp)
    8000174a:	74e2                	ld	s1,56(sp)
    8000174c:	7942                	ld	s2,48(sp)
    8000174e:	79a2                	ld	s3,40(sp)
    80001750:	7a02                	ld	s4,32(sp)
    80001752:	6ae2                	ld	s5,24(sp)
    80001754:	6b42                	ld	s6,16(sp)
    80001756:	6ba2                	ld	s7,8(sp)
    80001758:	6c02                	ld	s8,0(sp)
    8000175a:	6161                	addi	sp,sp,80
    8000175c:	8082                	ret

000000008000175e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000175e:	c6bd                	beqz	a3,800017cc <copyin+0x6e>
{
    80001760:	715d                	addi	sp,sp,-80
    80001762:	e486                	sd	ra,72(sp)
    80001764:	e0a2                	sd	s0,64(sp)
    80001766:	fc26                	sd	s1,56(sp)
    80001768:	f84a                	sd	s2,48(sp)
    8000176a:	f44e                	sd	s3,40(sp)
    8000176c:	f052                	sd	s4,32(sp)
    8000176e:	ec56                	sd	s5,24(sp)
    80001770:	e85a                	sd	s6,16(sp)
    80001772:	e45e                	sd	s7,8(sp)
    80001774:	e062                	sd	s8,0(sp)
    80001776:	0880                	addi	s0,sp,80
    80001778:	8b2a                	mv	s6,a0
    8000177a:	8a2e                	mv	s4,a1
    8000177c:	8c32                	mv	s8,a2
    8000177e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001780:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001782:	6a85                	lui	s5,0x1
    80001784:	a015                	j	800017a8 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001786:	9562                	add	a0,a0,s8
    80001788:	0004861b          	sext.w	a2,s1
    8000178c:	412505b3          	sub	a1,a0,s2
    80001790:	8552                	mv	a0,s4
    80001792:	fffff097          	auipc	ra,0xfffff
    80001796:	5da080e7          	jalr	1498(ra) # 80000d6c <memmove>

    len -= n;
    8000179a:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000179e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017a0:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017a4:	02098263          	beqz	s3,800017c8 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    800017a8:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017ac:	85ca                	mv	a1,s2
    800017ae:	855a                	mv	a0,s6
    800017b0:	00000097          	auipc	ra,0x0
    800017b4:	8ee080e7          	jalr	-1810(ra) # 8000109e <walkaddr>
    if(pa0 == 0)
    800017b8:	cd01                	beqz	a0,800017d0 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    800017ba:	418904b3          	sub	s1,s2,s8
    800017be:	94d6                	add	s1,s1,s5
    if(n > len)
    800017c0:	fc99f3e3          	bgeu	s3,s1,80001786 <copyin+0x28>
    800017c4:	84ce                	mv	s1,s3
    800017c6:	b7c1                	j	80001786 <copyin+0x28>
  }
  return 0;
    800017c8:	4501                	li	a0,0
    800017ca:	a021                	j	800017d2 <copyin+0x74>
    800017cc:	4501                	li	a0,0
}
    800017ce:	8082                	ret
      return -1;
    800017d0:	557d                	li	a0,-1
}
    800017d2:	60a6                	ld	ra,72(sp)
    800017d4:	6406                	ld	s0,64(sp)
    800017d6:	74e2                	ld	s1,56(sp)
    800017d8:	7942                	ld	s2,48(sp)
    800017da:	79a2                	ld	s3,40(sp)
    800017dc:	7a02                	ld	s4,32(sp)
    800017de:	6ae2                	ld	s5,24(sp)
    800017e0:	6b42                	ld	s6,16(sp)
    800017e2:	6ba2                	ld	s7,8(sp)
    800017e4:	6c02                	ld	s8,0(sp)
    800017e6:	6161                	addi	sp,sp,80
    800017e8:	8082                	ret

00000000800017ea <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017ea:	c6c5                	beqz	a3,80001892 <copyinstr+0xa8>
{
    800017ec:	715d                	addi	sp,sp,-80
    800017ee:	e486                	sd	ra,72(sp)
    800017f0:	e0a2                	sd	s0,64(sp)
    800017f2:	fc26                	sd	s1,56(sp)
    800017f4:	f84a                	sd	s2,48(sp)
    800017f6:	f44e                	sd	s3,40(sp)
    800017f8:	f052                	sd	s4,32(sp)
    800017fa:	ec56                	sd	s5,24(sp)
    800017fc:	e85a                	sd	s6,16(sp)
    800017fe:	e45e                	sd	s7,8(sp)
    80001800:	0880                	addi	s0,sp,80
    80001802:	8a2a                	mv	s4,a0
    80001804:	8b2e                	mv	s6,a1
    80001806:	8bb2                	mv	s7,a2
    80001808:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000180a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000180c:	6985                	lui	s3,0x1
    8000180e:	a035                	j	8000183a <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001810:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001814:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001816:	0017b793          	seqz	a5,a5
    8000181a:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000181e:	60a6                	ld	ra,72(sp)
    80001820:	6406                	ld	s0,64(sp)
    80001822:	74e2                	ld	s1,56(sp)
    80001824:	7942                	ld	s2,48(sp)
    80001826:	79a2                	ld	s3,40(sp)
    80001828:	7a02                	ld	s4,32(sp)
    8000182a:	6ae2                	ld	s5,24(sp)
    8000182c:	6b42                	ld	s6,16(sp)
    8000182e:	6ba2                	ld	s7,8(sp)
    80001830:	6161                	addi	sp,sp,80
    80001832:	8082                	ret
    srcva = va0 + PGSIZE;
    80001834:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001838:	c8a9                	beqz	s1,8000188a <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    8000183a:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000183e:	85ca                	mv	a1,s2
    80001840:	8552                	mv	a0,s4
    80001842:	00000097          	auipc	ra,0x0
    80001846:	85c080e7          	jalr	-1956(ra) # 8000109e <walkaddr>
    if(pa0 == 0)
    8000184a:	c131                	beqz	a0,8000188e <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    8000184c:	41790833          	sub	a6,s2,s7
    80001850:	984e                	add	a6,a6,s3
    if(n > max)
    80001852:	0104f363          	bgeu	s1,a6,80001858 <copyinstr+0x6e>
    80001856:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001858:	955e                	add	a0,a0,s7
    8000185a:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000185e:	fc080be3          	beqz	a6,80001834 <copyinstr+0x4a>
    80001862:	985a                	add	a6,a6,s6
    80001864:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001866:	41650633          	sub	a2,a0,s6
    8000186a:	14fd                	addi	s1,s1,-1
    8000186c:	9b26                	add	s6,s6,s1
    8000186e:	00f60733          	add	a4,a2,a5
    80001872:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    80001876:	df49                	beqz	a4,80001810 <copyinstr+0x26>
        *dst = *p;
    80001878:	00e78023          	sb	a4,0(a5)
      --max;
    8000187c:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001880:	0785                	addi	a5,a5,1
    while(n > 0){
    80001882:	ff0796e3          	bne	a5,a6,8000186e <copyinstr+0x84>
      dst++;
    80001886:	8b42                	mv	s6,a6
    80001888:	b775                	j	80001834 <copyinstr+0x4a>
    8000188a:	4781                	li	a5,0
    8000188c:	b769                	j	80001816 <copyinstr+0x2c>
      return -1;
    8000188e:	557d                	li	a0,-1
    80001890:	b779                	j	8000181e <copyinstr+0x34>
  int got_null = 0;
    80001892:	4781                	li	a5,0
  if(got_null){
    80001894:	0017b793          	seqz	a5,a5
    80001898:	40f00533          	neg	a0,a5
}
    8000189c:	8082                	ret

000000008000189e <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    8000189e:	1101                	addi	sp,sp,-32
    800018a0:	ec06                	sd	ra,24(sp)
    800018a2:	e822                	sd	s0,16(sp)
    800018a4:	e426                	sd	s1,8(sp)
    800018a6:	1000                	addi	s0,sp,32
    800018a8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800018aa:	fffff097          	auipc	ra,0xfffff
    800018ae:	2ec080e7          	jalr	748(ra) # 80000b96 <holding>
    800018b2:	c909                	beqz	a0,800018c4 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800018b4:	749c                	ld	a5,40(s1)
    800018b6:	00978f63          	beq	a5,s1,800018d4 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800018ba:	60e2                	ld	ra,24(sp)
    800018bc:	6442                	ld	s0,16(sp)
    800018be:	64a2                	ld	s1,8(sp)
    800018c0:	6105                	addi	sp,sp,32
    800018c2:	8082                	ret
    panic("wakeup1");
    800018c4:	00007517          	auipc	a0,0x7
    800018c8:	90450513          	addi	a0,a0,-1788 # 800081c8 <digits+0x188>
    800018cc:	fffff097          	auipc	ra,0xfffff
    800018d0:	c7c080e7          	jalr	-900(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    800018d4:	4c98                	lw	a4,24(s1)
    800018d6:	4785                	li	a5,1
    800018d8:	fef711e3          	bne	a4,a5,800018ba <wakeup1+0x1c>
    p->state = RUNNABLE;
    800018dc:	4789                	li	a5,2
    800018de:	cc9c                	sw	a5,24(s1)
}
    800018e0:	bfe9                	j	800018ba <wakeup1+0x1c>

00000000800018e2 <procinit>:
{
    800018e2:	715d                	addi	sp,sp,-80
    800018e4:	e486                	sd	ra,72(sp)
    800018e6:	e0a2                	sd	s0,64(sp)
    800018e8:	fc26                	sd	s1,56(sp)
    800018ea:	f84a                	sd	s2,48(sp)
    800018ec:	f44e                	sd	s3,40(sp)
    800018ee:	f052                	sd	s4,32(sp)
    800018f0:	ec56                	sd	s5,24(sp)
    800018f2:	e85a                	sd	s6,16(sp)
    800018f4:	e45e                	sd	s7,8(sp)
    800018f6:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8d858593          	addi	a1,a1,-1832 # 800081d0 <digits+0x190>
    80001900:	00010517          	auipc	a0,0x10
    80001904:	05050513          	addi	a0,a0,80 # 80011950 <pid_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	278080e7          	jalr	632(ra) # 80000b80 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	00010917          	auipc	s2,0x10
    80001914:	45890913          	addi	s2,s2,1112 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001918:	00007b97          	auipc	s7,0x7
    8000191c:	8c0b8b93          	addi	s7,s7,-1856 # 800081d8 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    80001920:	8b4a                	mv	s6,s2
    80001922:	00006a97          	auipc	s5,0x6
    80001926:	6dea8a93          	addi	s5,s5,1758 # 80008000 <etext>
    8000192a:	040009b7          	lui	s3,0x4000
    8000192e:	19fd                	addi	s3,s3,-1
    80001930:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001932:	00016a17          	auipc	s4,0x16
    80001936:	e36a0a13          	addi	s4,s4,-458 # 80017768 <tickslock>
      initlock(&p->lock, "proc");
    8000193a:	85de                	mv	a1,s7
    8000193c:	854a                	mv	a0,s2
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	242080e7          	jalr	578(ra) # 80000b80 <initlock>
      char *pa = kalloc();
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	1da080e7          	jalr	474(ra) # 80000b20 <kalloc>
    8000194e:	85aa                	mv	a1,a0
      if(pa == 0)
    80001950:	c929                	beqz	a0,800019a2 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001952:	416904b3          	sub	s1,s2,s6
    80001956:	848d                	srai	s1,s1,0x3
    80001958:	000ab783          	ld	a5,0(s5)
    8000195c:	02f484b3          	mul	s1,s1,a5
    80001960:	2485                	addiw	s1,s1,1
    80001962:	00d4949b          	slliw	s1,s1,0xd
    80001966:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000196a:	4699                	li	a3,6
    8000196c:	6605                	lui	a2,0x1
    8000196e:	8526                	mv	a0,s1
    80001970:	00000097          	auipc	ra,0x0
    80001974:	85c080e7          	jalr	-1956(ra) # 800011cc <kvmmap>
      p->kstack = va;
    80001978:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197c:	16890913          	addi	s2,s2,360
    80001980:	fb491de3          	bne	s2,s4,8000193a <procinit+0x58>
  kvminithart();
    80001984:	fffff097          	auipc	ra,0xfffff
    80001988:	650080e7          	jalr	1616(ra) # 80000fd4 <kvminithart>
}
    8000198c:	60a6                	ld	ra,72(sp)
    8000198e:	6406                	ld	s0,64(sp)
    80001990:	74e2                	ld	s1,56(sp)
    80001992:	7942                	ld	s2,48(sp)
    80001994:	79a2                	ld	s3,40(sp)
    80001996:	7a02                	ld	s4,32(sp)
    80001998:	6ae2                	ld	s5,24(sp)
    8000199a:	6b42                	ld	s6,16(sp)
    8000199c:	6ba2                	ld	s7,8(sp)
    8000199e:	6161                	addi	sp,sp,80
    800019a0:	8082                	ret
        panic("kalloc");
    800019a2:	00007517          	auipc	a0,0x7
    800019a6:	83e50513          	addi	a0,a0,-1986 # 800081e0 <digits+0x1a0>
    800019aa:	fffff097          	auipc	ra,0xfffff
    800019ae:	b9e080e7          	jalr	-1122(ra) # 80000548 <panic>

00000000800019b2 <cpuid>:
{
    800019b2:	1141                	addi	sp,sp,-16
    800019b4:	e422                	sd	s0,8(sp)
    800019b6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019b8:	8512                	mv	a0,tp
}
    800019ba:	2501                	sext.w	a0,a0
    800019bc:	6422                	ld	s0,8(sp)
    800019be:	0141                	addi	sp,sp,16
    800019c0:	8082                	ret

00000000800019c2 <mycpu>:
mycpu(void) {
    800019c2:	1141                	addi	sp,sp,-16
    800019c4:	e422                	sd	s0,8(sp)
    800019c6:	0800                	addi	s0,sp,16
    800019c8:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    800019ca:	2781                	sext.w	a5,a5
    800019cc:	079e                	slli	a5,a5,0x7
}
    800019ce:	00010517          	auipc	a0,0x10
    800019d2:	f9a50513          	addi	a0,a0,-102 # 80011968 <cpus>
    800019d6:	953e                	add	a0,a0,a5
    800019d8:	6422                	ld	s0,8(sp)
    800019da:	0141                	addi	sp,sp,16
    800019dc:	8082                	ret

00000000800019de <myproc>:
myproc(void) {
    800019de:	1101                	addi	sp,sp,-32
    800019e0:	ec06                	sd	ra,24(sp)
    800019e2:	e822                	sd	s0,16(sp)
    800019e4:	e426                	sd	s1,8(sp)
    800019e6:	1000                	addi	s0,sp,32
  push_off();
    800019e8:	fffff097          	auipc	ra,0xfffff
    800019ec:	1dc080e7          	jalr	476(ra) # 80000bc4 <push_off>
    800019f0:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    800019f2:	2781                	sext.w	a5,a5
    800019f4:	079e                	slli	a5,a5,0x7
    800019f6:	00010717          	auipc	a4,0x10
    800019fa:	f5a70713          	addi	a4,a4,-166 # 80011950 <pid_lock>
    800019fe:	97ba                	add	a5,a5,a4
    80001a00:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a02:	fffff097          	auipc	ra,0xfffff
    80001a06:	262080e7          	jalr	610(ra) # 80000c64 <pop_off>
}
    80001a0a:	8526                	mv	a0,s1
    80001a0c:	60e2                	ld	ra,24(sp)
    80001a0e:	6442                	ld	s0,16(sp)
    80001a10:	64a2                	ld	s1,8(sp)
    80001a12:	6105                	addi	sp,sp,32
    80001a14:	8082                	ret

0000000080001a16 <forkret>:
{
    80001a16:	1141                	addi	sp,sp,-16
    80001a18:	e406                	sd	ra,8(sp)
    80001a1a:	e022                	sd	s0,0(sp)
    80001a1c:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a1e:	00000097          	auipc	ra,0x0
    80001a22:	fc0080e7          	jalr	-64(ra) # 800019de <myproc>
    80001a26:	fffff097          	auipc	ra,0xfffff
    80001a2a:	29e080e7          	jalr	670(ra) # 80000cc4 <release>
  if (first) {
    80001a2e:	00007797          	auipc	a5,0x7
    80001a32:	de27a783          	lw	a5,-542(a5) # 80008810 <first.1662>
    80001a36:	eb89                	bnez	a5,80001a48 <forkret+0x32>
  usertrapret();
    80001a38:	00001097          	auipc	ra,0x1
    80001a3c:	c18080e7          	jalr	-1000(ra) # 80002650 <usertrapret>
}
    80001a40:	60a2                	ld	ra,8(sp)
    80001a42:	6402                	ld	s0,0(sp)
    80001a44:	0141                	addi	sp,sp,16
    80001a46:	8082                	ret
    first = 0;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	dc07a423          	sw	zero,-568(a5) # 80008810 <first.1662>
    fsinit(ROOTDEV);
    80001a50:	4505                	li	a0,1
    80001a52:	00002097          	auipc	ra,0x2
    80001a56:	940080e7          	jalr	-1728(ra) # 80003392 <fsinit>
    80001a5a:	bff9                	j	80001a38 <forkret+0x22>

0000000080001a5c <allocpid>:
allocpid() {
    80001a5c:	1101                	addi	sp,sp,-32
    80001a5e:	ec06                	sd	ra,24(sp)
    80001a60:	e822                	sd	s0,16(sp)
    80001a62:	e426                	sd	s1,8(sp)
    80001a64:	e04a                	sd	s2,0(sp)
    80001a66:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a68:	00010917          	auipc	s2,0x10
    80001a6c:	ee890913          	addi	s2,s2,-280 # 80011950 <pid_lock>
    80001a70:	854a                	mv	a0,s2
    80001a72:	fffff097          	auipc	ra,0xfffff
    80001a76:	19e080e7          	jalr	414(ra) # 80000c10 <acquire>
  pid = nextpid;
    80001a7a:	00007797          	auipc	a5,0x7
    80001a7e:	d9a78793          	addi	a5,a5,-614 # 80008814 <nextpid>
    80001a82:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a84:	0014871b          	addiw	a4,s1,1
    80001a88:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a8a:	854a                	mv	a0,s2
    80001a8c:	fffff097          	auipc	ra,0xfffff
    80001a90:	238080e7          	jalr	568(ra) # 80000cc4 <release>
}
    80001a94:	8526                	mv	a0,s1
    80001a96:	60e2                	ld	ra,24(sp)
    80001a98:	6442                	ld	s0,16(sp)
    80001a9a:	64a2                	ld	s1,8(sp)
    80001a9c:	6902                	ld	s2,0(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <proc_pagetable>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
    80001aae:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ab0:	00000097          	auipc	ra,0x0
    80001ab4:	8ea080e7          	jalr	-1814(ra) # 8000139a <uvmcreate>
    80001ab8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001aba:	c121                	beqz	a0,80001afa <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001abc:	4729                	li	a4,10
    80001abe:	00005697          	auipc	a3,0x5
    80001ac2:	54268693          	addi	a3,a3,1346 # 80007000 <_trampoline>
    80001ac6:	6605                	lui	a2,0x1
    80001ac8:	040005b7          	lui	a1,0x4000
    80001acc:	15fd                	addi	a1,a1,-1
    80001ace:	05b2                	slli	a1,a1,0xc
    80001ad0:	fffff097          	auipc	ra,0xfffff
    80001ad4:	66e080e7          	jalr	1646(ra) # 8000113e <mappages>
    80001ad8:	02054863          	bltz	a0,80001b08 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001adc:	4719                	li	a4,6
    80001ade:	05893683          	ld	a3,88(s2)
    80001ae2:	6605                	lui	a2,0x1
    80001ae4:	020005b7          	lui	a1,0x2000
    80001ae8:	15fd                	addi	a1,a1,-1
    80001aea:	05b6                	slli	a1,a1,0xd
    80001aec:	8526                	mv	a0,s1
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	650080e7          	jalr	1616(ra) # 8000113e <mappages>
    80001af6:	02054163          	bltz	a0,80001b18 <proc_pagetable+0x76>
}
    80001afa:	8526                	mv	a0,s1
    80001afc:	60e2                	ld	ra,24(sp)
    80001afe:	6442                	ld	s0,16(sp)
    80001b00:	64a2                	ld	s1,8(sp)
    80001b02:	6902                	ld	s2,0(sp)
    80001b04:	6105                	addi	sp,sp,32
    80001b06:	8082                	ret
    uvmfree(pagetable, 0);
    80001b08:	4581                	li	a1,0
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	00000097          	auipc	ra,0x0
    80001b10:	a8a080e7          	jalr	-1398(ra) # 80001596 <uvmfree>
    return 0;
    80001b14:	4481                	li	s1,0
    80001b16:	b7d5                	j	80001afa <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b18:	4681                	li	a3,0
    80001b1a:	4605                	li	a2,1
    80001b1c:	040005b7          	lui	a1,0x4000
    80001b20:	15fd                	addi	a1,a1,-1
    80001b22:	05b2                	slli	a1,a1,0xc
    80001b24:	8526                	mv	a0,s1
    80001b26:	fffff097          	auipc	ra,0xfffff
    80001b2a:	7b0080e7          	jalr	1968(ra) # 800012d6 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b2e:	4581                	li	a1,0
    80001b30:	8526                	mv	a0,s1
    80001b32:	00000097          	auipc	ra,0x0
    80001b36:	a64080e7          	jalr	-1436(ra) # 80001596 <uvmfree>
    return 0;
    80001b3a:	4481                	li	s1,0
    80001b3c:	bf7d                	j	80001afa <proc_pagetable+0x58>

0000000080001b3e <proc_freepagetable>:
{
    80001b3e:	1101                	addi	sp,sp,-32
    80001b40:	ec06                	sd	ra,24(sp)
    80001b42:	e822                	sd	s0,16(sp)
    80001b44:	e426                	sd	s1,8(sp)
    80001b46:	e04a                	sd	s2,0(sp)
    80001b48:	1000                	addi	s0,sp,32
    80001b4a:	84aa                	mv	s1,a0
    80001b4c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b4e:	4681                	li	a3,0
    80001b50:	4605                	li	a2,1
    80001b52:	040005b7          	lui	a1,0x4000
    80001b56:	15fd                	addi	a1,a1,-1
    80001b58:	05b2                	slli	a1,a1,0xc
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	77c080e7          	jalr	1916(ra) # 800012d6 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b62:	4681                	li	a3,0
    80001b64:	4605                	li	a2,1
    80001b66:	020005b7          	lui	a1,0x2000
    80001b6a:	15fd                	addi	a1,a1,-1
    80001b6c:	05b6                	slli	a1,a1,0xd
    80001b6e:	8526                	mv	a0,s1
    80001b70:	fffff097          	auipc	ra,0xfffff
    80001b74:	766080e7          	jalr	1894(ra) # 800012d6 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b78:	85ca                	mv	a1,s2
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	00000097          	auipc	ra,0x0
    80001b80:	a1a080e7          	jalr	-1510(ra) # 80001596 <uvmfree>
}
    80001b84:	60e2                	ld	ra,24(sp)
    80001b86:	6442                	ld	s0,16(sp)
    80001b88:	64a2                	ld	s1,8(sp)
    80001b8a:	6902                	ld	s2,0(sp)
    80001b8c:	6105                	addi	sp,sp,32
    80001b8e:	8082                	ret

0000000080001b90 <freeproc>:
{
    80001b90:	1101                	addi	sp,sp,-32
    80001b92:	ec06                	sd	ra,24(sp)
    80001b94:	e822                	sd	s0,16(sp)
    80001b96:	e426                	sd	s1,8(sp)
    80001b98:	1000                	addi	s0,sp,32
    80001b9a:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b9c:	6d28                	ld	a0,88(a0)
    80001b9e:	c509                	beqz	a0,80001ba8 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001ba0:	fffff097          	auipc	ra,0xfffff
    80001ba4:	e84080e7          	jalr	-380(ra) # 80000a24 <kfree>
  p->trapframe = 0;
    80001ba8:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bac:	68a8                	ld	a0,80(s1)
    80001bae:	c511                	beqz	a0,80001bba <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bb0:	64ac                	ld	a1,72(s1)
    80001bb2:	00000097          	auipc	ra,0x0
    80001bb6:	f8c080e7          	jalr	-116(ra) # 80001b3e <proc_freepagetable>
  p->pagetable = 0;
    80001bba:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bbe:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bc2:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001bc6:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001bca:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bce:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001bd2:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001bd6:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001bda:	0004ac23          	sw	zero,24(s1)
}
    80001bde:	60e2                	ld	ra,24(sp)
    80001be0:	6442                	ld	s0,16(sp)
    80001be2:	64a2                	ld	s1,8(sp)
    80001be4:	6105                	addi	sp,sp,32
    80001be6:	8082                	ret

0000000080001be8 <allocproc>:
{
    80001be8:	1101                	addi	sp,sp,-32
    80001bea:	ec06                	sd	ra,24(sp)
    80001bec:	e822                	sd	s0,16(sp)
    80001bee:	e426                	sd	s1,8(sp)
    80001bf0:	e04a                	sd	s2,0(sp)
    80001bf2:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf4:	00010497          	auipc	s1,0x10
    80001bf8:	17448493          	addi	s1,s1,372 # 80011d68 <proc>
    80001bfc:	00016917          	auipc	s2,0x16
    80001c00:	b6c90913          	addi	s2,s2,-1172 # 80017768 <tickslock>
    acquire(&p->lock);
    80001c04:	8526                	mv	a0,s1
    80001c06:	fffff097          	auipc	ra,0xfffff
    80001c0a:	00a080e7          	jalr	10(ra) # 80000c10 <acquire>
    if(p->state == UNUSED) {
    80001c0e:	4c9c                	lw	a5,24(s1)
    80001c10:	cf81                	beqz	a5,80001c28 <allocproc+0x40>
      release(&p->lock);
    80001c12:	8526                	mv	a0,s1
    80001c14:	fffff097          	auipc	ra,0xfffff
    80001c18:	0b0080e7          	jalr	176(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c1c:	16848493          	addi	s1,s1,360
    80001c20:	ff2492e3          	bne	s1,s2,80001c04 <allocproc+0x1c>
  return 0;
    80001c24:	4481                	li	s1,0
    80001c26:	a0b9                	j	80001c74 <allocproc+0x8c>
  p->pid = allocpid();
    80001c28:	00000097          	auipc	ra,0x0
    80001c2c:	e34080e7          	jalr	-460(ra) # 80001a5c <allocpid>
    80001c30:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c32:	fffff097          	auipc	ra,0xfffff
    80001c36:	eee080e7          	jalr	-274(ra) # 80000b20 <kalloc>
    80001c3a:	892a                	mv	s2,a0
    80001c3c:	eca8                	sd	a0,88(s1)
    80001c3e:	c131                	beqz	a0,80001c82 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001c40:	8526                	mv	a0,s1
    80001c42:	00000097          	auipc	ra,0x0
    80001c46:	e60080e7          	jalr	-416(ra) # 80001aa2 <proc_pagetable>
    80001c4a:	892a                	mv	s2,a0
    80001c4c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c4e:	c129                	beqz	a0,80001c90 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001c50:	07000613          	li	a2,112
    80001c54:	4581                	li	a1,0
    80001c56:	06048513          	addi	a0,s1,96
    80001c5a:	fffff097          	auipc	ra,0xfffff
    80001c5e:	0b2080e7          	jalr	178(ra) # 80000d0c <memset>
  p->context.ra = (uint64)forkret;
    80001c62:	00000797          	auipc	a5,0x0
    80001c66:	db478793          	addi	a5,a5,-588 # 80001a16 <forkret>
    80001c6a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c6c:	60bc                	ld	a5,64(s1)
    80001c6e:	6705                	lui	a4,0x1
    80001c70:	97ba                	add	a5,a5,a4
    80001c72:	f4bc                	sd	a5,104(s1)
}
    80001c74:	8526                	mv	a0,s1
    80001c76:	60e2                	ld	ra,24(sp)
    80001c78:	6442                	ld	s0,16(sp)
    80001c7a:	64a2                	ld	s1,8(sp)
    80001c7c:	6902                	ld	s2,0(sp)
    80001c7e:	6105                	addi	sp,sp,32
    80001c80:	8082                	ret
    release(&p->lock);
    80001c82:	8526                	mv	a0,s1
    80001c84:	fffff097          	auipc	ra,0xfffff
    80001c88:	040080e7          	jalr	64(ra) # 80000cc4 <release>
    return 0;
    80001c8c:	84ca                	mv	s1,s2
    80001c8e:	b7dd                	j	80001c74 <allocproc+0x8c>
    freeproc(p);
    80001c90:	8526                	mv	a0,s1
    80001c92:	00000097          	auipc	ra,0x0
    80001c96:	efe080e7          	jalr	-258(ra) # 80001b90 <freeproc>
    release(&p->lock);
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	028080e7          	jalr	40(ra) # 80000cc4 <release>
    return 0;
    80001ca4:	84ca                	mv	s1,s2
    80001ca6:	b7f9                	j	80001c74 <allocproc+0x8c>

0000000080001ca8 <userinit>:
{
    80001ca8:	1101                	addi	sp,sp,-32
    80001caa:	ec06                	sd	ra,24(sp)
    80001cac:	e822                	sd	s0,16(sp)
    80001cae:	e426                	sd	s1,8(sp)
    80001cb0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cb2:	00000097          	auipc	ra,0x0
    80001cb6:	f36080e7          	jalr	-202(ra) # 80001be8 <allocproc>
    80001cba:	84aa                	mv	s1,a0
  initproc = p;
    80001cbc:	00007797          	auipc	a5,0x7
    80001cc0:	34a7be23          	sd	a0,860(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cc4:	03400613          	li	a2,52
    80001cc8:	00007597          	auipc	a1,0x7
    80001ccc:	b5858593          	addi	a1,a1,-1192 # 80008820 <initcode>
    80001cd0:	6928                	ld	a0,80(a0)
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	6f6080e7          	jalr	1782(ra) # 800013c8 <uvminit>
  p->sz = PGSIZE;
    80001cda:	6785                	lui	a5,0x1
    80001cdc:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cde:	6cb8                	ld	a4,88(s1)
    80001ce0:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001ce4:	6cb8                	ld	a4,88(s1)
    80001ce6:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ce8:	4641                	li	a2,16
    80001cea:	00006597          	auipc	a1,0x6
    80001cee:	4fe58593          	addi	a1,a1,1278 # 800081e8 <digits+0x1a8>
    80001cf2:	15848513          	addi	a0,s1,344
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	16c080e7          	jalr	364(ra) # 80000e62 <safestrcpy>
  p->cwd = namei("/");
    80001cfe:	00006517          	auipc	a0,0x6
    80001d02:	4fa50513          	addi	a0,a0,1274 # 800081f8 <digits+0x1b8>
    80001d06:	00002097          	auipc	ra,0x2
    80001d0a:	0b4080e7          	jalr	180(ra) # 80003dba <namei>
    80001d0e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d12:	4789                	li	a5,2
    80001d14:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d16:	8526                	mv	a0,s1
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	fac080e7          	jalr	-84(ra) # 80000cc4 <release>
}
    80001d20:	60e2                	ld	ra,24(sp)
    80001d22:	6442                	ld	s0,16(sp)
    80001d24:	64a2                	ld	s1,8(sp)
    80001d26:	6105                	addi	sp,sp,32
    80001d28:	8082                	ret

0000000080001d2a <growproc>:
{
    80001d2a:	1101                	addi	sp,sp,-32
    80001d2c:	ec06                	sd	ra,24(sp)
    80001d2e:	e822                	sd	s0,16(sp)
    80001d30:	e426                	sd	s1,8(sp)
    80001d32:	e04a                	sd	s2,0(sp)
    80001d34:	1000                	addi	s0,sp,32
    80001d36:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d38:	00000097          	auipc	ra,0x0
    80001d3c:	ca6080e7          	jalr	-858(ra) # 800019de <myproc>
    80001d40:	892a                	mv	s2,a0
  sz = p->sz;
    80001d42:	652c                	ld	a1,72(a0)
    80001d44:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d48:	00904f63          	bgtz	s1,80001d66 <growproc+0x3c>
  } else if(n < 0){
    80001d4c:	0204cc63          	bltz	s1,80001d84 <growproc+0x5a>
  p->sz = sz;
    80001d50:	1602                	slli	a2,a2,0x20
    80001d52:	9201                	srli	a2,a2,0x20
    80001d54:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d58:	4501                	li	a0,0
}
    80001d5a:	60e2                	ld	ra,24(sp)
    80001d5c:	6442                	ld	s0,16(sp)
    80001d5e:	64a2                	ld	s1,8(sp)
    80001d60:	6902                	ld	s2,0(sp)
    80001d62:	6105                	addi	sp,sp,32
    80001d64:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d66:	9e25                	addw	a2,a2,s1
    80001d68:	1602                	slli	a2,a2,0x20
    80001d6a:	9201                	srli	a2,a2,0x20
    80001d6c:	1582                	slli	a1,a1,0x20
    80001d6e:	9181                	srli	a1,a1,0x20
    80001d70:	6928                	ld	a0,80(a0)
    80001d72:	fffff097          	auipc	ra,0xfffff
    80001d76:	710080e7          	jalr	1808(ra) # 80001482 <uvmalloc>
    80001d7a:	0005061b          	sext.w	a2,a0
    80001d7e:	fa69                	bnez	a2,80001d50 <growproc+0x26>
      return -1;
    80001d80:	557d                	li	a0,-1
    80001d82:	bfe1                	j	80001d5a <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d84:	9e25                	addw	a2,a2,s1
    80001d86:	1602                	slli	a2,a2,0x20
    80001d88:	9201                	srli	a2,a2,0x20
    80001d8a:	1582                	slli	a1,a1,0x20
    80001d8c:	9181                	srli	a1,a1,0x20
    80001d8e:	6928                	ld	a0,80(a0)
    80001d90:	fffff097          	auipc	ra,0xfffff
    80001d94:	6aa080e7          	jalr	1706(ra) # 8000143a <uvmdealloc>
    80001d98:	0005061b          	sext.w	a2,a0
    80001d9c:	bf55                	j	80001d50 <growproc+0x26>

0000000080001d9e <fork>:
{
    80001d9e:	7179                	addi	sp,sp,-48
    80001da0:	f406                	sd	ra,40(sp)
    80001da2:	f022                	sd	s0,32(sp)
    80001da4:	ec26                	sd	s1,24(sp)
    80001da6:	e84a                	sd	s2,16(sp)
    80001da8:	e44e                	sd	s3,8(sp)
    80001daa:	e052                	sd	s4,0(sp)
    80001dac:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dae:	00000097          	auipc	ra,0x0
    80001db2:	c30080e7          	jalr	-976(ra) # 800019de <myproc>
    80001db6:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001db8:	00000097          	auipc	ra,0x0
    80001dbc:	e30080e7          	jalr	-464(ra) # 80001be8 <allocproc>
    80001dc0:	c175                	beqz	a0,80001ea4 <fork+0x106>
    80001dc2:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dc4:	04893603          	ld	a2,72(s2)
    80001dc8:	692c                	ld	a1,80(a0)
    80001dca:	05093503          	ld	a0,80(s2)
    80001dce:	00000097          	auipc	ra,0x0
    80001dd2:	800080e7          	jalr	-2048(ra) # 800015ce <uvmcopy>
    80001dd6:	04054863          	bltz	a0,80001e26 <fork+0x88>
  np->sz = p->sz;
    80001dda:	04893783          	ld	a5,72(s2)
    80001dde:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001de2:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001de6:	05893683          	ld	a3,88(s2)
    80001dea:	87b6                	mv	a5,a3
    80001dec:	0589b703          	ld	a4,88(s3)
    80001df0:	12068693          	addi	a3,a3,288
    80001df4:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001df8:	6788                	ld	a0,8(a5)
    80001dfa:	6b8c                	ld	a1,16(a5)
    80001dfc:	6f90                	ld	a2,24(a5)
    80001dfe:	01073023          	sd	a6,0(a4)
    80001e02:	e708                	sd	a0,8(a4)
    80001e04:	eb0c                	sd	a1,16(a4)
    80001e06:	ef10                	sd	a2,24(a4)
    80001e08:	02078793          	addi	a5,a5,32
    80001e0c:	02070713          	addi	a4,a4,32
    80001e10:	fed792e3          	bne	a5,a3,80001df4 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e14:	0589b783          	ld	a5,88(s3)
    80001e18:	0607b823          	sd	zero,112(a5)
    80001e1c:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e20:	15000a13          	li	s4,336
    80001e24:	a03d                	j	80001e52 <fork+0xb4>
    freeproc(np);
    80001e26:	854e                	mv	a0,s3
    80001e28:	00000097          	auipc	ra,0x0
    80001e2c:	d68080e7          	jalr	-664(ra) # 80001b90 <freeproc>
    release(&np->lock);
    80001e30:	854e                	mv	a0,s3
    80001e32:	fffff097          	auipc	ra,0xfffff
    80001e36:	e92080e7          	jalr	-366(ra) # 80000cc4 <release>
    return -1;
    80001e3a:	54fd                	li	s1,-1
    80001e3c:	a899                	j	80001e92 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e3e:	00002097          	auipc	ra,0x2
    80001e42:	608080e7          	jalr	1544(ra) # 80004446 <filedup>
    80001e46:	009987b3          	add	a5,s3,s1
    80001e4a:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001e4c:	04a1                	addi	s1,s1,8
    80001e4e:	01448763          	beq	s1,s4,80001e5c <fork+0xbe>
    if(p->ofile[i])
    80001e52:	009907b3          	add	a5,s2,s1
    80001e56:	6388                	ld	a0,0(a5)
    80001e58:	f17d                	bnez	a0,80001e3e <fork+0xa0>
    80001e5a:	bfcd                	j	80001e4c <fork+0xae>
  np->cwd = idup(p->cwd);
    80001e5c:	15093503          	ld	a0,336(s2)
    80001e60:	00001097          	auipc	ra,0x1
    80001e64:	76c080e7          	jalr	1900(ra) # 800035cc <idup>
    80001e68:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e6c:	4641                	li	a2,16
    80001e6e:	15890593          	addi	a1,s2,344
    80001e72:	15898513          	addi	a0,s3,344
    80001e76:	fffff097          	auipc	ra,0xfffff
    80001e7a:	fec080e7          	jalr	-20(ra) # 80000e62 <safestrcpy>
  pid = np->pid;
    80001e7e:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001e82:	4789                	li	a5,2
    80001e84:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e88:	854e                	mv	a0,s3
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	e3a080e7          	jalr	-454(ra) # 80000cc4 <release>
}
    80001e92:	8526                	mv	a0,s1
    80001e94:	70a2                	ld	ra,40(sp)
    80001e96:	7402                	ld	s0,32(sp)
    80001e98:	64e2                	ld	s1,24(sp)
    80001e9a:	6942                	ld	s2,16(sp)
    80001e9c:	69a2                	ld	s3,8(sp)
    80001e9e:	6a02                	ld	s4,0(sp)
    80001ea0:	6145                	addi	sp,sp,48
    80001ea2:	8082                	ret
    return -1;
    80001ea4:	54fd                	li	s1,-1
    80001ea6:	b7f5                	j	80001e92 <fork+0xf4>

0000000080001ea8 <reparent>:
{
    80001ea8:	7179                	addi	sp,sp,-48
    80001eaa:	f406                	sd	ra,40(sp)
    80001eac:	f022                	sd	s0,32(sp)
    80001eae:	ec26                	sd	s1,24(sp)
    80001eb0:	e84a                	sd	s2,16(sp)
    80001eb2:	e44e                	sd	s3,8(sp)
    80001eb4:	e052                	sd	s4,0(sp)
    80001eb6:	1800                	addi	s0,sp,48
    80001eb8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001eba:	00010497          	auipc	s1,0x10
    80001ebe:	eae48493          	addi	s1,s1,-338 # 80011d68 <proc>
      pp->parent = initproc;
    80001ec2:	00007a17          	auipc	s4,0x7
    80001ec6:	156a0a13          	addi	s4,s4,342 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001eca:	00016997          	auipc	s3,0x16
    80001ece:	89e98993          	addi	s3,s3,-1890 # 80017768 <tickslock>
    80001ed2:	a029                	j	80001edc <reparent+0x34>
    80001ed4:	16848493          	addi	s1,s1,360
    80001ed8:	03348363          	beq	s1,s3,80001efe <reparent+0x56>
    if(pp->parent == p){
    80001edc:	709c                	ld	a5,32(s1)
    80001ede:	ff279be3          	bne	a5,s2,80001ed4 <reparent+0x2c>
      acquire(&pp->lock);
    80001ee2:	8526                	mv	a0,s1
    80001ee4:	fffff097          	auipc	ra,0xfffff
    80001ee8:	d2c080e7          	jalr	-724(ra) # 80000c10 <acquire>
      pp->parent = initproc;
    80001eec:	000a3783          	ld	a5,0(s4)
    80001ef0:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001ef2:	8526                	mv	a0,s1
    80001ef4:	fffff097          	auipc	ra,0xfffff
    80001ef8:	dd0080e7          	jalr	-560(ra) # 80000cc4 <release>
    80001efc:	bfe1                	j	80001ed4 <reparent+0x2c>
}
    80001efe:	70a2                	ld	ra,40(sp)
    80001f00:	7402                	ld	s0,32(sp)
    80001f02:	64e2                	ld	s1,24(sp)
    80001f04:	6942                	ld	s2,16(sp)
    80001f06:	69a2                	ld	s3,8(sp)
    80001f08:	6a02                	ld	s4,0(sp)
    80001f0a:	6145                	addi	sp,sp,48
    80001f0c:	8082                	ret

0000000080001f0e <scheduler>:
{
    80001f0e:	715d                	addi	sp,sp,-80
    80001f10:	e486                	sd	ra,72(sp)
    80001f12:	e0a2                	sd	s0,64(sp)
    80001f14:	fc26                	sd	s1,56(sp)
    80001f16:	f84a                	sd	s2,48(sp)
    80001f18:	f44e                	sd	s3,40(sp)
    80001f1a:	f052                	sd	s4,32(sp)
    80001f1c:	ec56                	sd	s5,24(sp)
    80001f1e:	e85a                	sd	s6,16(sp)
    80001f20:	e45e                	sd	s7,8(sp)
    80001f22:	e062                	sd	s8,0(sp)
    80001f24:	0880                	addi	s0,sp,80
    80001f26:	8792                	mv	a5,tp
  int id = r_tp();
    80001f28:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f2a:	00779b13          	slli	s6,a5,0x7
    80001f2e:	00010717          	auipc	a4,0x10
    80001f32:	a2270713          	addi	a4,a4,-1502 # 80011950 <pid_lock>
    80001f36:	975a                	add	a4,a4,s6
    80001f38:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001f3c:	00010717          	auipc	a4,0x10
    80001f40:	a3470713          	addi	a4,a4,-1484 # 80011970 <cpus+0x8>
    80001f44:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f46:	4c0d                	li	s8,3
        c->proc = p;
    80001f48:	079e                	slli	a5,a5,0x7
    80001f4a:	00010a17          	auipc	s4,0x10
    80001f4e:	a06a0a13          	addi	s4,s4,-1530 # 80011950 <pid_lock>
    80001f52:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f54:	00016997          	auipc	s3,0x16
    80001f58:	81498993          	addi	s3,s3,-2028 # 80017768 <tickslock>
        found = 1;
    80001f5c:	4b85                	li	s7,1
    80001f5e:	a899                	j	80001fb4 <scheduler+0xa6>
        p->state = RUNNING;
    80001f60:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001f64:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80001f68:	06048593          	addi	a1,s1,96
    80001f6c:	855a                	mv	a0,s6
    80001f6e:	00000097          	auipc	ra,0x0
    80001f72:	638080e7          	jalr	1592(ra) # 800025a6 <swtch>
        c->proc = 0;
    80001f76:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001f7a:	8ade                	mv	s5,s7
      release(&p->lock);
    80001f7c:	8526                	mv	a0,s1
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	d46080e7          	jalr	-698(ra) # 80000cc4 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f86:	16848493          	addi	s1,s1,360
    80001f8a:	01348b63          	beq	s1,s3,80001fa0 <scheduler+0x92>
      acquire(&p->lock);
    80001f8e:	8526                	mv	a0,s1
    80001f90:	fffff097          	auipc	ra,0xfffff
    80001f94:	c80080e7          	jalr	-896(ra) # 80000c10 <acquire>
      if(p->state == RUNNABLE) {
    80001f98:	4c9c                	lw	a5,24(s1)
    80001f9a:	ff2791e3          	bne	a5,s2,80001f7c <scheduler+0x6e>
    80001f9e:	b7c9                	j	80001f60 <scheduler+0x52>
    if(found == 0) {
    80001fa0:	000a9a63          	bnez	s5,80001fb4 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fa8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fac:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001fb0:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fb4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fb8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fbc:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001fc0:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fc2:	00010497          	auipc	s1,0x10
    80001fc6:	da648493          	addi	s1,s1,-602 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    80001fca:	4909                	li	s2,2
    80001fcc:	b7c9                	j	80001f8e <scheduler+0x80>

0000000080001fce <sched>:
{
    80001fce:	7179                	addi	sp,sp,-48
    80001fd0:	f406                	sd	ra,40(sp)
    80001fd2:	f022                	sd	s0,32(sp)
    80001fd4:	ec26                	sd	s1,24(sp)
    80001fd6:	e84a                	sd	s2,16(sp)
    80001fd8:	e44e                	sd	s3,8(sp)
    80001fda:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fdc:	00000097          	auipc	ra,0x0
    80001fe0:	a02080e7          	jalr	-1534(ra) # 800019de <myproc>
    80001fe4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fe6:	fffff097          	auipc	ra,0xfffff
    80001fea:	bb0080e7          	jalr	-1104(ra) # 80000b96 <holding>
    80001fee:	c93d                	beqz	a0,80002064 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ff0:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001ff2:	2781                	sext.w	a5,a5
    80001ff4:	079e                	slli	a5,a5,0x7
    80001ff6:	00010717          	auipc	a4,0x10
    80001ffa:	95a70713          	addi	a4,a4,-1702 # 80011950 <pid_lock>
    80001ffe:	97ba                	add	a5,a5,a4
    80002000:	0907a703          	lw	a4,144(a5)
    80002004:	4785                	li	a5,1
    80002006:	06f71763          	bne	a4,a5,80002074 <sched+0xa6>
  if(p->state == RUNNING)
    8000200a:	4c98                	lw	a4,24(s1)
    8000200c:	478d                	li	a5,3
    8000200e:	06f70b63          	beq	a4,a5,80002084 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002012:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002016:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002018:	efb5                	bnez	a5,80002094 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000201a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000201c:	00010917          	auipc	s2,0x10
    80002020:	93490913          	addi	s2,s2,-1740 # 80011950 <pid_lock>
    80002024:	2781                	sext.w	a5,a5
    80002026:	079e                	slli	a5,a5,0x7
    80002028:	97ca                	add	a5,a5,s2
    8000202a:	0947a983          	lw	s3,148(a5)
    8000202e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002030:	2781                	sext.w	a5,a5
    80002032:	079e                	slli	a5,a5,0x7
    80002034:	00010597          	auipc	a1,0x10
    80002038:	93c58593          	addi	a1,a1,-1732 # 80011970 <cpus+0x8>
    8000203c:	95be                	add	a1,a1,a5
    8000203e:	06048513          	addi	a0,s1,96
    80002042:	00000097          	auipc	ra,0x0
    80002046:	564080e7          	jalr	1380(ra) # 800025a6 <swtch>
    8000204a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000204c:	2781                	sext.w	a5,a5
    8000204e:	079e                	slli	a5,a5,0x7
    80002050:	97ca                	add	a5,a5,s2
    80002052:	0937aa23          	sw	s3,148(a5)
}
    80002056:	70a2                	ld	ra,40(sp)
    80002058:	7402                	ld	s0,32(sp)
    8000205a:	64e2                	ld	s1,24(sp)
    8000205c:	6942                	ld	s2,16(sp)
    8000205e:	69a2                	ld	s3,8(sp)
    80002060:	6145                	addi	sp,sp,48
    80002062:	8082                	ret
    panic("sched p->lock");
    80002064:	00006517          	auipc	a0,0x6
    80002068:	19c50513          	addi	a0,a0,412 # 80008200 <digits+0x1c0>
    8000206c:	ffffe097          	auipc	ra,0xffffe
    80002070:	4dc080e7          	jalr	1244(ra) # 80000548 <panic>
    panic("sched locks");
    80002074:	00006517          	auipc	a0,0x6
    80002078:	19c50513          	addi	a0,a0,412 # 80008210 <digits+0x1d0>
    8000207c:	ffffe097          	auipc	ra,0xffffe
    80002080:	4cc080e7          	jalr	1228(ra) # 80000548 <panic>
    panic("sched running");
    80002084:	00006517          	auipc	a0,0x6
    80002088:	19c50513          	addi	a0,a0,412 # 80008220 <digits+0x1e0>
    8000208c:	ffffe097          	auipc	ra,0xffffe
    80002090:	4bc080e7          	jalr	1212(ra) # 80000548 <panic>
    panic("sched interruptible");
    80002094:	00006517          	auipc	a0,0x6
    80002098:	19c50513          	addi	a0,a0,412 # 80008230 <digits+0x1f0>
    8000209c:	ffffe097          	auipc	ra,0xffffe
    800020a0:	4ac080e7          	jalr	1196(ra) # 80000548 <panic>

00000000800020a4 <exit>:
{
    800020a4:	7179                	addi	sp,sp,-48
    800020a6:	f406                	sd	ra,40(sp)
    800020a8:	f022                	sd	s0,32(sp)
    800020aa:	ec26                	sd	s1,24(sp)
    800020ac:	e84a                	sd	s2,16(sp)
    800020ae:	e44e                	sd	s3,8(sp)
    800020b0:	e052                	sd	s4,0(sp)
    800020b2:	1800                	addi	s0,sp,48
    800020b4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020b6:	00000097          	auipc	ra,0x0
    800020ba:	928080e7          	jalr	-1752(ra) # 800019de <myproc>
    800020be:	89aa                	mv	s3,a0
  if(p == initproc)
    800020c0:	00007797          	auipc	a5,0x7
    800020c4:	f587b783          	ld	a5,-168(a5) # 80009018 <initproc>
    800020c8:	0d050493          	addi	s1,a0,208
    800020cc:	15050913          	addi	s2,a0,336
    800020d0:	02a79363          	bne	a5,a0,800020f6 <exit+0x52>
    panic("init exiting");
    800020d4:	00006517          	auipc	a0,0x6
    800020d8:	17450513          	addi	a0,a0,372 # 80008248 <digits+0x208>
    800020dc:	ffffe097          	auipc	ra,0xffffe
    800020e0:	46c080e7          	jalr	1132(ra) # 80000548 <panic>
      fileclose(f);
    800020e4:	00002097          	auipc	ra,0x2
    800020e8:	3b4080e7          	jalr	948(ra) # 80004498 <fileclose>
      p->ofile[fd] = 0;
    800020ec:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800020f0:	04a1                	addi	s1,s1,8
    800020f2:	01248563          	beq	s1,s2,800020fc <exit+0x58>
    if(p->ofile[fd]){
    800020f6:	6088                	ld	a0,0(s1)
    800020f8:	f575                	bnez	a0,800020e4 <exit+0x40>
    800020fa:	bfdd                	j	800020f0 <exit+0x4c>
  begin_op();
    800020fc:	00002097          	auipc	ra,0x2
    80002100:	eca080e7          	jalr	-310(ra) # 80003fc6 <begin_op>
  iput(p->cwd);
    80002104:	1509b503          	ld	a0,336(s3)
    80002108:	00001097          	auipc	ra,0x1
    8000210c:	6bc080e7          	jalr	1724(ra) # 800037c4 <iput>
  end_op();
    80002110:	00002097          	auipc	ra,0x2
    80002114:	f36080e7          	jalr	-202(ra) # 80004046 <end_op>
  p->cwd = 0;
    80002118:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000211c:	00007497          	auipc	s1,0x7
    80002120:	efc48493          	addi	s1,s1,-260 # 80009018 <initproc>
    80002124:	6088                	ld	a0,0(s1)
    80002126:	fffff097          	auipc	ra,0xfffff
    8000212a:	aea080e7          	jalr	-1302(ra) # 80000c10 <acquire>
  wakeup1(initproc);
    8000212e:	6088                	ld	a0,0(s1)
    80002130:	fffff097          	auipc	ra,0xfffff
    80002134:	76e080e7          	jalr	1902(ra) # 8000189e <wakeup1>
  release(&initproc->lock);
    80002138:	6088                	ld	a0,0(s1)
    8000213a:	fffff097          	auipc	ra,0xfffff
    8000213e:	b8a080e7          	jalr	-1142(ra) # 80000cc4 <release>
  acquire(&p->lock);
    80002142:	854e                	mv	a0,s3
    80002144:	fffff097          	auipc	ra,0xfffff
    80002148:	acc080e7          	jalr	-1332(ra) # 80000c10 <acquire>
  struct proc *original_parent = p->parent;
    8000214c:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002150:	854e                	mv	a0,s3
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	b72080e7          	jalr	-1166(ra) # 80000cc4 <release>
  acquire(&original_parent->lock);
    8000215a:	8526                	mv	a0,s1
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	ab4080e7          	jalr	-1356(ra) # 80000c10 <acquire>
  acquire(&p->lock);
    80002164:	854e                	mv	a0,s3
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	aaa080e7          	jalr	-1366(ra) # 80000c10 <acquire>
  reparent(p);
    8000216e:	854e                	mv	a0,s3
    80002170:	00000097          	auipc	ra,0x0
    80002174:	d38080e7          	jalr	-712(ra) # 80001ea8 <reparent>
  wakeup1(original_parent);
    80002178:	8526                	mv	a0,s1
    8000217a:	fffff097          	auipc	ra,0xfffff
    8000217e:	724080e7          	jalr	1828(ra) # 8000189e <wakeup1>
  p->xstate = status;
    80002182:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002186:	4791                	li	a5,4
    80002188:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    8000218c:	8526                	mv	a0,s1
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	b36080e7          	jalr	-1226(ra) # 80000cc4 <release>
  sched();
    80002196:	00000097          	auipc	ra,0x0
    8000219a:	e38080e7          	jalr	-456(ra) # 80001fce <sched>
  panic("zombie exit");
    8000219e:	00006517          	auipc	a0,0x6
    800021a2:	0ba50513          	addi	a0,a0,186 # 80008258 <digits+0x218>
    800021a6:	ffffe097          	auipc	ra,0xffffe
    800021aa:	3a2080e7          	jalr	930(ra) # 80000548 <panic>

00000000800021ae <yield>:
{
    800021ae:	1101                	addi	sp,sp,-32
    800021b0:	ec06                	sd	ra,24(sp)
    800021b2:	e822                	sd	s0,16(sp)
    800021b4:	e426                	sd	s1,8(sp)
    800021b6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021b8:	00000097          	auipc	ra,0x0
    800021bc:	826080e7          	jalr	-2010(ra) # 800019de <myproc>
    800021c0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021c2:	fffff097          	auipc	ra,0xfffff
    800021c6:	a4e080e7          	jalr	-1458(ra) # 80000c10 <acquire>
  p->state = RUNNABLE;
    800021ca:	4789                	li	a5,2
    800021cc:	cc9c                	sw	a5,24(s1)
  sched();
    800021ce:	00000097          	auipc	ra,0x0
    800021d2:	e00080e7          	jalr	-512(ra) # 80001fce <sched>
  release(&p->lock);
    800021d6:	8526                	mv	a0,s1
    800021d8:	fffff097          	auipc	ra,0xfffff
    800021dc:	aec080e7          	jalr	-1300(ra) # 80000cc4 <release>
}
    800021e0:	60e2                	ld	ra,24(sp)
    800021e2:	6442                	ld	s0,16(sp)
    800021e4:	64a2                	ld	s1,8(sp)
    800021e6:	6105                	addi	sp,sp,32
    800021e8:	8082                	ret

00000000800021ea <sleep>:
{
    800021ea:	7179                	addi	sp,sp,-48
    800021ec:	f406                	sd	ra,40(sp)
    800021ee:	f022                	sd	s0,32(sp)
    800021f0:	ec26                	sd	s1,24(sp)
    800021f2:	e84a                	sd	s2,16(sp)
    800021f4:	e44e                	sd	s3,8(sp)
    800021f6:	1800                	addi	s0,sp,48
    800021f8:	89aa                	mv	s3,a0
    800021fa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021fc:	fffff097          	auipc	ra,0xfffff
    80002200:	7e2080e7          	jalr	2018(ra) # 800019de <myproc>
    80002204:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002206:	05250663          	beq	a0,s2,80002252 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	a06080e7          	jalr	-1530(ra) # 80000c10 <acquire>
    release(lk);
    80002212:	854a                	mv	a0,s2
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	ab0080e7          	jalr	-1360(ra) # 80000cc4 <release>
  p->chan = chan;
    8000221c:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002220:	4785                	li	a5,1
    80002222:	cc9c                	sw	a5,24(s1)
  sched();
    80002224:	00000097          	auipc	ra,0x0
    80002228:	daa080e7          	jalr	-598(ra) # 80001fce <sched>
  p->chan = 0;
    8000222c:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002230:	8526                	mv	a0,s1
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	a92080e7          	jalr	-1390(ra) # 80000cc4 <release>
    acquire(lk);
    8000223a:	854a                	mv	a0,s2
    8000223c:	fffff097          	auipc	ra,0xfffff
    80002240:	9d4080e7          	jalr	-1580(ra) # 80000c10 <acquire>
}
    80002244:	70a2                	ld	ra,40(sp)
    80002246:	7402                	ld	s0,32(sp)
    80002248:	64e2                	ld	s1,24(sp)
    8000224a:	6942                	ld	s2,16(sp)
    8000224c:	69a2                	ld	s3,8(sp)
    8000224e:	6145                	addi	sp,sp,48
    80002250:	8082                	ret
  p->chan = chan;
    80002252:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002256:	4785                	li	a5,1
    80002258:	cd1c                	sw	a5,24(a0)
  sched();
    8000225a:	00000097          	auipc	ra,0x0
    8000225e:	d74080e7          	jalr	-652(ra) # 80001fce <sched>
  p->chan = 0;
    80002262:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002266:	bff9                	j	80002244 <sleep+0x5a>

0000000080002268 <wait>:
{
    80002268:	715d                	addi	sp,sp,-80
    8000226a:	e486                	sd	ra,72(sp)
    8000226c:	e0a2                	sd	s0,64(sp)
    8000226e:	fc26                	sd	s1,56(sp)
    80002270:	f84a                	sd	s2,48(sp)
    80002272:	f44e                	sd	s3,40(sp)
    80002274:	f052                	sd	s4,32(sp)
    80002276:	ec56                	sd	s5,24(sp)
    80002278:	e85a                	sd	s6,16(sp)
    8000227a:	e45e                	sd	s7,8(sp)
    8000227c:	e062                	sd	s8,0(sp)
    8000227e:	0880                	addi	s0,sp,80
    80002280:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	75c080e7          	jalr	1884(ra) # 800019de <myproc>
    8000228a:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000228c:	8c2a                	mv	s8,a0
    8000228e:	fffff097          	auipc	ra,0xfffff
    80002292:	982080e7          	jalr	-1662(ra) # 80000c10 <acquire>
    havekids = 0;
    80002296:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002298:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    8000229a:	00015997          	auipc	s3,0x15
    8000229e:	4ce98993          	addi	s3,s3,1230 # 80017768 <tickslock>
        havekids = 1;
    800022a2:	4a85                	li	s5,1
    havekids = 0;
    800022a4:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800022a6:	00010497          	auipc	s1,0x10
    800022aa:	ac248493          	addi	s1,s1,-1342 # 80011d68 <proc>
    800022ae:	a08d                	j	80002310 <wait+0xa8>
          pid = np->pid;
    800022b0:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022b4:	000b0e63          	beqz	s6,800022d0 <wait+0x68>
    800022b8:	4691                	li	a3,4
    800022ba:	03448613          	addi	a2,s1,52
    800022be:	85da                	mv	a1,s6
    800022c0:	05093503          	ld	a0,80(s2)
    800022c4:	fffff097          	auipc	ra,0xfffff
    800022c8:	40e080e7          	jalr	1038(ra) # 800016d2 <copyout>
    800022cc:	02054263          	bltz	a0,800022f0 <wait+0x88>
          freeproc(np);
    800022d0:	8526                	mv	a0,s1
    800022d2:	00000097          	auipc	ra,0x0
    800022d6:	8be080e7          	jalr	-1858(ra) # 80001b90 <freeproc>
          release(&np->lock);
    800022da:	8526                	mv	a0,s1
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	9e8080e7          	jalr	-1560(ra) # 80000cc4 <release>
          release(&p->lock);
    800022e4:	854a                	mv	a0,s2
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	9de080e7          	jalr	-1570(ra) # 80000cc4 <release>
          return pid;
    800022ee:	a8a9                	j	80002348 <wait+0xe0>
            release(&np->lock);
    800022f0:	8526                	mv	a0,s1
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	9d2080e7          	jalr	-1582(ra) # 80000cc4 <release>
            release(&p->lock);
    800022fa:	854a                	mv	a0,s2
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	9c8080e7          	jalr	-1592(ra) # 80000cc4 <release>
            return -1;
    80002304:	59fd                	li	s3,-1
    80002306:	a089                	j	80002348 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002308:	16848493          	addi	s1,s1,360
    8000230c:	03348463          	beq	s1,s3,80002334 <wait+0xcc>
      if(np->parent == p){
    80002310:	709c                	ld	a5,32(s1)
    80002312:	ff279be3          	bne	a5,s2,80002308 <wait+0xa0>
        acquire(&np->lock);
    80002316:	8526                	mv	a0,s1
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	8f8080e7          	jalr	-1800(ra) # 80000c10 <acquire>
        if(np->state == ZOMBIE){
    80002320:	4c9c                	lw	a5,24(s1)
    80002322:	f94787e3          	beq	a5,s4,800022b0 <wait+0x48>
        release(&np->lock);
    80002326:	8526                	mv	a0,s1
    80002328:	fffff097          	auipc	ra,0xfffff
    8000232c:	99c080e7          	jalr	-1636(ra) # 80000cc4 <release>
        havekids = 1;
    80002330:	8756                	mv	a4,s5
    80002332:	bfd9                	j	80002308 <wait+0xa0>
    if(!havekids || p->killed){
    80002334:	c701                	beqz	a4,8000233c <wait+0xd4>
    80002336:	03092783          	lw	a5,48(s2)
    8000233a:	c785                	beqz	a5,80002362 <wait+0xfa>
      release(&p->lock);
    8000233c:	854a                	mv	a0,s2
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	986080e7          	jalr	-1658(ra) # 80000cc4 <release>
      return -1;
    80002346:	59fd                	li	s3,-1
}
    80002348:	854e                	mv	a0,s3
    8000234a:	60a6                	ld	ra,72(sp)
    8000234c:	6406                	ld	s0,64(sp)
    8000234e:	74e2                	ld	s1,56(sp)
    80002350:	7942                	ld	s2,48(sp)
    80002352:	79a2                	ld	s3,40(sp)
    80002354:	7a02                	ld	s4,32(sp)
    80002356:	6ae2                	ld	s5,24(sp)
    80002358:	6b42                	ld	s6,16(sp)
    8000235a:	6ba2                	ld	s7,8(sp)
    8000235c:	6c02                	ld	s8,0(sp)
    8000235e:	6161                	addi	sp,sp,80
    80002360:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002362:	85e2                	mv	a1,s8
    80002364:	854a                	mv	a0,s2
    80002366:	00000097          	auipc	ra,0x0
    8000236a:	e84080e7          	jalr	-380(ra) # 800021ea <sleep>
    havekids = 0;
    8000236e:	bf1d                	j	800022a4 <wait+0x3c>

0000000080002370 <wakeup>:
{
    80002370:	7139                	addi	sp,sp,-64
    80002372:	fc06                	sd	ra,56(sp)
    80002374:	f822                	sd	s0,48(sp)
    80002376:	f426                	sd	s1,40(sp)
    80002378:	f04a                	sd	s2,32(sp)
    8000237a:	ec4e                	sd	s3,24(sp)
    8000237c:	e852                	sd	s4,16(sp)
    8000237e:	e456                	sd	s5,8(sp)
    80002380:	0080                	addi	s0,sp,64
    80002382:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002384:	00010497          	auipc	s1,0x10
    80002388:	9e448493          	addi	s1,s1,-1564 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    8000238c:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000238e:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002390:	00015917          	auipc	s2,0x15
    80002394:	3d890913          	addi	s2,s2,984 # 80017768 <tickslock>
    80002398:	a821                	j	800023b0 <wakeup+0x40>
      p->state = RUNNABLE;
    8000239a:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    8000239e:	8526                	mv	a0,s1
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	924080e7          	jalr	-1756(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023a8:	16848493          	addi	s1,s1,360
    800023ac:	01248e63          	beq	s1,s2,800023c8 <wakeup+0x58>
    acquire(&p->lock);
    800023b0:	8526                	mv	a0,s1
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	85e080e7          	jalr	-1954(ra) # 80000c10 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800023ba:	4c9c                	lw	a5,24(s1)
    800023bc:	ff3791e3          	bne	a5,s3,8000239e <wakeup+0x2e>
    800023c0:	749c                	ld	a5,40(s1)
    800023c2:	fd479ee3          	bne	a5,s4,8000239e <wakeup+0x2e>
    800023c6:	bfd1                	j	8000239a <wakeup+0x2a>
}
    800023c8:	70e2                	ld	ra,56(sp)
    800023ca:	7442                	ld	s0,48(sp)
    800023cc:	74a2                	ld	s1,40(sp)
    800023ce:	7902                	ld	s2,32(sp)
    800023d0:	69e2                	ld	s3,24(sp)
    800023d2:	6a42                	ld	s4,16(sp)
    800023d4:	6aa2                	ld	s5,8(sp)
    800023d6:	6121                	addi	sp,sp,64
    800023d8:	8082                	ret

00000000800023da <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023da:	7179                	addi	sp,sp,-48
    800023dc:	f406                	sd	ra,40(sp)
    800023de:	f022                	sd	s0,32(sp)
    800023e0:	ec26                	sd	s1,24(sp)
    800023e2:	e84a                	sd	s2,16(sp)
    800023e4:	e44e                	sd	s3,8(sp)
    800023e6:	1800                	addi	s0,sp,48
    800023e8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023ea:	00010497          	auipc	s1,0x10
    800023ee:	97e48493          	addi	s1,s1,-1666 # 80011d68 <proc>
    800023f2:	00015997          	auipc	s3,0x15
    800023f6:	37698993          	addi	s3,s3,886 # 80017768 <tickslock>
    acquire(&p->lock);
    800023fa:	8526                	mv	a0,s1
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	814080e7          	jalr	-2028(ra) # 80000c10 <acquire>
    if(p->pid == pid){
    80002404:	5c9c                	lw	a5,56(s1)
    80002406:	01278d63          	beq	a5,s2,80002420 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000240a:	8526                	mv	a0,s1
    8000240c:	fffff097          	auipc	ra,0xfffff
    80002410:	8b8080e7          	jalr	-1864(ra) # 80000cc4 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002414:	16848493          	addi	s1,s1,360
    80002418:	ff3491e3          	bne	s1,s3,800023fa <kill+0x20>
  }
  return -1;
    8000241c:	557d                	li	a0,-1
    8000241e:	a829                	j	80002438 <kill+0x5e>
      p->killed = 1;
    80002420:	4785                	li	a5,1
    80002422:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002424:	4c98                	lw	a4,24(s1)
    80002426:	4785                	li	a5,1
    80002428:	00f70f63          	beq	a4,a5,80002446 <kill+0x6c>
      release(&p->lock);
    8000242c:	8526                	mv	a0,s1
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	896080e7          	jalr	-1898(ra) # 80000cc4 <release>
      return 0;
    80002436:	4501                	li	a0,0
}
    80002438:	70a2                	ld	ra,40(sp)
    8000243a:	7402                	ld	s0,32(sp)
    8000243c:	64e2                	ld	s1,24(sp)
    8000243e:	6942                	ld	s2,16(sp)
    80002440:	69a2                	ld	s3,8(sp)
    80002442:	6145                	addi	sp,sp,48
    80002444:	8082                	ret
        p->state = RUNNABLE;
    80002446:	4789                	li	a5,2
    80002448:	cc9c                	sw	a5,24(s1)
    8000244a:	b7cd                	j	8000242c <kill+0x52>

000000008000244c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000244c:	7179                	addi	sp,sp,-48
    8000244e:	f406                	sd	ra,40(sp)
    80002450:	f022                	sd	s0,32(sp)
    80002452:	ec26                	sd	s1,24(sp)
    80002454:	e84a                	sd	s2,16(sp)
    80002456:	e44e                	sd	s3,8(sp)
    80002458:	e052                	sd	s4,0(sp)
    8000245a:	1800                	addi	s0,sp,48
    8000245c:	84aa                	mv	s1,a0
    8000245e:	892e                	mv	s2,a1
    80002460:	89b2                	mv	s3,a2
    80002462:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	57a080e7          	jalr	1402(ra) # 800019de <myproc>
  if(user_dst){
    8000246c:	c08d                	beqz	s1,8000248e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000246e:	86d2                	mv	a3,s4
    80002470:	864e                	mv	a2,s3
    80002472:	85ca                	mv	a1,s2
    80002474:	6928                	ld	a0,80(a0)
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	25c080e7          	jalr	604(ra) # 800016d2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000247e:	70a2                	ld	ra,40(sp)
    80002480:	7402                	ld	s0,32(sp)
    80002482:	64e2                	ld	s1,24(sp)
    80002484:	6942                	ld	s2,16(sp)
    80002486:	69a2                	ld	s3,8(sp)
    80002488:	6a02                	ld	s4,0(sp)
    8000248a:	6145                	addi	sp,sp,48
    8000248c:	8082                	ret
    memmove((char *)dst, src, len);
    8000248e:	000a061b          	sext.w	a2,s4
    80002492:	85ce                	mv	a1,s3
    80002494:	854a                	mv	a0,s2
    80002496:	fffff097          	auipc	ra,0xfffff
    8000249a:	8d6080e7          	jalr	-1834(ra) # 80000d6c <memmove>
    return 0;
    8000249e:	8526                	mv	a0,s1
    800024a0:	bff9                	j	8000247e <either_copyout+0x32>

00000000800024a2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024a2:	7179                	addi	sp,sp,-48
    800024a4:	f406                	sd	ra,40(sp)
    800024a6:	f022                	sd	s0,32(sp)
    800024a8:	ec26                	sd	s1,24(sp)
    800024aa:	e84a                	sd	s2,16(sp)
    800024ac:	e44e                	sd	s3,8(sp)
    800024ae:	e052                	sd	s4,0(sp)
    800024b0:	1800                	addi	s0,sp,48
    800024b2:	892a                	mv	s2,a0
    800024b4:	84ae                	mv	s1,a1
    800024b6:	89b2                	mv	s3,a2
    800024b8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	524080e7          	jalr	1316(ra) # 800019de <myproc>
  if(user_src){
    800024c2:	c08d                	beqz	s1,800024e4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024c4:	86d2                	mv	a3,s4
    800024c6:	864e                	mv	a2,s3
    800024c8:	85ca                	mv	a1,s2
    800024ca:	6928                	ld	a0,80(a0)
    800024cc:	fffff097          	auipc	ra,0xfffff
    800024d0:	292080e7          	jalr	658(ra) # 8000175e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024d4:	70a2                	ld	ra,40(sp)
    800024d6:	7402                	ld	s0,32(sp)
    800024d8:	64e2                	ld	s1,24(sp)
    800024da:	6942                	ld	s2,16(sp)
    800024dc:	69a2                	ld	s3,8(sp)
    800024de:	6a02                	ld	s4,0(sp)
    800024e0:	6145                	addi	sp,sp,48
    800024e2:	8082                	ret
    memmove(dst, (char*)src, len);
    800024e4:	000a061b          	sext.w	a2,s4
    800024e8:	85ce                	mv	a1,s3
    800024ea:	854a                	mv	a0,s2
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	880080e7          	jalr	-1920(ra) # 80000d6c <memmove>
    return 0;
    800024f4:	8526                	mv	a0,s1
    800024f6:	bff9                	j	800024d4 <either_copyin+0x32>

00000000800024f8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800024f8:	715d                	addi	sp,sp,-80
    800024fa:	e486                	sd	ra,72(sp)
    800024fc:	e0a2                	sd	s0,64(sp)
    800024fe:	fc26                	sd	s1,56(sp)
    80002500:	f84a                	sd	s2,48(sp)
    80002502:	f44e                	sd	s3,40(sp)
    80002504:	f052                	sd	s4,32(sp)
    80002506:	ec56                	sd	s5,24(sp)
    80002508:	e85a                	sd	s6,16(sp)
    8000250a:	e45e                	sd	s7,8(sp)
    8000250c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000250e:	00006517          	auipc	a0,0x6
    80002512:	bba50513          	addi	a0,a0,-1094 # 800080c8 <digits+0x88>
    80002516:	ffffe097          	auipc	ra,0xffffe
    8000251a:	07c080e7          	jalr	124(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000251e:	00010497          	auipc	s1,0x10
    80002522:	9a248493          	addi	s1,s1,-1630 # 80011ec0 <proc+0x158>
    80002526:	00015917          	auipc	s2,0x15
    8000252a:	39a90913          	addi	s2,s2,922 # 800178c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000252e:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002530:	00006997          	auipc	s3,0x6
    80002534:	d3898993          	addi	s3,s3,-712 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    80002538:	00006a97          	auipc	s5,0x6
    8000253c:	d38a8a93          	addi	s5,s5,-712 # 80008270 <digits+0x230>
    printf("\n");
    80002540:	00006a17          	auipc	s4,0x6
    80002544:	b88a0a13          	addi	s4,s4,-1144 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002548:	00006b97          	auipc	s7,0x6
    8000254c:	d60b8b93          	addi	s7,s7,-672 # 800082a8 <states.1702>
    80002550:	a00d                	j	80002572 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002552:	ee06a583          	lw	a1,-288(a3)
    80002556:	8556                	mv	a0,s5
    80002558:	ffffe097          	auipc	ra,0xffffe
    8000255c:	03a080e7          	jalr	58(ra) # 80000592 <printf>
    printf("\n");
    80002560:	8552                	mv	a0,s4
    80002562:	ffffe097          	auipc	ra,0xffffe
    80002566:	030080e7          	jalr	48(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000256a:	16848493          	addi	s1,s1,360
    8000256e:	03248163          	beq	s1,s2,80002590 <procdump+0x98>
    if(p->state == UNUSED)
    80002572:	86a6                	mv	a3,s1
    80002574:	ec04a783          	lw	a5,-320(s1)
    80002578:	dbed                	beqz	a5,8000256a <procdump+0x72>
      state = "???";
    8000257a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000257c:	fcfb6be3          	bltu	s6,a5,80002552 <procdump+0x5a>
    80002580:	1782                	slli	a5,a5,0x20
    80002582:	9381                	srli	a5,a5,0x20
    80002584:	078e                	slli	a5,a5,0x3
    80002586:	97de                	add	a5,a5,s7
    80002588:	6390                	ld	a2,0(a5)
    8000258a:	f661                	bnez	a2,80002552 <procdump+0x5a>
      state = "???";
    8000258c:	864e                	mv	a2,s3
    8000258e:	b7d1                	j	80002552 <procdump+0x5a>
  }
}
    80002590:	60a6                	ld	ra,72(sp)
    80002592:	6406                	ld	s0,64(sp)
    80002594:	74e2                	ld	s1,56(sp)
    80002596:	7942                	ld	s2,48(sp)
    80002598:	79a2                	ld	s3,40(sp)
    8000259a:	7a02                	ld	s4,32(sp)
    8000259c:	6ae2                	ld	s5,24(sp)
    8000259e:	6b42                	ld	s6,16(sp)
    800025a0:	6ba2                	ld	s7,8(sp)
    800025a2:	6161                	addi	sp,sp,80
    800025a4:	8082                	ret

00000000800025a6 <swtch>:
    800025a6:	00153023          	sd	ra,0(a0)
    800025aa:	00253423          	sd	sp,8(a0)
    800025ae:	e900                	sd	s0,16(a0)
    800025b0:	ed04                	sd	s1,24(a0)
    800025b2:	03253023          	sd	s2,32(a0)
    800025b6:	03353423          	sd	s3,40(a0)
    800025ba:	03453823          	sd	s4,48(a0)
    800025be:	03553c23          	sd	s5,56(a0)
    800025c2:	05653023          	sd	s6,64(a0)
    800025c6:	05753423          	sd	s7,72(a0)
    800025ca:	05853823          	sd	s8,80(a0)
    800025ce:	05953c23          	sd	s9,88(a0)
    800025d2:	07a53023          	sd	s10,96(a0)
    800025d6:	07b53423          	sd	s11,104(a0)
    800025da:	0005b083          	ld	ra,0(a1)
    800025de:	0085b103          	ld	sp,8(a1)
    800025e2:	6980                	ld	s0,16(a1)
    800025e4:	6d84                	ld	s1,24(a1)
    800025e6:	0205b903          	ld	s2,32(a1)
    800025ea:	0285b983          	ld	s3,40(a1)
    800025ee:	0305ba03          	ld	s4,48(a1)
    800025f2:	0385ba83          	ld	s5,56(a1)
    800025f6:	0405bb03          	ld	s6,64(a1)
    800025fa:	0485bb83          	ld	s7,72(a1)
    800025fe:	0505bc03          	ld	s8,80(a1)
    80002602:	0585bc83          	ld	s9,88(a1)
    80002606:	0605bd03          	ld	s10,96(a1)
    8000260a:	0685bd83          	ld	s11,104(a1)
    8000260e:	8082                	ret

0000000080002610 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002610:	1141                	addi	sp,sp,-16
    80002612:	e406                	sd	ra,8(sp)
    80002614:	e022                	sd	s0,0(sp)
    80002616:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002618:	00006597          	auipc	a1,0x6
    8000261c:	cb858593          	addi	a1,a1,-840 # 800082d0 <states.1702+0x28>
    80002620:	00015517          	auipc	a0,0x15
    80002624:	14850513          	addi	a0,a0,328 # 80017768 <tickslock>
    80002628:	ffffe097          	auipc	ra,0xffffe
    8000262c:	558080e7          	jalr	1368(ra) # 80000b80 <initlock>
}
    80002630:	60a2                	ld	ra,8(sp)
    80002632:	6402                	ld	s0,0(sp)
    80002634:	0141                	addi	sp,sp,16
    80002636:	8082                	ret

0000000080002638 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002638:	1141                	addi	sp,sp,-16
    8000263a:	e422                	sd	s0,8(sp)
    8000263c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000263e:	00003797          	auipc	a5,0x3
    80002642:	4c278793          	addi	a5,a5,1218 # 80005b00 <kernelvec>
    80002646:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000264a:	6422                	ld	s0,8(sp)
    8000264c:	0141                	addi	sp,sp,16
    8000264e:	8082                	ret

0000000080002650 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002650:	1141                	addi	sp,sp,-16
    80002652:	e406                	sd	ra,8(sp)
    80002654:	e022                	sd	s0,0(sp)
    80002656:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002658:	fffff097          	auipc	ra,0xfffff
    8000265c:	386080e7          	jalr	902(ra) # 800019de <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002660:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002664:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002666:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000266a:	00005617          	auipc	a2,0x5
    8000266e:	99660613          	addi	a2,a2,-1642 # 80007000 <_trampoline>
    80002672:	00005697          	auipc	a3,0x5
    80002676:	98e68693          	addi	a3,a3,-1650 # 80007000 <_trampoline>
    8000267a:	8e91                	sub	a3,a3,a2
    8000267c:	040007b7          	lui	a5,0x4000
    80002680:	17fd                	addi	a5,a5,-1
    80002682:	07b2                	slli	a5,a5,0xc
    80002684:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002686:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000268a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000268c:	180026f3          	csrr	a3,satp
    80002690:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002692:	6d38                	ld	a4,88(a0)
    80002694:	6134                	ld	a3,64(a0)
    80002696:	6585                	lui	a1,0x1
    80002698:	96ae                	add	a3,a3,a1
    8000269a:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000269c:	6d38                	ld	a4,88(a0)
    8000269e:	00000697          	auipc	a3,0x0
    800026a2:	13868693          	addi	a3,a3,312 # 800027d6 <usertrap>
    800026a6:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026a8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026aa:	8692                	mv	a3,tp
    800026ac:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ae:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026b2:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026b6:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026ba:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026be:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026c0:	6f18                	ld	a4,24(a4)
    800026c2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026c6:	692c                	ld	a1,80(a0)
    800026c8:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800026ca:	00005717          	auipc	a4,0x5
    800026ce:	9c670713          	addi	a4,a4,-1594 # 80007090 <userret>
    800026d2:	8f11                	sub	a4,a4,a2
    800026d4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800026d6:	577d                	li	a4,-1
    800026d8:	177e                	slli	a4,a4,0x3f
    800026da:	8dd9                	or	a1,a1,a4
    800026dc:	02000537          	lui	a0,0x2000
    800026e0:	157d                	addi	a0,a0,-1
    800026e2:	0536                	slli	a0,a0,0xd
    800026e4:	9782                	jalr	a5
}
    800026e6:	60a2                	ld	ra,8(sp)
    800026e8:	6402                	ld	s0,0(sp)
    800026ea:	0141                	addi	sp,sp,16
    800026ec:	8082                	ret

00000000800026ee <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026ee:	1101                	addi	sp,sp,-32
    800026f0:	ec06                	sd	ra,24(sp)
    800026f2:	e822                	sd	s0,16(sp)
    800026f4:	e426                	sd	s1,8(sp)
    800026f6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800026f8:	00015497          	auipc	s1,0x15
    800026fc:	07048493          	addi	s1,s1,112 # 80017768 <tickslock>
    80002700:	8526                	mv	a0,s1
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	50e080e7          	jalr	1294(ra) # 80000c10 <acquire>
  ticks++;
    8000270a:	00007517          	auipc	a0,0x7
    8000270e:	91650513          	addi	a0,a0,-1770 # 80009020 <ticks>
    80002712:	411c                	lw	a5,0(a0)
    80002714:	2785                	addiw	a5,a5,1
    80002716:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002718:	00000097          	auipc	ra,0x0
    8000271c:	c58080e7          	jalr	-936(ra) # 80002370 <wakeup>
  release(&tickslock);
    80002720:	8526                	mv	a0,s1
    80002722:	ffffe097          	auipc	ra,0xffffe
    80002726:	5a2080e7          	jalr	1442(ra) # 80000cc4 <release>
}
    8000272a:	60e2                	ld	ra,24(sp)
    8000272c:	6442                	ld	s0,16(sp)
    8000272e:	64a2                	ld	s1,8(sp)
    80002730:	6105                	addi	sp,sp,32
    80002732:	8082                	ret

0000000080002734 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002734:	1101                	addi	sp,sp,-32
    80002736:	ec06                	sd	ra,24(sp)
    80002738:	e822                	sd	s0,16(sp)
    8000273a:	e426                	sd	s1,8(sp)
    8000273c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000273e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002742:	00074d63          	bltz	a4,8000275c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002746:	57fd                	li	a5,-1
    80002748:	17fe                	slli	a5,a5,0x3f
    8000274a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000274c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000274e:	06f70363          	beq	a4,a5,800027b4 <devintr+0x80>
  }
}
    80002752:	60e2                	ld	ra,24(sp)
    80002754:	6442                	ld	s0,16(sp)
    80002756:	64a2                	ld	s1,8(sp)
    80002758:	6105                	addi	sp,sp,32
    8000275a:	8082                	ret
     (scause & 0xff) == 9){
    8000275c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002760:	46a5                	li	a3,9
    80002762:	fed792e3          	bne	a5,a3,80002746 <devintr+0x12>
    int irq = plic_claim();
    80002766:	00003097          	auipc	ra,0x3
    8000276a:	4a2080e7          	jalr	1186(ra) # 80005c08 <plic_claim>
    8000276e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002770:	47a9                	li	a5,10
    80002772:	02f50763          	beq	a0,a5,800027a0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002776:	4785                	li	a5,1
    80002778:	02f50963          	beq	a0,a5,800027aa <devintr+0x76>
    return 1;
    8000277c:	4505                	li	a0,1
    } else if(irq){
    8000277e:	d8f1                	beqz	s1,80002752 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002780:	85a6                	mv	a1,s1
    80002782:	00006517          	auipc	a0,0x6
    80002786:	b5650513          	addi	a0,a0,-1194 # 800082d8 <states.1702+0x30>
    8000278a:	ffffe097          	auipc	ra,0xffffe
    8000278e:	e08080e7          	jalr	-504(ra) # 80000592 <printf>
      plic_complete(irq);
    80002792:	8526                	mv	a0,s1
    80002794:	00003097          	auipc	ra,0x3
    80002798:	498080e7          	jalr	1176(ra) # 80005c2c <plic_complete>
    return 1;
    8000279c:	4505                	li	a0,1
    8000279e:	bf55                	j	80002752 <devintr+0x1e>
      uartintr();
    800027a0:	ffffe097          	auipc	ra,0xffffe
    800027a4:	234080e7          	jalr	564(ra) # 800009d4 <uartintr>
    800027a8:	b7ed                	j	80002792 <devintr+0x5e>
      virtio_disk_intr();
    800027aa:	00004097          	auipc	ra,0x4
    800027ae:	91c080e7          	jalr	-1764(ra) # 800060c6 <virtio_disk_intr>
    800027b2:	b7c5                	j	80002792 <devintr+0x5e>
    if(cpuid() == 0){
    800027b4:	fffff097          	auipc	ra,0xfffff
    800027b8:	1fe080e7          	jalr	510(ra) # 800019b2 <cpuid>
    800027bc:	c901                	beqz	a0,800027cc <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027be:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027c2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027c4:	14479073          	csrw	sip,a5
    return 2;
    800027c8:	4509                	li	a0,2
    800027ca:	b761                	j	80002752 <devintr+0x1e>
      clockintr();
    800027cc:	00000097          	auipc	ra,0x0
    800027d0:	f22080e7          	jalr	-222(ra) # 800026ee <clockintr>
    800027d4:	b7ed                	j	800027be <devintr+0x8a>

00000000800027d6 <usertrap>:
{
    800027d6:	1101                	addi	sp,sp,-32
    800027d8:	ec06                	sd	ra,24(sp)
    800027da:	e822                	sd	s0,16(sp)
    800027dc:	e426                	sd	s1,8(sp)
    800027de:	e04a                	sd	s2,0(sp)
    800027e0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027e2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027e6:	1007f793          	andi	a5,a5,256
    800027ea:	e3ad                	bnez	a5,8000284c <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027ec:	00003797          	auipc	a5,0x3
    800027f0:	31478793          	addi	a5,a5,788 # 80005b00 <kernelvec>
    800027f4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027f8:	fffff097          	auipc	ra,0xfffff
    800027fc:	1e6080e7          	jalr	486(ra) # 800019de <myproc>
    80002800:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002802:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002804:	14102773          	csrr	a4,sepc
    80002808:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000280a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000280e:	47a1                	li	a5,8
    80002810:	04f71c63          	bne	a4,a5,80002868 <usertrap+0x92>
    if(p->killed)
    80002814:	591c                	lw	a5,48(a0)
    80002816:	e3b9                	bnez	a5,8000285c <usertrap+0x86>
    p->trapframe->epc += 4;
    80002818:	6cb8                	ld	a4,88(s1)
    8000281a:	6f1c                	ld	a5,24(a4)
    8000281c:	0791                	addi	a5,a5,4
    8000281e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002820:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002824:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002828:	10079073          	csrw	sstatus,a5
    syscall();
    8000282c:	00000097          	auipc	ra,0x0
    80002830:	2e0080e7          	jalr	736(ra) # 80002b0c <syscall>
  if(p->killed)
    80002834:	589c                	lw	a5,48(s1)
    80002836:	ebc1                	bnez	a5,800028c6 <usertrap+0xf0>
  usertrapret();
    80002838:	00000097          	auipc	ra,0x0
    8000283c:	e18080e7          	jalr	-488(ra) # 80002650 <usertrapret>
}
    80002840:	60e2                	ld	ra,24(sp)
    80002842:	6442                	ld	s0,16(sp)
    80002844:	64a2                	ld	s1,8(sp)
    80002846:	6902                	ld	s2,0(sp)
    80002848:	6105                	addi	sp,sp,32
    8000284a:	8082                	ret
    panic("usertrap: not from user mode");
    8000284c:	00006517          	auipc	a0,0x6
    80002850:	aac50513          	addi	a0,a0,-1364 # 800082f8 <states.1702+0x50>
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	cf4080e7          	jalr	-780(ra) # 80000548 <panic>
      exit(-1);
    8000285c:	557d                	li	a0,-1
    8000285e:	00000097          	auipc	ra,0x0
    80002862:	846080e7          	jalr	-1978(ra) # 800020a4 <exit>
    80002866:	bf4d                	j	80002818 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002868:	00000097          	auipc	ra,0x0
    8000286c:	ecc080e7          	jalr	-308(ra) # 80002734 <devintr>
    80002870:	892a                	mv	s2,a0
    80002872:	c501                	beqz	a0,8000287a <usertrap+0xa4>
  if(p->killed)
    80002874:	589c                	lw	a5,48(s1)
    80002876:	c3a1                	beqz	a5,800028b6 <usertrap+0xe0>
    80002878:	a815                	j	800028ac <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000287a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000287e:	5c90                	lw	a2,56(s1)
    80002880:	00006517          	auipc	a0,0x6
    80002884:	a9850513          	addi	a0,a0,-1384 # 80008318 <states.1702+0x70>
    80002888:	ffffe097          	auipc	ra,0xffffe
    8000288c:	d0a080e7          	jalr	-758(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002890:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002894:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002898:	00006517          	auipc	a0,0x6
    8000289c:	ab050513          	addi	a0,a0,-1360 # 80008348 <states.1702+0xa0>
    800028a0:	ffffe097          	auipc	ra,0xffffe
    800028a4:	cf2080e7          	jalr	-782(ra) # 80000592 <printf>
    p->killed = 1;
    800028a8:	4785                	li	a5,1
    800028aa:	d89c                	sw	a5,48(s1)
    exit(-1);
    800028ac:	557d                	li	a0,-1
    800028ae:	fffff097          	auipc	ra,0xfffff
    800028b2:	7f6080e7          	jalr	2038(ra) # 800020a4 <exit>
  if(which_dev == 2)
    800028b6:	4789                	li	a5,2
    800028b8:	f8f910e3          	bne	s2,a5,80002838 <usertrap+0x62>
    yield();
    800028bc:	00000097          	auipc	ra,0x0
    800028c0:	8f2080e7          	jalr	-1806(ra) # 800021ae <yield>
    800028c4:	bf95                	j	80002838 <usertrap+0x62>
  int which_dev = 0;
    800028c6:	4901                	li	s2,0
    800028c8:	b7d5                	j	800028ac <usertrap+0xd6>

00000000800028ca <kerneltrap>:
{
    800028ca:	7179                	addi	sp,sp,-48
    800028cc:	f406                	sd	ra,40(sp)
    800028ce:	f022                	sd	s0,32(sp)
    800028d0:	ec26                	sd	s1,24(sp)
    800028d2:	e84a                	sd	s2,16(sp)
    800028d4:	e44e                	sd	s3,8(sp)
    800028d6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028d8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028dc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028e0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028e4:	1004f793          	andi	a5,s1,256
    800028e8:	cb85                	beqz	a5,80002918 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ea:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028ee:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028f0:	ef85                	bnez	a5,80002928 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800028f2:	00000097          	auipc	ra,0x0
    800028f6:	e42080e7          	jalr	-446(ra) # 80002734 <devintr>
    800028fa:	cd1d                	beqz	a0,80002938 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800028fc:	4789                	li	a5,2
    800028fe:	06f50a63          	beq	a0,a5,80002972 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002902:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002906:	10049073          	csrw	sstatus,s1
}
    8000290a:	70a2                	ld	ra,40(sp)
    8000290c:	7402                	ld	s0,32(sp)
    8000290e:	64e2                	ld	s1,24(sp)
    80002910:	6942                	ld	s2,16(sp)
    80002912:	69a2                	ld	s3,8(sp)
    80002914:	6145                	addi	sp,sp,48
    80002916:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002918:	00006517          	auipc	a0,0x6
    8000291c:	a5050513          	addi	a0,a0,-1456 # 80008368 <states.1702+0xc0>
    80002920:	ffffe097          	auipc	ra,0xffffe
    80002924:	c28080e7          	jalr	-984(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002928:	00006517          	auipc	a0,0x6
    8000292c:	a6850513          	addi	a0,a0,-1432 # 80008390 <states.1702+0xe8>
    80002930:	ffffe097          	auipc	ra,0xffffe
    80002934:	c18080e7          	jalr	-1000(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002938:	85ce                	mv	a1,s3
    8000293a:	00006517          	auipc	a0,0x6
    8000293e:	a7650513          	addi	a0,a0,-1418 # 800083b0 <states.1702+0x108>
    80002942:	ffffe097          	auipc	ra,0xffffe
    80002946:	c50080e7          	jalr	-944(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000294a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000294e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002952:	00006517          	auipc	a0,0x6
    80002956:	a6e50513          	addi	a0,a0,-1426 # 800083c0 <states.1702+0x118>
    8000295a:	ffffe097          	auipc	ra,0xffffe
    8000295e:	c38080e7          	jalr	-968(ra) # 80000592 <printf>
    panic("kerneltrap");
    80002962:	00006517          	auipc	a0,0x6
    80002966:	a7650513          	addi	a0,a0,-1418 # 800083d8 <states.1702+0x130>
    8000296a:	ffffe097          	auipc	ra,0xffffe
    8000296e:	bde080e7          	jalr	-1058(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002972:	fffff097          	auipc	ra,0xfffff
    80002976:	06c080e7          	jalr	108(ra) # 800019de <myproc>
    8000297a:	d541                	beqz	a0,80002902 <kerneltrap+0x38>
    8000297c:	fffff097          	auipc	ra,0xfffff
    80002980:	062080e7          	jalr	98(ra) # 800019de <myproc>
    80002984:	4d18                	lw	a4,24(a0)
    80002986:	478d                	li	a5,3
    80002988:	f6f71de3          	bne	a4,a5,80002902 <kerneltrap+0x38>
    yield();
    8000298c:	00000097          	auipc	ra,0x0
    80002990:	822080e7          	jalr	-2014(ra) # 800021ae <yield>
    80002994:	b7bd                	j	80002902 <kerneltrap+0x38>

0000000080002996 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002996:	1101                	addi	sp,sp,-32
    80002998:	ec06                	sd	ra,24(sp)
    8000299a:	e822                	sd	s0,16(sp)
    8000299c:	e426                	sd	s1,8(sp)
    8000299e:	1000                	addi	s0,sp,32
    800029a0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029a2:	fffff097          	auipc	ra,0xfffff
    800029a6:	03c080e7          	jalr	60(ra) # 800019de <myproc>
  switch (n) {
    800029aa:	4795                	li	a5,5
    800029ac:	0497e163          	bltu	a5,s1,800029ee <argraw+0x58>
    800029b0:	048a                	slli	s1,s1,0x2
    800029b2:	00006717          	auipc	a4,0x6
    800029b6:	a5e70713          	addi	a4,a4,-1442 # 80008410 <states.1702+0x168>
    800029ba:	94ba                	add	s1,s1,a4
    800029bc:	409c                	lw	a5,0(s1)
    800029be:	97ba                	add	a5,a5,a4
    800029c0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029c2:	6d3c                	ld	a5,88(a0)
    800029c4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029c6:	60e2                	ld	ra,24(sp)
    800029c8:	6442                	ld	s0,16(sp)
    800029ca:	64a2                	ld	s1,8(sp)
    800029cc:	6105                	addi	sp,sp,32
    800029ce:	8082                	ret
    return p->trapframe->a1;
    800029d0:	6d3c                	ld	a5,88(a0)
    800029d2:	7fa8                	ld	a0,120(a5)
    800029d4:	bfcd                	j	800029c6 <argraw+0x30>
    return p->trapframe->a2;
    800029d6:	6d3c                	ld	a5,88(a0)
    800029d8:	63c8                	ld	a0,128(a5)
    800029da:	b7f5                	j	800029c6 <argraw+0x30>
    return p->trapframe->a3;
    800029dc:	6d3c                	ld	a5,88(a0)
    800029de:	67c8                	ld	a0,136(a5)
    800029e0:	b7dd                	j	800029c6 <argraw+0x30>
    return p->trapframe->a4;
    800029e2:	6d3c                	ld	a5,88(a0)
    800029e4:	6bc8                	ld	a0,144(a5)
    800029e6:	b7c5                	j	800029c6 <argraw+0x30>
    return p->trapframe->a5;
    800029e8:	6d3c                	ld	a5,88(a0)
    800029ea:	6fc8                	ld	a0,152(a5)
    800029ec:	bfe9                	j	800029c6 <argraw+0x30>
  panic("argraw");
    800029ee:	00006517          	auipc	a0,0x6
    800029f2:	9fa50513          	addi	a0,a0,-1542 # 800083e8 <states.1702+0x140>
    800029f6:	ffffe097          	auipc	ra,0xffffe
    800029fa:	b52080e7          	jalr	-1198(ra) # 80000548 <panic>

00000000800029fe <fetchaddr>:
{
    800029fe:	1101                	addi	sp,sp,-32
    80002a00:	ec06                	sd	ra,24(sp)
    80002a02:	e822                	sd	s0,16(sp)
    80002a04:	e426                	sd	s1,8(sp)
    80002a06:	e04a                	sd	s2,0(sp)
    80002a08:	1000                	addi	s0,sp,32
    80002a0a:	84aa                	mv	s1,a0
    80002a0c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a0e:	fffff097          	auipc	ra,0xfffff
    80002a12:	fd0080e7          	jalr	-48(ra) # 800019de <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a16:	653c                	ld	a5,72(a0)
    80002a18:	02f4f863          	bgeu	s1,a5,80002a48 <fetchaddr+0x4a>
    80002a1c:	00848713          	addi	a4,s1,8
    80002a20:	02e7e663          	bltu	a5,a4,80002a4c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a24:	46a1                	li	a3,8
    80002a26:	8626                	mv	a2,s1
    80002a28:	85ca                	mv	a1,s2
    80002a2a:	6928                	ld	a0,80(a0)
    80002a2c:	fffff097          	auipc	ra,0xfffff
    80002a30:	d32080e7          	jalr	-718(ra) # 8000175e <copyin>
    80002a34:	00a03533          	snez	a0,a0
    80002a38:	40a00533          	neg	a0,a0
}
    80002a3c:	60e2                	ld	ra,24(sp)
    80002a3e:	6442                	ld	s0,16(sp)
    80002a40:	64a2                	ld	s1,8(sp)
    80002a42:	6902                	ld	s2,0(sp)
    80002a44:	6105                	addi	sp,sp,32
    80002a46:	8082                	ret
    return -1;
    80002a48:	557d                	li	a0,-1
    80002a4a:	bfcd                	j	80002a3c <fetchaddr+0x3e>
    80002a4c:	557d                	li	a0,-1
    80002a4e:	b7fd                	j	80002a3c <fetchaddr+0x3e>

0000000080002a50 <fetchstr>:
{
    80002a50:	7179                	addi	sp,sp,-48
    80002a52:	f406                	sd	ra,40(sp)
    80002a54:	f022                	sd	s0,32(sp)
    80002a56:	ec26                	sd	s1,24(sp)
    80002a58:	e84a                	sd	s2,16(sp)
    80002a5a:	e44e                	sd	s3,8(sp)
    80002a5c:	1800                	addi	s0,sp,48
    80002a5e:	892a                	mv	s2,a0
    80002a60:	84ae                	mv	s1,a1
    80002a62:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a64:	fffff097          	auipc	ra,0xfffff
    80002a68:	f7a080e7          	jalr	-134(ra) # 800019de <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002a6c:	86ce                	mv	a3,s3
    80002a6e:	864a                	mv	a2,s2
    80002a70:	85a6                	mv	a1,s1
    80002a72:	6928                	ld	a0,80(a0)
    80002a74:	fffff097          	auipc	ra,0xfffff
    80002a78:	d76080e7          	jalr	-650(ra) # 800017ea <copyinstr>
  if(err < 0)
    80002a7c:	00054763          	bltz	a0,80002a8a <fetchstr+0x3a>
  return strlen(buf);
    80002a80:	8526                	mv	a0,s1
    80002a82:	ffffe097          	auipc	ra,0xffffe
    80002a86:	412080e7          	jalr	1042(ra) # 80000e94 <strlen>
}
    80002a8a:	70a2                	ld	ra,40(sp)
    80002a8c:	7402                	ld	s0,32(sp)
    80002a8e:	64e2                	ld	s1,24(sp)
    80002a90:	6942                	ld	s2,16(sp)
    80002a92:	69a2                	ld	s3,8(sp)
    80002a94:	6145                	addi	sp,sp,48
    80002a96:	8082                	ret

0000000080002a98 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002a98:	1101                	addi	sp,sp,-32
    80002a9a:	ec06                	sd	ra,24(sp)
    80002a9c:	e822                	sd	s0,16(sp)
    80002a9e:	e426                	sd	s1,8(sp)
    80002aa0:	1000                	addi	s0,sp,32
    80002aa2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002aa4:	00000097          	auipc	ra,0x0
    80002aa8:	ef2080e7          	jalr	-270(ra) # 80002996 <argraw>
    80002aac:	c088                	sw	a0,0(s1)
  return 0;
}
    80002aae:	4501                	li	a0,0
    80002ab0:	60e2                	ld	ra,24(sp)
    80002ab2:	6442                	ld	s0,16(sp)
    80002ab4:	64a2                	ld	s1,8(sp)
    80002ab6:	6105                	addi	sp,sp,32
    80002ab8:	8082                	ret

0000000080002aba <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002aba:	1101                	addi	sp,sp,-32
    80002abc:	ec06                	sd	ra,24(sp)
    80002abe:	e822                	sd	s0,16(sp)
    80002ac0:	e426                	sd	s1,8(sp)
    80002ac2:	1000                	addi	s0,sp,32
    80002ac4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ac6:	00000097          	auipc	ra,0x0
    80002aca:	ed0080e7          	jalr	-304(ra) # 80002996 <argraw>
    80002ace:	e088                	sd	a0,0(s1)
  return 0;
}
    80002ad0:	4501                	li	a0,0
    80002ad2:	60e2                	ld	ra,24(sp)
    80002ad4:	6442                	ld	s0,16(sp)
    80002ad6:	64a2                	ld	s1,8(sp)
    80002ad8:	6105                	addi	sp,sp,32
    80002ada:	8082                	ret

0000000080002adc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002adc:	1101                	addi	sp,sp,-32
    80002ade:	ec06                	sd	ra,24(sp)
    80002ae0:	e822                	sd	s0,16(sp)
    80002ae2:	e426                	sd	s1,8(sp)
    80002ae4:	e04a                	sd	s2,0(sp)
    80002ae6:	1000                	addi	s0,sp,32
    80002ae8:	84ae                	mv	s1,a1
    80002aea:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002aec:	00000097          	auipc	ra,0x0
    80002af0:	eaa080e7          	jalr	-342(ra) # 80002996 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002af4:	864a                	mv	a2,s2
    80002af6:	85a6                	mv	a1,s1
    80002af8:	00000097          	auipc	ra,0x0
    80002afc:	f58080e7          	jalr	-168(ra) # 80002a50 <fetchstr>
}
    80002b00:	60e2                	ld	ra,24(sp)
    80002b02:	6442                	ld	s0,16(sp)
    80002b04:	64a2                	ld	s1,8(sp)
    80002b06:	6902                	ld	s2,0(sp)
    80002b08:	6105                	addi	sp,sp,32
    80002b0a:	8082                	ret

0000000080002b0c <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002b0c:	1101                	addi	sp,sp,-32
    80002b0e:	ec06                	sd	ra,24(sp)
    80002b10:	e822                	sd	s0,16(sp)
    80002b12:	e426                	sd	s1,8(sp)
    80002b14:	e04a                	sd	s2,0(sp)
    80002b16:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b18:	fffff097          	auipc	ra,0xfffff
    80002b1c:	ec6080e7          	jalr	-314(ra) # 800019de <myproc>
    80002b20:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b22:	05853903          	ld	s2,88(a0)
    80002b26:	0a893783          	ld	a5,168(s2)
    80002b2a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b2e:	37fd                	addiw	a5,a5,-1
    80002b30:	4751                	li	a4,20
    80002b32:	00f76f63          	bltu	a4,a5,80002b50 <syscall+0x44>
    80002b36:	00369713          	slli	a4,a3,0x3
    80002b3a:	00006797          	auipc	a5,0x6
    80002b3e:	8ee78793          	addi	a5,a5,-1810 # 80008428 <syscalls>
    80002b42:	97ba                	add	a5,a5,a4
    80002b44:	639c                	ld	a5,0(a5)
    80002b46:	c789                	beqz	a5,80002b50 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002b48:	9782                	jalr	a5
    80002b4a:	06a93823          	sd	a0,112(s2)
    80002b4e:	a839                	j	80002b6c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b50:	15848613          	addi	a2,s1,344
    80002b54:	5c8c                	lw	a1,56(s1)
    80002b56:	00006517          	auipc	a0,0x6
    80002b5a:	89a50513          	addi	a0,a0,-1894 # 800083f0 <states.1702+0x148>
    80002b5e:	ffffe097          	auipc	ra,0xffffe
    80002b62:	a34080e7          	jalr	-1484(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b66:	6cbc                	ld	a5,88(s1)
    80002b68:	577d                	li	a4,-1
    80002b6a:	fbb8                	sd	a4,112(a5)
  }
}
    80002b6c:	60e2                	ld	ra,24(sp)
    80002b6e:	6442                	ld	s0,16(sp)
    80002b70:	64a2                	ld	s1,8(sp)
    80002b72:	6902                	ld	s2,0(sp)
    80002b74:	6105                	addi	sp,sp,32
    80002b76:	8082                	ret

0000000080002b78 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002b78:	1101                	addi	sp,sp,-32
    80002b7a:	ec06                	sd	ra,24(sp)
    80002b7c:	e822                	sd	s0,16(sp)
    80002b7e:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002b80:	fec40593          	addi	a1,s0,-20
    80002b84:	4501                	li	a0,0
    80002b86:	00000097          	auipc	ra,0x0
    80002b8a:	f12080e7          	jalr	-238(ra) # 80002a98 <argint>
    return -1;
    80002b8e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002b90:	00054963          	bltz	a0,80002ba2 <sys_exit+0x2a>
  exit(n);
    80002b94:	fec42503          	lw	a0,-20(s0)
    80002b98:	fffff097          	auipc	ra,0xfffff
    80002b9c:	50c080e7          	jalr	1292(ra) # 800020a4 <exit>
  return 0;  // not reached
    80002ba0:	4781                	li	a5,0
}
    80002ba2:	853e                	mv	a0,a5
    80002ba4:	60e2                	ld	ra,24(sp)
    80002ba6:	6442                	ld	s0,16(sp)
    80002ba8:	6105                	addi	sp,sp,32
    80002baa:	8082                	ret

0000000080002bac <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bac:	1141                	addi	sp,sp,-16
    80002bae:	e406                	sd	ra,8(sp)
    80002bb0:	e022                	sd	s0,0(sp)
    80002bb2:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002bb4:	fffff097          	auipc	ra,0xfffff
    80002bb8:	e2a080e7          	jalr	-470(ra) # 800019de <myproc>
}
    80002bbc:	5d08                	lw	a0,56(a0)
    80002bbe:	60a2                	ld	ra,8(sp)
    80002bc0:	6402                	ld	s0,0(sp)
    80002bc2:	0141                	addi	sp,sp,16
    80002bc4:	8082                	ret

0000000080002bc6 <sys_fork>:

uint64
sys_fork(void)
{
    80002bc6:	1141                	addi	sp,sp,-16
    80002bc8:	e406                	sd	ra,8(sp)
    80002bca:	e022                	sd	s0,0(sp)
    80002bcc:	0800                	addi	s0,sp,16
  return fork();
    80002bce:	fffff097          	auipc	ra,0xfffff
    80002bd2:	1d0080e7          	jalr	464(ra) # 80001d9e <fork>
}
    80002bd6:	60a2                	ld	ra,8(sp)
    80002bd8:	6402                	ld	s0,0(sp)
    80002bda:	0141                	addi	sp,sp,16
    80002bdc:	8082                	ret

0000000080002bde <sys_wait>:

uint64
sys_wait(void)
{
    80002bde:	1101                	addi	sp,sp,-32
    80002be0:	ec06                	sd	ra,24(sp)
    80002be2:	e822                	sd	s0,16(sp)
    80002be4:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002be6:	fe840593          	addi	a1,s0,-24
    80002bea:	4501                	li	a0,0
    80002bec:	00000097          	auipc	ra,0x0
    80002bf0:	ece080e7          	jalr	-306(ra) # 80002aba <argaddr>
    80002bf4:	87aa                	mv	a5,a0
    return -1;
    80002bf6:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002bf8:	0007c863          	bltz	a5,80002c08 <sys_wait+0x2a>
  return wait(p);
    80002bfc:	fe843503          	ld	a0,-24(s0)
    80002c00:	fffff097          	auipc	ra,0xfffff
    80002c04:	668080e7          	jalr	1640(ra) # 80002268 <wait>
}
    80002c08:	60e2                	ld	ra,24(sp)
    80002c0a:	6442                	ld	s0,16(sp)
    80002c0c:	6105                	addi	sp,sp,32
    80002c0e:	8082                	ret

0000000080002c10 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c10:	7179                	addi	sp,sp,-48
    80002c12:	f406                	sd	ra,40(sp)
    80002c14:	f022                	sd	s0,32(sp)
    80002c16:	ec26                	sd	s1,24(sp)
    80002c18:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c1a:	fdc40593          	addi	a1,s0,-36
    80002c1e:	4501                	li	a0,0
    80002c20:	00000097          	auipc	ra,0x0
    80002c24:	e78080e7          	jalr	-392(ra) # 80002a98 <argint>
    80002c28:	87aa                	mv	a5,a0
    return -1;
    80002c2a:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002c2c:	0207c063          	bltz	a5,80002c4c <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002c30:	fffff097          	auipc	ra,0xfffff
    80002c34:	dae080e7          	jalr	-594(ra) # 800019de <myproc>
    80002c38:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002c3a:	fdc42503          	lw	a0,-36(s0)
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	0ec080e7          	jalr	236(ra) # 80001d2a <growproc>
    80002c46:	00054863          	bltz	a0,80002c56 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002c4a:	8526                	mv	a0,s1
}
    80002c4c:	70a2                	ld	ra,40(sp)
    80002c4e:	7402                	ld	s0,32(sp)
    80002c50:	64e2                	ld	s1,24(sp)
    80002c52:	6145                	addi	sp,sp,48
    80002c54:	8082                	ret
    return -1;
    80002c56:	557d                	li	a0,-1
    80002c58:	bfd5                	j	80002c4c <sys_sbrk+0x3c>

0000000080002c5a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c5a:	7139                	addi	sp,sp,-64
    80002c5c:	fc06                	sd	ra,56(sp)
    80002c5e:	f822                	sd	s0,48(sp)
    80002c60:	f426                	sd	s1,40(sp)
    80002c62:	f04a                	sd	s2,32(sp)
    80002c64:	ec4e                	sd	s3,24(sp)
    80002c66:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002c68:	fcc40593          	addi	a1,s0,-52
    80002c6c:	4501                	li	a0,0
    80002c6e:	00000097          	auipc	ra,0x0
    80002c72:	e2a080e7          	jalr	-470(ra) # 80002a98 <argint>
    return -1;
    80002c76:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c78:	06054563          	bltz	a0,80002ce2 <sys_sleep+0x88>
  acquire(&tickslock);
    80002c7c:	00015517          	auipc	a0,0x15
    80002c80:	aec50513          	addi	a0,a0,-1300 # 80017768 <tickslock>
    80002c84:	ffffe097          	auipc	ra,0xffffe
    80002c88:	f8c080e7          	jalr	-116(ra) # 80000c10 <acquire>
  ticks0 = ticks;
    80002c8c:	00006917          	auipc	s2,0x6
    80002c90:	39492903          	lw	s2,916(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002c94:	fcc42783          	lw	a5,-52(s0)
    80002c98:	cf85                	beqz	a5,80002cd0 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c9a:	00015997          	auipc	s3,0x15
    80002c9e:	ace98993          	addi	s3,s3,-1330 # 80017768 <tickslock>
    80002ca2:	00006497          	auipc	s1,0x6
    80002ca6:	37e48493          	addi	s1,s1,894 # 80009020 <ticks>
    if(myproc()->killed){
    80002caa:	fffff097          	auipc	ra,0xfffff
    80002cae:	d34080e7          	jalr	-716(ra) # 800019de <myproc>
    80002cb2:	591c                	lw	a5,48(a0)
    80002cb4:	ef9d                	bnez	a5,80002cf2 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002cb6:	85ce                	mv	a1,s3
    80002cb8:	8526                	mv	a0,s1
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	530080e7          	jalr	1328(ra) # 800021ea <sleep>
  while(ticks - ticks0 < n){
    80002cc2:	409c                	lw	a5,0(s1)
    80002cc4:	412787bb          	subw	a5,a5,s2
    80002cc8:	fcc42703          	lw	a4,-52(s0)
    80002ccc:	fce7efe3          	bltu	a5,a4,80002caa <sys_sleep+0x50>
  }
  release(&tickslock);
    80002cd0:	00015517          	auipc	a0,0x15
    80002cd4:	a9850513          	addi	a0,a0,-1384 # 80017768 <tickslock>
    80002cd8:	ffffe097          	auipc	ra,0xffffe
    80002cdc:	fec080e7          	jalr	-20(ra) # 80000cc4 <release>
  return 0;
    80002ce0:	4781                	li	a5,0
}
    80002ce2:	853e                	mv	a0,a5
    80002ce4:	70e2                	ld	ra,56(sp)
    80002ce6:	7442                	ld	s0,48(sp)
    80002ce8:	74a2                	ld	s1,40(sp)
    80002cea:	7902                	ld	s2,32(sp)
    80002cec:	69e2                	ld	s3,24(sp)
    80002cee:	6121                	addi	sp,sp,64
    80002cf0:	8082                	ret
      release(&tickslock);
    80002cf2:	00015517          	auipc	a0,0x15
    80002cf6:	a7650513          	addi	a0,a0,-1418 # 80017768 <tickslock>
    80002cfa:	ffffe097          	auipc	ra,0xffffe
    80002cfe:	fca080e7          	jalr	-54(ra) # 80000cc4 <release>
      return -1;
    80002d02:	57fd                	li	a5,-1
    80002d04:	bff9                	j	80002ce2 <sys_sleep+0x88>

0000000080002d06 <sys_kill>:

uint64
sys_kill(void)
{
    80002d06:	1101                	addi	sp,sp,-32
    80002d08:	ec06                	sd	ra,24(sp)
    80002d0a:	e822                	sd	s0,16(sp)
    80002d0c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d0e:	fec40593          	addi	a1,s0,-20
    80002d12:	4501                	li	a0,0
    80002d14:	00000097          	auipc	ra,0x0
    80002d18:	d84080e7          	jalr	-636(ra) # 80002a98 <argint>
    80002d1c:	87aa                	mv	a5,a0
    return -1;
    80002d1e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002d20:	0007c863          	bltz	a5,80002d30 <sys_kill+0x2a>
  return kill(pid);
    80002d24:	fec42503          	lw	a0,-20(s0)
    80002d28:	fffff097          	auipc	ra,0xfffff
    80002d2c:	6b2080e7          	jalr	1714(ra) # 800023da <kill>
}
    80002d30:	60e2                	ld	ra,24(sp)
    80002d32:	6442                	ld	s0,16(sp)
    80002d34:	6105                	addi	sp,sp,32
    80002d36:	8082                	ret

0000000080002d38 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d38:	1101                	addi	sp,sp,-32
    80002d3a:	ec06                	sd	ra,24(sp)
    80002d3c:	e822                	sd	s0,16(sp)
    80002d3e:	e426                	sd	s1,8(sp)
    80002d40:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d42:	00015517          	auipc	a0,0x15
    80002d46:	a2650513          	addi	a0,a0,-1498 # 80017768 <tickslock>
    80002d4a:	ffffe097          	auipc	ra,0xffffe
    80002d4e:	ec6080e7          	jalr	-314(ra) # 80000c10 <acquire>
  xticks = ticks;
    80002d52:	00006497          	auipc	s1,0x6
    80002d56:	2ce4a483          	lw	s1,718(s1) # 80009020 <ticks>
  release(&tickslock);
    80002d5a:	00015517          	auipc	a0,0x15
    80002d5e:	a0e50513          	addi	a0,a0,-1522 # 80017768 <tickslock>
    80002d62:	ffffe097          	auipc	ra,0xffffe
    80002d66:	f62080e7          	jalr	-158(ra) # 80000cc4 <release>
  return xticks;
}
    80002d6a:	02049513          	slli	a0,s1,0x20
    80002d6e:	9101                	srli	a0,a0,0x20
    80002d70:	60e2                	ld	ra,24(sp)
    80002d72:	6442                	ld	s0,16(sp)
    80002d74:	64a2                	ld	s1,8(sp)
    80002d76:	6105                	addi	sp,sp,32
    80002d78:	8082                	ret

0000000080002d7a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d7a:	7179                	addi	sp,sp,-48
    80002d7c:	f406                	sd	ra,40(sp)
    80002d7e:	f022                	sd	s0,32(sp)
    80002d80:	ec26                	sd	s1,24(sp)
    80002d82:	e84a                	sd	s2,16(sp)
    80002d84:	e44e                	sd	s3,8(sp)
    80002d86:	e052                	sd	s4,0(sp)
    80002d88:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d8a:	00005597          	auipc	a1,0x5
    80002d8e:	74e58593          	addi	a1,a1,1870 # 800084d8 <syscalls+0xb0>
    80002d92:	00015517          	auipc	a0,0x15
    80002d96:	9ee50513          	addi	a0,a0,-1554 # 80017780 <bcache>
    80002d9a:	ffffe097          	auipc	ra,0xffffe
    80002d9e:	de6080e7          	jalr	-538(ra) # 80000b80 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002da2:	0001d797          	auipc	a5,0x1d
    80002da6:	9de78793          	addi	a5,a5,-1570 # 8001f780 <bcache+0x8000>
    80002daa:	0001d717          	auipc	a4,0x1d
    80002dae:	c3e70713          	addi	a4,a4,-962 # 8001f9e8 <bcache+0x8268>
    80002db2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002db6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dba:	00015497          	auipc	s1,0x15
    80002dbe:	9de48493          	addi	s1,s1,-1570 # 80017798 <bcache+0x18>
    b->next = bcache.head.next;
    80002dc2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002dc4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002dc6:	00005a17          	auipc	s4,0x5
    80002dca:	71aa0a13          	addi	s4,s4,1818 # 800084e0 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002dce:	2b893783          	ld	a5,696(s2)
    80002dd2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002dd4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002dd8:	85d2                	mv	a1,s4
    80002dda:	01048513          	addi	a0,s1,16
    80002dde:	00001097          	auipc	ra,0x1
    80002de2:	4ac080e7          	jalr	1196(ra) # 8000428a <initsleeplock>
    bcache.head.next->prev = b;
    80002de6:	2b893783          	ld	a5,696(s2)
    80002dea:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002dec:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002df0:	45848493          	addi	s1,s1,1112
    80002df4:	fd349de3          	bne	s1,s3,80002dce <binit+0x54>
  }
}
    80002df8:	70a2                	ld	ra,40(sp)
    80002dfa:	7402                	ld	s0,32(sp)
    80002dfc:	64e2                	ld	s1,24(sp)
    80002dfe:	6942                	ld	s2,16(sp)
    80002e00:	69a2                	ld	s3,8(sp)
    80002e02:	6a02                	ld	s4,0(sp)
    80002e04:	6145                	addi	sp,sp,48
    80002e06:	8082                	ret

0000000080002e08 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e08:	7179                	addi	sp,sp,-48
    80002e0a:	f406                	sd	ra,40(sp)
    80002e0c:	f022                	sd	s0,32(sp)
    80002e0e:	ec26                	sd	s1,24(sp)
    80002e10:	e84a                	sd	s2,16(sp)
    80002e12:	e44e                	sd	s3,8(sp)
    80002e14:	1800                	addi	s0,sp,48
    80002e16:	89aa                	mv	s3,a0
    80002e18:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002e1a:	00015517          	auipc	a0,0x15
    80002e1e:	96650513          	addi	a0,a0,-1690 # 80017780 <bcache>
    80002e22:	ffffe097          	auipc	ra,0xffffe
    80002e26:	dee080e7          	jalr	-530(ra) # 80000c10 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e2a:	0001d497          	auipc	s1,0x1d
    80002e2e:	c0e4b483          	ld	s1,-1010(s1) # 8001fa38 <bcache+0x82b8>
    80002e32:	0001d797          	auipc	a5,0x1d
    80002e36:	bb678793          	addi	a5,a5,-1098 # 8001f9e8 <bcache+0x8268>
    80002e3a:	02f48f63          	beq	s1,a5,80002e78 <bread+0x70>
    80002e3e:	873e                	mv	a4,a5
    80002e40:	a021                	j	80002e48 <bread+0x40>
    80002e42:	68a4                	ld	s1,80(s1)
    80002e44:	02e48a63          	beq	s1,a4,80002e78 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002e48:	449c                	lw	a5,8(s1)
    80002e4a:	ff379ce3          	bne	a5,s3,80002e42 <bread+0x3a>
    80002e4e:	44dc                	lw	a5,12(s1)
    80002e50:	ff2799e3          	bne	a5,s2,80002e42 <bread+0x3a>
      b->refcnt++;
    80002e54:	40bc                	lw	a5,64(s1)
    80002e56:	2785                	addiw	a5,a5,1
    80002e58:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e5a:	00015517          	auipc	a0,0x15
    80002e5e:	92650513          	addi	a0,a0,-1754 # 80017780 <bcache>
    80002e62:	ffffe097          	auipc	ra,0xffffe
    80002e66:	e62080e7          	jalr	-414(ra) # 80000cc4 <release>
      acquiresleep(&b->lock);
    80002e6a:	01048513          	addi	a0,s1,16
    80002e6e:	00001097          	auipc	ra,0x1
    80002e72:	456080e7          	jalr	1110(ra) # 800042c4 <acquiresleep>
      return b;
    80002e76:	a8b9                	j	80002ed4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e78:	0001d497          	auipc	s1,0x1d
    80002e7c:	bb84b483          	ld	s1,-1096(s1) # 8001fa30 <bcache+0x82b0>
    80002e80:	0001d797          	auipc	a5,0x1d
    80002e84:	b6878793          	addi	a5,a5,-1176 # 8001f9e8 <bcache+0x8268>
    80002e88:	00f48863          	beq	s1,a5,80002e98 <bread+0x90>
    80002e8c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e8e:	40bc                	lw	a5,64(s1)
    80002e90:	cf81                	beqz	a5,80002ea8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e92:	64a4                	ld	s1,72(s1)
    80002e94:	fee49de3          	bne	s1,a4,80002e8e <bread+0x86>
  panic("bget: no buffers");
    80002e98:	00005517          	auipc	a0,0x5
    80002e9c:	65050513          	addi	a0,a0,1616 # 800084e8 <syscalls+0xc0>
    80002ea0:	ffffd097          	auipc	ra,0xffffd
    80002ea4:	6a8080e7          	jalr	1704(ra) # 80000548 <panic>
      b->dev = dev;
    80002ea8:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002eac:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002eb0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002eb4:	4785                	li	a5,1
    80002eb6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002eb8:	00015517          	auipc	a0,0x15
    80002ebc:	8c850513          	addi	a0,a0,-1848 # 80017780 <bcache>
    80002ec0:	ffffe097          	auipc	ra,0xffffe
    80002ec4:	e04080e7          	jalr	-508(ra) # 80000cc4 <release>
      acquiresleep(&b->lock);
    80002ec8:	01048513          	addi	a0,s1,16
    80002ecc:	00001097          	auipc	ra,0x1
    80002ed0:	3f8080e7          	jalr	1016(ra) # 800042c4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ed4:	409c                	lw	a5,0(s1)
    80002ed6:	cb89                	beqz	a5,80002ee8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ed8:	8526                	mv	a0,s1
    80002eda:	70a2                	ld	ra,40(sp)
    80002edc:	7402                	ld	s0,32(sp)
    80002ede:	64e2                	ld	s1,24(sp)
    80002ee0:	6942                	ld	s2,16(sp)
    80002ee2:	69a2                	ld	s3,8(sp)
    80002ee4:	6145                	addi	sp,sp,48
    80002ee6:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ee8:	4581                	li	a1,0
    80002eea:	8526                	mv	a0,s1
    80002eec:	00003097          	auipc	ra,0x3
    80002ef0:	f30080e7          	jalr	-208(ra) # 80005e1c <virtio_disk_rw>
    b->valid = 1;
    80002ef4:	4785                	li	a5,1
    80002ef6:	c09c                	sw	a5,0(s1)
  return b;
    80002ef8:	b7c5                	j	80002ed8 <bread+0xd0>

0000000080002efa <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002efa:	1101                	addi	sp,sp,-32
    80002efc:	ec06                	sd	ra,24(sp)
    80002efe:	e822                	sd	s0,16(sp)
    80002f00:	e426                	sd	s1,8(sp)
    80002f02:	1000                	addi	s0,sp,32
    80002f04:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f06:	0541                	addi	a0,a0,16
    80002f08:	00001097          	auipc	ra,0x1
    80002f0c:	456080e7          	jalr	1110(ra) # 8000435e <holdingsleep>
    80002f10:	cd01                	beqz	a0,80002f28 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f12:	4585                	li	a1,1
    80002f14:	8526                	mv	a0,s1
    80002f16:	00003097          	auipc	ra,0x3
    80002f1a:	f06080e7          	jalr	-250(ra) # 80005e1c <virtio_disk_rw>
}
    80002f1e:	60e2                	ld	ra,24(sp)
    80002f20:	6442                	ld	s0,16(sp)
    80002f22:	64a2                	ld	s1,8(sp)
    80002f24:	6105                	addi	sp,sp,32
    80002f26:	8082                	ret
    panic("bwrite");
    80002f28:	00005517          	auipc	a0,0x5
    80002f2c:	5d850513          	addi	a0,a0,1496 # 80008500 <syscalls+0xd8>
    80002f30:	ffffd097          	auipc	ra,0xffffd
    80002f34:	618080e7          	jalr	1560(ra) # 80000548 <panic>

0000000080002f38 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f38:	1101                	addi	sp,sp,-32
    80002f3a:	ec06                	sd	ra,24(sp)
    80002f3c:	e822                	sd	s0,16(sp)
    80002f3e:	e426                	sd	s1,8(sp)
    80002f40:	e04a                	sd	s2,0(sp)
    80002f42:	1000                	addi	s0,sp,32
    80002f44:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f46:	01050913          	addi	s2,a0,16
    80002f4a:	854a                	mv	a0,s2
    80002f4c:	00001097          	auipc	ra,0x1
    80002f50:	412080e7          	jalr	1042(ra) # 8000435e <holdingsleep>
    80002f54:	c92d                	beqz	a0,80002fc6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002f56:	854a                	mv	a0,s2
    80002f58:	00001097          	auipc	ra,0x1
    80002f5c:	3c2080e7          	jalr	962(ra) # 8000431a <releasesleep>

  acquire(&bcache.lock);
    80002f60:	00015517          	auipc	a0,0x15
    80002f64:	82050513          	addi	a0,a0,-2016 # 80017780 <bcache>
    80002f68:	ffffe097          	auipc	ra,0xffffe
    80002f6c:	ca8080e7          	jalr	-856(ra) # 80000c10 <acquire>
  b->refcnt--;
    80002f70:	40bc                	lw	a5,64(s1)
    80002f72:	37fd                	addiw	a5,a5,-1
    80002f74:	0007871b          	sext.w	a4,a5
    80002f78:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f7a:	eb05                	bnez	a4,80002faa <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f7c:	68bc                	ld	a5,80(s1)
    80002f7e:	64b8                	ld	a4,72(s1)
    80002f80:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002f82:	64bc                	ld	a5,72(s1)
    80002f84:	68b8                	ld	a4,80(s1)
    80002f86:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f88:	0001c797          	auipc	a5,0x1c
    80002f8c:	7f878793          	addi	a5,a5,2040 # 8001f780 <bcache+0x8000>
    80002f90:	2b87b703          	ld	a4,696(a5)
    80002f94:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f96:	0001d717          	auipc	a4,0x1d
    80002f9a:	a5270713          	addi	a4,a4,-1454 # 8001f9e8 <bcache+0x8268>
    80002f9e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002fa0:	2b87b703          	ld	a4,696(a5)
    80002fa4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002fa6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002faa:	00014517          	auipc	a0,0x14
    80002fae:	7d650513          	addi	a0,a0,2006 # 80017780 <bcache>
    80002fb2:	ffffe097          	auipc	ra,0xffffe
    80002fb6:	d12080e7          	jalr	-750(ra) # 80000cc4 <release>
}
    80002fba:	60e2                	ld	ra,24(sp)
    80002fbc:	6442                	ld	s0,16(sp)
    80002fbe:	64a2                	ld	s1,8(sp)
    80002fc0:	6902                	ld	s2,0(sp)
    80002fc2:	6105                	addi	sp,sp,32
    80002fc4:	8082                	ret
    panic("brelse");
    80002fc6:	00005517          	auipc	a0,0x5
    80002fca:	54250513          	addi	a0,a0,1346 # 80008508 <syscalls+0xe0>
    80002fce:	ffffd097          	auipc	ra,0xffffd
    80002fd2:	57a080e7          	jalr	1402(ra) # 80000548 <panic>

0000000080002fd6 <bpin>:

void
bpin(struct buf *b) {
    80002fd6:	1101                	addi	sp,sp,-32
    80002fd8:	ec06                	sd	ra,24(sp)
    80002fda:	e822                	sd	s0,16(sp)
    80002fdc:	e426                	sd	s1,8(sp)
    80002fde:	1000                	addi	s0,sp,32
    80002fe0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fe2:	00014517          	auipc	a0,0x14
    80002fe6:	79e50513          	addi	a0,a0,1950 # 80017780 <bcache>
    80002fea:	ffffe097          	auipc	ra,0xffffe
    80002fee:	c26080e7          	jalr	-986(ra) # 80000c10 <acquire>
  b->refcnt++;
    80002ff2:	40bc                	lw	a5,64(s1)
    80002ff4:	2785                	addiw	a5,a5,1
    80002ff6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ff8:	00014517          	auipc	a0,0x14
    80002ffc:	78850513          	addi	a0,a0,1928 # 80017780 <bcache>
    80003000:	ffffe097          	auipc	ra,0xffffe
    80003004:	cc4080e7          	jalr	-828(ra) # 80000cc4 <release>
}
    80003008:	60e2                	ld	ra,24(sp)
    8000300a:	6442                	ld	s0,16(sp)
    8000300c:	64a2                	ld	s1,8(sp)
    8000300e:	6105                	addi	sp,sp,32
    80003010:	8082                	ret

0000000080003012 <bunpin>:

void
bunpin(struct buf *b) {
    80003012:	1101                	addi	sp,sp,-32
    80003014:	ec06                	sd	ra,24(sp)
    80003016:	e822                	sd	s0,16(sp)
    80003018:	e426                	sd	s1,8(sp)
    8000301a:	1000                	addi	s0,sp,32
    8000301c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000301e:	00014517          	auipc	a0,0x14
    80003022:	76250513          	addi	a0,a0,1890 # 80017780 <bcache>
    80003026:	ffffe097          	auipc	ra,0xffffe
    8000302a:	bea080e7          	jalr	-1046(ra) # 80000c10 <acquire>
  b->refcnt--;
    8000302e:	40bc                	lw	a5,64(s1)
    80003030:	37fd                	addiw	a5,a5,-1
    80003032:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003034:	00014517          	auipc	a0,0x14
    80003038:	74c50513          	addi	a0,a0,1868 # 80017780 <bcache>
    8000303c:	ffffe097          	auipc	ra,0xffffe
    80003040:	c88080e7          	jalr	-888(ra) # 80000cc4 <release>
}
    80003044:	60e2                	ld	ra,24(sp)
    80003046:	6442                	ld	s0,16(sp)
    80003048:	64a2                	ld	s1,8(sp)
    8000304a:	6105                	addi	sp,sp,32
    8000304c:	8082                	ret

000000008000304e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000304e:	1101                	addi	sp,sp,-32
    80003050:	ec06                	sd	ra,24(sp)
    80003052:	e822                	sd	s0,16(sp)
    80003054:	e426                	sd	s1,8(sp)
    80003056:	e04a                	sd	s2,0(sp)
    80003058:	1000                	addi	s0,sp,32
    8000305a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000305c:	00d5d59b          	srliw	a1,a1,0xd
    80003060:	0001d797          	auipc	a5,0x1d
    80003064:	dfc7a783          	lw	a5,-516(a5) # 8001fe5c <sb+0x1c>
    80003068:	9dbd                	addw	a1,a1,a5
    8000306a:	00000097          	auipc	ra,0x0
    8000306e:	d9e080e7          	jalr	-610(ra) # 80002e08 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003072:	0074f713          	andi	a4,s1,7
    80003076:	4785                	li	a5,1
    80003078:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000307c:	14ce                	slli	s1,s1,0x33
    8000307e:	90d9                	srli	s1,s1,0x36
    80003080:	00950733          	add	a4,a0,s1
    80003084:	05874703          	lbu	a4,88(a4)
    80003088:	00e7f6b3          	and	a3,a5,a4
    8000308c:	c69d                	beqz	a3,800030ba <bfree+0x6c>
    8000308e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003090:	94aa                	add	s1,s1,a0
    80003092:	fff7c793          	not	a5,a5
    80003096:	8ff9                	and	a5,a5,a4
    80003098:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000309c:	00001097          	auipc	ra,0x1
    800030a0:	100080e7          	jalr	256(ra) # 8000419c <log_write>
  brelse(bp);
    800030a4:	854a                	mv	a0,s2
    800030a6:	00000097          	auipc	ra,0x0
    800030aa:	e92080e7          	jalr	-366(ra) # 80002f38 <brelse>
}
    800030ae:	60e2                	ld	ra,24(sp)
    800030b0:	6442                	ld	s0,16(sp)
    800030b2:	64a2                	ld	s1,8(sp)
    800030b4:	6902                	ld	s2,0(sp)
    800030b6:	6105                	addi	sp,sp,32
    800030b8:	8082                	ret
    panic("freeing free block");
    800030ba:	00005517          	auipc	a0,0x5
    800030be:	45650513          	addi	a0,a0,1110 # 80008510 <syscalls+0xe8>
    800030c2:	ffffd097          	auipc	ra,0xffffd
    800030c6:	486080e7          	jalr	1158(ra) # 80000548 <panic>

00000000800030ca <balloc>:
{
    800030ca:	711d                	addi	sp,sp,-96
    800030cc:	ec86                	sd	ra,88(sp)
    800030ce:	e8a2                	sd	s0,80(sp)
    800030d0:	e4a6                	sd	s1,72(sp)
    800030d2:	e0ca                	sd	s2,64(sp)
    800030d4:	fc4e                	sd	s3,56(sp)
    800030d6:	f852                	sd	s4,48(sp)
    800030d8:	f456                	sd	s5,40(sp)
    800030da:	f05a                	sd	s6,32(sp)
    800030dc:	ec5e                	sd	s7,24(sp)
    800030de:	e862                	sd	s8,16(sp)
    800030e0:	e466                	sd	s9,8(sp)
    800030e2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800030e4:	0001d797          	auipc	a5,0x1d
    800030e8:	d607a783          	lw	a5,-672(a5) # 8001fe44 <sb+0x4>
    800030ec:	cbd1                	beqz	a5,80003180 <balloc+0xb6>
    800030ee:	8baa                	mv	s7,a0
    800030f0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800030f2:	0001db17          	auipc	s6,0x1d
    800030f6:	d4eb0b13          	addi	s6,s6,-690 # 8001fe40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030fa:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800030fc:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030fe:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003100:	6c89                	lui	s9,0x2
    80003102:	a831                	j	8000311e <balloc+0x54>
    brelse(bp);
    80003104:	854a                	mv	a0,s2
    80003106:	00000097          	auipc	ra,0x0
    8000310a:	e32080e7          	jalr	-462(ra) # 80002f38 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000310e:	015c87bb          	addw	a5,s9,s5
    80003112:	00078a9b          	sext.w	s5,a5
    80003116:	004b2703          	lw	a4,4(s6)
    8000311a:	06eaf363          	bgeu	s5,a4,80003180 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000311e:	41fad79b          	sraiw	a5,s5,0x1f
    80003122:	0137d79b          	srliw	a5,a5,0x13
    80003126:	015787bb          	addw	a5,a5,s5
    8000312a:	40d7d79b          	sraiw	a5,a5,0xd
    8000312e:	01cb2583          	lw	a1,28(s6)
    80003132:	9dbd                	addw	a1,a1,a5
    80003134:	855e                	mv	a0,s7
    80003136:	00000097          	auipc	ra,0x0
    8000313a:	cd2080e7          	jalr	-814(ra) # 80002e08 <bread>
    8000313e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003140:	004b2503          	lw	a0,4(s6)
    80003144:	000a849b          	sext.w	s1,s5
    80003148:	8662                	mv	a2,s8
    8000314a:	faa4fde3          	bgeu	s1,a0,80003104 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000314e:	41f6579b          	sraiw	a5,a2,0x1f
    80003152:	01d7d69b          	srliw	a3,a5,0x1d
    80003156:	00c6873b          	addw	a4,a3,a2
    8000315a:	00777793          	andi	a5,a4,7
    8000315e:	9f95                	subw	a5,a5,a3
    80003160:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003164:	4037571b          	sraiw	a4,a4,0x3
    80003168:	00e906b3          	add	a3,s2,a4
    8000316c:	0586c683          	lbu	a3,88(a3)
    80003170:	00d7f5b3          	and	a1,a5,a3
    80003174:	cd91                	beqz	a1,80003190 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003176:	2605                	addiw	a2,a2,1
    80003178:	2485                	addiw	s1,s1,1
    8000317a:	fd4618e3          	bne	a2,s4,8000314a <balloc+0x80>
    8000317e:	b759                	j	80003104 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003180:	00005517          	auipc	a0,0x5
    80003184:	3a850513          	addi	a0,a0,936 # 80008528 <syscalls+0x100>
    80003188:	ffffd097          	auipc	ra,0xffffd
    8000318c:	3c0080e7          	jalr	960(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003190:	974a                	add	a4,a4,s2
    80003192:	8fd5                	or	a5,a5,a3
    80003194:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003198:	854a                	mv	a0,s2
    8000319a:	00001097          	auipc	ra,0x1
    8000319e:	002080e7          	jalr	2(ra) # 8000419c <log_write>
        brelse(bp);
    800031a2:	854a                	mv	a0,s2
    800031a4:	00000097          	auipc	ra,0x0
    800031a8:	d94080e7          	jalr	-620(ra) # 80002f38 <brelse>
  bp = bread(dev, bno);
    800031ac:	85a6                	mv	a1,s1
    800031ae:	855e                	mv	a0,s7
    800031b0:	00000097          	auipc	ra,0x0
    800031b4:	c58080e7          	jalr	-936(ra) # 80002e08 <bread>
    800031b8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031ba:	40000613          	li	a2,1024
    800031be:	4581                	li	a1,0
    800031c0:	05850513          	addi	a0,a0,88
    800031c4:	ffffe097          	auipc	ra,0xffffe
    800031c8:	b48080e7          	jalr	-1208(ra) # 80000d0c <memset>
  log_write(bp);
    800031cc:	854a                	mv	a0,s2
    800031ce:	00001097          	auipc	ra,0x1
    800031d2:	fce080e7          	jalr	-50(ra) # 8000419c <log_write>
  brelse(bp);
    800031d6:	854a                	mv	a0,s2
    800031d8:	00000097          	auipc	ra,0x0
    800031dc:	d60080e7          	jalr	-672(ra) # 80002f38 <brelse>
}
    800031e0:	8526                	mv	a0,s1
    800031e2:	60e6                	ld	ra,88(sp)
    800031e4:	6446                	ld	s0,80(sp)
    800031e6:	64a6                	ld	s1,72(sp)
    800031e8:	6906                	ld	s2,64(sp)
    800031ea:	79e2                	ld	s3,56(sp)
    800031ec:	7a42                	ld	s4,48(sp)
    800031ee:	7aa2                	ld	s5,40(sp)
    800031f0:	7b02                	ld	s6,32(sp)
    800031f2:	6be2                	ld	s7,24(sp)
    800031f4:	6c42                	ld	s8,16(sp)
    800031f6:	6ca2                	ld	s9,8(sp)
    800031f8:	6125                	addi	sp,sp,96
    800031fa:	8082                	ret

00000000800031fc <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800031fc:	7179                	addi	sp,sp,-48
    800031fe:	f406                	sd	ra,40(sp)
    80003200:	f022                	sd	s0,32(sp)
    80003202:	ec26                	sd	s1,24(sp)
    80003204:	e84a                	sd	s2,16(sp)
    80003206:	e44e                	sd	s3,8(sp)
    80003208:	e052                	sd	s4,0(sp)
    8000320a:	1800                	addi	s0,sp,48
    8000320c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000320e:	47ad                	li	a5,11
    80003210:	04b7fe63          	bgeu	a5,a1,8000326c <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003214:	ff45849b          	addiw	s1,a1,-12
    80003218:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000321c:	0ff00793          	li	a5,255
    80003220:	0ae7e363          	bltu	a5,a4,800032c6 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003224:	08052583          	lw	a1,128(a0)
    80003228:	c5ad                	beqz	a1,80003292 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000322a:	00092503          	lw	a0,0(s2)
    8000322e:	00000097          	auipc	ra,0x0
    80003232:	bda080e7          	jalr	-1062(ra) # 80002e08 <bread>
    80003236:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003238:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000323c:	02049593          	slli	a1,s1,0x20
    80003240:	9181                	srli	a1,a1,0x20
    80003242:	058a                	slli	a1,a1,0x2
    80003244:	00b784b3          	add	s1,a5,a1
    80003248:	0004a983          	lw	s3,0(s1)
    8000324c:	04098d63          	beqz	s3,800032a6 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003250:	8552                	mv	a0,s4
    80003252:	00000097          	auipc	ra,0x0
    80003256:	ce6080e7          	jalr	-794(ra) # 80002f38 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000325a:	854e                	mv	a0,s3
    8000325c:	70a2                	ld	ra,40(sp)
    8000325e:	7402                	ld	s0,32(sp)
    80003260:	64e2                	ld	s1,24(sp)
    80003262:	6942                	ld	s2,16(sp)
    80003264:	69a2                	ld	s3,8(sp)
    80003266:	6a02                	ld	s4,0(sp)
    80003268:	6145                	addi	sp,sp,48
    8000326a:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000326c:	02059493          	slli	s1,a1,0x20
    80003270:	9081                	srli	s1,s1,0x20
    80003272:	048a                	slli	s1,s1,0x2
    80003274:	94aa                	add	s1,s1,a0
    80003276:	0504a983          	lw	s3,80(s1)
    8000327a:	fe0990e3          	bnez	s3,8000325a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000327e:	4108                	lw	a0,0(a0)
    80003280:	00000097          	auipc	ra,0x0
    80003284:	e4a080e7          	jalr	-438(ra) # 800030ca <balloc>
    80003288:	0005099b          	sext.w	s3,a0
    8000328c:	0534a823          	sw	s3,80(s1)
    80003290:	b7e9                	j	8000325a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003292:	4108                	lw	a0,0(a0)
    80003294:	00000097          	auipc	ra,0x0
    80003298:	e36080e7          	jalr	-458(ra) # 800030ca <balloc>
    8000329c:	0005059b          	sext.w	a1,a0
    800032a0:	08b92023          	sw	a1,128(s2)
    800032a4:	b759                	j	8000322a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800032a6:	00092503          	lw	a0,0(s2)
    800032aa:	00000097          	auipc	ra,0x0
    800032ae:	e20080e7          	jalr	-480(ra) # 800030ca <balloc>
    800032b2:	0005099b          	sext.w	s3,a0
    800032b6:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800032ba:	8552                	mv	a0,s4
    800032bc:	00001097          	auipc	ra,0x1
    800032c0:	ee0080e7          	jalr	-288(ra) # 8000419c <log_write>
    800032c4:	b771                	j	80003250 <bmap+0x54>
  panic("bmap: out of range");
    800032c6:	00005517          	auipc	a0,0x5
    800032ca:	27a50513          	addi	a0,a0,634 # 80008540 <syscalls+0x118>
    800032ce:	ffffd097          	auipc	ra,0xffffd
    800032d2:	27a080e7          	jalr	634(ra) # 80000548 <panic>

00000000800032d6 <iget>:
{
    800032d6:	7179                	addi	sp,sp,-48
    800032d8:	f406                	sd	ra,40(sp)
    800032da:	f022                	sd	s0,32(sp)
    800032dc:	ec26                	sd	s1,24(sp)
    800032de:	e84a                	sd	s2,16(sp)
    800032e0:	e44e                	sd	s3,8(sp)
    800032e2:	e052                	sd	s4,0(sp)
    800032e4:	1800                	addi	s0,sp,48
    800032e6:	89aa                	mv	s3,a0
    800032e8:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800032ea:	0001d517          	auipc	a0,0x1d
    800032ee:	b7650513          	addi	a0,a0,-1162 # 8001fe60 <icache>
    800032f2:	ffffe097          	auipc	ra,0xffffe
    800032f6:	91e080e7          	jalr	-1762(ra) # 80000c10 <acquire>
  empty = 0;
    800032fa:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800032fc:	0001d497          	auipc	s1,0x1d
    80003300:	b7c48493          	addi	s1,s1,-1156 # 8001fe78 <icache+0x18>
    80003304:	0001e697          	auipc	a3,0x1e
    80003308:	60468693          	addi	a3,a3,1540 # 80021908 <log>
    8000330c:	a039                	j	8000331a <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000330e:	02090b63          	beqz	s2,80003344 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003312:	08848493          	addi	s1,s1,136
    80003316:	02d48a63          	beq	s1,a3,8000334a <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000331a:	449c                	lw	a5,8(s1)
    8000331c:	fef059e3          	blez	a5,8000330e <iget+0x38>
    80003320:	4098                	lw	a4,0(s1)
    80003322:	ff3716e3          	bne	a4,s3,8000330e <iget+0x38>
    80003326:	40d8                	lw	a4,4(s1)
    80003328:	ff4713e3          	bne	a4,s4,8000330e <iget+0x38>
      ip->ref++;
    8000332c:	2785                	addiw	a5,a5,1
    8000332e:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003330:	0001d517          	auipc	a0,0x1d
    80003334:	b3050513          	addi	a0,a0,-1232 # 8001fe60 <icache>
    80003338:	ffffe097          	auipc	ra,0xffffe
    8000333c:	98c080e7          	jalr	-1652(ra) # 80000cc4 <release>
      return ip;
    80003340:	8926                	mv	s2,s1
    80003342:	a03d                	j	80003370 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003344:	f7f9                	bnez	a5,80003312 <iget+0x3c>
    80003346:	8926                	mv	s2,s1
    80003348:	b7e9                	j	80003312 <iget+0x3c>
  if(empty == 0)
    8000334a:	02090c63          	beqz	s2,80003382 <iget+0xac>
  ip->dev = dev;
    8000334e:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003352:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003356:	4785                	li	a5,1
    80003358:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000335c:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003360:	0001d517          	auipc	a0,0x1d
    80003364:	b0050513          	addi	a0,a0,-1280 # 8001fe60 <icache>
    80003368:	ffffe097          	auipc	ra,0xffffe
    8000336c:	95c080e7          	jalr	-1700(ra) # 80000cc4 <release>
}
    80003370:	854a                	mv	a0,s2
    80003372:	70a2                	ld	ra,40(sp)
    80003374:	7402                	ld	s0,32(sp)
    80003376:	64e2                	ld	s1,24(sp)
    80003378:	6942                	ld	s2,16(sp)
    8000337a:	69a2                	ld	s3,8(sp)
    8000337c:	6a02                	ld	s4,0(sp)
    8000337e:	6145                	addi	sp,sp,48
    80003380:	8082                	ret
    panic("iget: no inodes");
    80003382:	00005517          	auipc	a0,0x5
    80003386:	1d650513          	addi	a0,a0,470 # 80008558 <syscalls+0x130>
    8000338a:	ffffd097          	auipc	ra,0xffffd
    8000338e:	1be080e7          	jalr	446(ra) # 80000548 <panic>

0000000080003392 <fsinit>:
fsinit(int dev) {
    80003392:	7179                	addi	sp,sp,-48
    80003394:	f406                	sd	ra,40(sp)
    80003396:	f022                	sd	s0,32(sp)
    80003398:	ec26                	sd	s1,24(sp)
    8000339a:	e84a                	sd	s2,16(sp)
    8000339c:	e44e                	sd	s3,8(sp)
    8000339e:	1800                	addi	s0,sp,48
    800033a0:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800033a2:	4585                	li	a1,1
    800033a4:	00000097          	auipc	ra,0x0
    800033a8:	a64080e7          	jalr	-1436(ra) # 80002e08 <bread>
    800033ac:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800033ae:	0001d997          	auipc	s3,0x1d
    800033b2:	a9298993          	addi	s3,s3,-1390 # 8001fe40 <sb>
    800033b6:	02000613          	li	a2,32
    800033ba:	05850593          	addi	a1,a0,88
    800033be:	854e                	mv	a0,s3
    800033c0:	ffffe097          	auipc	ra,0xffffe
    800033c4:	9ac080e7          	jalr	-1620(ra) # 80000d6c <memmove>
  brelse(bp);
    800033c8:	8526                	mv	a0,s1
    800033ca:	00000097          	auipc	ra,0x0
    800033ce:	b6e080e7          	jalr	-1170(ra) # 80002f38 <brelse>
  if(sb.magic != FSMAGIC)
    800033d2:	0009a703          	lw	a4,0(s3)
    800033d6:	102037b7          	lui	a5,0x10203
    800033da:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800033de:	02f71263          	bne	a4,a5,80003402 <fsinit+0x70>
  initlog(dev, &sb);
    800033e2:	0001d597          	auipc	a1,0x1d
    800033e6:	a5e58593          	addi	a1,a1,-1442 # 8001fe40 <sb>
    800033ea:	854a                	mv	a0,s2
    800033ec:	00001097          	auipc	ra,0x1
    800033f0:	b38080e7          	jalr	-1224(ra) # 80003f24 <initlog>
}
    800033f4:	70a2                	ld	ra,40(sp)
    800033f6:	7402                	ld	s0,32(sp)
    800033f8:	64e2                	ld	s1,24(sp)
    800033fa:	6942                	ld	s2,16(sp)
    800033fc:	69a2                	ld	s3,8(sp)
    800033fe:	6145                	addi	sp,sp,48
    80003400:	8082                	ret
    panic("invalid file system");
    80003402:	00005517          	auipc	a0,0x5
    80003406:	16650513          	addi	a0,a0,358 # 80008568 <syscalls+0x140>
    8000340a:	ffffd097          	auipc	ra,0xffffd
    8000340e:	13e080e7          	jalr	318(ra) # 80000548 <panic>

0000000080003412 <iinit>:
{
    80003412:	7179                	addi	sp,sp,-48
    80003414:	f406                	sd	ra,40(sp)
    80003416:	f022                	sd	s0,32(sp)
    80003418:	ec26                	sd	s1,24(sp)
    8000341a:	e84a                	sd	s2,16(sp)
    8000341c:	e44e                	sd	s3,8(sp)
    8000341e:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003420:	00005597          	auipc	a1,0x5
    80003424:	16058593          	addi	a1,a1,352 # 80008580 <syscalls+0x158>
    80003428:	0001d517          	auipc	a0,0x1d
    8000342c:	a3850513          	addi	a0,a0,-1480 # 8001fe60 <icache>
    80003430:	ffffd097          	auipc	ra,0xffffd
    80003434:	750080e7          	jalr	1872(ra) # 80000b80 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003438:	0001d497          	auipc	s1,0x1d
    8000343c:	a5048493          	addi	s1,s1,-1456 # 8001fe88 <icache+0x28>
    80003440:	0001e997          	auipc	s3,0x1e
    80003444:	4d898993          	addi	s3,s3,1240 # 80021918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003448:	00005917          	auipc	s2,0x5
    8000344c:	14090913          	addi	s2,s2,320 # 80008588 <syscalls+0x160>
    80003450:	85ca                	mv	a1,s2
    80003452:	8526                	mv	a0,s1
    80003454:	00001097          	auipc	ra,0x1
    80003458:	e36080e7          	jalr	-458(ra) # 8000428a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000345c:	08848493          	addi	s1,s1,136
    80003460:	ff3498e3          	bne	s1,s3,80003450 <iinit+0x3e>
}
    80003464:	70a2                	ld	ra,40(sp)
    80003466:	7402                	ld	s0,32(sp)
    80003468:	64e2                	ld	s1,24(sp)
    8000346a:	6942                	ld	s2,16(sp)
    8000346c:	69a2                	ld	s3,8(sp)
    8000346e:	6145                	addi	sp,sp,48
    80003470:	8082                	ret

0000000080003472 <ialloc>:
{
    80003472:	715d                	addi	sp,sp,-80
    80003474:	e486                	sd	ra,72(sp)
    80003476:	e0a2                	sd	s0,64(sp)
    80003478:	fc26                	sd	s1,56(sp)
    8000347a:	f84a                	sd	s2,48(sp)
    8000347c:	f44e                	sd	s3,40(sp)
    8000347e:	f052                	sd	s4,32(sp)
    80003480:	ec56                	sd	s5,24(sp)
    80003482:	e85a                	sd	s6,16(sp)
    80003484:	e45e                	sd	s7,8(sp)
    80003486:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003488:	0001d717          	auipc	a4,0x1d
    8000348c:	9c472703          	lw	a4,-1596(a4) # 8001fe4c <sb+0xc>
    80003490:	4785                	li	a5,1
    80003492:	04e7fa63          	bgeu	a5,a4,800034e6 <ialloc+0x74>
    80003496:	8aaa                	mv	s5,a0
    80003498:	8bae                	mv	s7,a1
    8000349a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000349c:	0001da17          	auipc	s4,0x1d
    800034a0:	9a4a0a13          	addi	s4,s4,-1628 # 8001fe40 <sb>
    800034a4:	00048b1b          	sext.w	s6,s1
    800034a8:	0044d593          	srli	a1,s1,0x4
    800034ac:	018a2783          	lw	a5,24(s4)
    800034b0:	9dbd                	addw	a1,a1,a5
    800034b2:	8556                	mv	a0,s5
    800034b4:	00000097          	auipc	ra,0x0
    800034b8:	954080e7          	jalr	-1708(ra) # 80002e08 <bread>
    800034bc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800034be:	05850993          	addi	s3,a0,88
    800034c2:	00f4f793          	andi	a5,s1,15
    800034c6:	079a                	slli	a5,a5,0x6
    800034c8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800034ca:	00099783          	lh	a5,0(s3)
    800034ce:	c785                	beqz	a5,800034f6 <ialloc+0x84>
    brelse(bp);
    800034d0:	00000097          	auipc	ra,0x0
    800034d4:	a68080e7          	jalr	-1432(ra) # 80002f38 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800034d8:	0485                	addi	s1,s1,1
    800034da:	00ca2703          	lw	a4,12(s4)
    800034de:	0004879b          	sext.w	a5,s1
    800034e2:	fce7e1e3          	bltu	a5,a4,800034a4 <ialloc+0x32>
  panic("ialloc: no inodes");
    800034e6:	00005517          	auipc	a0,0x5
    800034ea:	0aa50513          	addi	a0,a0,170 # 80008590 <syscalls+0x168>
    800034ee:	ffffd097          	auipc	ra,0xffffd
    800034f2:	05a080e7          	jalr	90(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    800034f6:	04000613          	li	a2,64
    800034fa:	4581                	li	a1,0
    800034fc:	854e                	mv	a0,s3
    800034fe:	ffffe097          	auipc	ra,0xffffe
    80003502:	80e080e7          	jalr	-2034(ra) # 80000d0c <memset>
      dip->type = type;
    80003506:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000350a:	854a                	mv	a0,s2
    8000350c:	00001097          	auipc	ra,0x1
    80003510:	c90080e7          	jalr	-880(ra) # 8000419c <log_write>
      brelse(bp);
    80003514:	854a                	mv	a0,s2
    80003516:	00000097          	auipc	ra,0x0
    8000351a:	a22080e7          	jalr	-1502(ra) # 80002f38 <brelse>
      return iget(dev, inum);
    8000351e:	85da                	mv	a1,s6
    80003520:	8556                	mv	a0,s5
    80003522:	00000097          	auipc	ra,0x0
    80003526:	db4080e7          	jalr	-588(ra) # 800032d6 <iget>
}
    8000352a:	60a6                	ld	ra,72(sp)
    8000352c:	6406                	ld	s0,64(sp)
    8000352e:	74e2                	ld	s1,56(sp)
    80003530:	7942                	ld	s2,48(sp)
    80003532:	79a2                	ld	s3,40(sp)
    80003534:	7a02                	ld	s4,32(sp)
    80003536:	6ae2                	ld	s5,24(sp)
    80003538:	6b42                	ld	s6,16(sp)
    8000353a:	6ba2                	ld	s7,8(sp)
    8000353c:	6161                	addi	sp,sp,80
    8000353e:	8082                	ret

0000000080003540 <iupdate>:
{
    80003540:	1101                	addi	sp,sp,-32
    80003542:	ec06                	sd	ra,24(sp)
    80003544:	e822                	sd	s0,16(sp)
    80003546:	e426                	sd	s1,8(sp)
    80003548:	e04a                	sd	s2,0(sp)
    8000354a:	1000                	addi	s0,sp,32
    8000354c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000354e:	415c                	lw	a5,4(a0)
    80003550:	0047d79b          	srliw	a5,a5,0x4
    80003554:	0001d597          	auipc	a1,0x1d
    80003558:	9045a583          	lw	a1,-1788(a1) # 8001fe58 <sb+0x18>
    8000355c:	9dbd                	addw	a1,a1,a5
    8000355e:	4108                	lw	a0,0(a0)
    80003560:	00000097          	auipc	ra,0x0
    80003564:	8a8080e7          	jalr	-1880(ra) # 80002e08 <bread>
    80003568:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000356a:	05850793          	addi	a5,a0,88
    8000356e:	40c8                	lw	a0,4(s1)
    80003570:	893d                	andi	a0,a0,15
    80003572:	051a                	slli	a0,a0,0x6
    80003574:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003576:	04449703          	lh	a4,68(s1)
    8000357a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000357e:	04649703          	lh	a4,70(s1)
    80003582:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003586:	04849703          	lh	a4,72(s1)
    8000358a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000358e:	04a49703          	lh	a4,74(s1)
    80003592:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003596:	44f8                	lw	a4,76(s1)
    80003598:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000359a:	03400613          	li	a2,52
    8000359e:	05048593          	addi	a1,s1,80
    800035a2:	0531                	addi	a0,a0,12
    800035a4:	ffffd097          	auipc	ra,0xffffd
    800035a8:	7c8080e7          	jalr	1992(ra) # 80000d6c <memmove>
  log_write(bp);
    800035ac:	854a                	mv	a0,s2
    800035ae:	00001097          	auipc	ra,0x1
    800035b2:	bee080e7          	jalr	-1042(ra) # 8000419c <log_write>
  brelse(bp);
    800035b6:	854a                	mv	a0,s2
    800035b8:	00000097          	auipc	ra,0x0
    800035bc:	980080e7          	jalr	-1664(ra) # 80002f38 <brelse>
}
    800035c0:	60e2                	ld	ra,24(sp)
    800035c2:	6442                	ld	s0,16(sp)
    800035c4:	64a2                	ld	s1,8(sp)
    800035c6:	6902                	ld	s2,0(sp)
    800035c8:	6105                	addi	sp,sp,32
    800035ca:	8082                	ret

00000000800035cc <idup>:
{
    800035cc:	1101                	addi	sp,sp,-32
    800035ce:	ec06                	sd	ra,24(sp)
    800035d0:	e822                	sd	s0,16(sp)
    800035d2:	e426                	sd	s1,8(sp)
    800035d4:	1000                	addi	s0,sp,32
    800035d6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800035d8:	0001d517          	auipc	a0,0x1d
    800035dc:	88850513          	addi	a0,a0,-1912 # 8001fe60 <icache>
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	630080e7          	jalr	1584(ra) # 80000c10 <acquire>
  ip->ref++;
    800035e8:	449c                	lw	a5,8(s1)
    800035ea:	2785                	addiw	a5,a5,1
    800035ec:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800035ee:	0001d517          	auipc	a0,0x1d
    800035f2:	87250513          	addi	a0,a0,-1934 # 8001fe60 <icache>
    800035f6:	ffffd097          	auipc	ra,0xffffd
    800035fa:	6ce080e7          	jalr	1742(ra) # 80000cc4 <release>
}
    800035fe:	8526                	mv	a0,s1
    80003600:	60e2                	ld	ra,24(sp)
    80003602:	6442                	ld	s0,16(sp)
    80003604:	64a2                	ld	s1,8(sp)
    80003606:	6105                	addi	sp,sp,32
    80003608:	8082                	ret

000000008000360a <ilock>:
{
    8000360a:	1101                	addi	sp,sp,-32
    8000360c:	ec06                	sd	ra,24(sp)
    8000360e:	e822                	sd	s0,16(sp)
    80003610:	e426                	sd	s1,8(sp)
    80003612:	e04a                	sd	s2,0(sp)
    80003614:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003616:	c115                	beqz	a0,8000363a <ilock+0x30>
    80003618:	84aa                	mv	s1,a0
    8000361a:	451c                	lw	a5,8(a0)
    8000361c:	00f05f63          	blez	a5,8000363a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003620:	0541                	addi	a0,a0,16
    80003622:	00001097          	auipc	ra,0x1
    80003626:	ca2080e7          	jalr	-862(ra) # 800042c4 <acquiresleep>
  if(ip->valid == 0){
    8000362a:	40bc                	lw	a5,64(s1)
    8000362c:	cf99                	beqz	a5,8000364a <ilock+0x40>
}
    8000362e:	60e2                	ld	ra,24(sp)
    80003630:	6442                	ld	s0,16(sp)
    80003632:	64a2                	ld	s1,8(sp)
    80003634:	6902                	ld	s2,0(sp)
    80003636:	6105                	addi	sp,sp,32
    80003638:	8082                	ret
    panic("ilock");
    8000363a:	00005517          	auipc	a0,0x5
    8000363e:	f6e50513          	addi	a0,a0,-146 # 800085a8 <syscalls+0x180>
    80003642:	ffffd097          	auipc	ra,0xffffd
    80003646:	f06080e7          	jalr	-250(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000364a:	40dc                	lw	a5,4(s1)
    8000364c:	0047d79b          	srliw	a5,a5,0x4
    80003650:	0001d597          	auipc	a1,0x1d
    80003654:	8085a583          	lw	a1,-2040(a1) # 8001fe58 <sb+0x18>
    80003658:	9dbd                	addw	a1,a1,a5
    8000365a:	4088                	lw	a0,0(s1)
    8000365c:	fffff097          	auipc	ra,0xfffff
    80003660:	7ac080e7          	jalr	1964(ra) # 80002e08 <bread>
    80003664:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003666:	05850593          	addi	a1,a0,88
    8000366a:	40dc                	lw	a5,4(s1)
    8000366c:	8bbd                	andi	a5,a5,15
    8000366e:	079a                	slli	a5,a5,0x6
    80003670:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003672:	00059783          	lh	a5,0(a1)
    80003676:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000367a:	00259783          	lh	a5,2(a1)
    8000367e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003682:	00459783          	lh	a5,4(a1)
    80003686:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000368a:	00659783          	lh	a5,6(a1)
    8000368e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003692:	459c                	lw	a5,8(a1)
    80003694:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003696:	03400613          	li	a2,52
    8000369a:	05b1                	addi	a1,a1,12
    8000369c:	05048513          	addi	a0,s1,80
    800036a0:	ffffd097          	auipc	ra,0xffffd
    800036a4:	6cc080e7          	jalr	1740(ra) # 80000d6c <memmove>
    brelse(bp);
    800036a8:	854a                	mv	a0,s2
    800036aa:	00000097          	auipc	ra,0x0
    800036ae:	88e080e7          	jalr	-1906(ra) # 80002f38 <brelse>
    ip->valid = 1;
    800036b2:	4785                	li	a5,1
    800036b4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800036b6:	04449783          	lh	a5,68(s1)
    800036ba:	fbb5                	bnez	a5,8000362e <ilock+0x24>
      panic("ilock: no type");
    800036bc:	00005517          	auipc	a0,0x5
    800036c0:	ef450513          	addi	a0,a0,-268 # 800085b0 <syscalls+0x188>
    800036c4:	ffffd097          	auipc	ra,0xffffd
    800036c8:	e84080e7          	jalr	-380(ra) # 80000548 <panic>

00000000800036cc <iunlock>:
{
    800036cc:	1101                	addi	sp,sp,-32
    800036ce:	ec06                	sd	ra,24(sp)
    800036d0:	e822                	sd	s0,16(sp)
    800036d2:	e426                	sd	s1,8(sp)
    800036d4:	e04a                	sd	s2,0(sp)
    800036d6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800036d8:	c905                	beqz	a0,80003708 <iunlock+0x3c>
    800036da:	84aa                	mv	s1,a0
    800036dc:	01050913          	addi	s2,a0,16
    800036e0:	854a                	mv	a0,s2
    800036e2:	00001097          	auipc	ra,0x1
    800036e6:	c7c080e7          	jalr	-900(ra) # 8000435e <holdingsleep>
    800036ea:	cd19                	beqz	a0,80003708 <iunlock+0x3c>
    800036ec:	449c                	lw	a5,8(s1)
    800036ee:	00f05d63          	blez	a5,80003708 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800036f2:	854a                	mv	a0,s2
    800036f4:	00001097          	auipc	ra,0x1
    800036f8:	c26080e7          	jalr	-986(ra) # 8000431a <releasesleep>
}
    800036fc:	60e2                	ld	ra,24(sp)
    800036fe:	6442                	ld	s0,16(sp)
    80003700:	64a2                	ld	s1,8(sp)
    80003702:	6902                	ld	s2,0(sp)
    80003704:	6105                	addi	sp,sp,32
    80003706:	8082                	ret
    panic("iunlock");
    80003708:	00005517          	auipc	a0,0x5
    8000370c:	eb850513          	addi	a0,a0,-328 # 800085c0 <syscalls+0x198>
    80003710:	ffffd097          	auipc	ra,0xffffd
    80003714:	e38080e7          	jalr	-456(ra) # 80000548 <panic>

0000000080003718 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003718:	7179                	addi	sp,sp,-48
    8000371a:	f406                	sd	ra,40(sp)
    8000371c:	f022                	sd	s0,32(sp)
    8000371e:	ec26                	sd	s1,24(sp)
    80003720:	e84a                	sd	s2,16(sp)
    80003722:	e44e                	sd	s3,8(sp)
    80003724:	e052                	sd	s4,0(sp)
    80003726:	1800                	addi	s0,sp,48
    80003728:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000372a:	05050493          	addi	s1,a0,80
    8000372e:	08050913          	addi	s2,a0,128
    80003732:	a021                	j	8000373a <itrunc+0x22>
    80003734:	0491                	addi	s1,s1,4
    80003736:	01248d63          	beq	s1,s2,80003750 <itrunc+0x38>
    if(ip->addrs[i]){
    8000373a:	408c                	lw	a1,0(s1)
    8000373c:	dde5                	beqz	a1,80003734 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000373e:	0009a503          	lw	a0,0(s3)
    80003742:	00000097          	auipc	ra,0x0
    80003746:	90c080e7          	jalr	-1780(ra) # 8000304e <bfree>
      ip->addrs[i] = 0;
    8000374a:	0004a023          	sw	zero,0(s1)
    8000374e:	b7dd                	j	80003734 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003750:	0809a583          	lw	a1,128(s3)
    80003754:	e185                	bnez	a1,80003774 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003756:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000375a:	854e                	mv	a0,s3
    8000375c:	00000097          	auipc	ra,0x0
    80003760:	de4080e7          	jalr	-540(ra) # 80003540 <iupdate>
}
    80003764:	70a2                	ld	ra,40(sp)
    80003766:	7402                	ld	s0,32(sp)
    80003768:	64e2                	ld	s1,24(sp)
    8000376a:	6942                	ld	s2,16(sp)
    8000376c:	69a2                	ld	s3,8(sp)
    8000376e:	6a02                	ld	s4,0(sp)
    80003770:	6145                	addi	sp,sp,48
    80003772:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003774:	0009a503          	lw	a0,0(s3)
    80003778:	fffff097          	auipc	ra,0xfffff
    8000377c:	690080e7          	jalr	1680(ra) # 80002e08 <bread>
    80003780:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003782:	05850493          	addi	s1,a0,88
    80003786:	45850913          	addi	s2,a0,1112
    8000378a:	a811                	j	8000379e <itrunc+0x86>
        bfree(ip->dev, a[j]);
    8000378c:	0009a503          	lw	a0,0(s3)
    80003790:	00000097          	auipc	ra,0x0
    80003794:	8be080e7          	jalr	-1858(ra) # 8000304e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003798:	0491                	addi	s1,s1,4
    8000379a:	01248563          	beq	s1,s2,800037a4 <itrunc+0x8c>
      if(a[j])
    8000379e:	408c                	lw	a1,0(s1)
    800037a0:	dde5                	beqz	a1,80003798 <itrunc+0x80>
    800037a2:	b7ed                	j	8000378c <itrunc+0x74>
    brelse(bp);
    800037a4:	8552                	mv	a0,s4
    800037a6:	fffff097          	auipc	ra,0xfffff
    800037aa:	792080e7          	jalr	1938(ra) # 80002f38 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800037ae:	0809a583          	lw	a1,128(s3)
    800037b2:	0009a503          	lw	a0,0(s3)
    800037b6:	00000097          	auipc	ra,0x0
    800037ba:	898080e7          	jalr	-1896(ra) # 8000304e <bfree>
    ip->addrs[NDIRECT] = 0;
    800037be:	0809a023          	sw	zero,128(s3)
    800037c2:	bf51                	j	80003756 <itrunc+0x3e>

00000000800037c4 <iput>:
{
    800037c4:	1101                	addi	sp,sp,-32
    800037c6:	ec06                	sd	ra,24(sp)
    800037c8:	e822                	sd	s0,16(sp)
    800037ca:	e426                	sd	s1,8(sp)
    800037cc:	e04a                	sd	s2,0(sp)
    800037ce:	1000                	addi	s0,sp,32
    800037d0:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800037d2:	0001c517          	auipc	a0,0x1c
    800037d6:	68e50513          	addi	a0,a0,1678 # 8001fe60 <icache>
    800037da:	ffffd097          	auipc	ra,0xffffd
    800037de:	436080e7          	jalr	1078(ra) # 80000c10 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037e2:	4498                	lw	a4,8(s1)
    800037e4:	4785                	li	a5,1
    800037e6:	02f70363          	beq	a4,a5,8000380c <iput+0x48>
  ip->ref--;
    800037ea:	449c                	lw	a5,8(s1)
    800037ec:	37fd                	addiw	a5,a5,-1
    800037ee:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800037f0:	0001c517          	auipc	a0,0x1c
    800037f4:	67050513          	addi	a0,a0,1648 # 8001fe60 <icache>
    800037f8:	ffffd097          	auipc	ra,0xffffd
    800037fc:	4cc080e7          	jalr	1228(ra) # 80000cc4 <release>
}
    80003800:	60e2                	ld	ra,24(sp)
    80003802:	6442                	ld	s0,16(sp)
    80003804:	64a2                	ld	s1,8(sp)
    80003806:	6902                	ld	s2,0(sp)
    80003808:	6105                	addi	sp,sp,32
    8000380a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000380c:	40bc                	lw	a5,64(s1)
    8000380e:	dff1                	beqz	a5,800037ea <iput+0x26>
    80003810:	04a49783          	lh	a5,74(s1)
    80003814:	fbf9                	bnez	a5,800037ea <iput+0x26>
    acquiresleep(&ip->lock);
    80003816:	01048913          	addi	s2,s1,16
    8000381a:	854a                	mv	a0,s2
    8000381c:	00001097          	auipc	ra,0x1
    80003820:	aa8080e7          	jalr	-1368(ra) # 800042c4 <acquiresleep>
    release(&icache.lock);
    80003824:	0001c517          	auipc	a0,0x1c
    80003828:	63c50513          	addi	a0,a0,1596 # 8001fe60 <icache>
    8000382c:	ffffd097          	auipc	ra,0xffffd
    80003830:	498080e7          	jalr	1176(ra) # 80000cc4 <release>
    itrunc(ip);
    80003834:	8526                	mv	a0,s1
    80003836:	00000097          	auipc	ra,0x0
    8000383a:	ee2080e7          	jalr	-286(ra) # 80003718 <itrunc>
    ip->type = 0;
    8000383e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003842:	8526                	mv	a0,s1
    80003844:	00000097          	auipc	ra,0x0
    80003848:	cfc080e7          	jalr	-772(ra) # 80003540 <iupdate>
    ip->valid = 0;
    8000384c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003850:	854a                	mv	a0,s2
    80003852:	00001097          	auipc	ra,0x1
    80003856:	ac8080e7          	jalr	-1336(ra) # 8000431a <releasesleep>
    acquire(&icache.lock);
    8000385a:	0001c517          	auipc	a0,0x1c
    8000385e:	60650513          	addi	a0,a0,1542 # 8001fe60 <icache>
    80003862:	ffffd097          	auipc	ra,0xffffd
    80003866:	3ae080e7          	jalr	942(ra) # 80000c10 <acquire>
    8000386a:	b741                	j	800037ea <iput+0x26>

000000008000386c <iunlockput>:
{
    8000386c:	1101                	addi	sp,sp,-32
    8000386e:	ec06                	sd	ra,24(sp)
    80003870:	e822                	sd	s0,16(sp)
    80003872:	e426                	sd	s1,8(sp)
    80003874:	1000                	addi	s0,sp,32
    80003876:	84aa                	mv	s1,a0
  iunlock(ip);
    80003878:	00000097          	auipc	ra,0x0
    8000387c:	e54080e7          	jalr	-428(ra) # 800036cc <iunlock>
  iput(ip);
    80003880:	8526                	mv	a0,s1
    80003882:	00000097          	auipc	ra,0x0
    80003886:	f42080e7          	jalr	-190(ra) # 800037c4 <iput>
}
    8000388a:	60e2                	ld	ra,24(sp)
    8000388c:	6442                	ld	s0,16(sp)
    8000388e:	64a2                	ld	s1,8(sp)
    80003890:	6105                	addi	sp,sp,32
    80003892:	8082                	ret

0000000080003894 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003894:	1141                	addi	sp,sp,-16
    80003896:	e422                	sd	s0,8(sp)
    80003898:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000389a:	411c                	lw	a5,0(a0)
    8000389c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000389e:	415c                	lw	a5,4(a0)
    800038a0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038a2:	04451783          	lh	a5,68(a0)
    800038a6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800038aa:	04a51783          	lh	a5,74(a0)
    800038ae:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800038b2:	04c56783          	lwu	a5,76(a0)
    800038b6:	e99c                	sd	a5,16(a1)
}
    800038b8:	6422                	ld	s0,8(sp)
    800038ba:	0141                	addi	sp,sp,16
    800038bc:	8082                	ret

00000000800038be <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038be:	457c                	lw	a5,76(a0)
    800038c0:	0ed7e863          	bltu	a5,a3,800039b0 <readi+0xf2>
{
    800038c4:	7159                	addi	sp,sp,-112
    800038c6:	f486                	sd	ra,104(sp)
    800038c8:	f0a2                	sd	s0,96(sp)
    800038ca:	eca6                	sd	s1,88(sp)
    800038cc:	e8ca                	sd	s2,80(sp)
    800038ce:	e4ce                	sd	s3,72(sp)
    800038d0:	e0d2                	sd	s4,64(sp)
    800038d2:	fc56                	sd	s5,56(sp)
    800038d4:	f85a                	sd	s6,48(sp)
    800038d6:	f45e                	sd	s7,40(sp)
    800038d8:	f062                	sd	s8,32(sp)
    800038da:	ec66                	sd	s9,24(sp)
    800038dc:	e86a                	sd	s10,16(sp)
    800038de:	e46e                	sd	s11,8(sp)
    800038e0:	1880                	addi	s0,sp,112
    800038e2:	8baa                	mv	s7,a0
    800038e4:	8c2e                	mv	s8,a1
    800038e6:	8ab2                	mv	s5,a2
    800038e8:	84b6                	mv	s1,a3
    800038ea:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800038ec:	9f35                	addw	a4,a4,a3
    return 0;
    800038ee:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800038f0:	08d76f63          	bltu	a4,a3,8000398e <readi+0xd0>
  if(off + n > ip->size)
    800038f4:	00e7f463          	bgeu	a5,a4,800038fc <readi+0x3e>
    n = ip->size - off;
    800038f8:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038fc:	0a0b0863          	beqz	s6,800039ac <readi+0xee>
    80003900:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003902:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003906:	5cfd                	li	s9,-1
    80003908:	a82d                	j	80003942 <readi+0x84>
    8000390a:	020a1d93          	slli	s11,s4,0x20
    8000390e:	020ddd93          	srli	s11,s11,0x20
    80003912:	05890613          	addi	a2,s2,88
    80003916:	86ee                	mv	a3,s11
    80003918:	963a                	add	a2,a2,a4
    8000391a:	85d6                	mv	a1,s5
    8000391c:	8562                	mv	a0,s8
    8000391e:	fffff097          	auipc	ra,0xfffff
    80003922:	b2e080e7          	jalr	-1234(ra) # 8000244c <either_copyout>
    80003926:	05950d63          	beq	a0,s9,80003980 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    8000392a:	854a                	mv	a0,s2
    8000392c:	fffff097          	auipc	ra,0xfffff
    80003930:	60c080e7          	jalr	1548(ra) # 80002f38 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003934:	013a09bb          	addw	s3,s4,s3
    80003938:	009a04bb          	addw	s1,s4,s1
    8000393c:	9aee                	add	s5,s5,s11
    8000393e:	0569f663          	bgeu	s3,s6,8000398a <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003942:	000ba903          	lw	s2,0(s7)
    80003946:	00a4d59b          	srliw	a1,s1,0xa
    8000394a:	855e                	mv	a0,s7
    8000394c:	00000097          	auipc	ra,0x0
    80003950:	8b0080e7          	jalr	-1872(ra) # 800031fc <bmap>
    80003954:	0005059b          	sext.w	a1,a0
    80003958:	854a                	mv	a0,s2
    8000395a:	fffff097          	auipc	ra,0xfffff
    8000395e:	4ae080e7          	jalr	1198(ra) # 80002e08 <bread>
    80003962:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003964:	3ff4f713          	andi	a4,s1,1023
    80003968:	40ed07bb          	subw	a5,s10,a4
    8000396c:	413b06bb          	subw	a3,s6,s3
    80003970:	8a3e                	mv	s4,a5
    80003972:	2781                	sext.w	a5,a5
    80003974:	0006861b          	sext.w	a2,a3
    80003978:	f8f679e3          	bgeu	a2,a5,8000390a <readi+0x4c>
    8000397c:	8a36                	mv	s4,a3
    8000397e:	b771                	j	8000390a <readi+0x4c>
      brelse(bp);
    80003980:	854a                	mv	a0,s2
    80003982:	fffff097          	auipc	ra,0xfffff
    80003986:	5b6080e7          	jalr	1462(ra) # 80002f38 <brelse>
  }
  return tot;
    8000398a:	0009851b          	sext.w	a0,s3
}
    8000398e:	70a6                	ld	ra,104(sp)
    80003990:	7406                	ld	s0,96(sp)
    80003992:	64e6                	ld	s1,88(sp)
    80003994:	6946                	ld	s2,80(sp)
    80003996:	69a6                	ld	s3,72(sp)
    80003998:	6a06                	ld	s4,64(sp)
    8000399a:	7ae2                	ld	s5,56(sp)
    8000399c:	7b42                	ld	s6,48(sp)
    8000399e:	7ba2                	ld	s7,40(sp)
    800039a0:	7c02                	ld	s8,32(sp)
    800039a2:	6ce2                	ld	s9,24(sp)
    800039a4:	6d42                	ld	s10,16(sp)
    800039a6:	6da2                	ld	s11,8(sp)
    800039a8:	6165                	addi	sp,sp,112
    800039aa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039ac:	89da                	mv	s3,s6
    800039ae:	bff1                	j	8000398a <readi+0xcc>
    return 0;
    800039b0:	4501                	li	a0,0
}
    800039b2:	8082                	ret

00000000800039b4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039b4:	457c                	lw	a5,76(a0)
    800039b6:	10d7e663          	bltu	a5,a3,80003ac2 <writei+0x10e>
{
    800039ba:	7159                	addi	sp,sp,-112
    800039bc:	f486                	sd	ra,104(sp)
    800039be:	f0a2                	sd	s0,96(sp)
    800039c0:	eca6                	sd	s1,88(sp)
    800039c2:	e8ca                	sd	s2,80(sp)
    800039c4:	e4ce                	sd	s3,72(sp)
    800039c6:	e0d2                	sd	s4,64(sp)
    800039c8:	fc56                	sd	s5,56(sp)
    800039ca:	f85a                	sd	s6,48(sp)
    800039cc:	f45e                	sd	s7,40(sp)
    800039ce:	f062                	sd	s8,32(sp)
    800039d0:	ec66                	sd	s9,24(sp)
    800039d2:	e86a                	sd	s10,16(sp)
    800039d4:	e46e                	sd	s11,8(sp)
    800039d6:	1880                	addi	s0,sp,112
    800039d8:	8baa                	mv	s7,a0
    800039da:	8c2e                	mv	s8,a1
    800039dc:	8ab2                	mv	s5,a2
    800039de:	8936                	mv	s2,a3
    800039e0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039e2:	00e687bb          	addw	a5,a3,a4
    800039e6:	0ed7e063          	bltu	a5,a3,80003ac6 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800039ea:	00043737          	lui	a4,0x43
    800039ee:	0cf76e63          	bltu	a4,a5,80003aca <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039f2:	0a0b0763          	beqz	s6,80003aa0 <writei+0xec>
    800039f6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800039f8:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800039fc:	5cfd                	li	s9,-1
    800039fe:	a091                	j	80003a42 <writei+0x8e>
    80003a00:	02099d93          	slli	s11,s3,0x20
    80003a04:	020ddd93          	srli	s11,s11,0x20
    80003a08:	05848513          	addi	a0,s1,88
    80003a0c:	86ee                	mv	a3,s11
    80003a0e:	8656                	mv	a2,s5
    80003a10:	85e2                	mv	a1,s8
    80003a12:	953a                	add	a0,a0,a4
    80003a14:	fffff097          	auipc	ra,0xfffff
    80003a18:	a8e080e7          	jalr	-1394(ra) # 800024a2 <either_copyin>
    80003a1c:	07950263          	beq	a0,s9,80003a80 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a20:	8526                	mv	a0,s1
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	77a080e7          	jalr	1914(ra) # 8000419c <log_write>
    brelse(bp);
    80003a2a:	8526                	mv	a0,s1
    80003a2c:	fffff097          	auipc	ra,0xfffff
    80003a30:	50c080e7          	jalr	1292(ra) # 80002f38 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a34:	01498a3b          	addw	s4,s3,s4
    80003a38:	0129893b          	addw	s2,s3,s2
    80003a3c:	9aee                	add	s5,s5,s11
    80003a3e:	056a7663          	bgeu	s4,s6,80003a8a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a42:	000ba483          	lw	s1,0(s7)
    80003a46:	00a9559b          	srliw	a1,s2,0xa
    80003a4a:	855e                	mv	a0,s7
    80003a4c:	fffff097          	auipc	ra,0xfffff
    80003a50:	7b0080e7          	jalr	1968(ra) # 800031fc <bmap>
    80003a54:	0005059b          	sext.w	a1,a0
    80003a58:	8526                	mv	a0,s1
    80003a5a:	fffff097          	auipc	ra,0xfffff
    80003a5e:	3ae080e7          	jalr	942(ra) # 80002e08 <bread>
    80003a62:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a64:	3ff97713          	andi	a4,s2,1023
    80003a68:	40ed07bb          	subw	a5,s10,a4
    80003a6c:	414b06bb          	subw	a3,s6,s4
    80003a70:	89be                	mv	s3,a5
    80003a72:	2781                	sext.w	a5,a5
    80003a74:	0006861b          	sext.w	a2,a3
    80003a78:	f8f674e3          	bgeu	a2,a5,80003a00 <writei+0x4c>
    80003a7c:	89b6                	mv	s3,a3
    80003a7e:	b749                	j	80003a00 <writei+0x4c>
      brelse(bp);
    80003a80:	8526                	mv	a0,s1
    80003a82:	fffff097          	auipc	ra,0xfffff
    80003a86:	4b6080e7          	jalr	1206(ra) # 80002f38 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003a8a:	04cba783          	lw	a5,76(s7)
    80003a8e:	0127f463          	bgeu	a5,s2,80003a96 <writei+0xe2>
      ip->size = off;
    80003a92:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003a96:	855e                	mv	a0,s7
    80003a98:	00000097          	auipc	ra,0x0
    80003a9c:	aa8080e7          	jalr	-1368(ra) # 80003540 <iupdate>
  }

  return n;
    80003aa0:	000b051b          	sext.w	a0,s6
}
    80003aa4:	70a6                	ld	ra,104(sp)
    80003aa6:	7406                	ld	s0,96(sp)
    80003aa8:	64e6                	ld	s1,88(sp)
    80003aaa:	6946                	ld	s2,80(sp)
    80003aac:	69a6                	ld	s3,72(sp)
    80003aae:	6a06                	ld	s4,64(sp)
    80003ab0:	7ae2                	ld	s5,56(sp)
    80003ab2:	7b42                	ld	s6,48(sp)
    80003ab4:	7ba2                	ld	s7,40(sp)
    80003ab6:	7c02                	ld	s8,32(sp)
    80003ab8:	6ce2                	ld	s9,24(sp)
    80003aba:	6d42                	ld	s10,16(sp)
    80003abc:	6da2                	ld	s11,8(sp)
    80003abe:	6165                	addi	sp,sp,112
    80003ac0:	8082                	ret
    return -1;
    80003ac2:	557d                	li	a0,-1
}
    80003ac4:	8082                	ret
    return -1;
    80003ac6:	557d                	li	a0,-1
    80003ac8:	bff1                	j	80003aa4 <writei+0xf0>
    return -1;
    80003aca:	557d                	li	a0,-1
    80003acc:	bfe1                	j	80003aa4 <writei+0xf0>

0000000080003ace <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ace:	1141                	addi	sp,sp,-16
    80003ad0:	e406                	sd	ra,8(sp)
    80003ad2:	e022                	sd	s0,0(sp)
    80003ad4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ad6:	4639                	li	a2,14
    80003ad8:	ffffd097          	auipc	ra,0xffffd
    80003adc:	310080e7          	jalr	784(ra) # 80000de8 <strncmp>
}
    80003ae0:	60a2                	ld	ra,8(sp)
    80003ae2:	6402                	ld	s0,0(sp)
    80003ae4:	0141                	addi	sp,sp,16
    80003ae6:	8082                	ret

0000000080003ae8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ae8:	7139                	addi	sp,sp,-64
    80003aea:	fc06                	sd	ra,56(sp)
    80003aec:	f822                	sd	s0,48(sp)
    80003aee:	f426                	sd	s1,40(sp)
    80003af0:	f04a                	sd	s2,32(sp)
    80003af2:	ec4e                	sd	s3,24(sp)
    80003af4:	e852                	sd	s4,16(sp)
    80003af6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003af8:	04451703          	lh	a4,68(a0)
    80003afc:	4785                	li	a5,1
    80003afe:	00f71a63          	bne	a4,a5,80003b12 <dirlookup+0x2a>
    80003b02:	892a                	mv	s2,a0
    80003b04:	89ae                	mv	s3,a1
    80003b06:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b08:	457c                	lw	a5,76(a0)
    80003b0a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b0c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b0e:	e79d                	bnez	a5,80003b3c <dirlookup+0x54>
    80003b10:	a8a5                	j	80003b88 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b12:	00005517          	auipc	a0,0x5
    80003b16:	ab650513          	addi	a0,a0,-1354 # 800085c8 <syscalls+0x1a0>
    80003b1a:	ffffd097          	auipc	ra,0xffffd
    80003b1e:	a2e080e7          	jalr	-1490(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003b22:	00005517          	auipc	a0,0x5
    80003b26:	abe50513          	addi	a0,a0,-1346 # 800085e0 <syscalls+0x1b8>
    80003b2a:	ffffd097          	auipc	ra,0xffffd
    80003b2e:	a1e080e7          	jalr	-1506(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b32:	24c1                	addiw	s1,s1,16
    80003b34:	04c92783          	lw	a5,76(s2)
    80003b38:	04f4f763          	bgeu	s1,a5,80003b86 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b3c:	4741                	li	a4,16
    80003b3e:	86a6                	mv	a3,s1
    80003b40:	fc040613          	addi	a2,s0,-64
    80003b44:	4581                	li	a1,0
    80003b46:	854a                	mv	a0,s2
    80003b48:	00000097          	auipc	ra,0x0
    80003b4c:	d76080e7          	jalr	-650(ra) # 800038be <readi>
    80003b50:	47c1                	li	a5,16
    80003b52:	fcf518e3          	bne	a0,a5,80003b22 <dirlookup+0x3a>
    if(de.inum == 0)
    80003b56:	fc045783          	lhu	a5,-64(s0)
    80003b5a:	dfe1                	beqz	a5,80003b32 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003b5c:	fc240593          	addi	a1,s0,-62
    80003b60:	854e                	mv	a0,s3
    80003b62:	00000097          	auipc	ra,0x0
    80003b66:	f6c080e7          	jalr	-148(ra) # 80003ace <namecmp>
    80003b6a:	f561                	bnez	a0,80003b32 <dirlookup+0x4a>
      if(poff)
    80003b6c:	000a0463          	beqz	s4,80003b74 <dirlookup+0x8c>
        *poff = off;
    80003b70:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003b74:	fc045583          	lhu	a1,-64(s0)
    80003b78:	00092503          	lw	a0,0(s2)
    80003b7c:	fffff097          	auipc	ra,0xfffff
    80003b80:	75a080e7          	jalr	1882(ra) # 800032d6 <iget>
    80003b84:	a011                	j	80003b88 <dirlookup+0xa0>
  return 0;
    80003b86:	4501                	li	a0,0
}
    80003b88:	70e2                	ld	ra,56(sp)
    80003b8a:	7442                	ld	s0,48(sp)
    80003b8c:	74a2                	ld	s1,40(sp)
    80003b8e:	7902                	ld	s2,32(sp)
    80003b90:	69e2                	ld	s3,24(sp)
    80003b92:	6a42                	ld	s4,16(sp)
    80003b94:	6121                	addi	sp,sp,64
    80003b96:	8082                	ret

0000000080003b98 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b98:	711d                	addi	sp,sp,-96
    80003b9a:	ec86                	sd	ra,88(sp)
    80003b9c:	e8a2                	sd	s0,80(sp)
    80003b9e:	e4a6                	sd	s1,72(sp)
    80003ba0:	e0ca                	sd	s2,64(sp)
    80003ba2:	fc4e                	sd	s3,56(sp)
    80003ba4:	f852                	sd	s4,48(sp)
    80003ba6:	f456                	sd	s5,40(sp)
    80003ba8:	f05a                	sd	s6,32(sp)
    80003baa:	ec5e                	sd	s7,24(sp)
    80003bac:	e862                	sd	s8,16(sp)
    80003bae:	e466                	sd	s9,8(sp)
    80003bb0:	1080                	addi	s0,sp,96
    80003bb2:	84aa                	mv	s1,a0
    80003bb4:	8b2e                	mv	s6,a1
    80003bb6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003bb8:	00054703          	lbu	a4,0(a0)
    80003bbc:	02f00793          	li	a5,47
    80003bc0:	02f70363          	beq	a4,a5,80003be6 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003bc4:	ffffe097          	auipc	ra,0xffffe
    80003bc8:	e1a080e7          	jalr	-486(ra) # 800019de <myproc>
    80003bcc:	15053503          	ld	a0,336(a0)
    80003bd0:	00000097          	auipc	ra,0x0
    80003bd4:	9fc080e7          	jalr	-1540(ra) # 800035cc <idup>
    80003bd8:	89aa                	mv	s3,a0
  while(*path == '/')
    80003bda:	02f00913          	li	s2,47
  len = path - s;
    80003bde:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003be0:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003be2:	4c05                	li	s8,1
    80003be4:	a865                	j	80003c9c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003be6:	4585                	li	a1,1
    80003be8:	4505                	li	a0,1
    80003bea:	fffff097          	auipc	ra,0xfffff
    80003bee:	6ec080e7          	jalr	1772(ra) # 800032d6 <iget>
    80003bf2:	89aa                	mv	s3,a0
    80003bf4:	b7dd                	j	80003bda <namex+0x42>
      iunlockput(ip);
    80003bf6:	854e                	mv	a0,s3
    80003bf8:	00000097          	auipc	ra,0x0
    80003bfc:	c74080e7          	jalr	-908(ra) # 8000386c <iunlockput>
      return 0;
    80003c00:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c02:	854e                	mv	a0,s3
    80003c04:	60e6                	ld	ra,88(sp)
    80003c06:	6446                	ld	s0,80(sp)
    80003c08:	64a6                	ld	s1,72(sp)
    80003c0a:	6906                	ld	s2,64(sp)
    80003c0c:	79e2                	ld	s3,56(sp)
    80003c0e:	7a42                	ld	s4,48(sp)
    80003c10:	7aa2                	ld	s5,40(sp)
    80003c12:	7b02                	ld	s6,32(sp)
    80003c14:	6be2                	ld	s7,24(sp)
    80003c16:	6c42                	ld	s8,16(sp)
    80003c18:	6ca2                	ld	s9,8(sp)
    80003c1a:	6125                	addi	sp,sp,96
    80003c1c:	8082                	ret
      iunlock(ip);
    80003c1e:	854e                	mv	a0,s3
    80003c20:	00000097          	auipc	ra,0x0
    80003c24:	aac080e7          	jalr	-1364(ra) # 800036cc <iunlock>
      return ip;
    80003c28:	bfe9                	j	80003c02 <namex+0x6a>
      iunlockput(ip);
    80003c2a:	854e                	mv	a0,s3
    80003c2c:	00000097          	auipc	ra,0x0
    80003c30:	c40080e7          	jalr	-960(ra) # 8000386c <iunlockput>
      return 0;
    80003c34:	89d2                	mv	s3,s4
    80003c36:	b7f1                	j	80003c02 <namex+0x6a>
  len = path - s;
    80003c38:	40b48633          	sub	a2,s1,a1
    80003c3c:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003c40:	094cd463          	bge	s9,s4,80003cc8 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003c44:	4639                	li	a2,14
    80003c46:	8556                	mv	a0,s5
    80003c48:	ffffd097          	auipc	ra,0xffffd
    80003c4c:	124080e7          	jalr	292(ra) # 80000d6c <memmove>
  while(*path == '/')
    80003c50:	0004c783          	lbu	a5,0(s1)
    80003c54:	01279763          	bne	a5,s2,80003c62 <namex+0xca>
    path++;
    80003c58:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c5a:	0004c783          	lbu	a5,0(s1)
    80003c5e:	ff278de3          	beq	a5,s2,80003c58 <namex+0xc0>
    ilock(ip);
    80003c62:	854e                	mv	a0,s3
    80003c64:	00000097          	auipc	ra,0x0
    80003c68:	9a6080e7          	jalr	-1626(ra) # 8000360a <ilock>
    if(ip->type != T_DIR){
    80003c6c:	04499783          	lh	a5,68(s3)
    80003c70:	f98793e3          	bne	a5,s8,80003bf6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003c74:	000b0563          	beqz	s6,80003c7e <namex+0xe6>
    80003c78:	0004c783          	lbu	a5,0(s1)
    80003c7c:	d3cd                	beqz	a5,80003c1e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c7e:	865e                	mv	a2,s7
    80003c80:	85d6                	mv	a1,s5
    80003c82:	854e                	mv	a0,s3
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	e64080e7          	jalr	-412(ra) # 80003ae8 <dirlookup>
    80003c8c:	8a2a                	mv	s4,a0
    80003c8e:	dd51                	beqz	a0,80003c2a <namex+0x92>
    iunlockput(ip);
    80003c90:	854e                	mv	a0,s3
    80003c92:	00000097          	auipc	ra,0x0
    80003c96:	bda080e7          	jalr	-1062(ra) # 8000386c <iunlockput>
    ip = next;
    80003c9a:	89d2                	mv	s3,s4
  while(*path == '/')
    80003c9c:	0004c783          	lbu	a5,0(s1)
    80003ca0:	05279763          	bne	a5,s2,80003cee <namex+0x156>
    path++;
    80003ca4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ca6:	0004c783          	lbu	a5,0(s1)
    80003caa:	ff278de3          	beq	a5,s2,80003ca4 <namex+0x10c>
  if(*path == 0)
    80003cae:	c79d                	beqz	a5,80003cdc <namex+0x144>
    path++;
    80003cb0:	85a6                	mv	a1,s1
  len = path - s;
    80003cb2:	8a5e                	mv	s4,s7
    80003cb4:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003cb6:	01278963          	beq	a5,s2,80003cc8 <namex+0x130>
    80003cba:	dfbd                	beqz	a5,80003c38 <namex+0xa0>
    path++;
    80003cbc:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003cbe:	0004c783          	lbu	a5,0(s1)
    80003cc2:	ff279ce3          	bne	a5,s2,80003cba <namex+0x122>
    80003cc6:	bf8d                	j	80003c38 <namex+0xa0>
    memmove(name, s, len);
    80003cc8:	2601                	sext.w	a2,a2
    80003cca:	8556                	mv	a0,s5
    80003ccc:	ffffd097          	auipc	ra,0xffffd
    80003cd0:	0a0080e7          	jalr	160(ra) # 80000d6c <memmove>
    name[len] = 0;
    80003cd4:	9a56                	add	s4,s4,s5
    80003cd6:	000a0023          	sb	zero,0(s4)
    80003cda:	bf9d                	j	80003c50 <namex+0xb8>
  if(nameiparent){
    80003cdc:	f20b03e3          	beqz	s6,80003c02 <namex+0x6a>
    iput(ip);
    80003ce0:	854e                	mv	a0,s3
    80003ce2:	00000097          	auipc	ra,0x0
    80003ce6:	ae2080e7          	jalr	-1310(ra) # 800037c4 <iput>
    return 0;
    80003cea:	4981                	li	s3,0
    80003cec:	bf19                	j	80003c02 <namex+0x6a>
  if(*path == 0)
    80003cee:	d7fd                	beqz	a5,80003cdc <namex+0x144>
  while(*path != '/' && *path != 0)
    80003cf0:	0004c783          	lbu	a5,0(s1)
    80003cf4:	85a6                	mv	a1,s1
    80003cf6:	b7d1                	j	80003cba <namex+0x122>

0000000080003cf8 <dirlink>:
{
    80003cf8:	7139                	addi	sp,sp,-64
    80003cfa:	fc06                	sd	ra,56(sp)
    80003cfc:	f822                	sd	s0,48(sp)
    80003cfe:	f426                	sd	s1,40(sp)
    80003d00:	f04a                	sd	s2,32(sp)
    80003d02:	ec4e                	sd	s3,24(sp)
    80003d04:	e852                	sd	s4,16(sp)
    80003d06:	0080                	addi	s0,sp,64
    80003d08:	892a                	mv	s2,a0
    80003d0a:	8a2e                	mv	s4,a1
    80003d0c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d0e:	4601                	li	a2,0
    80003d10:	00000097          	auipc	ra,0x0
    80003d14:	dd8080e7          	jalr	-552(ra) # 80003ae8 <dirlookup>
    80003d18:	e93d                	bnez	a0,80003d8e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d1a:	04c92483          	lw	s1,76(s2)
    80003d1e:	c49d                	beqz	s1,80003d4c <dirlink+0x54>
    80003d20:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d22:	4741                	li	a4,16
    80003d24:	86a6                	mv	a3,s1
    80003d26:	fc040613          	addi	a2,s0,-64
    80003d2a:	4581                	li	a1,0
    80003d2c:	854a                	mv	a0,s2
    80003d2e:	00000097          	auipc	ra,0x0
    80003d32:	b90080e7          	jalr	-1136(ra) # 800038be <readi>
    80003d36:	47c1                	li	a5,16
    80003d38:	06f51163          	bne	a0,a5,80003d9a <dirlink+0xa2>
    if(de.inum == 0)
    80003d3c:	fc045783          	lhu	a5,-64(s0)
    80003d40:	c791                	beqz	a5,80003d4c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d42:	24c1                	addiw	s1,s1,16
    80003d44:	04c92783          	lw	a5,76(s2)
    80003d48:	fcf4ede3          	bltu	s1,a5,80003d22 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003d4c:	4639                	li	a2,14
    80003d4e:	85d2                	mv	a1,s4
    80003d50:	fc240513          	addi	a0,s0,-62
    80003d54:	ffffd097          	auipc	ra,0xffffd
    80003d58:	0d0080e7          	jalr	208(ra) # 80000e24 <strncpy>
  de.inum = inum;
    80003d5c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d60:	4741                	li	a4,16
    80003d62:	86a6                	mv	a3,s1
    80003d64:	fc040613          	addi	a2,s0,-64
    80003d68:	4581                	li	a1,0
    80003d6a:	854a                	mv	a0,s2
    80003d6c:	00000097          	auipc	ra,0x0
    80003d70:	c48080e7          	jalr	-952(ra) # 800039b4 <writei>
    80003d74:	872a                	mv	a4,a0
    80003d76:	47c1                	li	a5,16
  return 0;
    80003d78:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d7a:	02f71863          	bne	a4,a5,80003daa <dirlink+0xb2>
}
    80003d7e:	70e2                	ld	ra,56(sp)
    80003d80:	7442                	ld	s0,48(sp)
    80003d82:	74a2                	ld	s1,40(sp)
    80003d84:	7902                	ld	s2,32(sp)
    80003d86:	69e2                	ld	s3,24(sp)
    80003d88:	6a42                	ld	s4,16(sp)
    80003d8a:	6121                	addi	sp,sp,64
    80003d8c:	8082                	ret
    iput(ip);
    80003d8e:	00000097          	auipc	ra,0x0
    80003d92:	a36080e7          	jalr	-1482(ra) # 800037c4 <iput>
    return -1;
    80003d96:	557d                	li	a0,-1
    80003d98:	b7dd                	j	80003d7e <dirlink+0x86>
      panic("dirlink read");
    80003d9a:	00005517          	auipc	a0,0x5
    80003d9e:	85650513          	addi	a0,a0,-1962 # 800085f0 <syscalls+0x1c8>
    80003da2:	ffffc097          	auipc	ra,0xffffc
    80003da6:	7a6080e7          	jalr	1958(ra) # 80000548 <panic>
    panic("dirlink");
    80003daa:	00005517          	auipc	a0,0x5
    80003dae:	96650513          	addi	a0,a0,-1690 # 80008710 <syscalls+0x2e8>
    80003db2:	ffffc097          	auipc	ra,0xffffc
    80003db6:	796080e7          	jalr	1942(ra) # 80000548 <panic>

0000000080003dba <namei>:

struct inode*
namei(char *path)
{
    80003dba:	1101                	addi	sp,sp,-32
    80003dbc:	ec06                	sd	ra,24(sp)
    80003dbe:	e822                	sd	s0,16(sp)
    80003dc0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003dc2:	fe040613          	addi	a2,s0,-32
    80003dc6:	4581                	li	a1,0
    80003dc8:	00000097          	auipc	ra,0x0
    80003dcc:	dd0080e7          	jalr	-560(ra) # 80003b98 <namex>
}
    80003dd0:	60e2                	ld	ra,24(sp)
    80003dd2:	6442                	ld	s0,16(sp)
    80003dd4:	6105                	addi	sp,sp,32
    80003dd6:	8082                	ret

0000000080003dd8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003dd8:	1141                	addi	sp,sp,-16
    80003dda:	e406                	sd	ra,8(sp)
    80003ddc:	e022                	sd	s0,0(sp)
    80003dde:	0800                	addi	s0,sp,16
    80003de0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003de2:	4585                	li	a1,1
    80003de4:	00000097          	auipc	ra,0x0
    80003de8:	db4080e7          	jalr	-588(ra) # 80003b98 <namex>
}
    80003dec:	60a2                	ld	ra,8(sp)
    80003dee:	6402                	ld	s0,0(sp)
    80003df0:	0141                	addi	sp,sp,16
    80003df2:	8082                	ret

0000000080003df4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003df4:	1101                	addi	sp,sp,-32
    80003df6:	ec06                	sd	ra,24(sp)
    80003df8:	e822                	sd	s0,16(sp)
    80003dfa:	e426                	sd	s1,8(sp)
    80003dfc:	e04a                	sd	s2,0(sp)
    80003dfe:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e00:	0001e917          	auipc	s2,0x1e
    80003e04:	b0890913          	addi	s2,s2,-1272 # 80021908 <log>
    80003e08:	01892583          	lw	a1,24(s2)
    80003e0c:	02892503          	lw	a0,40(s2)
    80003e10:	fffff097          	auipc	ra,0xfffff
    80003e14:	ff8080e7          	jalr	-8(ra) # 80002e08 <bread>
    80003e18:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e1a:	02c92683          	lw	a3,44(s2)
    80003e1e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e20:	02d05763          	blez	a3,80003e4e <write_head+0x5a>
    80003e24:	0001e797          	auipc	a5,0x1e
    80003e28:	b1478793          	addi	a5,a5,-1260 # 80021938 <log+0x30>
    80003e2c:	05c50713          	addi	a4,a0,92
    80003e30:	36fd                	addiw	a3,a3,-1
    80003e32:	1682                	slli	a3,a3,0x20
    80003e34:	9281                	srli	a3,a3,0x20
    80003e36:	068a                	slli	a3,a3,0x2
    80003e38:	0001e617          	auipc	a2,0x1e
    80003e3c:	b0460613          	addi	a2,a2,-1276 # 8002193c <log+0x34>
    80003e40:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003e42:	4390                	lw	a2,0(a5)
    80003e44:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e46:	0791                	addi	a5,a5,4
    80003e48:	0711                	addi	a4,a4,4
    80003e4a:	fed79ce3          	bne	a5,a3,80003e42 <write_head+0x4e>
  }
  bwrite(buf);
    80003e4e:	8526                	mv	a0,s1
    80003e50:	fffff097          	auipc	ra,0xfffff
    80003e54:	0aa080e7          	jalr	170(ra) # 80002efa <bwrite>
  brelse(buf);
    80003e58:	8526                	mv	a0,s1
    80003e5a:	fffff097          	auipc	ra,0xfffff
    80003e5e:	0de080e7          	jalr	222(ra) # 80002f38 <brelse>
}
    80003e62:	60e2                	ld	ra,24(sp)
    80003e64:	6442                	ld	s0,16(sp)
    80003e66:	64a2                	ld	s1,8(sp)
    80003e68:	6902                	ld	s2,0(sp)
    80003e6a:	6105                	addi	sp,sp,32
    80003e6c:	8082                	ret

0000000080003e6e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e6e:	0001e797          	auipc	a5,0x1e
    80003e72:	ac67a783          	lw	a5,-1338(a5) # 80021934 <log+0x2c>
    80003e76:	0af05663          	blez	a5,80003f22 <install_trans+0xb4>
{
    80003e7a:	7139                	addi	sp,sp,-64
    80003e7c:	fc06                	sd	ra,56(sp)
    80003e7e:	f822                	sd	s0,48(sp)
    80003e80:	f426                	sd	s1,40(sp)
    80003e82:	f04a                	sd	s2,32(sp)
    80003e84:	ec4e                	sd	s3,24(sp)
    80003e86:	e852                	sd	s4,16(sp)
    80003e88:	e456                	sd	s5,8(sp)
    80003e8a:	0080                	addi	s0,sp,64
    80003e8c:	0001ea97          	auipc	s5,0x1e
    80003e90:	aaca8a93          	addi	s5,s5,-1364 # 80021938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e94:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e96:	0001e997          	auipc	s3,0x1e
    80003e9a:	a7298993          	addi	s3,s3,-1422 # 80021908 <log>
    80003e9e:	0189a583          	lw	a1,24(s3)
    80003ea2:	014585bb          	addw	a1,a1,s4
    80003ea6:	2585                	addiw	a1,a1,1
    80003ea8:	0289a503          	lw	a0,40(s3)
    80003eac:	fffff097          	auipc	ra,0xfffff
    80003eb0:	f5c080e7          	jalr	-164(ra) # 80002e08 <bread>
    80003eb4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003eb6:	000aa583          	lw	a1,0(s5)
    80003eba:	0289a503          	lw	a0,40(s3)
    80003ebe:	fffff097          	auipc	ra,0xfffff
    80003ec2:	f4a080e7          	jalr	-182(ra) # 80002e08 <bread>
    80003ec6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ec8:	40000613          	li	a2,1024
    80003ecc:	05890593          	addi	a1,s2,88
    80003ed0:	05850513          	addi	a0,a0,88
    80003ed4:	ffffd097          	auipc	ra,0xffffd
    80003ed8:	e98080e7          	jalr	-360(ra) # 80000d6c <memmove>
    bwrite(dbuf);  // write dst to disk
    80003edc:	8526                	mv	a0,s1
    80003ede:	fffff097          	auipc	ra,0xfffff
    80003ee2:	01c080e7          	jalr	28(ra) # 80002efa <bwrite>
    bunpin(dbuf);
    80003ee6:	8526                	mv	a0,s1
    80003ee8:	fffff097          	auipc	ra,0xfffff
    80003eec:	12a080e7          	jalr	298(ra) # 80003012 <bunpin>
    brelse(lbuf);
    80003ef0:	854a                	mv	a0,s2
    80003ef2:	fffff097          	auipc	ra,0xfffff
    80003ef6:	046080e7          	jalr	70(ra) # 80002f38 <brelse>
    brelse(dbuf);
    80003efa:	8526                	mv	a0,s1
    80003efc:	fffff097          	auipc	ra,0xfffff
    80003f00:	03c080e7          	jalr	60(ra) # 80002f38 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f04:	2a05                	addiw	s4,s4,1
    80003f06:	0a91                	addi	s5,s5,4
    80003f08:	02c9a783          	lw	a5,44(s3)
    80003f0c:	f8fa49e3          	blt	s4,a5,80003e9e <install_trans+0x30>
}
    80003f10:	70e2                	ld	ra,56(sp)
    80003f12:	7442                	ld	s0,48(sp)
    80003f14:	74a2                	ld	s1,40(sp)
    80003f16:	7902                	ld	s2,32(sp)
    80003f18:	69e2                	ld	s3,24(sp)
    80003f1a:	6a42                	ld	s4,16(sp)
    80003f1c:	6aa2                	ld	s5,8(sp)
    80003f1e:	6121                	addi	sp,sp,64
    80003f20:	8082                	ret
    80003f22:	8082                	ret

0000000080003f24 <initlog>:
{
    80003f24:	7179                	addi	sp,sp,-48
    80003f26:	f406                	sd	ra,40(sp)
    80003f28:	f022                	sd	s0,32(sp)
    80003f2a:	ec26                	sd	s1,24(sp)
    80003f2c:	e84a                	sd	s2,16(sp)
    80003f2e:	e44e                	sd	s3,8(sp)
    80003f30:	1800                	addi	s0,sp,48
    80003f32:	892a                	mv	s2,a0
    80003f34:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f36:	0001e497          	auipc	s1,0x1e
    80003f3a:	9d248493          	addi	s1,s1,-1582 # 80021908 <log>
    80003f3e:	00004597          	auipc	a1,0x4
    80003f42:	6c258593          	addi	a1,a1,1730 # 80008600 <syscalls+0x1d8>
    80003f46:	8526                	mv	a0,s1
    80003f48:	ffffd097          	auipc	ra,0xffffd
    80003f4c:	c38080e7          	jalr	-968(ra) # 80000b80 <initlock>
  log.start = sb->logstart;
    80003f50:	0149a583          	lw	a1,20(s3)
    80003f54:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f56:	0109a783          	lw	a5,16(s3)
    80003f5a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f5c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f60:	854a                	mv	a0,s2
    80003f62:	fffff097          	auipc	ra,0xfffff
    80003f66:	ea6080e7          	jalr	-346(ra) # 80002e08 <bread>
  log.lh.n = lh->n;
    80003f6a:	4d3c                	lw	a5,88(a0)
    80003f6c:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003f6e:	02f05563          	blez	a5,80003f98 <initlog+0x74>
    80003f72:	05c50713          	addi	a4,a0,92
    80003f76:	0001e697          	auipc	a3,0x1e
    80003f7a:	9c268693          	addi	a3,a3,-1598 # 80021938 <log+0x30>
    80003f7e:	37fd                	addiw	a5,a5,-1
    80003f80:	1782                	slli	a5,a5,0x20
    80003f82:	9381                	srli	a5,a5,0x20
    80003f84:	078a                	slli	a5,a5,0x2
    80003f86:	06050613          	addi	a2,a0,96
    80003f8a:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003f8c:	4310                	lw	a2,0(a4)
    80003f8e:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80003f90:	0711                	addi	a4,a4,4
    80003f92:	0691                	addi	a3,a3,4
    80003f94:	fef71ce3          	bne	a4,a5,80003f8c <initlog+0x68>
  brelse(buf);
    80003f98:	fffff097          	auipc	ra,0xfffff
    80003f9c:	fa0080e7          	jalr	-96(ra) # 80002f38 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80003fa0:	00000097          	auipc	ra,0x0
    80003fa4:	ece080e7          	jalr	-306(ra) # 80003e6e <install_trans>
  log.lh.n = 0;
    80003fa8:	0001e797          	auipc	a5,0x1e
    80003fac:	9807a623          	sw	zero,-1652(a5) # 80021934 <log+0x2c>
  write_head(); // clear the log
    80003fb0:	00000097          	auipc	ra,0x0
    80003fb4:	e44080e7          	jalr	-444(ra) # 80003df4 <write_head>
}
    80003fb8:	70a2                	ld	ra,40(sp)
    80003fba:	7402                	ld	s0,32(sp)
    80003fbc:	64e2                	ld	s1,24(sp)
    80003fbe:	6942                	ld	s2,16(sp)
    80003fc0:	69a2                	ld	s3,8(sp)
    80003fc2:	6145                	addi	sp,sp,48
    80003fc4:	8082                	ret

0000000080003fc6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003fc6:	1101                	addi	sp,sp,-32
    80003fc8:	ec06                	sd	ra,24(sp)
    80003fca:	e822                	sd	s0,16(sp)
    80003fcc:	e426                	sd	s1,8(sp)
    80003fce:	e04a                	sd	s2,0(sp)
    80003fd0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003fd2:	0001e517          	auipc	a0,0x1e
    80003fd6:	93650513          	addi	a0,a0,-1738 # 80021908 <log>
    80003fda:	ffffd097          	auipc	ra,0xffffd
    80003fde:	c36080e7          	jalr	-970(ra) # 80000c10 <acquire>
  while(1){
    if(log.committing){
    80003fe2:	0001e497          	auipc	s1,0x1e
    80003fe6:	92648493          	addi	s1,s1,-1754 # 80021908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003fea:	4979                	li	s2,30
    80003fec:	a039                	j	80003ffa <begin_op+0x34>
      sleep(&log, &log.lock);
    80003fee:	85a6                	mv	a1,s1
    80003ff0:	8526                	mv	a0,s1
    80003ff2:	ffffe097          	auipc	ra,0xffffe
    80003ff6:	1f8080e7          	jalr	504(ra) # 800021ea <sleep>
    if(log.committing){
    80003ffa:	50dc                	lw	a5,36(s1)
    80003ffc:	fbed                	bnez	a5,80003fee <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003ffe:	509c                	lw	a5,32(s1)
    80004000:	0017871b          	addiw	a4,a5,1
    80004004:	0007069b          	sext.w	a3,a4
    80004008:	0027179b          	slliw	a5,a4,0x2
    8000400c:	9fb9                	addw	a5,a5,a4
    8000400e:	0017979b          	slliw	a5,a5,0x1
    80004012:	54d8                	lw	a4,44(s1)
    80004014:	9fb9                	addw	a5,a5,a4
    80004016:	00f95963          	bge	s2,a5,80004028 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000401a:	85a6                	mv	a1,s1
    8000401c:	8526                	mv	a0,s1
    8000401e:	ffffe097          	auipc	ra,0xffffe
    80004022:	1cc080e7          	jalr	460(ra) # 800021ea <sleep>
    80004026:	bfd1                	j	80003ffa <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004028:	0001e517          	auipc	a0,0x1e
    8000402c:	8e050513          	addi	a0,a0,-1824 # 80021908 <log>
    80004030:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004032:	ffffd097          	auipc	ra,0xffffd
    80004036:	c92080e7          	jalr	-878(ra) # 80000cc4 <release>
      break;
    }
  }
}
    8000403a:	60e2                	ld	ra,24(sp)
    8000403c:	6442                	ld	s0,16(sp)
    8000403e:	64a2                	ld	s1,8(sp)
    80004040:	6902                	ld	s2,0(sp)
    80004042:	6105                	addi	sp,sp,32
    80004044:	8082                	ret

0000000080004046 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004046:	7139                	addi	sp,sp,-64
    80004048:	fc06                	sd	ra,56(sp)
    8000404a:	f822                	sd	s0,48(sp)
    8000404c:	f426                	sd	s1,40(sp)
    8000404e:	f04a                	sd	s2,32(sp)
    80004050:	ec4e                	sd	s3,24(sp)
    80004052:	e852                	sd	s4,16(sp)
    80004054:	e456                	sd	s5,8(sp)
    80004056:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004058:	0001e497          	auipc	s1,0x1e
    8000405c:	8b048493          	addi	s1,s1,-1872 # 80021908 <log>
    80004060:	8526                	mv	a0,s1
    80004062:	ffffd097          	auipc	ra,0xffffd
    80004066:	bae080e7          	jalr	-1106(ra) # 80000c10 <acquire>
  log.outstanding -= 1;
    8000406a:	509c                	lw	a5,32(s1)
    8000406c:	37fd                	addiw	a5,a5,-1
    8000406e:	0007891b          	sext.w	s2,a5
    80004072:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004074:	50dc                	lw	a5,36(s1)
    80004076:	efb9                	bnez	a5,800040d4 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004078:	06091663          	bnez	s2,800040e4 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000407c:	0001e497          	auipc	s1,0x1e
    80004080:	88c48493          	addi	s1,s1,-1908 # 80021908 <log>
    80004084:	4785                	li	a5,1
    80004086:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004088:	8526                	mv	a0,s1
    8000408a:	ffffd097          	auipc	ra,0xffffd
    8000408e:	c3a080e7          	jalr	-966(ra) # 80000cc4 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004092:	54dc                	lw	a5,44(s1)
    80004094:	06f04763          	bgtz	a5,80004102 <end_op+0xbc>
    acquire(&log.lock);
    80004098:	0001e497          	auipc	s1,0x1e
    8000409c:	87048493          	addi	s1,s1,-1936 # 80021908 <log>
    800040a0:	8526                	mv	a0,s1
    800040a2:	ffffd097          	auipc	ra,0xffffd
    800040a6:	b6e080e7          	jalr	-1170(ra) # 80000c10 <acquire>
    log.committing = 0;
    800040aa:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800040ae:	8526                	mv	a0,s1
    800040b0:	ffffe097          	auipc	ra,0xffffe
    800040b4:	2c0080e7          	jalr	704(ra) # 80002370 <wakeup>
    release(&log.lock);
    800040b8:	8526                	mv	a0,s1
    800040ba:	ffffd097          	auipc	ra,0xffffd
    800040be:	c0a080e7          	jalr	-1014(ra) # 80000cc4 <release>
}
    800040c2:	70e2                	ld	ra,56(sp)
    800040c4:	7442                	ld	s0,48(sp)
    800040c6:	74a2                	ld	s1,40(sp)
    800040c8:	7902                	ld	s2,32(sp)
    800040ca:	69e2                	ld	s3,24(sp)
    800040cc:	6a42                	ld	s4,16(sp)
    800040ce:	6aa2                	ld	s5,8(sp)
    800040d0:	6121                	addi	sp,sp,64
    800040d2:	8082                	ret
    panic("log.committing");
    800040d4:	00004517          	auipc	a0,0x4
    800040d8:	53450513          	addi	a0,a0,1332 # 80008608 <syscalls+0x1e0>
    800040dc:	ffffc097          	auipc	ra,0xffffc
    800040e0:	46c080e7          	jalr	1132(ra) # 80000548 <panic>
    wakeup(&log);
    800040e4:	0001e497          	auipc	s1,0x1e
    800040e8:	82448493          	addi	s1,s1,-2012 # 80021908 <log>
    800040ec:	8526                	mv	a0,s1
    800040ee:	ffffe097          	auipc	ra,0xffffe
    800040f2:	282080e7          	jalr	642(ra) # 80002370 <wakeup>
  release(&log.lock);
    800040f6:	8526                	mv	a0,s1
    800040f8:	ffffd097          	auipc	ra,0xffffd
    800040fc:	bcc080e7          	jalr	-1076(ra) # 80000cc4 <release>
  if(do_commit){
    80004100:	b7c9                	j	800040c2 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004102:	0001ea97          	auipc	s5,0x1e
    80004106:	836a8a93          	addi	s5,s5,-1994 # 80021938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000410a:	0001da17          	auipc	s4,0x1d
    8000410e:	7fea0a13          	addi	s4,s4,2046 # 80021908 <log>
    80004112:	018a2583          	lw	a1,24(s4)
    80004116:	012585bb          	addw	a1,a1,s2
    8000411a:	2585                	addiw	a1,a1,1
    8000411c:	028a2503          	lw	a0,40(s4)
    80004120:	fffff097          	auipc	ra,0xfffff
    80004124:	ce8080e7          	jalr	-792(ra) # 80002e08 <bread>
    80004128:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000412a:	000aa583          	lw	a1,0(s5)
    8000412e:	028a2503          	lw	a0,40(s4)
    80004132:	fffff097          	auipc	ra,0xfffff
    80004136:	cd6080e7          	jalr	-810(ra) # 80002e08 <bread>
    8000413a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000413c:	40000613          	li	a2,1024
    80004140:	05850593          	addi	a1,a0,88
    80004144:	05848513          	addi	a0,s1,88
    80004148:	ffffd097          	auipc	ra,0xffffd
    8000414c:	c24080e7          	jalr	-988(ra) # 80000d6c <memmove>
    bwrite(to);  // write the log
    80004150:	8526                	mv	a0,s1
    80004152:	fffff097          	auipc	ra,0xfffff
    80004156:	da8080e7          	jalr	-600(ra) # 80002efa <bwrite>
    brelse(from);
    8000415a:	854e                	mv	a0,s3
    8000415c:	fffff097          	auipc	ra,0xfffff
    80004160:	ddc080e7          	jalr	-548(ra) # 80002f38 <brelse>
    brelse(to);
    80004164:	8526                	mv	a0,s1
    80004166:	fffff097          	auipc	ra,0xfffff
    8000416a:	dd2080e7          	jalr	-558(ra) # 80002f38 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000416e:	2905                	addiw	s2,s2,1
    80004170:	0a91                	addi	s5,s5,4
    80004172:	02ca2783          	lw	a5,44(s4)
    80004176:	f8f94ee3          	blt	s2,a5,80004112 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000417a:	00000097          	auipc	ra,0x0
    8000417e:	c7a080e7          	jalr	-902(ra) # 80003df4 <write_head>
    install_trans(); // Now install writes to home locations
    80004182:	00000097          	auipc	ra,0x0
    80004186:	cec080e7          	jalr	-788(ra) # 80003e6e <install_trans>
    log.lh.n = 0;
    8000418a:	0001d797          	auipc	a5,0x1d
    8000418e:	7a07a523          	sw	zero,1962(a5) # 80021934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004192:	00000097          	auipc	ra,0x0
    80004196:	c62080e7          	jalr	-926(ra) # 80003df4 <write_head>
    8000419a:	bdfd                	j	80004098 <end_op+0x52>

000000008000419c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000419c:	1101                	addi	sp,sp,-32
    8000419e:	ec06                	sd	ra,24(sp)
    800041a0:	e822                	sd	s0,16(sp)
    800041a2:	e426                	sd	s1,8(sp)
    800041a4:	e04a                	sd	s2,0(sp)
    800041a6:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800041a8:	0001d717          	auipc	a4,0x1d
    800041ac:	78c72703          	lw	a4,1932(a4) # 80021934 <log+0x2c>
    800041b0:	47f5                	li	a5,29
    800041b2:	08e7c063          	blt	a5,a4,80004232 <log_write+0x96>
    800041b6:	84aa                	mv	s1,a0
    800041b8:	0001d797          	auipc	a5,0x1d
    800041bc:	76c7a783          	lw	a5,1900(a5) # 80021924 <log+0x1c>
    800041c0:	37fd                	addiw	a5,a5,-1
    800041c2:	06f75863          	bge	a4,a5,80004232 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800041c6:	0001d797          	auipc	a5,0x1d
    800041ca:	7627a783          	lw	a5,1890(a5) # 80021928 <log+0x20>
    800041ce:	06f05a63          	blez	a5,80004242 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800041d2:	0001d917          	auipc	s2,0x1d
    800041d6:	73690913          	addi	s2,s2,1846 # 80021908 <log>
    800041da:	854a                	mv	a0,s2
    800041dc:	ffffd097          	auipc	ra,0xffffd
    800041e0:	a34080e7          	jalr	-1484(ra) # 80000c10 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800041e4:	02c92603          	lw	a2,44(s2)
    800041e8:	06c05563          	blez	a2,80004252 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800041ec:	44cc                	lw	a1,12(s1)
    800041ee:	0001d717          	auipc	a4,0x1d
    800041f2:	74a70713          	addi	a4,a4,1866 # 80021938 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800041f6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800041f8:	4314                	lw	a3,0(a4)
    800041fa:	04b68d63          	beq	a3,a1,80004254 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800041fe:	2785                	addiw	a5,a5,1
    80004200:	0711                	addi	a4,a4,4
    80004202:	fec79be3          	bne	a5,a2,800041f8 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004206:	0621                	addi	a2,a2,8
    80004208:	060a                	slli	a2,a2,0x2
    8000420a:	0001d797          	auipc	a5,0x1d
    8000420e:	6fe78793          	addi	a5,a5,1790 # 80021908 <log>
    80004212:	963e                	add	a2,a2,a5
    80004214:	44dc                	lw	a5,12(s1)
    80004216:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004218:	8526                	mv	a0,s1
    8000421a:	fffff097          	auipc	ra,0xfffff
    8000421e:	dbc080e7          	jalr	-580(ra) # 80002fd6 <bpin>
    log.lh.n++;
    80004222:	0001d717          	auipc	a4,0x1d
    80004226:	6e670713          	addi	a4,a4,1766 # 80021908 <log>
    8000422a:	575c                	lw	a5,44(a4)
    8000422c:	2785                	addiw	a5,a5,1
    8000422e:	d75c                	sw	a5,44(a4)
    80004230:	a83d                	j	8000426e <log_write+0xd2>
    panic("too big a transaction");
    80004232:	00004517          	auipc	a0,0x4
    80004236:	3e650513          	addi	a0,a0,998 # 80008618 <syscalls+0x1f0>
    8000423a:	ffffc097          	auipc	ra,0xffffc
    8000423e:	30e080e7          	jalr	782(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    80004242:	00004517          	auipc	a0,0x4
    80004246:	3ee50513          	addi	a0,a0,1006 # 80008630 <syscalls+0x208>
    8000424a:	ffffc097          	auipc	ra,0xffffc
    8000424e:	2fe080e7          	jalr	766(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004252:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004254:	00878713          	addi	a4,a5,8
    80004258:	00271693          	slli	a3,a4,0x2
    8000425c:	0001d717          	auipc	a4,0x1d
    80004260:	6ac70713          	addi	a4,a4,1708 # 80021908 <log>
    80004264:	9736                	add	a4,a4,a3
    80004266:	44d4                	lw	a3,12(s1)
    80004268:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000426a:	faf607e3          	beq	a2,a5,80004218 <log_write+0x7c>
  }
  release(&log.lock);
    8000426e:	0001d517          	auipc	a0,0x1d
    80004272:	69a50513          	addi	a0,a0,1690 # 80021908 <log>
    80004276:	ffffd097          	auipc	ra,0xffffd
    8000427a:	a4e080e7          	jalr	-1458(ra) # 80000cc4 <release>
}
    8000427e:	60e2                	ld	ra,24(sp)
    80004280:	6442                	ld	s0,16(sp)
    80004282:	64a2                	ld	s1,8(sp)
    80004284:	6902                	ld	s2,0(sp)
    80004286:	6105                	addi	sp,sp,32
    80004288:	8082                	ret

000000008000428a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000428a:	1101                	addi	sp,sp,-32
    8000428c:	ec06                	sd	ra,24(sp)
    8000428e:	e822                	sd	s0,16(sp)
    80004290:	e426                	sd	s1,8(sp)
    80004292:	e04a                	sd	s2,0(sp)
    80004294:	1000                	addi	s0,sp,32
    80004296:	84aa                	mv	s1,a0
    80004298:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000429a:	00004597          	auipc	a1,0x4
    8000429e:	3b658593          	addi	a1,a1,950 # 80008650 <syscalls+0x228>
    800042a2:	0521                	addi	a0,a0,8
    800042a4:	ffffd097          	auipc	ra,0xffffd
    800042a8:	8dc080e7          	jalr	-1828(ra) # 80000b80 <initlock>
  lk->name = name;
    800042ac:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042b0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042b4:	0204a423          	sw	zero,40(s1)
}
    800042b8:	60e2                	ld	ra,24(sp)
    800042ba:	6442                	ld	s0,16(sp)
    800042bc:	64a2                	ld	s1,8(sp)
    800042be:	6902                	ld	s2,0(sp)
    800042c0:	6105                	addi	sp,sp,32
    800042c2:	8082                	ret

00000000800042c4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800042c4:	1101                	addi	sp,sp,-32
    800042c6:	ec06                	sd	ra,24(sp)
    800042c8:	e822                	sd	s0,16(sp)
    800042ca:	e426                	sd	s1,8(sp)
    800042cc:	e04a                	sd	s2,0(sp)
    800042ce:	1000                	addi	s0,sp,32
    800042d0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042d2:	00850913          	addi	s2,a0,8
    800042d6:	854a                	mv	a0,s2
    800042d8:	ffffd097          	auipc	ra,0xffffd
    800042dc:	938080e7          	jalr	-1736(ra) # 80000c10 <acquire>
  while (lk->locked) {
    800042e0:	409c                	lw	a5,0(s1)
    800042e2:	cb89                	beqz	a5,800042f4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800042e4:	85ca                	mv	a1,s2
    800042e6:	8526                	mv	a0,s1
    800042e8:	ffffe097          	auipc	ra,0xffffe
    800042ec:	f02080e7          	jalr	-254(ra) # 800021ea <sleep>
  while (lk->locked) {
    800042f0:	409c                	lw	a5,0(s1)
    800042f2:	fbed                	bnez	a5,800042e4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800042f4:	4785                	li	a5,1
    800042f6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800042f8:	ffffd097          	auipc	ra,0xffffd
    800042fc:	6e6080e7          	jalr	1766(ra) # 800019de <myproc>
    80004300:	5d1c                	lw	a5,56(a0)
    80004302:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004304:	854a                	mv	a0,s2
    80004306:	ffffd097          	auipc	ra,0xffffd
    8000430a:	9be080e7          	jalr	-1602(ra) # 80000cc4 <release>
}
    8000430e:	60e2                	ld	ra,24(sp)
    80004310:	6442                	ld	s0,16(sp)
    80004312:	64a2                	ld	s1,8(sp)
    80004314:	6902                	ld	s2,0(sp)
    80004316:	6105                	addi	sp,sp,32
    80004318:	8082                	ret

000000008000431a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000431a:	1101                	addi	sp,sp,-32
    8000431c:	ec06                	sd	ra,24(sp)
    8000431e:	e822                	sd	s0,16(sp)
    80004320:	e426                	sd	s1,8(sp)
    80004322:	e04a                	sd	s2,0(sp)
    80004324:	1000                	addi	s0,sp,32
    80004326:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004328:	00850913          	addi	s2,a0,8
    8000432c:	854a                	mv	a0,s2
    8000432e:	ffffd097          	auipc	ra,0xffffd
    80004332:	8e2080e7          	jalr	-1822(ra) # 80000c10 <acquire>
  lk->locked = 0;
    80004336:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000433a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000433e:	8526                	mv	a0,s1
    80004340:	ffffe097          	auipc	ra,0xffffe
    80004344:	030080e7          	jalr	48(ra) # 80002370 <wakeup>
  release(&lk->lk);
    80004348:	854a                	mv	a0,s2
    8000434a:	ffffd097          	auipc	ra,0xffffd
    8000434e:	97a080e7          	jalr	-1670(ra) # 80000cc4 <release>
}
    80004352:	60e2                	ld	ra,24(sp)
    80004354:	6442                	ld	s0,16(sp)
    80004356:	64a2                	ld	s1,8(sp)
    80004358:	6902                	ld	s2,0(sp)
    8000435a:	6105                	addi	sp,sp,32
    8000435c:	8082                	ret

000000008000435e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000435e:	7179                	addi	sp,sp,-48
    80004360:	f406                	sd	ra,40(sp)
    80004362:	f022                	sd	s0,32(sp)
    80004364:	ec26                	sd	s1,24(sp)
    80004366:	e84a                	sd	s2,16(sp)
    80004368:	e44e                	sd	s3,8(sp)
    8000436a:	1800                	addi	s0,sp,48
    8000436c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000436e:	00850913          	addi	s2,a0,8
    80004372:	854a                	mv	a0,s2
    80004374:	ffffd097          	auipc	ra,0xffffd
    80004378:	89c080e7          	jalr	-1892(ra) # 80000c10 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000437c:	409c                	lw	a5,0(s1)
    8000437e:	ef99                	bnez	a5,8000439c <holdingsleep+0x3e>
    80004380:	4481                	li	s1,0
  release(&lk->lk);
    80004382:	854a                	mv	a0,s2
    80004384:	ffffd097          	auipc	ra,0xffffd
    80004388:	940080e7          	jalr	-1728(ra) # 80000cc4 <release>
  return r;
}
    8000438c:	8526                	mv	a0,s1
    8000438e:	70a2                	ld	ra,40(sp)
    80004390:	7402                	ld	s0,32(sp)
    80004392:	64e2                	ld	s1,24(sp)
    80004394:	6942                	ld	s2,16(sp)
    80004396:	69a2                	ld	s3,8(sp)
    80004398:	6145                	addi	sp,sp,48
    8000439a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000439c:	0284a983          	lw	s3,40(s1)
    800043a0:	ffffd097          	auipc	ra,0xffffd
    800043a4:	63e080e7          	jalr	1598(ra) # 800019de <myproc>
    800043a8:	5d04                	lw	s1,56(a0)
    800043aa:	413484b3          	sub	s1,s1,s3
    800043ae:	0014b493          	seqz	s1,s1
    800043b2:	bfc1                	j	80004382 <holdingsleep+0x24>

00000000800043b4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043b4:	1141                	addi	sp,sp,-16
    800043b6:	e406                	sd	ra,8(sp)
    800043b8:	e022                	sd	s0,0(sp)
    800043ba:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043bc:	00004597          	auipc	a1,0x4
    800043c0:	2a458593          	addi	a1,a1,676 # 80008660 <syscalls+0x238>
    800043c4:	0001d517          	auipc	a0,0x1d
    800043c8:	68c50513          	addi	a0,a0,1676 # 80021a50 <ftable>
    800043cc:	ffffc097          	auipc	ra,0xffffc
    800043d0:	7b4080e7          	jalr	1972(ra) # 80000b80 <initlock>
}
    800043d4:	60a2                	ld	ra,8(sp)
    800043d6:	6402                	ld	s0,0(sp)
    800043d8:	0141                	addi	sp,sp,16
    800043da:	8082                	ret

00000000800043dc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800043dc:	1101                	addi	sp,sp,-32
    800043de:	ec06                	sd	ra,24(sp)
    800043e0:	e822                	sd	s0,16(sp)
    800043e2:	e426                	sd	s1,8(sp)
    800043e4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800043e6:	0001d517          	auipc	a0,0x1d
    800043ea:	66a50513          	addi	a0,a0,1642 # 80021a50 <ftable>
    800043ee:	ffffd097          	auipc	ra,0xffffd
    800043f2:	822080e7          	jalr	-2014(ra) # 80000c10 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043f6:	0001d497          	auipc	s1,0x1d
    800043fa:	67248493          	addi	s1,s1,1650 # 80021a68 <ftable+0x18>
    800043fe:	0001e717          	auipc	a4,0x1e
    80004402:	60a70713          	addi	a4,a4,1546 # 80022a08 <ftable+0xfb8>
    if(f->ref == 0){
    80004406:	40dc                	lw	a5,4(s1)
    80004408:	cf99                	beqz	a5,80004426 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000440a:	02848493          	addi	s1,s1,40
    8000440e:	fee49ce3          	bne	s1,a4,80004406 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004412:	0001d517          	auipc	a0,0x1d
    80004416:	63e50513          	addi	a0,a0,1598 # 80021a50 <ftable>
    8000441a:	ffffd097          	auipc	ra,0xffffd
    8000441e:	8aa080e7          	jalr	-1878(ra) # 80000cc4 <release>
  return 0;
    80004422:	4481                	li	s1,0
    80004424:	a819                	j	8000443a <filealloc+0x5e>
      f->ref = 1;
    80004426:	4785                	li	a5,1
    80004428:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000442a:	0001d517          	auipc	a0,0x1d
    8000442e:	62650513          	addi	a0,a0,1574 # 80021a50 <ftable>
    80004432:	ffffd097          	auipc	ra,0xffffd
    80004436:	892080e7          	jalr	-1902(ra) # 80000cc4 <release>
}
    8000443a:	8526                	mv	a0,s1
    8000443c:	60e2                	ld	ra,24(sp)
    8000443e:	6442                	ld	s0,16(sp)
    80004440:	64a2                	ld	s1,8(sp)
    80004442:	6105                	addi	sp,sp,32
    80004444:	8082                	ret

0000000080004446 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004446:	1101                	addi	sp,sp,-32
    80004448:	ec06                	sd	ra,24(sp)
    8000444a:	e822                	sd	s0,16(sp)
    8000444c:	e426                	sd	s1,8(sp)
    8000444e:	1000                	addi	s0,sp,32
    80004450:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004452:	0001d517          	auipc	a0,0x1d
    80004456:	5fe50513          	addi	a0,a0,1534 # 80021a50 <ftable>
    8000445a:	ffffc097          	auipc	ra,0xffffc
    8000445e:	7b6080e7          	jalr	1974(ra) # 80000c10 <acquire>
  if(f->ref < 1)
    80004462:	40dc                	lw	a5,4(s1)
    80004464:	02f05263          	blez	a5,80004488 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004468:	2785                	addiw	a5,a5,1
    8000446a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000446c:	0001d517          	auipc	a0,0x1d
    80004470:	5e450513          	addi	a0,a0,1508 # 80021a50 <ftable>
    80004474:	ffffd097          	auipc	ra,0xffffd
    80004478:	850080e7          	jalr	-1968(ra) # 80000cc4 <release>
  return f;
}
    8000447c:	8526                	mv	a0,s1
    8000447e:	60e2                	ld	ra,24(sp)
    80004480:	6442                	ld	s0,16(sp)
    80004482:	64a2                	ld	s1,8(sp)
    80004484:	6105                	addi	sp,sp,32
    80004486:	8082                	ret
    panic("filedup");
    80004488:	00004517          	auipc	a0,0x4
    8000448c:	1e050513          	addi	a0,a0,480 # 80008668 <syscalls+0x240>
    80004490:	ffffc097          	auipc	ra,0xffffc
    80004494:	0b8080e7          	jalr	184(ra) # 80000548 <panic>

0000000080004498 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004498:	7139                	addi	sp,sp,-64
    8000449a:	fc06                	sd	ra,56(sp)
    8000449c:	f822                	sd	s0,48(sp)
    8000449e:	f426                	sd	s1,40(sp)
    800044a0:	f04a                	sd	s2,32(sp)
    800044a2:	ec4e                	sd	s3,24(sp)
    800044a4:	e852                	sd	s4,16(sp)
    800044a6:	e456                	sd	s5,8(sp)
    800044a8:	0080                	addi	s0,sp,64
    800044aa:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044ac:	0001d517          	auipc	a0,0x1d
    800044b0:	5a450513          	addi	a0,a0,1444 # 80021a50 <ftable>
    800044b4:	ffffc097          	auipc	ra,0xffffc
    800044b8:	75c080e7          	jalr	1884(ra) # 80000c10 <acquire>
  if(f->ref < 1)
    800044bc:	40dc                	lw	a5,4(s1)
    800044be:	06f05163          	blez	a5,80004520 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800044c2:	37fd                	addiw	a5,a5,-1
    800044c4:	0007871b          	sext.w	a4,a5
    800044c8:	c0dc                	sw	a5,4(s1)
    800044ca:	06e04363          	bgtz	a4,80004530 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800044ce:	0004a903          	lw	s2,0(s1)
    800044d2:	0094ca83          	lbu	s5,9(s1)
    800044d6:	0104ba03          	ld	s4,16(s1)
    800044da:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800044de:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800044e2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800044e6:	0001d517          	auipc	a0,0x1d
    800044ea:	56a50513          	addi	a0,a0,1386 # 80021a50 <ftable>
    800044ee:	ffffc097          	auipc	ra,0xffffc
    800044f2:	7d6080e7          	jalr	2006(ra) # 80000cc4 <release>

  if(ff.type == FD_PIPE){
    800044f6:	4785                	li	a5,1
    800044f8:	04f90d63          	beq	s2,a5,80004552 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800044fc:	3979                	addiw	s2,s2,-2
    800044fe:	4785                	li	a5,1
    80004500:	0527e063          	bltu	a5,s2,80004540 <fileclose+0xa8>
    begin_op();
    80004504:	00000097          	auipc	ra,0x0
    80004508:	ac2080e7          	jalr	-1342(ra) # 80003fc6 <begin_op>
    iput(ff.ip);
    8000450c:	854e                	mv	a0,s3
    8000450e:	fffff097          	auipc	ra,0xfffff
    80004512:	2b6080e7          	jalr	694(ra) # 800037c4 <iput>
    end_op();
    80004516:	00000097          	auipc	ra,0x0
    8000451a:	b30080e7          	jalr	-1232(ra) # 80004046 <end_op>
    8000451e:	a00d                	j	80004540 <fileclose+0xa8>
    panic("fileclose");
    80004520:	00004517          	auipc	a0,0x4
    80004524:	15050513          	addi	a0,a0,336 # 80008670 <syscalls+0x248>
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	020080e7          	jalr	32(ra) # 80000548 <panic>
    release(&ftable.lock);
    80004530:	0001d517          	auipc	a0,0x1d
    80004534:	52050513          	addi	a0,a0,1312 # 80021a50 <ftable>
    80004538:	ffffc097          	auipc	ra,0xffffc
    8000453c:	78c080e7          	jalr	1932(ra) # 80000cc4 <release>
  }
}
    80004540:	70e2                	ld	ra,56(sp)
    80004542:	7442                	ld	s0,48(sp)
    80004544:	74a2                	ld	s1,40(sp)
    80004546:	7902                	ld	s2,32(sp)
    80004548:	69e2                	ld	s3,24(sp)
    8000454a:	6a42                	ld	s4,16(sp)
    8000454c:	6aa2                	ld	s5,8(sp)
    8000454e:	6121                	addi	sp,sp,64
    80004550:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004552:	85d6                	mv	a1,s5
    80004554:	8552                	mv	a0,s4
    80004556:	00000097          	auipc	ra,0x0
    8000455a:	372080e7          	jalr	882(ra) # 800048c8 <pipeclose>
    8000455e:	b7cd                	j	80004540 <fileclose+0xa8>

0000000080004560 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004560:	715d                	addi	sp,sp,-80
    80004562:	e486                	sd	ra,72(sp)
    80004564:	e0a2                	sd	s0,64(sp)
    80004566:	fc26                	sd	s1,56(sp)
    80004568:	f84a                	sd	s2,48(sp)
    8000456a:	f44e                	sd	s3,40(sp)
    8000456c:	0880                	addi	s0,sp,80
    8000456e:	84aa                	mv	s1,a0
    80004570:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004572:	ffffd097          	auipc	ra,0xffffd
    80004576:	46c080e7          	jalr	1132(ra) # 800019de <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000457a:	409c                	lw	a5,0(s1)
    8000457c:	37f9                	addiw	a5,a5,-2
    8000457e:	4705                	li	a4,1
    80004580:	04f76763          	bltu	a4,a5,800045ce <filestat+0x6e>
    80004584:	892a                	mv	s2,a0
    ilock(f->ip);
    80004586:	6c88                	ld	a0,24(s1)
    80004588:	fffff097          	auipc	ra,0xfffff
    8000458c:	082080e7          	jalr	130(ra) # 8000360a <ilock>
    stati(f->ip, &st);
    80004590:	fb840593          	addi	a1,s0,-72
    80004594:	6c88                	ld	a0,24(s1)
    80004596:	fffff097          	auipc	ra,0xfffff
    8000459a:	2fe080e7          	jalr	766(ra) # 80003894 <stati>
    iunlock(f->ip);
    8000459e:	6c88                	ld	a0,24(s1)
    800045a0:	fffff097          	auipc	ra,0xfffff
    800045a4:	12c080e7          	jalr	300(ra) # 800036cc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800045a8:	46e1                	li	a3,24
    800045aa:	fb840613          	addi	a2,s0,-72
    800045ae:	85ce                	mv	a1,s3
    800045b0:	05093503          	ld	a0,80(s2)
    800045b4:	ffffd097          	auipc	ra,0xffffd
    800045b8:	11e080e7          	jalr	286(ra) # 800016d2 <copyout>
    800045bc:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800045c0:	60a6                	ld	ra,72(sp)
    800045c2:	6406                	ld	s0,64(sp)
    800045c4:	74e2                	ld	s1,56(sp)
    800045c6:	7942                	ld	s2,48(sp)
    800045c8:	79a2                	ld	s3,40(sp)
    800045ca:	6161                	addi	sp,sp,80
    800045cc:	8082                	ret
  return -1;
    800045ce:	557d                	li	a0,-1
    800045d0:	bfc5                	j	800045c0 <filestat+0x60>

00000000800045d2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800045d2:	7179                	addi	sp,sp,-48
    800045d4:	f406                	sd	ra,40(sp)
    800045d6:	f022                	sd	s0,32(sp)
    800045d8:	ec26                	sd	s1,24(sp)
    800045da:	e84a                	sd	s2,16(sp)
    800045dc:	e44e                	sd	s3,8(sp)
    800045de:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800045e0:	00854783          	lbu	a5,8(a0)
    800045e4:	c3d5                	beqz	a5,80004688 <fileread+0xb6>
    800045e6:	84aa                	mv	s1,a0
    800045e8:	89ae                	mv	s3,a1
    800045ea:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800045ec:	411c                	lw	a5,0(a0)
    800045ee:	4705                	li	a4,1
    800045f0:	04e78963          	beq	a5,a4,80004642 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045f4:	470d                	li	a4,3
    800045f6:	04e78d63          	beq	a5,a4,80004650 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800045fa:	4709                	li	a4,2
    800045fc:	06e79e63          	bne	a5,a4,80004678 <fileread+0xa6>
    ilock(f->ip);
    80004600:	6d08                	ld	a0,24(a0)
    80004602:	fffff097          	auipc	ra,0xfffff
    80004606:	008080e7          	jalr	8(ra) # 8000360a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000460a:	874a                	mv	a4,s2
    8000460c:	5094                	lw	a3,32(s1)
    8000460e:	864e                	mv	a2,s3
    80004610:	4585                	li	a1,1
    80004612:	6c88                	ld	a0,24(s1)
    80004614:	fffff097          	auipc	ra,0xfffff
    80004618:	2aa080e7          	jalr	682(ra) # 800038be <readi>
    8000461c:	892a                	mv	s2,a0
    8000461e:	00a05563          	blez	a0,80004628 <fileread+0x56>
      f->off += r;
    80004622:	509c                	lw	a5,32(s1)
    80004624:	9fa9                	addw	a5,a5,a0
    80004626:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004628:	6c88                	ld	a0,24(s1)
    8000462a:	fffff097          	auipc	ra,0xfffff
    8000462e:	0a2080e7          	jalr	162(ra) # 800036cc <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004632:	854a                	mv	a0,s2
    80004634:	70a2                	ld	ra,40(sp)
    80004636:	7402                	ld	s0,32(sp)
    80004638:	64e2                	ld	s1,24(sp)
    8000463a:	6942                	ld	s2,16(sp)
    8000463c:	69a2                	ld	s3,8(sp)
    8000463e:	6145                	addi	sp,sp,48
    80004640:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004642:	6908                	ld	a0,16(a0)
    80004644:	00000097          	auipc	ra,0x0
    80004648:	418080e7          	jalr	1048(ra) # 80004a5c <piperead>
    8000464c:	892a                	mv	s2,a0
    8000464e:	b7d5                	j	80004632 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004650:	02451783          	lh	a5,36(a0)
    80004654:	03079693          	slli	a3,a5,0x30
    80004658:	92c1                	srli	a3,a3,0x30
    8000465a:	4725                	li	a4,9
    8000465c:	02d76863          	bltu	a4,a3,8000468c <fileread+0xba>
    80004660:	0792                	slli	a5,a5,0x4
    80004662:	0001d717          	auipc	a4,0x1d
    80004666:	34e70713          	addi	a4,a4,846 # 800219b0 <devsw>
    8000466a:	97ba                	add	a5,a5,a4
    8000466c:	639c                	ld	a5,0(a5)
    8000466e:	c38d                	beqz	a5,80004690 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004670:	4505                	li	a0,1
    80004672:	9782                	jalr	a5
    80004674:	892a                	mv	s2,a0
    80004676:	bf75                	j	80004632 <fileread+0x60>
    panic("fileread");
    80004678:	00004517          	auipc	a0,0x4
    8000467c:	00850513          	addi	a0,a0,8 # 80008680 <syscalls+0x258>
    80004680:	ffffc097          	auipc	ra,0xffffc
    80004684:	ec8080e7          	jalr	-312(ra) # 80000548 <panic>
    return -1;
    80004688:	597d                	li	s2,-1
    8000468a:	b765                	j	80004632 <fileread+0x60>
      return -1;
    8000468c:	597d                	li	s2,-1
    8000468e:	b755                	j	80004632 <fileread+0x60>
    80004690:	597d                	li	s2,-1
    80004692:	b745                	j	80004632 <fileread+0x60>

0000000080004694 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004694:	00954783          	lbu	a5,9(a0)
    80004698:	14078563          	beqz	a5,800047e2 <filewrite+0x14e>
{
    8000469c:	715d                	addi	sp,sp,-80
    8000469e:	e486                	sd	ra,72(sp)
    800046a0:	e0a2                	sd	s0,64(sp)
    800046a2:	fc26                	sd	s1,56(sp)
    800046a4:	f84a                	sd	s2,48(sp)
    800046a6:	f44e                	sd	s3,40(sp)
    800046a8:	f052                	sd	s4,32(sp)
    800046aa:	ec56                	sd	s5,24(sp)
    800046ac:	e85a                	sd	s6,16(sp)
    800046ae:	e45e                	sd	s7,8(sp)
    800046b0:	e062                	sd	s8,0(sp)
    800046b2:	0880                	addi	s0,sp,80
    800046b4:	892a                	mv	s2,a0
    800046b6:	8aae                	mv	s5,a1
    800046b8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800046ba:	411c                	lw	a5,0(a0)
    800046bc:	4705                	li	a4,1
    800046be:	02e78263          	beq	a5,a4,800046e2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046c2:	470d                	li	a4,3
    800046c4:	02e78563          	beq	a5,a4,800046ee <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800046c8:	4709                	li	a4,2
    800046ca:	10e79463          	bne	a5,a4,800047d2 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800046ce:	0ec05e63          	blez	a2,800047ca <filewrite+0x136>
    int i = 0;
    800046d2:	4981                	li	s3,0
    800046d4:	6b05                	lui	s6,0x1
    800046d6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800046da:	6b85                	lui	s7,0x1
    800046dc:	c00b8b9b          	addiw	s7,s7,-1024
    800046e0:	a851                	j	80004774 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800046e2:	6908                	ld	a0,16(a0)
    800046e4:	00000097          	auipc	ra,0x0
    800046e8:	254080e7          	jalr	596(ra) # 80004938 <pipewrite>
    800046ec:	a85d                	j	800047a2 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800046ee:	02451783          	lh	a5,36(a0)
    800046f2:	03079693          	slli	a3,a5,0x30
    800046f6:	92c1                	srli	a3,a3,0x30
    800046f8:	4725                	li	a4,9
    800046fa:	0ed76663          	bltu	a4,a3,800047e6 <filewrite+0x152>
    800046fe:	0792                	slli	a5,a5,0x4
    80004700:	0001d717          	auipc	a4,0x1d
    80004704:	2b070713          	addi	a4,a4,688 # 800219b0 <devsw>
    80004708:	97ba                	add	a5,a5,a4
    8000470a:	679c                	ld	a5,8(a5)
    8000470c:	cff9                	beqz	a5,800047ea <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    8000470e:	4505                	li	a0,1
    80004710:	9782                	jalr	a5
    80004712:	a841                	j	800047a2 <filewrite+0x10e>
    80004714:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004718:	00000097          	auipc	ra,0x0
    8000471c:	8ae080e7          	jalr	-1874(ra) # 80003fc6 <begin_op>
      ilock(f->ip);
    80004720:	01893503          	ld	a0,24(s2)
    80004724:	fffff097          	auipc	ra,0xfffff
    80004728:	ee6080e7          	jalr	-282(ra) # 8000360a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000472c:	8762                	mv	a4,s8
    8000472e:	02092683          	lw	a3,32(s2)
    80004732:	01598633          	add	a2,s3,s5
    80004736:	4585                	li	a1,1
    80004738:	01893503          	ld	a0,24(s2)
    8000473c:	fffff097          	auipc	ra,0xfffff
    80004740:	278080e7          	jalr	632(ra) # 800039b4 <writei>
    80004744:	84aa                	mv	s1,a0
    80004746:	02a05f63          	blez	a0,80004784 <filewrite+0xf0>
        f->off += r;
    8000474a:	02092783          	lw	a5,32(s2)
    8000474e:	9fa9                	addw	a5,a5,a0
    80004750:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004754:	01893503          	ld	a0,24(s2)
    80004758:	fffff097          	auipc	ra,0xfffff
    8000475c:	f74080e7          	jalr	-140(ra) # 800036cc <iunlock>
      end_op();
    80004760:	00000097          	auipc	ra,0x0
    80004764:	8e6080e7          	jalr	-1818(ra) # 80004046 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004768:	049c1963          	bne	s8,s1,800047ba <filewrite+0x126>
        panic("short filewrite");
      i += r;
    8000476c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004770:	0349d663          	bge	s3,s4,8000479c <filewrite+0x108>
      int n1 = n - i;
    80004774:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004778:	84be                	mv	s1,a5
    8000477a:	2781                	sext.w	a5,a5
    8000477c:	f8fb5ce3          	bge	s6,a5,80004714 <filewrite+0x80>
    80004780:	84de                	mv	s1,s7
    80004782:	bf49                	j	80004714 <filewrite+0x80>
      iunlock(f->ip);
    80004784:	01893503          	ld	a0,24(s2)
    80004788:	fffff097          	auipc	ra,0xfffff
    8000478c:	f44080e7          	jalr	-188(ra) # 800036cc <iunlock>
      end_op();
    80004790:	00000097          	auipc	ra,0x0
    80004794:	8b6080e7          	jalr	-1866(ra) # 80004046 <end_op>
      if(r < 0)
    80004798:	fc04d8e3          	bgez	s1,80004768 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    8000479c:	8552                	mv	a0,s4
    8000479e:	033a1863          	bne	s4,s3,800047ce <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800047a2:	60a6                	ld	ra,72(sp)
    800047a4:	6406                	ld	s0,64(sp)
    800047a6:	74e2                	ld	s1,56(sp)
    800047a8:	7942                	ld	s2,48(sp)
    800047aa:	79a2                	ld	s3,40(sp)
    800047ac:	7a02                	ld	s4,32(sp)
    800047ae:	6ae2                	ld	s5,24(sp)
    800047b0:	6b42                	ld	s6,16(sp)
    800047b2:	6ba2                	ld	s7,8(sp)
    800047b4:	6c02                	ld	s8,0(sp)
    800047b6:	6161                	addi	sp,sp,80
    800047b8:	8082                	ret
        panic("short filewrite");
    800047ba:	00004517          	auipc	a0,0x4
    800047be:	ed650513          	addi	a0,a0,-298 # 80008690 <syscalls+0x268>
    800047c2:	ffffc097          	auipc	ra,0xffffc
    800047c6:	d86080e7          	jalr	-634(ra) # 80000548 <panic>
    int i = 0;
    800047ca:	4981                	li	s3,0
    800047cc:	bfc1                	j	8000479c <filewrite+0x108>
    ret = (i == n ? n : -1);
    800047ce:	557d                	li	a0,-1
    800047d0:	bfc9                	j	800047a2 <filewrite+0x10e>
    panic("filewrite");
    800047d2:	00004517          	auipc	a0,0x4
    800047d6:	ece50513          	addi	a0,a0,-306 # 800086a0 <syscalls+0x278>
    800047da:	ffffc097          	auipc	ra,0xffffc
    800047de:	d6e080e7          	jalr	-658(ra) # 80000548 <panic>
    return -1;
    800047e2:	557d                	li	a0,-1
}
    800047e4:	8082                	ret
      return -1;
    800047e6:	557d                	li	a0,-1
    800047e8:	bf6d                	j	800047a2 <filewrite+0x10e>
    800047ea:	557d                	li	a0,-1
    800047ec:	bf5d                	j	800047a2 <filewrite+0x10e>

00000000800047ee <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800047ee:	7179                	addi	sp,sp,-48
    800047f0:	f406                	sd	ra,40(sp)
    800047f2:	f022                	sd	s0,32(sp)
    800047f4:	ec26                	sd	s1,24(sp)
    800047f6:	e84a                	sd	s2,16(sp)
    800047f8:	e44e                	sd	s3,8(sp)
    800047fa:	e052                	sd	s4,0(sp)
    800047fc:	1800                	addi	s0,sp,48
    800047fe:	84aa                	mv	s1,a0
    80004800:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004802:	0005b023          	sd	zero,0(a1)
    80004806:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000480a:	00000097          	auipc	ra,0x0
    8000480e:	bd2080e7          	jalr	-1070(ra) # 800043dc <filealloc>
    80004812:	e088                	sd	a0,0(s1)
    80004814:	c551                	beqz	a0,800048a0 <pipealloc+0xb2>
    80004816:	00000097          	auipc	ra,0x0
    8000481a:	bc6080e7          	jalr	-1082(ra) # 800043dc <filealloc>
    8000481e:	00aa3023          	sd	a0,0(s4)
    80004822:	c92d                	beqz	a0,80004894 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004824:	ffffc097          	auipc	ra,0xffffc
    80004828:	2fc080e7          	jalr	764(ra) # 80000b20 <kalloc>
    8000482c:	892a                	mv	s2,a0
    8000482e:	c125                	beqz	a0,8000488e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004830:	4985                	li	s3,1
    80004832:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004836:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000483a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000483e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004842:	00004597          	auipc	a1,0x4
    80004846:	e6e58593          	addi	a1,a1,-402 # 800086b0 <syscalls+0x288>
    8000484a:	ffffc097          	auipc	ra,0xffffc
    8000484e:	336080e7          	jalr	822(ra) # 80000b80 <initlock>
  (*f0)->type = FD_PIPE;
    80004852:	609c                	ld	a5,0(s1)
    80004854:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004858:	609c                	ld	a5,0(s1)
    8000485a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000485e:	609c                	ld	a5,0(s1)
    80004860:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004864:	609c                	ld	a5,0(s1)
    80004866:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000486a:	000a3783          	ld	a5,0(s4)
    8000486e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004872:	000a3783          	ld	a5,0(s4)
    80004876:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000487a:	000a3783          	ld	a5,0(s4)
    8000487e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004882:	000a3783          	ld	a5,0(s4)
    80004886:	0127b823          	sd	s2,16(a5)
  return 0;
    8000488a:	4501                	li	a0,0
    8000488c:	a025                	j	800048b4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000488e:	6088                	ld	a0,0(s1)
    80004890:	e501                	bnez	a0,80004898 <pipealloc+0xaa>
    80004892:	a039                	j	800048a0 <pipealloc+0xb2>
    80004894:	6088                	ld	a0,0(s1)
    80004896:	c51d                	beqz	a0,800048c4 <pipealloc+0xd6>
    fileclose(*f0);
    80004898:	00000097          	auipc	ra,0x0
    8000489c:	c00080e7          	jalr	-1024(ra) # 80004498 <fileclose>
  if(*f1)
    800048a0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048a4:	557d                	li	a0,-1
  if(*f1)
    800048a6:	c799                	beqz	a5,800048b4 <pipealloc+0xc6>
    fileclose(*f1);
    800048a8:	853e                	mv	a0,a5
    800048aa:	00000097          	auipc	ra,0x0
    800048ae:	bee080e7          	jalr	-1042(ra) # 80004498 <fileclose>
  return -1;
    800048b2:	557d                	li	a0,-1
}
    800048b4:	70a2                	ld	ra,40(sp)
    800048b6:	7402                	ld	s0,32(sp)
    800048b8:	64e2                	ld	s1,24(sp)
    800048ba:	6942                	ld	s2,16(sp)
    800048bc:	69a2                	ld	s3,8(sp)
    800048be:	6a02                	ld	s4,0(sp)
    800048c0:	6145                	addi	sp,sp,48
    800048c2:	8082                	ret
  return -1;
    800048c4:	557d                	li	a0,-1
    800048c6:	b7fd                	j	800048b4 <pipealloc+0xc6>

00000000800048c8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048c8:	1101                	addi	sp,sp,-32
    800048ca:	ec06                	sd	ra,24(sp)
    800048cc:	e822                	sd	s0,16(sp)
    800048ce:	e426                	sd	s1,8(sp)
    800048d0:	e04a                	sd	s2,0(sp)
    800048d2:	1000                	addi	s0,sp,32
    800048d4:	84aa                	mv	s1,a0
    800048d6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048d8:	ffffc097          	auipc	ra,0xffffc
    800048dc:	338080e7          	jalr	824(ra) # 80000c10 <acquire>
  if(writable){
    800048e0:	02090d63          	beqz	s2,8000491a <pipeclose+0x52>
    pi->writeopen = 0;
    800048e4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800048e8:	21848513          	addi	a0,s1,536
    800048ec:	ffffe097          	auipc	ra,0xffffe
    800048f0:	a84080e7          	jalr	-1404(ra) # 80002370 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800048f4:	2204b783          	ld	a5,544(s1)
    800048f8:	eb95                	bnez	a5,8000492c <pipeclose+0x64>
    release(&pi->lock);
    800048fa:	8526                	mv	a0,s1
    800048fc:	ffffc097          	auipc	ra,0xffffc
    80004900:	3c8080e7          	jalr	968(ra) # 80000cc4 <release>
    kfree((char*)pi);
    80004904:	8526                	mv	a0,s1
    80004906:	ffffc097          	auipc	ra,0xffffc
    8000490a:	11e080e7          	jalr	286(ra) # 80000a24 <kfree>
  } else
    release(&pi->lock);
}
    8000490e:	60e2                	ld	ra,24(sp)
    80004910:	6442                	ld	s0,16(sp)
    80004912:	64a2                	ld	s1,8(sp)
    80004914:	6902                	ld	s2,0(sp)
    80004916:	6105                	addi	sp,sp,32
    80004918:	8082                	ret
    pi->readopen = 0;
    8000491a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000491e:	21c48513          	addi	a0,s1,540
    80004922:	ffffe097          	auipc	ra,0xffffe
    80004926:	a4e080e7          	jalr	-1458(ra) # 80002370 <wakeup>
    8000492a:	b7e9                	j	800048f4 <pipeclose+0x2c>
    release(&pi->lock);
    8000492c:	8526                	mv	a0,s1
    8000492e:	ffffc097          	auipc	ra,0xffffc
    80004932:	396080e7          	jalr	918(ra) # 80000cc4 <release>
}
    80004936:	bfe1                	j	8000490e <pipeclose+0x46>

0000000080004938 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004938:	7119                	addi	sp,sp,-128
    8000493a:	fc86                	sd	ra,120(sp)
    8000493c:	f8a2                	sd	s0,112(sp)
    8000493e:	f4a6                	sd	s1,104(sp)
    80004940:	f0ca                	sd	s2,96(sp)
    80004942:	ecce                	sd	s3,88(sp)
    80004944:	e8d2                	sd	s4,80(sp)
    80004946:	e4d6                	sd	s5,72(sp)
    80004948:	e0da                	sd	s6,64(sp)
    8000494a:	fc5e                	sd	s7,56(sp)
    8000494c:	f862                	sd	s8,48(sp)
    8000494e:	f466                	sd	s9,40(sp)
    80004950:	f06a                	sd	s10,32(sp)
    80004952:	ec6e                	sd	s11,24(sp)
    80004954:	0100                	addi	s0,sp,128
    80004956:	84aa                	mv	s1,a0
    80004958:	8cae                	mv	s9,a1
    8000495a:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    8000495c:	ffffd097          	auipc	ra,0xffffd
    80004960:	082080e7          	jalr	130(ra) # 800019de <myproc>
    80004964:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004966:	8526                	mv	a0,s1
    80004968:	ffffc097          	auipc	ra,0xffffc
    8000496c:	2a8080e7          	jalr	680(ra) # 80000c10 <acquire>
  for(i = 0; i < n; i++){
    80004970:	0d605963          	blez	s6,80004a42 <pipewrite+0x10a>
    80004974:	89a6                	mv	s3,s1
    80004976:	3b7d                	addiw	s6,s6,-1
    80004978:	1b02                	slli	s6,s6,0x20
    8000497a:	020b5b13          	srli	s6,s6,0x20
    8000497e:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004980:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004984:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004988:	5dfd                	li	s11,-1
    8000498a:	000b8d1b          	sext.w	s10,s7
    8000498e:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004990:	2184a783          	lw	a5,536(s1)
    80004994:	21c4a703          	lw	a4,540(s1)
    80004998:	2007879b          	addiw	a5,a5,512
    8000499c:	02f71b63          	bne	a4,a5,800049d2 <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    800049a0:	2204a783          	lw	a5,544(s1)
    800049a4:	cbad                	beqz	a5,80004a16 <pipewrite+0xde>
    800049a6:	03092783          	lw	a5,48(s2)
    800049aa:	e7b5                	bnez	a5,80004a16 <pipewrite+0xde>
      wakeup(&pi->nread);
    800049ac:	8556                	mv	a0,s5
    800049ae:	ffffe097          	auipc	ra,0xffffe
    800049b2:	9c2080e7          	jalr	-1598(ra) # 80002370 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800049b6:	85ce                	mv	a1,s3
    800049b8:	8552                	mv	a0,s4
    800049ba:	ffffe097          	auipc	ra,0xffffe
    800049be:	830080e7          	jalr	-2000(ra) # 800021ea <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800049c2:	2184a783          	lw	a5,536(s1)
    800049c6:	21c4a703          	lw	a4,540(s1)
    800049ca:	2007879b          	addiw	a5,a5,512
    800049ce:	fcf709e3          	beq	a4,a5,800049a0 <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049d2:	4685                	li	a3,1
    800049d4:	019b8633          	add	a2,s7,s9
    800049d8:	f8f40593          	addi	a1,s0,-113
    800049dc:	05093503          	ld	a0,80(s2)
    800049e0:	ffffd097          	auipc	ra,0xffffd
    800049e4:	d7e080e7          	jalr	-642(ra) # 8000175e <copyin>
    800049e8:	05b50e63          	beq	a0,s11,80004a44 <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800049ec:	21c4a783          	lw	a5,540(s1)
    800049f0:	0017871b          	addiw	a4,a5,1
    800049f4:	20e4ae23          	sw	a4,540(s1)
    800049f8:	1ff7f793          	andi	a5,a5,511
    800049fc:	97a6                	add	a5,a5,s1
    800049fe:	f8f44703          	lbu	a4,-113(s0)
    80004a02:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004a06:	001d0c1b          	addiw	s8,s10,1
    80004a0a:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004a0e:	036b8b63          	beq	s7,s6,80004a44 <pipewrite+0x10c>
    80004a12:	8bbe                	mv	s7,a5
    80004a14:	bf9d                	j	8000498a <pipewrite+0x52>
        release(&pi->lock);
    80004a16:	8526                	mv	a0,s1
    80004a18:	ffffc097          	auipc	ra,0xffffc
    80004a1c:	2ac080e7          	jalr	684(ra) # 80000cc4 <release>
        return -1;
    80004a20:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004a22:	8562                	mv	a0,s8
    80004a24:	70e6                	ld	ra,120(sp)
    80004a26:	7446                	ld	s0,112(sp)
    80004a28:	74a6                	ld	s1,104(sp)
    80004a2a:	7906                	ld	s2,96(sp)
    80004a2c:	69e6                	ld	s3,88(sp)
    80004a2e:	6a46                	ld	s4,80(sp)
    80004a30:	6aa6                	ld	s5,72(sp)
    80004a32:	6b06                	ld	s6,64(sp)
    80004a34:	7be2                	ld	s7,56(sp)
    80004a36:	7c42                	ld	s8,48(sp)
    80004a38:	7ca2                	ld	s9,40(sp)
    80004a3a:	7d02                	ld	s10,32(sp)
    80004a3c:	6de2                	ld	s11,24(sp)
    80004a3e:	6109                	addi	sp,sp,128
    80004a40:	8082                	ret
  for(i = 0; i < n; i++){
    80004a42:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004a44:	21848513          	addi	a0,s1,536
    80004a48:	ffffe097          	auipc	ra,0xffffe
    80004a4c:	928080e7          	jalr	-1752(ra) # 80002370 <wakeup>
  release(&pi->lock);
    80004a50:	8526                	mv	a0,s1
    80004a52:	ffffc097          	auipc	ra,0xffffc
    80004a56:	272080e7          	jalr	626(ra) # 80000cc4 <release>
  return i;
    80004a5a:	b7e1                	j	80004a22 <pipewrite+0xea>

0000000080004a5c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a5c:	715d                	addi	sp,sp,-80
    80004a5e:	e486                	sd	ra,72(sp)
    80004a60:	e0a2                	sd	s0,64(sp)
    80004a62:	fc26                	sd	s1,56(sp)
    80004a64:	f84a                	sd	s2,48(sp)
    80004a66:	f44e                	sd	s3,40(sp)
    80004a68:	f052                	sd	s4,32(sp)
    80004a6a:	ec56                	sd	s5,24(sp)
    80004a6c:	e85a                	sd	s6,16(sp)
    80004a6e:	0880                	addi	s0,sp,80
    80004a70:	84aa                	mv	s1,a0
    80004a72:	892e                	mv	s2,a1
    80004a74:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a76:	ffffd097          	auipc	ra,0xffffd
    80004a7a:	f68080e7          	jalr	-152(ra) # 800019de <myproc>
    80004a7e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004a80:	8b26                	mv	s6,s1
    80004a82:	8526                	mv	a0,s1
    80004a84:	ffffc097          	auipc	ra,0xffffc
    80004a88:	18c080e7          	jalr	396(ra) # 80000c10 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a8c:	2184a703          	lw	a4,536(s1)
    80004a90:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a94:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a98:	02f71463          	bne	a4,a5,80004ac0 <piperead+0x64>
    80004a9c:	2244a783          	lw	a5,548(s1)
    80004aa0:	c385                	beqz	a5,80004ac0 <piperead+0x64>
    if(pr->killed){
    80004aa2:	030a2783          	lw	a5,48(s4)
    80004aa6:	ebc1                	bnez	a5,80004b36 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004aa8:	85da                	mv	a1,s6
    80004aaa:	854e                	mv	a0,s3
    80004aac:	ffffd097          	auipc	ra,0xffffd
    80004ab0:	73e080e7          	jalr	1854(ra) # 800021ea <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ab4:	2184a703          	lw	a4,536(s1)
    80004ab8:	21c4a783          	lw	a5,540(s1)
    80004abc:	fef700e3          	beq	a4,a5,80004a9c <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ac0:	09505263          	blez	s5,80004b44 <piperead+0xe8>
    80004ac4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ac6:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004ac8:	2184a783          	lw	a5,536(s1)
    80004acc:	21c4a703          	lw	a4,540(s1)
    80004ad0:	02f70d63          	beq	a4,a5,80004b0a <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ad4:	0017871b          	addiw	a4,a5,1
    80004ad8:	20e4ac23          	sw	a4,536(s1)
    80004adc:	1ff7f793          	andi	a5,a5,511
    80004ae0:	97a6                	add	a5,a5,s1
    80004ae2:	0187c783          	lbu	a5,24(a5)
    80004ae6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004aea:	4685                	li	a3,1
    80004aec:	fbf40613          	addi	a2,s0,-65
    80004af0:	85ca                	mv	a1,s2
    80004af2:	050a3503          	ld	a0,80(s4)
    80004af6:	ffffd097          	auipc	ra,0xffffd
    80004afa:	bdc080e7          	jalr	-1060(ra) # 800016d2 <copyout>
    80004afe:	01650663          	beq	a0,s6,80004b0a <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b02:	2985                	addiw	s3,s3,1
    80004b04:	0905                	addi	s2,s2,1
    80004b06:	fd3a91e3          	bne	s5,s3,80004ac8 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b0a:	21c48513          	addi	a0,s1,540
    80004b0e:	ffffe097          	auipc	ra,0xffffe
    80004b12:	862080e7          	jalr	-1950(ra) # 80002370 <wakeup>
  release(&pi->lock);
    80004b16:	8526                	mv	a0,s1
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	1ac080e7          	jalr	428(ra) # 80000cc4 <release>
  return i;
}
    80004b20:	854e                	mv	a0,s3
    80004b22:	60a6                	ld	ra,72(sp)
    80004b24:	6406                	ld	s0,64(sp)
    80004b26:	74e2                	ld	s1,56(sp)
    80004b28:	7942                	ld	s2,48(sp)
    80004b2a:	79a2                	ld	s3,40(sp)
    80004b2c:	7a02                	ld	s4,32(sp)
    80004b2e:	6ae2                	ld	s5,24(sp)
    80004b30:	6b42                	ld	s6,16(sp)
    80004b32:	6161                	addi	sp,sp,80
    80004b34:	8082                	ret
      release(&pi->lock);
    80004b36:	8526                	mv	a0,s1
    80004b38:	ffffc097          	auipc	ra,0xffffc
    80004b3c:	18c080e7          	jalr	396(ra) # 80000cc4 <release>
      return -1;
    80004b40:	59fd                	li	s3,-1
    80004b42:	bff9                	j	80004b20 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b44:	4981                	li	s3,0
    80004b46:	b7d1                	j	80004b0a <piperead+0xae>

0000000080004b48 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004b48:	df010113          	addi	sp,sp,-528
    80004b4c:	20113423          	sd	ra,520(sp)
    80004b50:	20813023          	sd	s0,512(sp)
    80004b54:	ffa6                	sd	s1,504(sp)
    80004b56:	fbca                	sd	s2,496(sp)
    80004b58:	f7ce                	sd	s3,488(sp)
    80004b5a:	f3d2                	sd	s4,480(sp)
    80004b5c:	efd6                	sd	s5,472(sp)
    80004b5e:	ebda                	sd	s6,464(sp)
    80004b60:	e7de                	sd	s7,456(sp)
    80004b62:	e3e2                	sd	s8,448(sp)
    80004b64:	ff66                	sd	s9,440(sp)
    80004b66:	fb6a                	sd	s10,432(sp)
    80004b68:	f76e                	sd	s11,424(sp)
    80004b6a:	0c00                	addi	s0,sp,528
    80004b6c:	84aa                	mv	s1,a0
    80004b6e:	dea43c23          	sd	a0,-520(s0)
    80004b72:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b76:	ffffd097          	auipc	ra,0xffffd
    80004b7a:	e68080e7          	jalr	-408(ra) # 800019de <myproc>
    80004b7e:	892a                	mv	s2,a0

  begin_op();
    80004b80:	fffff097          	auipc	ra,0xfffff
    80004b84:	446080e7          	jalr	1094(ra) # 80003fc6 <begin_op>

  if((ip = namei(path)) == 0){
    80004b88:	8526                	mv	a0,s1
    80004b8a:	fffff097          	auipc	ra,0xfffff
    80004b8e:	230080e7          	jalr	560(ra) # 80003dba <namei>
    80004b92:	c92d                	beqz	a0,80004c04 <exec+0xbc>
    80004b94:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004b96:	fffff097          	auipc	ra,0xfffff
    80004b9a:	a74080e7          	jalr	-1420(ra) # 8000360a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004b9e:	04000713          	li	a4,64
    80004ba2:	4681                	li	a3,0
    80004ba4:	e4840613          	addi	a2,s0,-440
    80004ba8:	4581                	li	a1,0
    80004baa:	8526                	mv	a0,s1
    80004bac:	fffff097          	auipc	ra,0xfffff
    80004bb0:	d12080e7          	jalr	-750(ra) # 800038be <readi>
    80004bb4:	04000793          	li	a5,64
    80004bb8:	00f51a63          	bne	a0,a5,80004bcc <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004bbc:	e4842703          	lw	a4,-440(s0)
    80004bc0:	464c47b7          	lui	a5,0x464c4
    80004bc4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004bc8:	04f70463          	beq	a4,a5,80004c10 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004bcc:	8526                	mv	a0,s1
    80004bce:	fffff097          	auipc	ra,0xfffff
    80004bd2:	c9e080e7          	jalr	-866(ra) # 8000386c <iunlockput>
    end_op();
    80004bd6:	fffff097          	auipc	ra,0xfffff
    80004bda:	470080e7          	jalr	1136(ra) # 80004046 <end_op>
  }
  return -1;
    80004bde:	557d                	li	a0,-1
}
    80004be0:	20813083          	ld	ra,520(sp)
    80004be4:	20013403          	ld	s0,512(sp)
    80004be8:	74fe                	ld	s1,504(sp)
    80004bea:	795e                	ld	s2,496(sp)
    80004bec:	79be                	ld	s3,488(sp)
    80004bee:	7a1e                	ld	s4,480(sp)
    80004bf0:	6afe                	ld	s5,472(sp)
    80004bf2:	6b5e                	ld	s6,464(sp)
    80004bf4:	6bbe                	ld	s7,456(sp)
    80004bf6:	6c1e                	ld	s8,448(sp)
    80004bf8:	7cfa                	ld	s9,440(sp)
    80004bfa:	7d5a                	ld	s10,432(sp)
    80004bfc:	7dba                	ld	s11,424(sp)
    80004bfe:	21010113          	addi	sp,sp,528
    80004c02:	8082                	ret
    end_op();
    80004c04:	fffff097          	auipc	ra,0xfffff
    80004c08:	442080e7          	jalr	1090(ra) # 80004046 <end_op>
    return -1;
    80004c0c:	557d                	li	a0,-1
    80004c0e:	bfc9                	j	80004be0 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c10:	854a                	mv	a0,s2
    80004c12:	ffffd097          	auipc	ra,0xffffd
    80004c16:	e90080e7          	jalr	-368(ra) # 80001aa2 <proc_pagetable>
    80004c1a:	8baa                	mv	s7,a0
    80004c1c:	d945                	beqz	a0,80004bcc <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c1e:	e6842983          	lw	s3,-408(s0)
    80004c22:	e8045783          	lhu	a5,-384(s0)
    80004c26:	c7ad                	beqz	a5,80004c90 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004c28:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c2a:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004c2c:	6c85                	lui	s9,0x1
    80004c2e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c32:	def43823          	sd	a5,-528(s0)
    80004c36:	a42d                	j	80004e60 <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004c38:	00004517          	auipc	a0,0x4
    80004c3c:	a8050513          	addi	a0,a0,-1408 # 800086b8 <syscalls+0x290>
    80004c40:	ffffc097          	auipc	ra,0xffffc
    80004c44:	908080e7          	jalr	-1784(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c48:	8756                	mv	a4,s5
    80004c4a:	012d86bb          	addw	a3,s11,s2
    80004c4e:	4581                	li	a1,0
    80004c50:	8526                	mv	a0,s1
    80004c52:	fffff097          	auipc	ra,0xfffff
    80004c56:	c6c080e7          	jalr	-916(ra) # 800038be <readi>
    80004c5a:	2501                	sext.w	a0,a0
    80004c5c:	1aaa9963          	bne	s5,a0,80004e0e <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004c60:	6785                	lui	a5,0x1
    80004c62:	0127893b          	addw	s2,a5,s2
    80004c66:	77fd                	lui	a5,0xfffff
    80004c68:	01478a3b          	addw	s4,a5,s4
    80004c6c:	1f897163          	bgeu	s2,s8,80004e4e <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004c70:	02091593          	slli	a1,s2,0x20
    80004c74:	9181                	srli	a1,a1,0x20
    80004c76:	95ea                	add	a1,a1,s10
    80004c78:	855e                	mv	a0,s7
    80004c7a:	ffffc097          	auipc	ra,0xffffc
    80004c7e:	424080e7          	jalr	1060(ra) # 8000109e <walkaddr>
    80004c82:	862a                	mv	a2,a0
    if(pa == 0)
    80004c84:	d955                	beqz	a0,80004c38 <exec+0xf0>
      n = PGSIZE;
    80004c86:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004c88:	fd9a70e3          	bgeu	s4,s9,80004c48 <exec+0x100>
      n = sz - i;
    80004c8c:	8ad2                	mv	s5,s4
    80004c8e:	bf6d                	j	80004c48 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004c90:	4901                	li	s2,0
  iunlockput(ip);
    80004c92:	8526                	mv	a0,s1
    80004c94:	fffff097          	auipc	ra,0xfffff
    80004c98:	bd8080e7          	jalr	-1064(ra) # 8000386c <iunlockput>
  end_op();
    80004c9c:	fffff097          	auipc	ra,0xfffff
    80004ca0:	3aa080e7          	jalr	938(ra) # 80004046 <end_op>
  p = myproc();
    80004ca4:	ffffd097          	auipc	ra,0xffffd
    80004ca8:	d3a080e7          	jalr	-710(ra) # 800019de <myproc>
    80004cac:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004cae:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004cb2:	6785                	lui	a5,0x1
    80004cb4:	17fd                	addi	a5,a5,-1
    80004cb6:	993e                	add	s2,s2,a5
    80004cb8:	757d                	lui	a0,0xfffff
    80004cba:	00a977b3          	and	a5,s2,a0
    80004cbe:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004cc2:	6609                	lui	a2,0x2
    80004cc4:	963e                	add	a2,a2,a5
    80004cc6:	85be                	mv	a1,a5
    80004cc8:	855e                	mv	a0,s7
    80004cca:	ffffc097          	auipc	ra,0xffffc
    80004cce:	7b8080e7          	jalr	1976(ra) # 80001482 <uvmalloc>
    80004cd2:	8b2a                	mv	s6,a0
  ip = 0;
    80004cd4:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004cd6:	12050c63          	beqz	a0,80004e0e <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004cda:	75f9                	lui	a1,0xffffe
    80004cdc:	95aa                	add	a1,a1,a0
    80004cde:	855e                	mv	a0,s7
    80004ce0:	ffffd097          	auipc	ra,0xffffd
    80004ce4:	9c0080e7          	jalr	-1600(ra) # 800016a0 <uvmclear>
  stackbase = sp - PGSIZE;
    80004ce8:	7c7d                	lui	s8,0xfffff
    80004cea:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004cec:	e0043783          	ld	a5,-512(s0)
    80004cf0:	6388                	ld	a0,0(a5)
    80004cf2:	c535                	beqz	a0,80004d5e <exec+0x216>
    80004cf4:	e8840993          	addi	s3,s0,-376
    80004cf8:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004cfc:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004cfe:	ffffc097          	auipc	ra,0xffffc
    80004d02:	196080e7          	jalr	406(ra) # 80000e94 <strlen>
    80004d06:	2505                	addiw	a0,a0,1
    80004d08:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d0c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004d10:	13896363          	bltu	s2,s8,80004e36 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d14:	e0043d83          	ld	s11,-512(s0)
    80004d18:	000dba03          	ld	s4,0(s11)
    80004d1c:	8552                	mv	a0,s4
    80004d1e:	ffffc097          	auipc	ra,0xffffc
    80004d22:	176080e7          	jalr	374(ra) # 80000e94 <strlen>
    80004d26:	0015069b          	addiw	a3,a0,1
    80004d2a:	8652                	mv	a2,s4
    80004d2c:	85ca                	mv	a1,s2
    80004d2e:	855e                	mv	a0,s7
    80004d30:	ffffd097          	auipc	ra,0xffffd
    80004d34:	9a2080e7          	jalr	-1630(ra) # 800016d2 <copyout>
    80004d38:	10054363          	bltz	a0,80004e3e <exec+0x2f6>
    ustack[argc] = sp;
    80004d3c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004d40:	0485                	addi	s1,s1,1
    80004d42:	008d8793          	addi	a5,s11,8
    80004d46:	e0f43023          	sd	a5,-512(s0)
    80004d4a:	008db503          	ld	a0,8(s11)
    80004d4e:	c911                	beqz	a0,80004d62 <exec+0x21a>
    if(argc >= MAXARG)
    80004d50:	09a1                	addi	s3,s3,8
    80004d52:	fb3c96e3          	bne	s9,s3,80004cfe <exec+0x1b6>
  sz = sz1;
    80004d56:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004d5a:	4481                	li	s1,0
    80004d5c:	a84d                	j	80004e0e <exec+0x2c6>
  sp = sz;
    80004d5e:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004d60:	4481                	li	s1,0
  ustack[argc] = 0;
    80004d62:	00349793          	slli	a5,s1,0x3
    80004d66:	f9040713          	addi	a4,s0,-112
    80004d6a:	97ba                	add	a5,a5,a4
    80004d6c:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80004d70:	00148693          	addi	a3,s1,1
    80004d74:	068e                	slli	a3,a3,0x3
    80004d76:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004d7a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004d7e:	01897663          	bgeu	s2,s8,80004d8a <exec+0x242>
  sz = sz1;
    80004d82:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004d86:	4481                	li	s1,0
    80004d88:	a059                	j	80004e0e <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004d8a:	e8840613          	addi	a2,s0,-376
    80004d8e:	85ca                	mv	a1,s2
    80004d90:	855e                	mv	a0,s7
    80004d92:	ffffd097          	auipc	ra,0xffffd
    80004d96:	940080e7          	jalr	-1728(ra) # 800016d2 <copyout>
    80004d9a:	0a054663          	bltz	a0,80004e46 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004d9e:	058ab783          	ld	a5,88(s5)
    80004da2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004da6:	df843783          	ld	a5,-520(s0)
    80004daa:	0007c703          	lbu	a4,0(a5)
    80004dae:	cf11                	beqz	a4,80004dca <exec+0x282>
    80004db0:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004db2:	02f00693          	li	a3,47
    80004db6:	a029                	j	80004dc0 <exec+0x278>
  for(last=s=path; *s; s++)
    80004db8:	0785                	addi	a5,a5,1
    80004dba:	fff7c703          	lbu	a4,-1(a5)
    80004dbe:	c711                	beqz	a4,80004dca <exec+0x282>
    if(*s == '/')
    80004dc0:	fed71ce3          	bne	a4,a3,80004db8 <exec+0x270>
      last = s+1;
    80004dc4:	def43c23          	sd	a5,-520(s0)
    80004dc8:	bfc5                	j	80004db8 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004dca:	4641                	li	a2,16
    80004dcc:	df843583          	ld	a1,-520(s0)
    80004dd0:	158a8513          	addi	a0,s5,344
    80004dd4:	ffffc097          	auipc	ra,0xffffc
    80004dd8:	08e080e7          	jalr	142(ra) # 80000e62 <safestrcpy>
  oldpagetable = p->pagetable;
    80004ddc:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004de0:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004de4:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004de8:	058ab783          	ld	a5,88(s5)
    80004dec:	e6043703          	ld	a4,-416(s0)
    80004df0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004df2:	058ab783          	ld	a5,88(s5)
    80004df6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004dfa:	85ea                	mv	a1,s10
    80004dfc:	ffffd097          	auipc	ra,0xffffd
    80004e00:	d42080e7          	jalr	-702(ra) # 80001b3e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e04:	0004851b          	sext.w	a0,s1
    80004e08:	bbe1                	j	80004be0 <exec+0x98>
    80004e0a:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004e0e:	e0843583          	ld	a1,-504(s0)
    80004e12:	855e                	mv	a0,s7
    80004e14:	ffffd097          	auipc	ra,0xffffd
    80004e18:	d2a080e7          	jalr	-726(ra) # 80001b3e <proc_freepagetable>
  if(ip){
    80004e1c:	da0498e3          	bnez	s1,80004bcc <exec+0x84>
  return -1;
    80004e20:	557d                	li	a0,-1
    80004e22:	bb7d                	j	80004be0 <exec+0x98>
    80004e24:	e1243423          	sd	s2,-504(s0)
    80004e28:	b7dd                	j	80004e0e <exec+0x2c6>
    80004e2a:	e1243423          	sd	s2,-504(s0)
    80004e2e:	b7c5                	j	80004e0e <exec+0x2c6>
    80004e30:	e1243423          	sd	s2,-504(s0)
    80004e34:	bfe9                	j	80004e0e <exec+0x2c6>
  sz = sz1;
    80004e36:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004e3a:	4481                	li	s1,0
    80004e3c:	bfc9                	j	80004e0e <exec+0x2c6>
  sz = sz1;
    80004e3e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004e42:	4481                	li	s1,0
    80004e44:	b7e9                	j	80004e0e <exec+0x2c6>
  sz = sz1;
    80004e46:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004e4a:	4481                	li	s1,0
    80004e4c:	b7c9                	j	80004e0e <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004e4e:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e52:	2b05                	addiw	s6,s6,1
    80004e54:	0389899b          	addiw	s3,s3,56
    80004e58:	e8045783          	lhu	a5,-384(s0)
    80004e5c:	e2fb5be3          	bge	s6,a5,80004c92 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e60:	2981                	sext.w	s3,s3
    80004e62:	03800713          	li	a4,56
    80004e66:	86ce                	mv	a3,s3
    80004e68:	e1040613          	addi	a2,s0,-496
    80004e6c:	4581                	li	a1,0
    80004e6e:	8526                	mv	a0,s1
    80004e70:	fffff097          	auipc	ra,0xfffff
    80004e74:	a4e080e7          	jalr	-1458(ra) # 800038be <readi>
    80004e78:	03800793          	li	a5,56
    80004e7c:	f8f517e3          	bne	a0,a5,80004e0a <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80004e80:	e1042783          	lw	a5,-496(s0)
    80004e84:	4705                	li	a4,1
    80004e86:	fce796e3          	bne	a5,a4,80004e52 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80004e8a:	e3843603          	ld	a2,-456(s0)
    80004e8e:	e3043783          	ld	a5,-464(s0)
    80004e92:	f8f669e3          	bltu	a2,a5,80004e24 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004e96:	e2043783          	ld	a5,-480(s0)
    80004e9a:	963e                	add	a2,a2,a5
    80004e9c:	f8f667e3          	bltu	a2,a5,80004e2a <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004ea0:	85ca                	mv	a1,s2
    80004ea2:	855e                	mv	a0,s7
    80004ea4:	ffffc097          	auipc	ra,0xffffc
    80004ea8:	5de080e7          	jalr	1502(ra) # 80001482 <uvmalloc>
    80004eac:	e0a43423          	sd	a0,-504(s0)
    80004eb0:	d141                	beqz	a0,80004e30 <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    80004eb2:	e2043d03          	ld	s10,-480(s0)
    80004eb6:	df043783          	ld	a5,-528(s0)
    80004eba:	00fd77b3          	and	a5,s10,a5
    80004ebe:	fba1                	bnez	a5,80004e0e <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ec0:	e1842d83          	lw	s11,-488(s0)
    80004ec4:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ec8:	f80c03e3          	beqz	s8,80004e4e <exec+0x306>
    80004ecc:	8a62                	mv	s4,s8
    80004ece:	4901                	li	s2,0
    80004ed0:	b345                	j	80004c70 <exec+0x128>

0000000080004ed2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ed2:	7179                	addi	sp,sp,-48
    80004ed4:	f406                	sd	ra,40(sp)
    80004ed6:	f022                	sd	s0,32(sp)
    80004ed8:	ec26                	sd	s1,24(sp)
    80004eda:	e84a                	sd	s2,16(sp)
    80004edc:	1800                	addi	s0,sp,48
    80004ede:	892e                	mv	s2,a1
    80004ee0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004ee2:	fdc40593          	addi	a1,s0,-36
    80004ee6:	ffffe097          	auipc	ra,0xffffe
    80004eea:	bb2080e7          	jalr	-1102(ra) # 80002a98 <argint>
    80004eee:	04054063          	bltz	a0,80004f2e <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ef2:	fdc42703          	lw	a4,-36(s0)
    80004ef6:	47bd                	li	a5,15
    80004ef8:	02e7ed63          	bltu	a5,a4,80004f32 <argfd+0x60>
    80004efc:	ffffd097          	auipc	ra,0xffffd
    80004f00:	ae2080e7          	jalr	-1310(ra) # 800019de <myproc>
    80004f04:	fdc42703          	lw	a4,-36(s0)
    80004f08:	01a70793          	addi	a5,a4,26
    80004f0c:	078e                	slli	a5,a5,0x3
    80004f0e:	953e                	add	a0,a0,a5
    80004f10:	611c                	ld	a5,0(a0)
    80004f12:	c395                	beqz	a5,80004f36 <argfd+0x64>
    return -1;
  if(pfd)
    80004f14:	00090463          	beqz	s2,80004f1c <argfd+0x4a>
    *pfd = fd;
    80004f18:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f1c:	4501                	li	a0,0
  if(pf)
    80004f1e:	c091                	beqz	s1,80004f22 <argfd+0x50>
    *pf = f;
    80004f20:	e09c                	sd	a5,0(s1)
}
    80004f22:	70a2                	ld	ra,40(sp)
    80004f24:	7402                	ld	s0,32(sp)
    80004f26:	64e2                	ld	s1,24(sp)
    80004f28:	6942                	ld	s2,16(sp)
    80004f2a:	6145                	addi	sp,sp,48
    80004f2c:	8082                	ret
    return -1;
    80004f2e:	557d                	li	a0,-1
    80004f30:	bfcd                	j	80004f22 <argfd+0x50>
    return -1;
    80004f32:	557d                	li	a0,-1
    80004f34:	b7fd                	j	80004f22 <argfd+0x50>
    80004f36:	557d                	li	a0,-1
    80004f38:	b7ed                	j	80004f22 <argfd+0x50>

0000000080004f3a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f3a:	1101                	addi	sp,sp,-32
    80004f3c:	ec06                	sd	ra,24(sp)
    80004f3e:	e822                	sd	s0,16(sp)
    80004f40:	e426                	sd	s1,8(sp)
    80004f42:	1000                	addi	s0,sp,32
    80004f44:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f46:	ffffd097          	auipc	ra,0xffffd
    80004f4a:	a98080e7          	jalr	-1384(ra) # 800019de <myproc>
    80004f4e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f50:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    80004f54:	4501                	li	a0,0
    80004f56:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f58:	6398                	ld	a4,0(a5)
    80004f5a:	cb19                	beqz	a4,80004f70 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f5c:	2505                	addiw	a0,a0,1
    80004f5e:	07a1                	addi	a5,a5,8
    80004f60:	fed51ce3          	bne	a0,a3,80004f58 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f64:	557d                	li	a0,-1
}
    80004f66:	60e2                	ld	ra,24(sp)
    80004f68:	6442                	ld	s0,16(sp)
    80004f6a:	64a2                	ld	s1,8(sp)
    80004f6c:	6105                	addi	sp,sp,32
    80004f6e:	8082                	ret
      p->ofile[fd] = f;
    80004f70:	01a50793          	addi	a5,a0,26
    80004f74:	078e                	slli	a5,a5,0x3
    80004f76:	963e                	add	a2,a2,a5
    80004f78:	e204                	sd	s1,0(a2)
      return fd;
    80004f7a:	b7f5                	j	80004f66 <fdalloc+0x2c>

0000000080004f7c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004f7c:	715d                	addi	sp,sp,-80
    80004f7e:	e486                	sd	ra,72(sp)
    80004f80:	e0a2                	sd	s0,64(sp)
    80004f82:	fc26                	sd	s1,56(sp)
    80004f84:	f84a                	sd	s2,48(sp)
    80004f86:	f44e                	sd	s3,40(sp)
    80004f88:	f052                	sd	s4,32(sp)
    80004f8a:	ec56                	sd	s5,24(sp)
    80004f8c:	0880                	addi	s0,sp,80
    80004f8e:	89ae                	mv	s3,a1
    80004f90:	8ab2                	mv	s5,a2
    80004f92:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004f94:	fb040593          	addi	a1,s0,-80
    80004f98:	fffff097          	auipc	ra,0xfffff
    80004f9c:	e40080e7          	jalr	-448(ra) # 80003dd8 <nameiparent>
    80004fa0:	892a                	mv	s2,a0
    80004fa2:	12050f63          	beqz	a0,800050e0 <create+0x164>
    return 0;

  ilock(dp);
    80004fa6:	ffffe097          	auipc	ra,0xffffe
    80004faa:	664080e7          	jalr	1636(ra) # 8000360a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004fae:	4601                	li	a2,0
    80004fb0:	fb040593          	addi	a1,s0,-80
    80004fb4:	854a                	mv	a0,s2
    80004fb6:	fffff097          	auipc	ra,0xfffff
    80004fba:	b32080e7          	jalr	-1230(ra) # 80003ae8 <dirlookup>
    80004fbe:	84aa                	mv	s1,a0
    80004fc0:	c921                	beqz	a0,80005010 <create+0x94>
    iunlockput(dp);
    80004fc2:	854a                	mv	a0,s2
    80004fc4:	fffff097          	auipc	ra,0xfffff
    80004fc8:	8a8080e7          	jalr	-1880(ra) # 8000386c <iunlockput>
    ilock(ip);
    80004fcc:	8526                	mv	a0,s1
    80004fce:	ffffe097          	auipc	ra,0xffffe
    80004fd2:	63c080e7          	jalr	1596(ra) # 8000360a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004fd6:	2981                	sext.w	s3,s3
    80004fd8:	4789                	li	a5,2
    80004fda:	02f99463          	bne	s3,a5,80005002 <create+0x86>
    80004fde:	0444d783          	lhu	a5,68(s1)
    80004fe2:	37f9                	addiw	a5,a5,-2
    80004fe4:	17c2                	slli	a5,a5,0x30
    80004fe6:	93c1                	srli	a5,a5,0x30
    80004fe8:	4705                	li	a4,1
    80004fea:	00f76c63          	bltu	a4,a5,80005002 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004fee:	8526                	mv	a0,s1
    80004ff0:	60a6                	ld	ra,72(sp)
    80004ff2:	6406                	ld	s0,64(sp)
    80004ff4:	74e2                	ld	s1,56(sp)
    80004ff6:	7942                	ld	s2,48(sp)
    80004ff8:	79a2                	ld	s3,40(sp)
    80004ffa:	7a02                	ld	s4,32(sp)
    80004ffc:	6ae2                	ld	s5,24(sp)
    80004ffe:	6161                	addi	sp,sp,80
    80005000:	8082                	ret
    iunlockput(ip);
    80005002:	8526                	mv	a0,s1
    80005004:	fffff097          	auipc	ra,0xfffff
    80005008:	868080e7          	jalr	-1944(ra) # 8000386c <iunlockput>
    return 0;
    8000500c:	4481                	li	s1,0
    8000500e:	b7c5                	j	80004fee <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005010:	85ce                	mv	a1,s3
    80005012:	00092503          	lw	a0,0(s2)
    80005016:	ffffe097          	auipc	ra,0xffffe
    8000501a:	45c080e7          	jalr	1116(ra) # 80003472 <ialloc>
    8000501e:	84aa                	mv	s1,a0
    80005020:	c529                	beqz	a0,8000506a <create+0xee>
  ilock(ip);
    80005022:	ffffe097          	auipc	ra,0xffffe
    80005026:	5e8080e7          	jalr	1512(ra) # 8000360a <ilock>
  ip->major = major;
    8000502a:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000502e:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005032:	4785                	li	a5,1
    80005034:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005038:	8526                	mv	a0,s1
    8000503a:	ffffe097          	auipc	ra,0xffffe
    8000503e:	506080e7          	jalr	1286(ra) # 80003540 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005042:	2981                	sext.w	s3,s3
    80005044:	4785                	li	a5,1
    80005046:	02f98a63          	beq	s3,a5,8000507a <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    8000504a:	40d0                	lw	a2,4(s1)
    8000504c:	fb040593          	addi	a1,s0,-80
    80005050:	854a                	mv	a0,s2
    80005052:	fffff097          	auipc	ra,0xfffff
    80005056:	ca6080e7          	jalr	-858(ra) # 80003cf8 <dirlink>
    8000505a:	06054b63          	bltz	a0,800050d0 <create+0x154>
  iunlockput(dp);
    8000505e:	854a                	mv	a0,s2
    80005060:	fffff097          	auipc	ra,0xfffff
    80005064:	80c080e7          	jalr	-2036(ra) # 8000386c <iunlockput>
  return ip;
    80005068:	b759                	j	80004fee <create+0x72>
    panic("create: ialloc");
    8000506a:	00003517          	auipc	a0,0x3
    8000506e:	66e50513          	addi	a0,a0,1646 # 800086d8 <syscalls+0x2b0>
    80005072:	ffffb097          	auipc	ra,0xffffb
    80005076:	4d6080e7          	jalr	1238(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    8000507a:	04a95783          	lhu	a5,74(s2)
    8000507e:	2785                	addiw	a5,a5,1
    80005080:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005084:	854a                	mv	a0,s2
    80005086:	ffffe097          	auipc	ra,0xffffe
    8000508a:	4ba080e7          	jalr	1210(ra) # 80003540 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000508e:	40d0                	lw	a2,4(s1)
    80005090:	00003597          	auipc	a1,0x3
    80005094:	65858593          	addi	a1,a1,1624 # 800086e8 <syscalls+0x2c0>
    80005098:	8526                	mv	a0,s1
    8000509a:	fffff097          	auipc	ra,0xfffff
    8000509e:	c5e080e7          	jalr	-930(ra) # 80003cf8 <dirlink>
    800050a2:	00054f63          	bltz	a0,800050c0 <create+0x144>
    800050a6:	00492603          	lw	a2,4(s2)
    800050aa:	00003597          	auipc	a1,0x3
    800050ae:	64658593          	addi	a1,a1,1606 # 800086f0 <syscalls+0x2c8>
    800050b2:	8526                	mv	a0,s1
    800050b4:	fffff097          	auipc	ra,0xfffff
    800050b8:	c44080e7          	jalr	-956(ra) # 80003cf8 <dirlink>
    800050bc:	f80557e3          	bgez	a0,8000504a <create+0xce>
      panic("create dots");
    800050c0:	00003517          	auipc	a0,0x3
    800050c4:	63850513          	addi	a0,a0,1592 # 800086f8 <syscalls+0x2d0>
    800050c8:	ffffb097          	auipc	ra,0xffffb
    800050cc:	480080e7          	jalr	1152(ra) # 80000548 <panic>
    panic("create: dirlink");
    800050d0:	00003517          	auipc	a0,0x3
    800050d4:	63850513          	addi	a0,a0,1592 # 80008708 <syscalls+0x2e0>
    800050d8:	ffffb097          	auipc	ra,0xffffb
    800050dc:	470080e7          	jalr	1136(ra) # 80000548 <panic>
    return 0;
    800050e0:	84aa                	mv	s1,a0
    800050e2:	b731                	j	80004fee <create+0x72>

00000000800050e4 <sys_dup>:
{
    800050e4:	7179                	addi	sp,sp,-48
    800050e6:	f406                	sd	ra,40(sp)
    800050e8:	f022                	sd	s0,32(sp)
    800050ea:	ec26                	sd	s1,24(sp)
    800050ec:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800050ee:	fd840613          	addi	a2,s0,-40
    800050f2:	4581                	li	a1,0
    800050f4:	4501                	li	a0,0
    800050f6:	00000097          	auipc	ra,0x0
    800050fa:	ddc080e7          	jalr	-548(ra) # 80004ed2 <argfd>
    return -1;
    800050fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005100:	02054363          	bltz	a0,80005126 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005104:	fd843503          	ld	a0,-40(s0)
    80005108:	00000097          	auipc	ra,0x0
    8000510c:	e32080e7          	jalr	-462(ra) # 80004f3a <fdalloc>
    80005110:	84aa                	mv	s1,a0
    return -1;
    80005112:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005114:	00054963          	bltz	a0,80005126 <sys_dup+0x42>
  filedup(f);
    80005118:	fd843503          	ld	a0,-40(s0)
    8000511c:	fffff097          	auipc	ra,0xfffff
    80005120:	32a080e7          	jalr	810(ra) # 80004446 <filedup>
  return fd;
    80005124:	87a6                	mv	a5,s1
}
    80005126:	853e                	mv	a0,a5
    80005128:	70a2                	ld	ra,40(sp)
    8000512a:	7402                	ld	s0,32(sp)
    8000512c:	64e2                	ld	s1,24(sp)
    8000512e:	6145                	addi	sp,sp,48
    80005130:	8082                	ret

0000000080005132 <sys_read>:
{
    80005132:	7179                	addi	sp,sp,-48
    80005134:	f406                	sd	ra,40(sp)
    80005136:	f022                	sd	s0,32(sp)
    80005138:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000513a:	fe840613          	addi	a2,s0,-24
    8000513e:	4581                	li	a1,0
    80005140:	4501                	li	a0,0
    80005142:	00000097          	auipc	ra,0x0
    80005146:	d90080e7          	jalr	-624(ra) # 80004ed2 <argfd>
    return -1;
    8000514a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000514c:	04054163          	bltz	a0,8000518e <sys_read+0x5c>
    80005150:	fe440593          	addi	a1,s0,-28
    80005154:	4509                	li	a0,2
    80005156:	ffffe097          	auipc	ra,0xffffe
    8000515a:	942080e7          	jalr	-1726(ra) # 80002a98 <argint>
    return -1;
    8000515e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005160:	02054763          	bltz	a0,8000518e <sys_read+0x5c>
    80005164:	fd840593          	addi	a1,s0,-40
    80005168:	4505                	li	a0,1
    8000516a:	ffffe097          	auipc	ra,0xffffe
    8000516e:	950080e7          	jalr	-1712(ra) # 80002aba <argaddr>
    return -1;
    80005172:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005174:	00054d63          	bltz	a0,8000518e <sys_read+0x5c>
  return fileread(f, p, n);
    80005178:	fe442603          	lw	a2,-28(s0)
    8000517c:	fd843583          	ld	a1,-40(s0)
    80005180:	fe843503          	ld	a0,-24(s0)
    80005184:	fffff097          	auipc	ra,0xfffff
    80005188:	44e080e7          	jalr	1102(ra) # 800045d2 <fileread>
    8000518c:	87aa                	mv	a5,a0
}
    8000518e:	853e                	mv	a0,a5
    80005190:	70a2                	ld	ra,40(sp)
    80005192:	7402                	ld	s0,32(sp)
    80005194:	6145                	addi	sp,sp,48
    80005196:	8082                	ret

0000000080005198 <sys_write>:
{
    80005198:	7179                	addi	sp,sp,-48
    8000519a:	f406                	sd	ra,40(sp)
    8000519c:	f022                	sd	s0,32(sp)
    8000519e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051a0:	fe840613          	addi	a2,s0,-24
    800051a4:	4581                	li	a1,0
    800051a6:	4501                	li	a0,0
    800051a8:	00000097          	auipc	ra,0x0
    800051ac:	d2a080e7          	jalr	-726(ra) # 80004ed2 <argfd>
    return -1;
    800051b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051b2:	04054163          	bltz	a0,800051f4 <sys_write+0x5c>
    800051b6:	fe440593          	addi	a1,s0,-28
    800051ba:	4509                	li	a0,2
    800051bc:	ffffe097          	auipc	ra,0xffffe
    800051c0:	8dc080e7          	jalr	-1828(ra) # 80002a98 <argint>
    return -1;
    800051c4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051c6:	02054763          	bltz	a0,800051f4 <sys_write+0x5c>
    800051ca:	fd840593          	addi	a1,s0,-40
    800051ce:	4505                	li	a0,1
    800051d0:	ffffe097          	auipc	ra,0xffffe
    800051d4:	8ea080e7          	jalr	-1814(ra) # 80002aba <argaddr>
    return -1;
    800051d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051da:	00054d63          	bltz	a0,800051f4 <sys_write+0x5c>
  return filewrite(f, p, n);
    800051de:	fe442603          	lw	a2,-28(s0)
    800051e2:	fd843583          	ld	a1,-40(s0)
    800051e6:	fe843503          	ld	a0,-24(s0)
    800051ea:	fffff097          	auipc	ra,0xfffff
    800051ee:	4aa080e7          	jalr	1194(ra) # 80004694 <filewrite>
    800051f2:	87aa                	mv	a5,a0
}
    800051f4:	853e                	mv	a0,a5
    800051f6:	70a2                	ld	ra,40(sp)
    800051f8:	7402                	ld	s0,32(sp)
    800051fa:	6145                	addi	sp,sp,48
    800051fc:	8082                	ret

00000000800051fe <sys_close>:
{
    800051fe:	1101                	addi	sp,sp,-32
    80005200:	ec06                	sd	ra,24(sp)
    80005202:	e822                	sd	s0,16(sp)
    80005204:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005206:	fe040613          	addi	a2,s0,-32
    8000520a:	fec40593          	addi	a1,s0,-20
    8000520e:	4501                	li	a0,0
    80005210:	00000097          	auipc	ra,0x0
    80005214:	cc2080e7          	jalr	-830(ra) # 80004ed2 <argfd>
    return -1;
    80005218:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000521a:	02054463          	bltz	a0,80005242 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000521e:	ffffc097          	auipc	ra,0xffffc
    80005222:	7c0080e7          	jalr	1984(ra) # 800019de <myproc>
    80005226:	fec42783          	lw	a5,-20(s0)
    8000522a:	07e9                	addi	a5,a5,26
    8000522c:	078e                	slli	a5,a5,0x3
    8000522e:	97aa                	add	a5,a5,a0
    80005230:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005234:	fe043503          	ld	a0,-32(s0)
    80005238:	fffff097          	auipc	ra,0xfffff
    8000523c:	260080e7          	jalr	608(ra) # 80004498 <fileclose>
  return 0;
    80005240:	4781                	li	a5,0
}
    80005242:	853e                	mv	a0,a5
    80005244:	60e2                	ld	ra,24(sp)
    80005246:	6442                	ld	s0,16(sp)
    80005248:	6105                	addi	sp,sp,32
    8000524a:	8082                	ret

000000008000524c <sys_fstat>:
{
    8000524c:	1101                	addi	sp,sp,-32
    8000524e:	ec06                	sd	ra,24(sp)
    80005250:	e822                	sd	s0,16(sp)
    80005252:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005254:	fe840613          	addi	a2,s0,-24
    80005258:	4581                	li	a1,0
    8000525a:	4501                	li	a0,0
    8000525c:	00000097          	auipc	ra,0x0
    80005260:	c76080e7          	jalr	-906(ra) # 80004ed2 <argfd>
    return -1;
    80005264:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005266:	02054563          	bltz	a0,80005290 <sys_fstat+0x44>
    8000526a:	fe040593          	addi	a1,s0,-32
    8000526e:	4505                	li	a0,1
    80005270:	ffffe097          	auipc	ra,0xffffe
    80005274:	84a080e7          	jalr	-1974(ra) # 80002aba <argaddr>
    return -1;
    80005278:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000527a:	00054b63          	bltz	a0,80005290 <sys_fstat+0x44>
  return filestat(f, st);
    8000527e:	fe043583          	ld	a1,-32(s0)
    80005282:	fe843503          	ld	a0,-24(s0)
    80005286:	fffff097          	auipc	ra,0xfffff
    8000528a:	2da080e7          	jalr	730(ra) # 80004560 <filestat>
    8000528e:	87aa                	mv	a5,a0
}
    80005290:	853e                	mv	a0,a5
    80005292:	60e2                	ld	ra,24(sp)
    80005294:	6442                	ld	s0,16(sp)
    80005296:	6105                	addi	sp,sp,32
    80005298:	8082                	ret

000000008000529a <sys_link>:
{
    8000529a:	7169                	addi	sp,sp,-304
    8000529c:	f606                	sd	ra,296(sp)
    8000529e:	f222                	sd	s0,288(sp)
    800052a0:	ee26                	sd	s1,280(sp)
    800052a2:	ea4a                	sd	s2,272(sp)
    800052a4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052a6:	08000613          	li	a2,128
    800052aa:	ed040593          	addi	a1,s0,-304
    800052ae:	4501                	li	a0,0
    800052b0:	ffffe097          	auipc	ra,0xffffe
    800052b4:	82c080e7          	jalr	-2004(ra) # 80002adc <argstr>
    return -1;
    800052b8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052ba:	10054e63          	bltz	a0,800053d6 <sys_link+0x13c>
    800052be:	08000613          	li	a2,128
    800052c2:	f5040593          	addi	a1,s0,-176
    800052c6:	4505                	li	a0,1
    800052c8:	ffffe097          	auipc	ra,0xffffe
    800052cc:	814080e7          	jalr	-2028(ra) # 80002adc <argstr>
    return -1;
    800052d0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052d2:	10054263          	bltz	a0,800053d6 <sys_link+0x13c>
  begin_op();
    800052d6:	fffff097          	auipc	ra,0xfffff
    800052da:	cf0080e7          	jalr	-784(ra) # 80003fc6 <begin_op>
  if((ip = namei(old)) == 0){
    800052de:	ed040513          	addi	a0,s0,-304
    800052e2:	fffff097          	auipc	ra,0xfffff
    800052e6:	ad8080e7          	jalr	-1320(ra) # 80003dba <namei>
    800052ea:	84aa                	mv	s1,a0
    800052ec:	c551                	beqz	a0,80005378 <sys_link+0xde>
  ilock(ip);
    800052ee:	ffffe097          	auipc	ra,0xffffe
    800052f2:	31c080e7          	jalr	796(ra) # 8000360a <ilock>
  if(ip->type == T_DIR){
    800052f6:	04449703          	lh	a4,68(s1)
    800052fa:	4785                	li	a5,1
    800052fc:	08f70463          	beq	a4,a5,80005384 <sys_link+0xea>
  ip->nlink++;
    80005300:	04a4d783          	lhu	a5,74(s1)
    80005304:	2785                	addiw	a5,a5,1
    80005306:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000530a:	8526                	mv	a0,s1
    8000530c:	ffffe097          	auipc	ra,0xffffe
    80005310:	234080e7          	jalr	564(ra) # 80003540 <iupdate>
  iunlock(ip);
    80005314:	8526                	mv	a0,s1
    80005316:	ffffe097          	auipc	ra,0xffffe
    8000531a:	3b6080e7          	jalr	950(ra) # 800036cc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000531e:	fd040593          	addi	a1,s0,-48
    80005322:	f5040513          	addi	a0,s0,-176
    80005326:	fffff097          	auipc	ra,0xfffff
    8000532a:	ab2080e7          	jalr	-1358(ra) # 80003dd8 <nameiparent>
    8000532e:	892a                	mv	s2,a0
    80005330:	c935                	beqz	a0,800053a4 <sys_link+0x10a>
  ilock(dp);
    80005332:	ffffe097          	auipc	ra,0xffffe
    80005336:	2d8080e7          	jalr	728(ra) # 8000360a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000533a:	00092703          	lw	a4,0(s2)
    8000533e:	409c                	lw	a5,0(s1)
    80005340:	04f71d63          	bne	a4,a5,8000539a <sys_link+0x100>
    80005344:	40d0                	lw	a2,4(s1)
    80005346:	fd040593          	addi	a1,s0,-48
    8000534a:	854a                	mv	a0,s2
    8000534c:	fffff097          	auipc	ra,0xfffff
    80005350:	9ac080e7          	jalr	-1620(ra) # 80003cf8 <dirlink>
    80005354:	04054363          	bltz	a0,8000539a <sys_link+0x100>
  iunlockput(dp);
    80005358:	854a                	mv	a0,s2
    8000535a:	ffffe097          	auipc	ra,0xffffe
    8000535e:	512080e7          	jalr	1298(ra) # 8000386c <iunlockput>
  iput(ip);
    80005362:	8526                	mv	a0,s1
    80005364:	ffffe097          	auipc	ra,0xffffe
    80005368:	460080e7          	jalr	1120(ra) # 800037c4 <iput>
  end_op();
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	cda080e7          	jalr	-806(ra) # 80004046 <end_op>
  return 0;
    80005374:	4781                	li	a5,0
    80005376:	a085                	j	800053d6 <sys_link+0x13c>
    end_op();
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	cce080e7          	jalr	-818(ra) # 80004046 <end_op>
    return -1;
    80005380:	57fd                	li	a5,-1
    80005382:	a891                	j	800053d6 <sys_link+0x13c>
    iunlockput(ip);
    80005384:	8526                	mv	a0,s1
    80005386:	ffffe097          	auipc	ra,0xffffe
    8000538a:	4e6080e7          	jalr	1254(ra) # 8000386c <iunlockput>
    end_op();
    8000538e:	fffff097          	auipc	ra,0xfffff
    80005392:	cb8080e7          	jalr	-840(ra) # 80004046 <end_op>
    return -1;
    80005396:	57fd                	li	a5,-1
    80005398:	a83d                	j	800053d6 <sys_link+0x13c>
    iunlockput(dp);
    8000539a:	854a                	mv	a0,s2
    8000539c:	ffffe097          	auipc	ra,0xffffe
    800053a0:	4d0080e7          	jalr	1232(ra) # 8000386c <iunlockput>
  ilock(ip);
    800053a4:	8526                	mv	a0,s1
    800053a6:	ffffe097          	auipc	ra,0xffffe
    800053aa:	264080e7          	jalr	612(ra) # 8000360a <ilock>
  ip->nlink--;
    800053ae:	04a4d783          	lhu	a5,74(s1)
    800053b2:	37fd                	addiw	a5,a5,-1
    800053b4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053b8:	8526                	mv	a0,s1
    800053ba:	ffffe097          	auipc	ra,0xffffe
    800053be:	186080e7          	jalr	390(ra) # 80003540 <iupdate>
  iunlockput(ip);
    800053c2:	8526                	mv	a0,s1
    800053c4:	ffffe097          	auipc	ra,0xffffe
    800053c8:	4a8080e7          	jalr	1192(ra) # 8000386c <iunlockput>
  end_op();
    800053cc:	fffff097          	auipc	ra,0xfffff
    800053d0:	c7a080e7          	jalr	-902(ra) # 80004046 <end_op>
  return -1;
    800053d4:	57fd                	li	a5,-1
}
    800053d6:	853e                	mv	a0,a5
    800053d8:	70b2                	ld	ra,296(sp)
    800053da:	7412                	ld	s0,288(sp)
    800053dc:	64f2                	ld	s1,280(sp)
    800053de:	6952                	ld	s2,272(sp)
    800053e0:	6155                	addi	sp,sp,304
    800053e2:	8082                	ret

00000000800053e4 <sys_unlink>:
{
    800053e4:	7151                	addi	sp,sp,-240
    800053e6:	f586                	sd	ra,232(sp)
    800053e8:	f1a2                	sd	s0,224(sp)
    800053ea:	eda6                	sd	s1,216(sp)
    800053ec:	e9ca                	sd	s2,208(sp)
    800053ee:	e5ce                	sd	s3,200(sp)
    800053f0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800053f2:	08000613          	li	a2,128
    800053f6:	f3040593          	addi	a1,s0,-208
    800053fa:	4501                	li	a0,0
    800053fc:	ffffd097          	auipc	ra,0xffffd
    80005400:	6e0080e7          	jalr	1760(ra) # 80002adc <argstr>
    80005404:	18054163          	bltz	a0,80005586 <sys_unlink+0x1a2>
  begin_op();
    80005408:	fffff097          	auipc	ra,0xfffff
    8000540c:	bbe080e7          	jalr	-1090(ra) # 80003fc6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005410:	fb040593          	addi	a1,s0,-80
    80005414:	f3040513          	addi	a0,s0,-208
    80005418:	fffff097          	auipc	ra,0xfffff
    8000541c:	9c0080e7          	jalr	-1600(ra) # 80003dd8 <nameiparent>
    80005420:	84aa                	mv	s1,a0
    80005422:	c979                	beqz	a0,800054f8 <sys_unlink+0x114>
  ilock(dp);
    80005424:	ffffe097          	auipc	ra,0xffffe
    80005428:	1e6080e7          	jalr	486(ra) # 8000360a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000542c:	00003597          	auipc	a1,0x3
    80005430:	2bc58593          	addi	a1,a1,700 # 800086e8 <syscalls+0x2c0>
    80005434:	fb040513          	addi	a0,s0,-80
    80005438:	ffffe097          	auipc	ra,0xffffe
    8000543c:	696080e7          	jalr	1686(ra) # 80003ace <namecmp>
    80005440:	14050a63          	beqz	a0,80005594 <sys_unlink+0x1b0>
    80005444:	00003597          	auipc	a1,0x3
    80005448:	2ac58593          	addi	a1,a1,684 # 800086f0 <syscalls+0x2c8>
    8000544c:	fb040513          	addi	a0,s0,-80
    80005450:	ffffe097          	auipc	ra,0xffffe
    80005454:	67e080e7          	jalr	1662(ra) # 80003ace <namecmp>
    80005458:	12050e63          	beqz	a0,80005594 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000545c:	f2c40613          	addi	a2,s0,-212
    80005460:	fb040593          	addi	a1,s0,-80
    80005464:	8526                	mv	a0,s1
    80005466:	ffffe097          	auipc	ra,0xffffe
    8000546a:	682080e7          	jalr	1666(ra) # 80003ae8 <dirlookup>
    8000546e:	892a                	mv	s2,a0
    80005470:	12050263          	beqz	a0,80005594 <sys_unlink+0x1b0>
  ilock(ip);
    80005474:	ffffe097          	auipc	ra,0xffffe
    80005478:	196080e7          	jalr	406(ra) # 8000360a <ilock>
  if(ip->nlink < 1)
    8000547c:	04a91783          	lh	a5,74(s2)
    80005480:	08f05263          	blez	a5,80005504 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005484:	04491703          	lh	a4,68(s2)
    80005488:	4785                	li	a5,1
    8000548a:	08f70563          	beq	a4,a5,80005514 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000548e:	4641                	li	a2,16
    80005490:	4581                	li	a1,0
    80005492:	fc040513          	addi	a0,s0,-64
    80005496:	ffffc097          	auipc	ra,0xffffc
    8000549a:	876080e7          	jalr	-1930(ra) # 80000d0c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000549e:	4741                	li	a4,16
    800054a0:	f2c42683          	lw	a3,-212(s0)
    800054a4:	fc040613          	addi	a2,s0,-64
    800054a8:	4581                	li	a1,0
    800054aa:	8526                	mv	a0,s1
    800054ac:	ffffe097          	auipc	ra,0xffffe
    800054b0:	508080e7          	jalr	1288(ra) # 800039b4 <writei>
    800054b4:	47c1                	li	a5,16
    800054b6:	0af51563          	bne	a0,a5,80005560 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800054ba:	04491703          	lh	a4,68(s2)
    800054be:	4785                	li	a5,1
    800054c0:	0af70863          	beq	a4,a5,80005570 <sys_unlink+0x18c>
  iunlockput(dp);
    800054c4:	8526                	mv	a0,s1
    800054c6:	ffffe097          	auipc	ra,0xffffe
    800054ca:	3a6080e7          	jalr	934(ra) # 8000386c <iunlockput>
  ip->nlink--;
    800054ce:	04a95783          	lhu	a5,74(s2)
    800054d2:	37fd                	addiw	a5,a5,-1
    800054d4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800054d8:	854a                	mv	a0,s2
    800054da:	ffffe097          	auipc	ra,0xffffe
    800054de:	066080e7          	jalr	102(ra) # 80003540 <iupdate>
  iunlockput(ip);
    800054e2:	854a                	mv	a0,s2
    800054e4:	ffffe097          	auipc	ra,0xffffe
    800054e8:	388080e7          	jalr	904(ra) # 8000386c <iunlockput>
  end_op();
    800054ec:	fffff097          	auipc	ra,0xfffff
    800054f0:	b5a080e7          	jalr	-1190(ra) # 80004046 <end_op>
  return 0;
    800054f4:	4501                	li	a0,0
    800054f6:	a84d                	j	800055a8 <sys_unlink+0x1c4>
    end_op();
    800054f8:	fffff097          	auipc	ra,0xfffff
    800054fc:	b4e080e7          	jalr	-1202(ra) # 80004046 <end_op>
    return -1;
    80005500:	557d                	li	a0,-1
    80005502:	a05d                	j	800055a8 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005504:	00003517          	auipc	a0,0x3
    80005508:	21450513          	addi	a0,a0,532 # 80008718 <syscalls+0x2f0>
    8000550c:	ffffb097          	auipc	ra,0xffffb
    80005510:	03c080e7          	jalr	60(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005514:	04c92703          	lw	a4,76(s2)
    80005518:	02000793          	li	a5,32
    8000551c:	f6e7f9e3          	bgeu	a5,a4,8000548e <sys_unlink+0xaa>
    80005520:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005524:	4741                	li	a4,16
    80005526:	86ce                	mv	a3,s3
    80005528:	f1840613          	addi	a2,s0,-232
    8000552c:	4581                	li	a1,0
    8000552e:	854a                	mv	a0,s2
    80005530:	ffffe097          	auipc	ra,0xffffe
    80005534:	38e080e7          	jalr	910(ra) # 800038be <readi>
    80005538:	47c1                	li	a5,16
    8000553a:	00f51b63          	bne	a0,a5,80005550 <sys_unlink+0x16c>
    if(de.inum != 0)
    8000553e:	f1845783          	lhu	a5,-232(s0)
    80005542:	e7a1                	bnez	a5,8000558a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005544:	29c1                	addiw	s3,s3,16
    80005546:	04c92783          	lw	a5,76(s2)
    8000554a:	fcf9ede3          	bltu	s3,a5,80005524 <sys_unlink+0x140>
    8000554e:	b781                	j	8000548e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005550:	00003517          	auipc	a0,0x3
    80005554:	1e050513          	addi	a0,a0,480 # 80008730 <syscalls+0x308>
    80005558:	ffffb097          	auipc	ra,0xffffb
    8000555c:	ff0080e7          	jalr	-16(ra) # 80000548 <panic>
    panic("unlink: writei");
    80005560:	00003517          	auipc	a0,0x3
    80005564:	1e850513          	addi	a0,a0,488 # 80008748 <syscalls+0x320>
    80005568:	ffffb097          	auipc	ra,0xffffb
    8000556c:	fe0080e7          	jalr	-32(ra) # 80000548 <panic>
    dp->nlink--;
    80005570:	04a4d783          	lhu	a5,74(s1)
    80005574:	37fd                	addiw	a5,a5,-1
    80005576:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000557a:	8526                	mv	a0,s1
    8000557c:	ffffe097          	auipc	ra,0xffffe
    80005580:	fc4080e7          	jalr	-60(ra) # 80003540 <iupdate>
    80005584:	b781                	j	800054c4 <sys_unlink+0xe0>
    return -1;
    80005586:	557d                	li	a0,-1
    80005588:	a005                	j	800055a8 <sys_unlink+0x1c4>
    iunlockput(ip);
    8000558a:	854a                	mv	a0,s2
    8000558c:	ffffe097          	auipc	ra,0xffffe
    80005590:	2e0080e7          	jalr	736(ra) # 8000386c <iunlockput>
  iunlockput(dp);
    80005594:	8526                	mv	a0,s1
    80005596:	ffffe097          	auipc	ra,0xffffe
    8000559a:	2d6080e7          	jalr	726(ra) # 8000386c <iunlockput>
  end_op();
    8000559e:	fffff097          	auipc	ra,0xfffff
    800055a2:	aa8080e7          	jalr	-1368(ra) # 80004046 <end_op>
  return -1;
    800055a6:	557d                	li	a0,-1
}
    800055a8:	70ae                	ld	ra,232(sp)
    800055aa:	740e                	ld	s0,224(sp)
    800055ac:	64ee                	ld	s1,216(sp)
    800055ae:	694e                	ld	s2,208(sp)
    800055b0:	69ae                	ld	s3,200(sp)
    800055b2:	616d                	addi	sp,sp,240
    800055b4:	8082                	ret

00000000800055b6 <sys_open>:

uint64
sys_open(void)
{
    800055b6:	7131                	addi	sp,sp,-192
    800055b8:	fd06                	sd	ra,184(sp)
    800055ba:	f922                	sd	s0,176(sp)
    800055bc:	f526                	sd	s1,168(sp)
    800055be:	f14a                	sd	s2,160(sp)
    800055c0:	ed4e                	sd	s3,152(sp)
    800055c2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800055c4:	08000613          	li	a2,128
    800055c8:	f5040593          	addi	a1,s0,-176
    800055cc:	4501                	li	a0,0
    800055ce:	ffffd097          	auipc	ra,0xffffd
    800055d2:	50e080e7          	jalr	1294(ra) # 80002adc <argstr>
    return -1;
    800055d6:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800055d8:	0c054163          	bltz	a0,8000569a <sys_open+0xe4>
    800055dc:	f4c40593          	addi	a1,s0,-180
    800055e0:	4505                	li	a0,1
    800055e2:	ffffd097          	auipc	ra,0xffffd
    800055e6:	4b6080e7          	jalr	1206(ra) # 80002a98 <argint>
    800055ea:	0a054863          	bltz	a0,8000569a <sys_open+0xe4>

  begin_op();
    800055ee:	fffff097          	auipc	ra,0xfffff
    800055f2:	9d8080e7          	jalr	-1576(ra) # 80003fc6 <begin_op>

  if(omode & O_CREATE){
    800055f6:	f4c42783          	lw	a5,-180(s0)
    800055fa:	2007f793          	andi	a5,a5,512
    800055fe:	cbdd                	beqz	a5,800056b4 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005600:	4681                	li	a3,0
    80005602:	4601                	li	a2,0
    80005604:	4589                	li	a1,2
    80005606:	f5040513          	addi	a0,s0,-176
    8000560a:	00000097          	auipc	ra,0x0
    8000560e:	972080e7          	jalr	-1678(ra) # 80004f7c <create>
    80005612:	892a                	mv	s2,a0
    if(ip == 0){
    80005614:	c959                	beqz	a0,800056aa <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005616:	04491703          	lh	a4,68(s2)
    8000561a:	478d                	li	a5,3
    8000561c:	00f71763          	bne	a4,a5,8000562a <sys_open+0x74>
    80005620:	04695703          	lhu	a4,70(s2)
    80005624:	47a5                	li	a5,9
    80005626:	0ce7ec63          	bltu	a5,a4,800056fe <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000562a:	fffff097          	auipc	ra,0xfffff
    8000562e:	db2080e7          	jalr	-590(ra) # 800043dc <filealloc>
    80005632:	89aa                	mv	s3,a0
    80005634:	10050263          	beqz	a0,80005738 <sys_open+0x182>
    80005638:	00000097          	auipc	ra,0x0
    8000563c:	902080e7          	jalr	-1790(ra) # 80004f3a <fdalloc>
    80005640:	84aa                	mv	s1,a0
    80005642:	0e054663          	bltz	a0,8000572e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005646:	04491703          	lh	a4,68(s2)
    8000564a:	478d                	li	a5,3
    8000564c:	0cf70463          	beq	a4,a5,80005714 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005650:	4789                	li	a5,2
    80005652:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005656:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000565a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000565e:	f4c42783          	lw	a5,-180(s0)
    80005662:	0017c713          	xori	a4,a5,1
    80005666:	8b05                	andi	a4,a4,1
    80005668:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000566c:	0037f713          	andi	a4,a5,3
    80005670:	00e03733          	snez	a4,a4
    80005674:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005678:	4007f793          	andi	a5,a5,1024
    8000567c:	c791                	beqz	a5,80005688 <sys_open+0xd2>
    8000567e:	04491703          	lh	a4,68(s2)
    80005682:	4789                	li	a5,2
    80005684:	08f70f63          	beq	a4,a5,80005722 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005688:	854a                	mv	a0,s2
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	042080e7          	jalr	66(ra) # 800036cc <iunlock>
  end_op();
    80005692:	fffff097          	auipc	ra,0xfffff
    80005696:	9b4080e7          	jalr	-1612(ra) # 80004046 <end_op>

  return fd;
}
    8000569a:	8526                	mv	a0,s1
    8000569c:	70ea                	ld	ra,184(sp)
    8000569e:	744a                	ld	s0,176(sp)
    800056a0:	74aa                	ld	s1,168(sp)
    800056a2:	790a                	ld	s2,160(sp)
    800056a4:	69ea                	ld	s3,152(sp)
    800056a6:	6129                	addi	sp,sp,192
    800056a8:	8082                	ret
      end_op();
    800056aa:	fffff097          	auipc	ra,0xfffff
    800056ae:	99c080e7          	jalr	-1636(ra) # 80004046 <end_op>
      return -1;
    800056b2:	b7e5                	j	8000569a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800056b4:	f5040513          	addi	a0,s0,-176
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	702080e7          	jalr	1794(ra) # 80003dba <namei>
    800056c0:	892a                	mv	s2,a0
    800056c2:	c905                	beqz	a0,800056f2 <sys_open+0x13c>
    ilock(ip);
    800056c4:	ffffe097          	auipc	ra,0xffffe
    800056c8:	f46080e7          	jalr	-186(ra) # 8000360a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800056cc:	04491703          	lh	a4,68(s2)
    800056d0:	4785                	li	a5,1
    800056d2:	f4f712e3          	bne	a4,a5,80005616 <sys_open+0x60>
    800056d6:	f4c42783          	lw	a5,-180(s0)
    800056da:	dba1                	beqz	a5,8000562a <sys_open+0x74>
      iunlockput(ip);
    800056dc:	854a                	mv	a0,s2
    800056de:	ffffe097          	auipc	ra,0xffffe
    800056e2:	18e080e7          	jalr	398(ra) # 8000386c <iunlockput>
      end_op();
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	960080e7          	jalr	-1696(ra) # 80004046 <end_op>
      return -1;
    800056ee:	54fd                	li	s1,-1
    800056f0:	b76d                	j	8000569a <sys_open+0xe4>
      end_op();
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	954080e7          	jalr	-1708(ra) # 80004046 <end_op>
      return -1;
    800056fa:	54fd                	li	s1,-1
    800056fc:	bf79                	j	8000569a <sys_open+0xe4>
    iunlockput(ip);
    800056fe:	854a                	mv	a0,s2
    80005700:	ffffe097          	auipc	ra,0xffffe
    80005704:	16c080e7          	jalr	364(ra) # 8000386c <iunlockput>
    end_op();
    80005708:	fffff097          	auipc	ra,0xfffff
    8000570c:	93e080e7          	jalr	-1730(ra) # 80004046 <end_op>
    return -1;
    80005710:	54fd                	li	s1,-1
    80005712:	b761                	j	8000569a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005714:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005718:	04691783          	lh	a5,70(s2)
    8000571c:	02f99223          	sh	a5,36(s3)
    80005720:	bf2d                	j	8000565a <sys_open+0xa4>
    itrunc(ip);
    80005722:	854a                	mv	a0,s2
    80005724:	ffffe097          	auipc	ra,0xffffe
    80005728:	ff4080e7          	jalr	-12(ra) # 80003718 <itrunc>
    8000572c:	bfb1                	j	80005688 <sys_open+0xd2>
      fileclose(f);
    8000572e:	854e                	mv	a0,s3
    80005730:	fffff097          	auipc	ra,0xfffff
    80005734:	d68080e7          	jalr	-664(ra) # 80004498 <fileclose>
    iunlockput(ip);
    80005738:	854a                	mv	a0,s2
    8000573a:	ffffe097          	auipc	ra,0xffffe
    8000573e:	132080e7          	jalr	306(ra) # 8000386c <iunlockput>
    end_op();
    80005742:	fffff097          	auipc	ra,0xfffff
    80005746:	904080e7          	jalr	-1788(ra) # 80004046 <end_op>
    return -1;
    8000574a:	54fd                	li	s1,-1
    8000574c:	b7b9                	j	8000569a <sys_open+0xe4>

000000008000574e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000574e:	7175                	addi	sp,sp,-144
    80005750:	e506                	sd	ra,136(sp)
    80005752:	e122                	sd	s0,128(sp)
    80005754:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005756:	fffff097          	auipc	ra,0xfffff
    8000575a:	870080e7          	jalr	-1936(ra) # 80003fc6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000575e:	08000613          	li	a2,128
    80005762:	f7040593          	addi	a1,s0,-144
    80005766:	4501                	li	a0,0
    80005768:	ffffd097          	auipc	ra,0xffffd
    8000576c:	374080e7          	jalr	884(ra) # 80002adc <argstr>
    80005770:	02054963          	bltz	a0,800057a2 <sys_mkdir+0x54>
    80005774:	4681                	li	a3,0
    80005776:	4601                	li	a2,0
    80005778:	4585                	li	a1,1
    8000577a:	f7040513          	addi	a0,s0,-144
    8000577e:	fffff097          	auipc	ra,0xfffff
    80005782:	7fe080e7          	jalr	2046(ra) # 80004f7c <create>
    80005786:	cd11                	beqz	a0,800057a2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005788:	ffffe097          	auipc	ra,0xffffe
    8000578c:	0e4080e7          	jalr	228(ra) # 8000386c <iunlockput>
  end_op();
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	8b6080e7          	jalr	-1866(ra) # 80004046 <end_op>
  return 0;
    80005798:	4501                	li	a0,0
}
    8000579a:	60aa                	ld	ra,136(sp)
    8000579c:	640a                	ld	s0,128(sp)
    8000579e:	6149                	addi	sp,sp,144
    800057a0:	8082                	ret
    end_op();
    800057a2:	fffff097          	auipc	ra,0xfffff
    800057a6:	8a4080e7          	jalr	-1884(ra) # 80004046 <end_op>
    return -1;
    800057aa:	557d                	li	a0,-1
    800057ac:	b7fd                	j	8000579a <sys_mkdir+0x4c>

00000000800057ae <sys_mknod>:

uint64
sys_mknod(void)
{
    800057ae:	7135                	addi	sp,sp,-160
    800057b0:	ed06                	sd	ra,152(sp)
    800057b2:	e922                	sd	s0,144(sp)
    800057b4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800057b6:	fffff097          	auipc	ra,0xfffff
    800057ba:	810080e7          	jalr	-2032(ra) # 80003fc6 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057be:	08000613          	li	a2,128
    800057c2:	f7040593          	addi	a1,s0,-144
    800057c6:	4501                	li	a0,0
    800057c8:	ffffd097          	auipc	ra,0xffffd
    800057cc:	314080e7          	jalr	788(ra) # 80002adc <argstr>
    800057d0:	04054a63          	bltz	a0,80005824 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800057d4:	f6c40593          	addi	a1,s0,-148
    800057d8:	4505                	li	a0,1
    800057da:	ffffd097          	auipc	ra,0xffffd
    800057de:	2be080e7          	jalr	702(ra) # 80002a98 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057e2:	04054163          	bltz	a0,80005824 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800057e6:	f6840593          	addi	a1,s0,-152
    800057ea:	4509                	li	a0,2
    800057ec:	ffffd097          	auipc	ra,0xffffd
    800057f0:	2ac080e7          	jalr	684(ra) # 80002a98 <argint>
     argint(1, &major) < 0 ||
    800057f4:	02054863          	bltz	a0,80005824 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800057f8:	f6841683          	lh	a3,-152(s0)
    800057fc:	f6c41603          	lh	a2,-148(s0)
    80005800:	458d                	li	a1,3
    80005802:	f7040513          	addi	a0,s0,-144
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	776080e7          	jalr	1910(ra) # 80004f7c <create>
     argint(2, &minor) < 0 ||
    8000580e:	c919                	beqz	a0,80005824 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	05c080e7          	jalr	92(ra) # 8000386c <iunlockput>
  end_op();
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	82e080e7          	jalr	-2002(ra) # 80004046 <end_op>
  return 0;
    80005820:	4501                	li	a0,0
    80005822:	a031                	j	8000582e <sys_mknod+0x80>
    end_op();
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	822080e7          	jalr	-2014(ra) # 80004046 <end_op>
    return -1;
    8000582c:	557d                	li	a0,-1
}
    8000582e:	60ea                	ld	ra,152(sp)
    80005830:	644a                	ld	s0,144(sp)
    80005832:	610d                	addi	sp,sp,160
    80005834:	8082                	ret

0000000080005836 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005836:	7135                	addi	sp,sp,-160
    80005838:	ed06                	sd	ra,152(sp)
    8000583a:	e922                	sd	s0,144(sp)
    8000583c:	e526                	sd	s1,136(sp)
    8000583e:	e14a                	sd	s2,128(sp)
    80005840:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005842:	ffffc097          	auipc	ra,0xffffc
    80005846:	19c080e7          	jalr	412(ra) # 800019de <myproc>
    8000584a:	892a                	mv	s2,a0
  
  begin_op();
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	77a080e7          	jalr	1914(ra) # 80003fc6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005854:	08000613          	li	a2,128
    80005858:	f6040593          	addi	a1,s0,-160
    8000585c:	4501                	li	a0,0
    8000585e:	ffffd097          	auipc	ra,0xffffd
    80005862:	27e080e7          	jalr	638(ra) # 80002adc <argstr>
    80005866:	04054b63          	bltz	a0,800058bc <sys_chdir+0x86>
    8000586a:	f6040513          	addi	a0,s0,-160
    8000586e:	ffffe097          	auipc	ra,0xffffe
    80005872:	54c080e7          	jalr	1356(ra) # 80003dba <namei>
    80005876:	84aa                	mv	s1,a0
    80005878:	c131                	beqz	a0,800058bc <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000587a:	ffffe097          	auipc	ra,0xffffe
    8000587e:	d90080e7          	jalr	-624(ra) # 8000360a <ilock>
  if(ip->type != T_DIR){
    80005882:	04449703          	lh	a4,68(s1)
    80005886:	4785                	li	a5,1
    80005888:	04f71063          	bne	a4,a5,800058c8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000588c:	8526                	mv	a0,s1
    8000588e:	ffffe097          	auipc	ra,0xffffe
    80005892:	e3e080e7          	jalr	-450(ra) # 800036cc <iunlock>
  iput(p->cwd);
    80005896:	15093503          	ld	a0,336(s2)
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	f2a080e7          	jalr	-214(ra) # 800037c4 <iput>
  end_op();
    800058a2:	ffffe097          	auipc	ra,0xffffe
    800058a6:	7a4080e7          	jalr	1956(ra) # 80004046 <end_op>
  p->cwd = ip;
    800058aa:	14993823          	sd	s1,336(s2)
  return 0;
    800058ae:	4501                	li	a0,0
}
    800058b0:	60ea                	ld	ra,152(sp)
    800058b2:	644a                	ld	s0,144(sp)
    800058b4:	64aa                	ld	s1,136(sp)
    800058b6:	690a                	ld	s2,128(sp)
    800058b8:	610d                	addi	sp,sp,160
    800058ba:	8082                	ret
    end_op();
    800058bc:	ffffe097          	auipc	ra,0xffffe
    800058c0:	78a080e7          	jalr	1930(ra) # 80004046 <end_op>
    return -1;
    800058c4:	557d                	li	a0,-1
    800058c6:	b7ed                	j	800058b0 <sys_chdir+0x7a>
    iunlockput(ip);
    800058c8:	8526                	mv	a0,s1
    800058ca:	ffffe097          	auipc	ra,0xffffe
    800058ce:	fa2080e7          	jalr	-94(ra) # 8000386c <iunlockput>
    end_op();
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	774080e7          	jalr	1908(ra) # 80004046 <end_op>
    return -1;
    800058da:	557d                	li	a0,-1
    800058dc:	bfd1                	j	800058b0 <sys_chdir+0x7a>

00000000800058de <sys_exec>:

uint64
sys_exec(void)
{
    800058de:	7145                	addi	sp,sp,-464
    800058e0:	e786                	sd	ra,456(sp)
    800058e2:	e3a2                	sd	s0,448(sp)
    800058e4:	ff26                	sd	s1,440(sp)
    800058e6:	fb4a                	sd	s2,432(sp)
    800058e8:	f74e                	sd	s3,424(sp)
    800058ea:	f352                	sd	s4,416(sp)
    800058ec:	ef56                	sd	s5,408(sp)
    800058ee:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800058f0:	08000613          	li	a2,128
    800058f4:	f4040593          	addi	a1,s0,-192
    800058f8:	4501                	li	a0,0
    800058fa:	ffffd097          	auipc	ra,0xffffd
    800058fe:	1e2080e7          	jalr	482(ra) # 80002adc <argstr>
    return -1;
    80005902:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005904:	0c054a63          	bltz	a0,800059d8 <sys_exec+0xfa>
    80005908:	e3840593          	addi	a1,s0,-456
    8000590c:	4505                	li	a0,1
    8000590e:	ffffd097          	auipc	ra,0xffffd
    80005912:	1ac080e7          	jalr	428(ra) # 80002aba <argaddr>
    80005916:	0c054163          	bltz	a0,800059d8 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    8000591a:	10000613          	li	a2,256
    8000591e:	4581                	li	a1,0
    80005920:	e4040513          	addi	a0,s0,-448
    80005924:	ffffb097          	auipc	ra,0xffffb
    80005928:	3e8080e7          	jalr	1000(ra) # 80000d0c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000592c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005930:	89a6                	mv	s3,s1
    80005932:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005934:	02000a13          	li	s4,32
    80005938:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000593c:	00391513          	slli	a0,s2,0x3
    80005940:	e3040593          	addi	a1,s0,-464
    80005944:	e3843783          	ld	a5,-456(s0)
    80005948:	953e                	add	a0,a0,a5
    8000594a:	ffffd097          	auipc	ra,0xffffd
    8000594e:	0b4080e7          	jalr	180(ra) # 800029fe <fetchaddr>
    80005952:	02054a63          	bltz	a0,80005986 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005956:	e3043783          	ld	a5,-464(s0)
    8000595a:	c3b9                	beqz	a5,800059a0 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000595c:	ffffb097          	auipc	ra,0xffffb
    80005960:	1c4080e7          	jalr	452(ra) # 80000b20 <kalloc>
    80005964:	85aa                	mv	a1,a0
    80005966:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000596a:	cd11                	beqz	a0,80005986 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000596c:	6605                	lui	a2,0x1
    8000596e:	e3043503          	ld	a0,-464(s0)
    80005972:	ffffd097          	auipc	ra,0xffffd
    80005976:	0de080e7          	jalr	222(ra) # 80002a50 <fetchstr>
    8000597a:	00054663          	bltz	a0,80005986 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    8000597e:	0905                	addi	s2,s2,1
    80005980:	09a1                	addi	s3,s3,8
    80005982:	fb491be3          	bne	s2,s4,80005938 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005986:	10048913          	addi	s2,s1,256
    8000598a:	6088                	ld	a0,0(s1)
    8000598c:	c529                	beqz	a0,800059d6 <sys_exec+0xf8>
    kfree(argv[i]);
    8000598e:	ffffb097          	auipc	ra,0xffffb
    80005992:	096080e7          	jalr	150(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005996:	04a1                	addi	s1,s1,8
    80005998:	ff2499e3          	bne	s1,s2,8000598a <sys_exec+0xac>
  return -1;
    8000599c:	597d                	li	s2,-1
    8000599e:	a82d                	j	800059d8 <sys_exec+0xfa>
      argv[i] = 0;
    800059a0:	0a8e                	slli	s5,s5,0x3
    800059a2:	fc040793          	addi	a5,s0,-64
    800059a6:	9abe                	add	s5,s5,a5
    800059a8:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800059ac:	e4040593          	addi	a1,s0,-448
    800059b0:	f4040513          	addi	a0,s0,-192
    800059b4:	fffff097          	auipc	ra,0xfffff
    800059b8:	194080e7          	jalr	404(ra) # 80004b48 <exec>
    800059bc:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059be:	10048993          	addi	s3,s1,256
    800059c2:	6088                	ld	a0,0(s1)
    800059c4:	c911                	beqz	a0,800059d8 <sys_exec+0xfa>
    kfree(argv[i]);
    800059c6:	ffffb097          	auipc	ra,0xffffb
    800059ca:	05e080e7          	jalr	94(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059ce:	04a1                	addi	s1,s1,8
    800059d0:	ff3499e3          	bne	s1,s3,800059c2 <sys_exec+0xe4>
    800059d4:	a011                	j	800059d8 <sys_exec+0xfa>
  return -1;
    800059d6:	597d                	li	s2,-1
}
    800059d8:	854a                	mv	a0,s2
    800059da:	60be                	ld	ra,456(sp)
    800059dc:	641e                	ld	s0,448(sp)
    800059de:	74fa                	ld	s1,440(sp)
    800059e0:	795a                	ld	s2,432(sp)
    800059e2:	79ba                	ld	s3,424(sp)
    800059e4:	7a1a                	ld	s4,416(sp)
    800059e6:	6afa                	ld	s5,408(sp)
    800059e8:	6179                	addi	sp,sp,464
    800059ea:	8082                	ret

00000000800059ec <sys_pipe>:

uint64
sys_pipe(void)
{
    800059ec:	7139                	addi	sp,sp,-64
    800059ee:	fc06                	sd	ra,56(sp)
    800059f0:	f822                	sd	s0,48(sp)
    800059f2:	f426                	sd	s1,40(sp)
    800059f4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800059f6:	ffffc097          	auipc	ra,0xffffc
    800059fa:	fe8080e7          	jalr	-24(ra) # 800019de <myproc>
    800059fe:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005a00:	fd840593          	addi	a1,s0,-40
    80005a04:	4501                	li	a0,0
    80005a06:	ffffd097          	auipc	ra,0xffffd
    80005a0a:	0b4080e7          	jalr	180(ra) # 80002aba <argaddr>
    return -1;
    80005a0e:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005a10:	0e054063          	bltz	a0,80005af0 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005a14:	fc840593          	addi	a1,s0,-56
    80005a18:	fd040513          	addi	a0,s0,-48
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	dd2080e7          	jalr	-558(ra) # 800047ee <pipealloc>
    return -1;
    80005a24:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a26:	0c054563          	bltz	a0,80005af0 <sys_pipe+0x104>
  fd0 = -1;
    80005a2a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a2e:	fd043503          	ld	a0,-48(s0)
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	508080e7          	jalr	1288(ra) # 80004f3a <fdalloc>
    80005a3a:	fca42223          	sw	a0,-60(s0)
    80005a3e:	08054c63          	bltz	a0,80005ad6 <sys_pipe+0xea>
    80005a42:	fc843503          	ld	a0,-56(s0)
    80005a46:	fffff097          	auipc	ra,0xfffff
    80005a4a:	4f4080e7          	jalr	1268(ra) # 80004f3a <fdalloc>
    80005a4e:	fca42023          	sw	a0,-64(s0)
    80005a52:	06054863          	bltz	a0,80005ac2 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a56:	4691                	li	a3,4
    80005a58:	fc440613          	addi	a2,s0,-60
    80005a5c:	fd843583          	ld	a1,-40(s0)
    80005a60:	68a8                	ld	a0,80(s1)
    80005a62:	ffffc097          	auipc	ra,0xffffc
    80005a66:	c70080e7          	jalr	-912(ra) # 800016d2 <copyout>
    80005a6a:	02054063          	bltz	a0,80005a8a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a6e:	4691                	li	a3,4
    80005a70:	fc040613          	addi	a2,s0,-64
    80005a74:	fd843583          	ld	a1,-40(s0)
    80005a78:	0591                	addi	a1,a1,4
    80005a7a:	68a8                	ld	a0,80(s1)
    80005a7c:	ffffc097          	auipc	ra,0xffffc
    80005a80:	c56080e7          	jalr	-938(ra) # 800016d2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a84:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a86:	06055563          	bgez	a0,80005af0 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005a8a:	fc442783          	lw	a5,-60(s0)
    80005a8e:	07e9                	addi	a5,a5,26
    80005a90:	078e                	slli	a5,a5,0x3
    80005a92:	97a6                	add	a5,a5,s1
    80005a94:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005a98:	fc042503          	lw	a0,-64(s0)
    80005a9c:	0569                	addi	a0,a0,26
    80005a9e:	050e                	slli	a0,a0,0x3
    80005aa0:	9526                	add	a0,a0,s1
    80005aa2:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005aa6:	fd043503          	ld	a0,-48(s0)
    80005aaa:	fffff097          	auipc	ra,0xfffff
    80005aae:	9ee080e7          	jalr	-1554(ra) # 80004498 <fileclose>
    fileclose(wf);
    80005ab2:	fc843503          	ld	a0,-56(s0)
    80005ab6:	fffff097          	auipc	ra,0xfffff
    80005aba:	9e2080e7          	jalr	-1566(ra) # 80004498 <fileclose>
    return -1;
    80005abe:	57fd                	li	a5,-1
    80005ac0:	a805                	j	80005af0 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005ac2:	fc442783          	lw	a5,-60(s0)
    80005ac6:	0007c863          	bltz	a5,80005ad6 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005aca:	01a78513          	addi	a0,a5,26
    80005ace:	050e                	slli	a0,a0,0x3
    80005ad0:	9526                	add	a0,a0,s1
    80005ad2:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005ad6:	fd043503          	ld	a0,-48(s0)
    80005ada:	fffff097          	auipc	ra,0xfffff
    80005ade:	9be080e7          	jalr	-1602(ra) # 80004498 <fileclose>
    fileclose(wf);
    80005ae2:	fc843503          	ld	a0,-56(s0)
    80005ae6:	fffff097          	auipc	ra,0xfffff
    80005aea:	9b2080e7          	jalr	-1614(ra) # 80004498 <fileclose>
    return -1;
    80005aee:	57fd                	li	a5,-1
}
    80005af0:	853e                	mv	a0,a5
    80005af2:	70e2                	ld	ra,56(sp)
    80005af4:	7442                	ld	s0,48(sp)
    80005af6:	74a2                	ld	s1,40(sp)
    80005af8:	6121                	addi	sp,sp,64
    80005afa:	8082                	ret
    80005afc:	0000                	unimp
	...

0000000080005b00 <kernelvec>:
    80005b00:	7111                	addi	sp,sp,-256
    80005b02:	e006                	sd	ra,0(sp)
    80005b04:	e40a                	sd	sp,8(sp)
    80005b06:	e80e                	sd	gp,16(sp)
    80005b08:	ec12                	sd	tp,24(sp)
    80005b0a:	f016                	sd	t0,32(sp)
    80005b0c:	f41a                	sd	t1,40(sp)
    80005b0e:	f81e                	sd	t2,48(sp)
    80005b10:	fc22                	sd	s0,56(sp)
    80005b12:	e0a6                	sd	s1,64(sp)
    80005b14:	e4aa                	sd	a0,72(sp)
    80005b16:	e8ae                	sd	a1,80(sp)
    80005b18:	ecb2                	sd	a2,88(sp)
    80005b1a:	f0b6                	sd	a3,96(sp)
    80005b1c:	f4ba                	sd	a4,104(sp)
    80005b1e:	f8be                	sd	a5,112(sp)
    80005b20:	fcc2                	sd	a6,120(sp)
    80005b22:	e146                	sd	a7,128(sp)
    80005b24:	e54a                	sd	s2,136(sp)
    80005b26:	e94e                	sd	s3,144(sp)
    80005b28:	ed52                	sd	s4,152(sp)
    80005b2a:	f156                	sd	s5,160(sp)
    80005b2c:	f55a                	sd	s6,168(sp)
    80005b2e:	f95e                	sd	s7,176(sp)
    80005b30:	fd62                	sd	s8,184(sp)
    80005b32:	e1e6                	sd	s9,192(sp)
    80005b34:	e5ea                	sd	s10,200(sp)
    80005b36:	e9ee                	sd	s11,208(sp)
    80005b38:	edf2                	sd	t3,216(sp)
    80005b3a:	f1f6                	sd	t4,224(sp)
    80005b3c:	f5fa                	sd	t5,232(sp)
    80005b3e:	f9fe                	sd	t6,240(sp)
    80005b40:	d8bfc0ef          	jal	ra,800028ca <kerneltrap>
    80005b44:	6082                	ld	ra,0(sp)
    80005b46:	6122                	ld	sp,8(sp)
    80005b48:	61c2                	ld	gp,16(sp)
    80005b4a:	7282                	ld	t0,32(sp)
    80005b4c:	7322                	ld	t1,40(sp)
    80005b4e:	73c2                	ld	t2,48(sp)
    80005b50:	7462                	ld	s0,56(sp)
    80005b52:	6486                	ld	s1,64(sp)
    80005b54:	6526                	ld	a0,72(sp)
    80005b56:	65c6                	ld	a1,80(sp)
    80005b58:	6666                	ld	a2,88(sp)
    80005b5a:	7686                	ld	a3,96(sp)
    80005b5c:	7726                	ld	a4,104(sp)
    80005b5e:	77c6                	ld	a5,112(sp)
    80005b60:	7866                	ld	a6,120(sp)
    80005b62:	688a                	ld	a7,128(sp)
    80005b64:	692a                	ld	s2,136(sp)
    80005b66:	69ca                	ld	s3,144(sp)
    80005b68:	6a6a                	ld	s4,152(sp)
    80005b6a:	7a8a                	ld	s5,160(sp)
    80005b6c:	7b2a                	ld	s6,168(sp)
    80005b6e:	7bca                	ld	s7,176(sp)
    80005b70:	7c6a                	ld	s8,184(sp)
    80005b72:	6c8e                	ld	s9,192(sp)
    80005b74:	6d2e                	ld	s10,200(sp)
    80005b76:	6dce                	ld	s11,208(sp)
    80005b78:	6e6e                	ld	t3,216(sp)
    80005b7a:	7e8e                	ld	t4,224(sp)
    80005b7c:	7f2e                	ld	t5,232(sp)
    80005b7e:	7fce                	ld	t6,240(sp)
    80005b80:	6111                	addi	sp,sp,256
    80005b82:	10200073          	sret
    80005b86:	00000013          	nop
    80005b8a:	00000013          	nop
    80005b8e:	0001                	nop

0000000080005b90 <timervec>:
    80005b90:	34051573          	csrrw	a0,mscratch,a0
    80005b94:	e10c                	sd	a1,0(a0)
    80005b96:	e510                	sd	a2,8(a0)
    80005b98:	e914                	sd	a3,16(a0)
    80005b9a:	710c                	ld	a1,32(a0)
    80005b9c:	7510                	ld	a2,40(a0)
    80005b9e:	6194                	ld	a3,0(a1)
    80005ba0:	96b2                	add	a3,a3,a2
    80005ba2:	e194                	sd	a3,0(a1)
    80005ba4:	4589                	li	a1,2
    80005ba6:	14459073          	csrw	sip,a1
    80005baa:	6914                	ld	a3,16(a0)
    80005bac:	6510                	ld	a2,8(a0)
    80005bae:	610c                	ld	a1,0(a0)
    80005bb0:	34051573          	csrrw	a0,mscratch,a0
    80005bb4:	30200073          	mret
	...

0000000080005bba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005bba:	1141                	addi	sp,sp,-16
    80005bbc:	e422                	sd	s0,8(sp)
    80005bbe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005bc0:	0c0007b7          	lui	a5,0xc000
    80005bc4:	4705                	li	a4,1
    80005bc6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005bc8:	c3d8                	sw	a4,4(a5)
}
    80005bca:	6422                	ld	s0,8(sp)
    80005bcc:	0141                	addi	sp,sp,16
    80005bce:	8082                	ret

0000000080005bd0 <plicinithart>:

void
plicinithart(void)
{
    80005bd0:	1141                	addi	sp,sp,-16
    80005bd2:	e406                	sd	ra,8(sp)
    80005bd4:	e022                	sd	s0,0(sp)
    80005bd6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bd8:	ffffc097          	auipc	ra,0xffffc
    80005bdc:	dda080e7          	jalr	-550(ra) # 800019b2 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005be0:	0085171b          	slliw	a4,a0,0x8
    80005be4:	0c0027b7          	lui	a5,0xc002
    80005be8:	97ba                	add	a5,a5,a4
    80005bea:	40200713          	li	a4,1026
    80005bee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005bf2:	00d5151b          	slliw	a0,a0,0xd
    80005bf6:	0c2017b7          	lui	a5,0xc201
    80005bfa:	953e                	add	a0,a0,a5
    80005bfc:	00052023          	sw	zero,0(a0)
}
    80005c00:	60a2                	ld	ra,8(sp)
    80005c02:	6402                	ld	s0,0(sp)
    80005c04:	0141                	addi	sp,sp,16
    80005c06:	8082                	ret

0000000080005c08 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c08:	1141                	addi	sp,sp,-16
    80005c0a:	e406                	sd	ra,8(sp)
    80005c0c:	e022                	sd	s0,0(sp)
    80005c0e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c10:	ffffc097          	auipc	ra,0xffffc
    80005c14:	da2080e7          	jalr	-606(ra) # 800019b2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c18:	00d5179b          	slliw	a5,a0,0xd
    80005c1c:	0c201537          	lui	a0,0xc201
    80005c20:	953e                	add	a0,a0,a5
  return irq;
}
    80005c22:	4148                	lw	a0,4(a0)
    80005c24:	60a2                	ld	ra,8(sp)
    80005c26:	6402                	ld	s0,0(sp)
    80005c28:	0141                	addi	sp,sp,16
    80005c2a:	8082                	ret

0000000080005c2c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c2c:	1101                	addi	sp,sp,-32
    80005c2e:	ec06                	sd	ra,24(sp)
    80005c30:	e822                	sd	s0,16(sp)
    80005c32:	e426                	sd	s1,8(sp)
    80005c34:	1000                	addi	s0,sp,32
    80005c36:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c38:	ffffc097          	auipc	ra,0xffffc
    80005c3c:	d7a080e7          	jalr	-646(ra) # 800019b2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c40:	00d5151b          	slliw	a0,a0,0xd
    80005c44:	0c2017b7          	lui	a5,0xc201
    80005c48:	97aa                	add	a5,a5,a0
    80005c4a:	c3c4                	sw	s1,4(a5)
}
    80005c4c:	60e2                	ld	ra,24(sp)
    80005c4e:	6442                	ld	s0,16(sp)
    80005c50:	64a2                	ld	s1,8(sp)
    80005c52:	6105                	addi	sp,sp,32
    80005c54:	8082                	ret

0000000080005c56 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c56:	1141                	addi	sp,sp,-16
    80005c58:	e406                	sd	ra,8(sp)
    80005c5a:	e022                	sd	s0,0(sp)
    80005c5c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c5e:	479d                	li	a5,7
    80005c60:	04a7cc63          	blt	a5,a0,80005cb8 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005c64:	0001d797          	auipc	a5,0x1d
    80005c68:	39c78793          	addi	a5,a5,924 # 80023000 <disk>
    80005c6c:	00a78733          	add	a4,a5,a0
    80005c70:	6789                	lui	a5,0x2
    80005c72:	97ba                	add	a5,a5,a4
    80005c74:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005c78:	eba1                	bnez	a5,80005cc8 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005c7a:	00451713          	slli	a4,a0,0x4
    80005c7e:	0001f797          	auipc	a5,0x1f
    80005c82:	3827b783          	ld	a5,898(a5) # 80025000 <disk+0x2000>
    80005c86:	97ba                	add	a5,a5,a4
    80005c88:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005c8c:	0001d797          	auipc	a5,0x1d
    80005c90:	37478793          	addi	a5,a5,884 # 80023000 <disk>
    80005c94:	97aa                	add	a5,a5,a0
    80005c96:	6509                	lui	a0,0x2
    80005c98:	953e                	add	a0,a0,a5
    80005c9a:	4785                	li	a5,1
    80005c9c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005ca0:	0001f517          	auipc	a0,0x1f
    80005ca4:	37850513          	addi	a0,a0,888 # 80025018 <disk+0x2018>
    80005ca8:	ffffc097          	auipc	ra,0xffffc
    80005cac:	6c8080e7          	jalr	1736(ra) # 80002370 <wakeup>
}
    80005cb0:	60a2                	ld	ra,8(sp)
    80005cb2:	6402                	ld	s0,0(sp)
    80005cb4:	0141                	addi	sp,sp,16
    80005cb6:	8082                	ret
    panic("virtio_disk_intr 1");
    80005cb8:	00003517          	auipc	a0,0x3
    80005cbc:	aa050513          	addi	a0,a0,-1376 # 80008758 <syscalls+0x330>
    80005cc0:	ffffb097          	auipc	ra,0xffffb
    80005cc4:	888080e7          	jalr	-1912(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80005cc8:	00003517          	auipc	a0,0x3
    80005ccc:	aa850513          	addi	a0,a0,-1368 # 80008770 <syscalls+0x348>
    80005cd0:	ffffb097          	auipc	ra,0xffffb
    80005cd4:	878080e7          	jalr	-1928(ra) # 80000548 <panic>

0000000080005cd8 <virtio_disk_init>:
{
    80005cd8:	1101                	addi	sp,sp,-32
    80005cda:	ec06                	sd	ra,24(sp)
    80005cdc:	e822                	sd	s0,16(sp)
    80005cde:	e426                	sd	s1,8(sp)
    80005ce0:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ce2:	00003597          	auipc	a1,0x3
    80005ce6:	aa658593          	addi	a1,a1,-1370 # 80008788 <syscalls+0x360>
    80005cea:	0001f517          	auipc	a0,0x1f
    80005cee:	3be50513          	addi	a0,a0,958 # 800250a8 <disk+0x20a8>
    80005cf2:	ffffb097          	auipc	ra,0xffffb
    80005cf6:	e8e080e7          	jalr	-370(ra) # 80000b80 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005cfa:	100017b7          	lui	a5,0x10001
    80005cfe:	4398                	lw	a4,0(a5)
    80005d00:	2701                	sext.w	a4,a4
    80005d02:	747277b7          	lui	a5,0x74727
    80005d06:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d0a:	0ef71163          	bne	a4,a5,80005dec <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005d0e:	100017b7          	lui	a5,0x10001
    80005d12:	43dc                	lw	a5,4(a5)
    80005d14:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d16:	4705                	li	a4,1
    80005d18:	0ce79a63          	bne	a5,a4,80005dec <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d1c:	100017b7          	lui	a5,0x10001
    80005d20:	479c                	lw	a5,8(a5)
    80005d22:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005d24:	4709                	li	a4,2
    80005d26:	0ce79363          	bne	a5,a4,80005dec <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d2a:	100017b7          	lui	a5,0x10001
    80005d2e:	47d8                	lw	a4,12(a5)
    80005d30:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d32:	554d47b7          	lui	a5,0x554d4
    80005d36:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d3a:	0af71963          	bne	a4,a5,80005dec <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d3e:	100017b7          	lui	a5,0x10001
    80005d42:	4705                	li	a4,1
    80005d44:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d46:	470d                	li	a4,3
    80005d48:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005d4a:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005d4c:	c7ffe737          	lui	a4,0xc7ffe
    80005d50:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005d54:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d56:	2701                	sext.w	a4,a4
    80005d58:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d5a:	472d                	li	a4,11
    80005d5c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d5e:	473d                	li	a4,15
    80005d60:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005d62:	6705                	lui	a4,0x1
    80005d64:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d66:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d6a:	5bdc                	lw	a5,52(a5)
    80005d6c:	2781                	sext.w	a5,a5
  if(max == 0)
    80005d6e:	c7d9                	beqz	a5,80005dfc <virtio_disk_init+0x124>
  if(max < NUM)
    80005d70:	471d                	li	a4,7
    80005d72:	08f77d63          	bgeu	a4,a5,80005e0c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005d76:	100014b7          	lui	s1,0x10001
    80005d7a:	47a1                	li	a5,8
    80005d7c:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005d7e:	6609                	lui	a2,0x2
    80005d80:	4581                	li	a1,0
    80005d82:	0001d517          	auipc	a0,0x1d
    80005d86:	27e50513          	addi	a0,a0,638 # 80023000 <disk>
    80005d8a:	ffffb097          	auipc	ra,0xffffb
    80005d8e:	f82080e7          	jalr	-126(ra) # 80000d0c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005d92:	0001d717          	auipc	a4,0x1d
    80005d96:	26e70713          	addi	a4,a4,622 # 80023000 <disk>
    80005d9a:	00c75793          	srli	a5,a4,0xc
    80005d9e:	2781                	sext.w	a5,a5
    80005da0:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005da2:	0001f797          	auipc	a5,0x1f
    80005da6:	25e78793          	addi	a5,a5,606 # 80025000 <disk+0x2000>
    80005daa:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005dac:	0001d717          	auipc	a4,0x1d
    80005db0:	2d470713          	addi	a4,a4,724 # 80023080 <disk+0x80>
    80005db4:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005db6:	0001e717          	auipc	a4,0x1e
    80005dba:	24a70713          	addi	a4,a4,586 # 80024000 <disk+0x1000>
    80005dbe:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005dc0:	4705                	li	a4,1
    80005dc2:	00e78c23          	sb	a4,24(a5)
    80005dc6:	00e78ca3          	sb	a4,25(a5)
    80005dca:	00e78d23          	sb	a4,26(a5)
    80005dce:	00e78da3          	sb	a4,27(a5)
    80005dd2:	00e78e23          	sb	a4,28(a5)
    80005dd6:	00e78ea3          	sb	a4,29(a5)
    80005dda:	00e78f23          	sb	a4,30(a5)
    80005dde:	00e78fa3          	sb	a4,31(a5)
}
    80005de2:	60e2                	ld	ra,24(sp)
    80005de4:	6442                	ld	s0,16(sp)
    80005de6:	64a2                	ld	s1,8(sp)
    80005de8:	6105                	addi	sp,sp,32
    80005dea:	8082                	ret
    panic("could not find virtio disk");
    80005dec:	00003517          	auipc	a0,0x3
    80005df0:	9ac50513          	addi	a0,a0,-1620 # 80008798 <syscalls+0x370>
    80005df4:	ffffa097          	auipc	ra,0xffffa
    80005df8:	754080e7          	jalr	1876(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    80005dfc:	00003517          	auipc	a0,0x3
    80005e00:	9bc50513          	addi	a0,a0,-1604 # 800087b8 <syscalls+0x390>
    80005e04:	ffffa097          	auipc	ra,0xffffa
    80005e08:	744080e7          	jalr	1860(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    80005e0c:	00003517          	auipc	a0,0x3
    80005e10:	9cc50513          	addi	a0,a0,-1588 # 800087d8 <syscalls+0x3b0>
    80005e14:	ffffa097          	auipc	ra,0xffffa
    80005e18:	734080e7          	jalr	1844(ra) # 80000548 <panic>

0000000080005e1c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005e1c:	7119                	addi	sp,sp,-128
    80005e1e:	fc86                	sd	ra,120(sp)
    80005e20:	f8a2                	sd	s0,112(sp)
    80005e22:	f4a6                	sd	s1,104(sp)
    80005e24:	f0ca                	sd	s2,96(sp)
    80005e26:	ecce                	sd	s3,88(sp)
    80005e28:	e8d2                	sd	s4,80(sp)
    80005e2a:	e4d6                	sd	s5,72(sp)
    80005e2c:	e0da                	sd	s6,64(sp)
    80005e2e:	fc5e                	sd	s7,56(sp)
    80005e30:	f862                	sd	s8,48(sp)
    80005e32:	f466                	sd	s9,40(sp)
    80005e34:	f06a                	sd	s10,32(sp)
    80005e36:	0100                	addi	s0,sp,128
    80005e38:	892a                	mv	s2,a0
    80005e3a:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005e3c:	00c52c83          	lw	s9,12(a0)
    80005e40:	001c9c9b          	slliw	s9,s9,0x1
    80005e44:	1c82                	slli	s9,s9,0x20
    80005e46:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005e4a:	0001f517          	auipc	a0,0x1f
    80005e4e:	25e50513          	addi	a0,a0,606 # 800250a8 <disk+0x20a8>
    80005e52:	ffffb097          	auipc	ra,0xffffb
    80005e56:	dbe080e7          	jalr	-578(ra) # 80000c10 <acquire>
  for(int i = 0; i < 3; i++){
    80005e5a:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005e5c:	4c21                	li	s8,8
      disk.free[i] = 0;
    80005e5e:	0001db97          	auipc	s7,0x1d
    80005e62:	1a2b8b93          	addi	s7,s7,418 # 80023000 <disk>
    80005e66:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005e68:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005e6a:	8a4e                	mv	s4,s3
    80005e6c:	a051                	j	80005ef0 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80005e6e:	00fb86b3          	add	a3,s7,a5
    80005e72:	96da                	add	a3,a3,s6
    80005e74:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005e78:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005e7a:	0207c563          	bltz	a5,80005ea4 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005e7e:	2485                	addiw	s1,s1,1
    80005e80:	0711                	addi	a4,a4,4
    80005e82:	23548d63          	beq	s1,s5,800060bc <virtio_disk_rw+0x2a0>
    idx[i] = alloc_desc();
    80005e86:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005e88:	0001f697          	auipc	a3,0x1f
    80005e8c:	19068693          	addi	a3,a3,400 # 80025018 <disk+0x2018>
    80005e90:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80005e92:	0006c583          	lbu	a1,0(a3)
    80005e96:	fde1                	bnez	a1,80005e6e <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005e98:	2785                	addiw	a5,a5,1
    80005e9a:	0685                	addi	a3,a3,1
    80005e9c:	ff879be3          	bne	a5,s8,80005e92 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005ea0:	57fd                	li	a5,-1
    80005ea2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80005ea4:	02905a63          	blez	s1,80005ed8 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005ea8:	f9042503          	lw	a0,-112(s0)
    80005eac:	00000097          	auipc	ra,0x0
    80005eb0:	daa080e7          	jalr	-598(ra) # 80005c56 <free_desc>
      for(int j = 0; j < i; j++)
    80005eb4:	4785                	li	a5,1
    80005eb6:	0297d163          	bge	a5,s1,80005ed8 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005eba:	f9442503          	lw	a0,-108(s0)
    80005ebe:	00000097          	auipc	ra,0x0
    80005ec2:	d98080e7          	jalr	-616(ra) # 80005c56 <free_desc>
      for(int j = 0; j < i; j++)
    80005ec6:	4789                	li	a5,2
    80005ec8:	0097d863          	bge	a5,s1,80005ed8 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005ecc:	f9842503          	lw	a0,-104(s0)
    80005ed0:	00000097          	auipc	ra,0x0
    80005ed4:	d86080e7          	jalr	-634(ra) # 80005c56 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ed8:	0001f597          	auipc	a1,0x1f
    80005edc:	1d058593          	addi	a1,a1,464 # 800250a8 <disk+0x20a8>
    80005ee0:	0001f517          	auipc	a0,0x1f
    80005ee4:	13850513          	addi	a0,a0,312 # 80025018 <disk+0x2018>
    80005ee8:	ffffc097          	auipc	ra,0xffffc
    80005eec:	302080e7          	jalr	770(ra) # 800021ea <sleep>
  for(int i = 0; i < 3; i++){
    80005ef0:	f9040713          	addi	a4,s0,-112
    80005ef4:	84ce                	mv	s1,s3
    80005ef6:	bf41                	j	80005e86 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80005ef8:	4785                	li	a5,1
    80005efa:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    80005efe:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    80005f02:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80005f06:	f9042983          	lw	s3,-112(s0)
    80005f0a:	00499493          	slli	s1,s3,0x4
    80005f0e:	0001fa17          	auipc	s4,0x1f
    80005f12:	0f2a0a13          	addi	s4,s4,242 # 80025000 <disk+0x2000>
    80005f16:	000a3a83          	ld	s5,0(s4)
    80005f1a:	9aa6                	add	s5,s5,s1
    80005f1c:	f8040513          	addi	a0,s0,-128
    80005f20:	ffffb097          	auipc	ra,0xffffb
    80005f24:	1c0080e7          	jalr	448(ra) # 800010e0 <kvmpa>
    80005f28:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    80005f2c:	000a3783          	ld	a5,0(s4)
    80005f30:	97a6                	add	a5,a5,s1
    80005f32:	4741                	li	a4,16
    80005f34:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005f36:	000a3783          	ld	a5,0(s4)
    80005f3a:	97a6                	add	a5,a5,s1
    80005f3c:	4705                	li	a4,1
    80005f3e:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80005f42:	f9442703          	lw	a4,-108(s0)
    80005f46:	000a3783          	ld	a5,0(s4)
    80005f4a:	97a6                	add	a5,a5,s1
    80005f4c:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005f50:	0712                	slli	a4,a4,0x4
    80005f52:	000a3783          	ld	a5,0(s4)
    80005f56:	97ba                	add	a5,a5,a4
    80005f58:	05890693          	addi	a3,s2,88
    80005f5c:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    80005f5e:	000a3783          	ld	a5,0(s4)
    80005f62:	97ba                	add	a5,a5,a4
    80005f64:	40000693          	li	a3,1024
    80005f68:	c794                	sw	a3,8(a5)
  if(write)
    80005f6a:	100d0a63          	beqz	s10,8000607e <virtio_disk_rw+0x262>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005f6e:	0001f797          	auipc	a5,0x1f
    80005f72:	0927b783          	ld	a5,146(a5) # 80025000 <disk+0x2000>
    80005f76:	97ba                	add	a5,a5,a4
    80005f78:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005f7c:	0001d517          	auipc	a0,0x1d
    80005f80:	08450513          	addi	a0,a0,132 # 80023000 <disk>
    80005f84:	0001f797          	auipc	a5,0x1f
    80005f88:	07c78793          	addi	a5,a5,124 # 80025000 <disk+0x2000>
    80005f8c:	6394                	ld	a3,0(a5)
    80005f8e:	96ba                	add	a3,a3,a4
    80005f90:	00c6d603          	lhu	a2,12(a3)
    80005f94:	00166613          	ori	a2,a2,1
    80005f98:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005f9c:	f9842683          	lw	a3,-104(s0)
    80005fa0:	6390                	ld	a2,0(a5)
    80005fa2:	9732                	add	a4,a4,a2
    80005fa4:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80005fa8:	20098613          	addi	a2,s3,512
    80005fac:	0612                	slli	a2,a2,0x4
    80005fae:	962a                	add	a2,a2,a0
    80005fb0:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005fb4:	00469713          	slli	a4,a3,0x4
    80005fb8:	6394                	ld	a3,0(a5)
    80005fba:	96ba                	add	a3,a3,a4
    80005fbc:	6589                	lui	a1,0x2
    80005fbe:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    80005fc2:	94ae                	add	s1,s1,a1
    80005fc4:	94aa                	add	s1,s1,a0
    80005fc6:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    80005fc8:	6394                	ld	a3,0(a5)
    80005fca:	96ba                	add	a3,a3,a4
    80005fcc:	4585                	li	a1,1
    80005fce:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005fd0:	6394                	ld	a3,0(a5)
    80005fd2:	96ba                	add	a3,a3,a4
    80005fd4:	4509                	li	a0,2
    80005fd6:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    80005fda:	6394                	ld	a3,0(a5)
    80005fdc:	9736                	add	a4,a4,a3
    80005fde:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005fe2:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80005fe6:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    80005fea:	6794                	ld	a3,8(a5)
    80005fec:	0026d703          	lhu	a4,2(a3)
    80005ff0:	8b1d                	andi	a4,a4,7
    80005ff2:	2709                	addiw	a4,a4,2
    80005ff4:	0706                	slli	a4,a4,0x1
    80005ff6:	9736                	add	a4,a4,a3
    80005ff8:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    80005ffc:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80006000:	6798                	ld	a4,8(a5)
    80006002:	00275783          	lhu	a5,2(a4)
    80006006:	2785                	addiw	a5,a5,1
    80006008:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000600c:	100017b7          	lui	a5,0x10001
    80006010:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006014:	00492703          	lw	a4,4(s2)
    80006018:	4785                	li	a5,1
    8000601a:	02f71163          	bne	a4,a5,8000603c <virtio_disk_rw+0x220>
    sleep(b, &disk.vdisk_lock);
    8000601e:	0001f997          	auipc	s3,0x1f
    80006022:	08a98993          	addi	s3,s3,138 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006026:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006028:	85ce                	mv	a1,s3
    8000602a:	854a                	mv	a0,s2
    8000602c:	ffffc097          	auipc	ra,0xffffc
    80006030:	1be080e7          	jalr	446(ra) # 800021ea <sleep>
  while(b->disk == 1) {
    80006034:	00492783          	lw	a5,4(s2)
    80006038:	fe9788e3          	beq	a5,s1,80006028 <virtio_disk_rw+0x20c>
  }

  disk.info[idx[0]].b = 0;
    8000603c:	f9042483          	lw	s1,-112(s0)
    80006040:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    80006044:	00479713          	slli	a4,a5,0x4
    80006048:	0001d797          	auipc	a5,0x1d
    8000604c:	fb878793          	addi	a5,a5,-72 # 80023000 <disk>
    80006050:	97ba                	add	a5,a5,a4
    80006052:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006056:	0001f917          	auipc	s2,0x1f
    8000605a:	faa90913          	addi	s2,s2,-86 # 80025000 <disk+0x2000>
    free_desc(i);
    8000605e:	8526                	mv	a0,s1
    80006060:	00000097          	auipc	ra,0x0
    80006064:	bf6080e7          	jalr	-1034(ra) # 80005c56 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006068:	0492                	slli	s1,s1,0x4
    8000606a:	00093783          	ld	a5,0(s2)
    8000606e:	94be                	add	s1,s1,a5
    80006070:	00c4d783          	lhu	a5,12(s1)
    80006074:	8b85                	andi	a5,a5,1
    80006076:	cf89                	beqz	a5,80006090 <virtio_disk_rw+0x274>
      i = disk.desc[i].next;
    80006078:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    8000607c:	b7cd                	j	8000605e <virtio_disk_rw+0x242>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000607e:	0001f797          	auipc	a5,0x1f
    80006082:	f827b783          	ld	a5,-126(a5) # 80025000 <disk+0x2000>
    80006086:	97ba                	add	a5,a5,a4
    80006088:	4689                	li	a3,2
    8000608a:	00d79623          	sh	a3,12(a5)
    8000608e:	b5fd                	j	80005f7c <virtio_disk_rw+0x160>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006090:	0001f517          	auipc	a0,0x1f
    80006094:	01850513          	addi	a0,a0,24 # 800250a8 <disk+0x20a8>
    80006098:	ffffb097          	auipc	ra,0xffffb
    8000609c:	c2c080e7          	jalr	-980(ra) # 80000cc4 <release>
}
    800060a0:	70e6                	ld	ra,120(sp)
    800060a2:	7446                	ld	s0,112(sp)
    800060a4:	74a6                	ld	s1,104(sp)
    800060a6:	7906                	ld	s2,96(sp)
    800060a8:	69e6                	ld	s3,88(sp)
    800060aa:	6a46                	ld	s4,80(sp)
    800060ac:	6aa6                	ld	s5,72(sp)
    800060ae:	6b06                	ld	s6,64(sp)
    800060b0:	7be2                	ld	s7,56(sp)
    800060b2:	7c42                	ld	s8,48(sp)
    800060b4:	7ca2                	ld	s9,40(sp)
    800060b6:	7d02                	ld	s10,32(sp)
    800060b8:	6109                	addi	sp,sp,128
    800060ba:	8082                	ret
  if(write)
    800060bc:	e20d1ee3          	bnez	s10,80005ef8 <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    800060c0:	f8042023          	sw	zero,-128(s0)
    800060c4:	bd2d                	j	80005efe <virtio_disk_rw+0xe2>

00000000800060c6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800060c6:	1101                	addi	sp,sp,-32
    800060c8:	ec06                	sd	ra,24(sp)
    800060ca:	e822                	sd	s0,16(sp)
    800060cc:	e426                	sd	s1,8(sp)
    800060ce:	e04a                	sd	s2,0(sp)
    800060d0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800060d2:	0001f517          	auipc	a0,0x1f
    800060d6:	fd650513          	addi	a0,a0,-42 # 800250a8 <disk+0x20a8>
    800060da:	ffffb097          	auipc	ra,0xffffb
    800060de:	b36080e7          	jalr	-1226(ra) # 80000c10 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800060e2:	0001f717          	auipc	a4,0x1f
    800060e6:	f1e70713          	addi	a4,a4,-226 # 80025000 <disk+0x2000>
    800060ea:	02075783          	lhu	a5,32(a4)
    800060ee:	6b18                	ld	a4,16(a4)
    800060f0:	00275683          	lhu	a3,2(a4)
    800060f4:	8ebd                	xor	a3,a3,a5
    800060f6:	8a9d                	andi	a3,a3,7
    800060f8:	cab9                	beqz	a3,8000614e <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    800060fa:	0001d917          	auipc	s2,0x1d
    800060fe:	f0690913          	addi	s2,s2,-250 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006102:	0001f497          	auipc	s1,0x1f
    80006106:	efe48493          	addi	s1,s1,-258 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000610a:	078e                	slli	a5,a5,0x3
    8000610c:	97ba                	add	a5,a5,a4
    8000610e:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006110:	20078713          	addi	a4,a5,512
    80006114:	0712                	slli	a4,a4,0x4
    80006116:	974a                	add	a4,a4,s2
    80006118:	03074703          	lbu	a4,48(a4)
    8000611c:	ef21                	bnez	a4,80006174 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000611e:	20078793          	addi	a5,a5,512
    80006122:	0792                	slli	a5,a5,0x4
    80006124:	97ca                	add	a5,a5,s2
    80006126:	7798                	ld	a4,40(a5)
    80006128:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    8000612c:	7788                	ld	a0,40(a5)
    8000612e:	ffffc097          	auipc	ra,0xffffc
    80006132:	242080e7          	jalr	578(ra) # 80002370 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006136:	0204d783          	lhu	a5,32(s1)
    8000613a:	2785                	addiw	a5,a5,1
    8000613c:	8b9d                	andi	a5,a5,7
    8000613e:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006142:	6898                	ld	a4,16(s1)
    80006144:	00275683          	lhu	a3,2(a4)
    80006148:	8a9d                	andi	a3,a3,7
    8000614a:	fcf690e3          	bne	a3,a5,8000610a <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000614e:	10001737          	lui	a4,0x10001
    80006152:	533c                	lw	a5,96(a4)
    80006154:	8b8d                	andi	a5,a5,3
    80006156:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006158:	0001f517          	auipc	a0,0x1f
    8000615c:	f5050513          	addi	a0,a0,-176 # 800250a8 <disk+0x20a8>
    80006160:	ffffb097          	auipc	ra,0xffffb
    80006164:	b64080e7          	jalr	-1180(ra) # 80000cc4 <release>
}
    80006168:	60e2                	ld	ra,24(sp)
    8000616a:	6442                	ld	s0,16(sp)
    8000616c:	64a2                	ld	s1,8(sp)
    8000616e:	6902                	ld	s2,0(sp)
    80006170:	6105                	addi	sp,sp,32
    80006172:	8082                	ret
      panic("virtio_disk_intr status");
    80006174:	00002517          	auipc	a0,0x2
    80006178:	68450513          	addi	a0,a0,1668 # 800087f8 <syscalls+0x3d0>
    8000617c:	ffffa097          	auipc	ra,0xffffa
    80006180:	3cc080e7          	jalr	972(ra) # 80000548 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
