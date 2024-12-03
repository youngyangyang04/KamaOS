
user/_primes:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sieve>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// 筛选质数的函数，接收一个管道作为参数
void sieve(int pleft[2]) {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	0080                	addi	s0,sp,64
   c:	84aa                	mv	s1,a0
	// 从左邻居读取整数
	int p;
	read(pleft[0], &p, sizeof(p));
   e:	4611                	li	a2,4
  10:	fdc40593          	addi	a1,s0,-36
  14:	4108                	lw	a0,0(a0)
  16:	00000097          	auipc	ra,0x0
  1a:	418080e7          	jalr	1048(ra) # 42e <read>
	if(p == -1) { 
  1e:	fdc42583          	lw	a1,-36(s0)
  22:	57fd                	li	a5,-1
  24:	04f58c63          	beq	a1,a5,7c <sieve+0x7c>
		exit(0);    // 如果读取到-1，表示结束，退出进程
	}
	printf("prime %d\n", p);    // 此时接收到的数字肯定是质数
  28:	00001517          	auipc	a0,0x1
  2c:	90850513          	addi	a0,a0,-1784 # 930 <malloc+0xe4>
  30:	00000097          	auipc	ra,0x0
  34:	75e080e7          	jalr	1886(ra) # 78e <printf>

    // 创建一个新的管道
    int pright[2];
	pipe(pright); 
  38:	fd040513          	addi	a0,s0,-48
  3c:	00000097          	auipc	ra,0x0
  40:	3ea080e7          	jalr	1002(ra) # 426 <pipe>

	if(fork() == 0) {       // 右邻居
  44:	00000097          	auipc	ra,0x0
  48:	3ca080e7          	jalr	970(ra) # 40e <fork>
  4c:	ed0d                	bnez	a0,86 <sieve+0x86>
		close(pright[1]);   // 右邻居用不到这个管道的写端，关闭
  4e:	fd442503          	lw	a0,-44(s0)
  52:	00000097          	auipc	ra,0x0
  56:	3ec080e7          	jalr	1004(ra) # 43e <close>
		close(pleft[0]);    // 右邻居用不到这个管道的读端，关闭
  5a:	4088                	lw	a0,0(s1)
  5c:	00000097          	auipc	ra,0x0
  60:	3e2080e7          	jalr	994(ra) # 43e <close>
		sieve(pright);      // 递归调用筛选函数
  64:	fd040513          	addi	a0,s0,-48
  68:	00000097          	auipc	ra,0x0
  6c:	f98080e7          	jalr	-104(ra) # 0 <sieve>
        buf = -1;
		write(pright[1], &buf, sizeof(buf)); 
		wait(0); 
		exit(0);
	}
}
  70:	70e2                	ld	ra,56(sp)
  72:	7442                	ld	s0,48(sp)
  74:	74a2                	ld	s1,40(sp)
  76:	7902                	ld	s2,32(sp)
  78:	6121                	addi	sp,sp,64
  7a:	8082                	ret
		exit(0);    // 如果读取到-1，表示结束，退出进程
  7c:	4501                	li	a0,0
  7e:	00000097          	auipc	ra,0x0
  82:	398080e7          	jalr	920(ra) # 416 <exit>
        close(pright[0]);       // 当前进程用不到这个管道的读端，关闭
  86:	fd042503          	lw	a0,-48(s0)
  8a:	00000097          	auipc	ra,0x0
  8e:	3b4080e7          	jalr	948(ra) # 43e <close>
		while(read(pleft[0], &buf, sizeof(buf)) && buf != -1) { 
  92:	597d                	li	s2,-1
  94:	4611                	li	a2,4
  96:	fcc40593          	addi	a1,s0,-52
  9a:	4088                	lw	a0,0(s1)
  9c:	00000097          	auipc	ra,0x0
  a0:	392080e7          	jalr	914(ra) # 42e <read>
  a4:	c505                	beqz	a0,cc <sieve+0xcc>
  a6:	fcc42783          	lw	a5,-52(s0)
  aa:	03278163          	beq	a5,s2,cc <sieve+0xcc>
			if(buf % p != 0) {                              // 如果接收到的数字不是第一次接收到的数字的倍数
  ae:	fdc42703          	lw	a4,-36(s0)
  b2:	02e7e7bb          	remw	a5,a5,a4
  b6:	dff9                	beqz	a5,94 <sieve+0x94>
				write(pright[1], &buf, sizeof(buf));        // 才往管道中给右邻居写入这个数字
  b8:	4611                	li	a2,4
  ba:	fcc40593          	addi	a1,s0,-52
  be:	fd442503          	lw	a0,-44(s0)
  c2:	00000097          	auipc	ra,0x0
  c6:	374080e7          	jalr	884(ra) # 436 <write>
  ca:	b7e9                	j	94 <sieve+0x94>
        buf = -1;
  cc:	57fd                	li	a5,-1
  ce:	fcf42623          	sw	a5,-52(s0)
		write(pright[1], &buf, sizeof(buf)); 
  d2:	4611                	li	a2,4
  d4:	fcc40593          	addi	a1,s0,-52
  d8:	fd442503          	lw	a0,-44(s0)
  dc:	00000097          	auipc	ra,0x0
  e0:	35a080e7          	jalr	858(ra) # 436 <write>
		wait(0); 
  e4:	4501                	li	a0,0
  e6:	00000097          	auipc	ra,0x0
  ea:	338080e7          	jalr	824(ra) # 41e <wait>
		exit(0);
  ee:	4501                	li	a0,0
  f0:	00000097          	auipc	ra,0x0
  f4:	326080e7          	jalr	806(ra) # 416 <exit>

00000000000000f8 <main>:

int main(int argc, char **argv) {
  f8:	7179                	addi	sp,sp,-48
  fa:	f406                	sd	ra,40(sp)
  fc:	f022                	sd	s0,32(sp)
  fe:	ec26                	sd	s1,24(sp)
 100:	1800                	addi	s0,sp,48
	// 创建初始管道
	int input_pipe[2];
	pipe(input_pipe); 
 102:	fd840513          	addi	a0,s0,-40
 106:	00000097          	auipc	ra,0x0
 10a:	320080e7          	jalr	800(ra) # 426 <pipe>

	if(fork() == 0) {				// 右邻居
 10e:	00000097          	auipc	ra,0x0
 112:	300080e7          	jalr	768(ra) # 40e <fork>
 116:	e115                	bnez	a0,13a <main+0x42>
		close(input_pipe[1]); 		// 右邻居用不到这个管道的写端，关闭右邻居的管道写文件描述符
 118:	fdc42503          	lw	a0,-36(s0)
 11c:	00000097          	auipc	ra,0x0
 120:	322080e7          	jalr	802(ra) # 43e <close>
		sieve(input_pipe);			// 调用筛选函数
 124:	fd840513          	addi	a0,s0,-40
 128:	00000097          	auipc	ra,0x0
 12c:	ed8080e7          	jalr	-296(ra) # 0 <sieve>
		exit(0);
 130:	4501                	li	a0,0
 132:	00000097          	auipc	ra,0x0
 136:	2e4080e7          	jalr	740(ra) # 416 <exit>
	} else {						// 父进程	
		close(input_pipe[0]); 		// 父进程只会向管道中给右邻居写数据，关闭父进程的管道读文件描述符
 13a:	fd842503          	lw	a0,-40(s0)
 13e:	00000097          	auipc	ra,0x0
 142:	300080e7          	jalr	768(ra) # 43e <close>
		int i;
		for(i=2;i<=35;i++){
 146:	4789                	li	a5,2
 148:	fcf42a23          	sw	a5,-44(s0)
 14c:	02300493          	li	s1,35
			write(input_pipe[1], &i, sizeof(i));	// 向管道写入2~35的整数
 150:	4611                	li	a2,4
 152:	fd440593          	addi	a1,s0,-44
 156:	fdc42503          	lw	a0,-36(s0)
 15a:	00000097          	auipc	ra,0x0
 15e:	2dc080e7          	jalr	732(ra) # 436 <write>
		for(i=2;i<=35;i++){
 162:	fd442783          	lw	a5,-44(s0)
 166:	2785                	addiw	a5,a5,1
 168:	0007871b          	sext.w	a4,a5
 16c:	fcf42a23          	sw	a5,-44(s0)
 170:	fee4d0e3          	bge	s1,a4,150 <main+0x58>
		}
		// 写入结束标志
		i = -1;
 174:	57fd                	li	a5,-1
 176:	fcf42a23          	sw	a5,-44(s0)
		write(input_pipe[1], &i, sizeof(i)); 
 17a:	4611                	li	a2,4
 17c:	fd440593          	addi	a1,s0,-44
 180:	fdc42503          	lw	a0,-36(s0)
 184:	00000097          	auipc	ra,0x0
 188:	2b2080e7          	jalr	690(ra) # 436 <write>
	}
	wait(0); 	// 等待子进程结束
 18c:	4501                	li	a0,0
 18e:	00000097          	auipc	ra,0x0
 192:	290080e7          	jalr	656(ra) # 41e <wait>
	// 注意：这里无法等待子进程的子进程，只能等待直接子进程，无法等待间接子进程。
	// 在 sieve() 中再各自执行 wait(0)，形成等待链
	exit(0);	// 退出进程
 196:	4501                	li	a0,0
 198:	00000097          	auipc	ra,0x0
 19c:	27e080e7          	jalr	638(ra) # 416 <exit>

00000000000001a0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1a6:	87aa                	mv	a5,a0
 1a8:	0585                	addi	a1,a1,1
 1aa:	0785                	addi	a5,a5,1
 1ac:	fff5c703          	lbu	a4,-1(a1)
 1b0:	fee78fa3          	sb	a4,-1(a5)
 1b4:	fb75                	bnez	a4,1a8 <strcpy+0x8>
    ;
  return os;
}
 1b6:	6422                	ld	s0,8(sp)
 1b8:	0141                	addi	sp,sp,16
 1ba:	8082                	ret

00000000000001bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e422                	sd	s0,8(sp)
 1c0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1c2:	00054783          	lbu	a5,0(a0)
 1c6:	cb91                	beqz	a5,1da <strcmp+0x1e>
 1c8:	0005c703          	lbu	a4,0(a1)
 1cc:	00f71763          	bne	a4,a5,1da <strcmp+0x1e>
    p++, q++;
 1d0:	0505                	addi	a0,a0,1
 1d2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1d4:	00054783          	lbu	a5,0(a0)
 1d8:	fbe5                	bnez	a5,1c8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1da:	0005c503          	lbu	a0,0(a1)
}
 1de:	40a7853b          	subw	a0,a5,a0
 1e2:	6422                	ld	s0,8(sp)
 1e4:	0141                	addi	sp,sp,16
 1e6:	8082                	ret

00000000000001e8 <strlen>:

uint
strlen(const char *s)
{
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e422                	sd	s0,8(sp)
 1ec:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ee:	00054783          	lbu	a5,0(a0)
 1f2:	cf91                	beqz	a5,20e <strlen+0x26>
 1f4:	0505                	addi	a0,a0,1
 1f6:	87aa                	mv	a5,a0
 1f8:	4685                	li	a3,1
 1fa:	9e89                	subw	a3,a3,a0
 1fc:	00f6853b          	addw	a0,a3,a5
 200:	0785                	addi	a5,a5,1
 202:	fff7c703          	lbu	a4,-1(a5)
 206:	fb7d                	bnez	a4,1fc <strlen+0x14>
    ;
  return n;
}
 208:	6422                	ld	s0,8(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret
  for(n = 0; s[n]; n++)
 20e:	4501                	li	a0,0
 210:	bfe5                	j	208 <strlen+0x20>

0000000000000212 <memset>:

void*
memset(void *dst, int c, uint n)
{
 212:	1141                	addi	sp,sp,-16
 214:	e422                	sd	s0,8(sp)
 216:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 218:	ce09                	beqz	a2,232 <memset+0x20>
 21a:	87aa                	mv	a5,a0
 21c:	fff6071b          	addiw	a4,a2,-1
 220:	1702                	slli	a4,a4,0x20
 222:	9301                	srli	a4,a4,0x20
 224:	0705                	addi	a4,a4,1
 226:	972a                	add	a4,a4,a0
    cdst[i] = c;
 228:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 22c:	0785                	addi	a5,a5,1
 22e:	fee79de3          	bne	a5,a4,228 <memset+0x16>
  }
  return dst;
}
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret

0000000000000238 <strchr>:

char*
strchr(const char *s, char c)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 23e:	00054783          	lbu	a5,0(a0)
 242:	cb99                	beqz	a5,258 <strchr+0x20>
    if(*s == c)
 244:	00f58763          	beq	a1,a5,252 <strchr+0x1a>
  for(; *s; s++)
 248:	0505                	addi	a0,a0,1
 24a:	00054783          	lbu	a5,0(a0)
 24e:	fbfd                	bnez	a5,244 <strchr+0xc>
      return (char*)s;
  return 0;
 250:	4501                	li	a0,0
}
 252:	6422                	ld	s0,8(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret
  return 0;
 258:	4501                	li	a0,0
 25a:	bfe5                	j	252 <strchr+0x1a>

000000000000025c <gets>:

char*
gets(char *buf, int max)
{
 25c:	711d                	addi	sp,sp,-96
 25e:	ec86                	sd	ra,88(sp)
 260:	e8a2                	sd	s0,80(sp)
 262:	e4a6                	sd	s1,72(sp)
 264:	e0ca                	sd	s2,64(sp)
 266:	fc4e                	sd	s3,56(sp)
 268:	f852                	sd	s4,48(sp)
 26a:	f456                	sd	s5,40(sp)
 26c:	f05a                	sd	s6,32(sp)
 26e:	ec5e                	sd	s7,24(sp)
 270:	1080                	addi	s0,sp,96
 272:	8baa                	mv	s7,a0
 274:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 276:	892a                	mv	s2,a0
 278:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 27a:	4aa9                	li	s5,10
 27c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 27e:	89a6                	mv	s3,s1
 280:	2485                	addiw	s1,s1,1
 282:	0344d863          	bge	s1,s4,2b2 <gets+0x56>
    cc = read(0, &c, 1);
 286:	4605                	li	a2,1
 288:	faf40593          	addi	a1,s0,-81
 28c:	4501                	li	a0,0
 28e:	00000097          	auipc	ra,0x0
 292:	1a0080e7          	jalr	416(ra) # 42e <read>
    if(cc < 1)
 296:	00a05e63          	blez	a0,2b2 <gets+0x56>
    buf[i++] = c;
 29a:	faf44783          	lbu	a5,-81(s0)
 29e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a2:	01578763          	beq	a5,s5,2b0 <gets+0x54>
 2a6:	0905                	addi	s2,s2,1
 2a8:	fd679be3          	bne	a5,s6,27e <gets+0x22>
  for(i=0; i+1 < max; ){
 2ac:	89a6                	mv	s3,s1
 2ae:	a011                	j	2b2 <gets+0x56>
 2b0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2b2:	99de                	add	s3,s3,s7
 2b4:	00098023          	sb	zero,0(s3)
  return buf;
}
 2b8:	855e                	mv	a0,s7
 2ba:	60e6                	ld	ra,88(sp)
 2bc:	6446                	ld	s0,80(sp)
 2be:	64a6                	ld	s1,72(sp)
 2c0:	6906                	ld	s2,64(sp)
 2c2:	79e2                	ld	s3,56(sp)
 2c4:	7a42                	ld	s4,48(sp)
 2c6:	7aa2                	ld	s5,40(sp)
 2c8:	7b02                	ld	s6,32(sp)
 2ca:	6be2                	ld	s7,24(sp)
 2cc:	6125                	addi	sp,sp,96
 2ce:	8082                	ret

00000000000002d0 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d0:	1101                	addi	sp,sp,-32
 2d2:	ec06                	sd	ra,24(sp)
 2d4:	e822                	sd	s0,16(sp)
 2d6:	e426                	sd	s1,8(sp)
 2d8:	e04a                	sd	s2,0(sp)
 2da:	1000                	addi	s0,sp,32
 2dc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2de:	4581                	li	a1,0
 2e0:	00000097          	auipc	ra,0x0
 2e4:	176080e7          	jalr	374(ra) # 456 <open>
  if(fd < 0)
 2e8:	02054563          	bltz	a0,312 <stat+0x42>
 2ec:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ee:	85ca                	mv	a1,s2
 2f0:	00000097          	auipc	ra,0x0
 2f4:	17e080e7          	jalr	382(ra) # 46e <fstat>
 2f8:	892a                	mv	s2,a0
  close(fd);
 2fa:	8526                	mv	a0,s1
 2fc:	00000097          	auipc	ra,0x0
 300:	142080e7          	jalr	322(ra) # 43e <close>
  return r;
}
 304:	854a                	mv	a0,s2
 306:	60e2                	ld	ra,24(sp)
 308:	6442                	ld	s0,16(sp)
 30a:	64a2                	ld	s1,8(sp)
 30c:	6902                	ld	s2,0(sp)
 30e:	6105                	addi	sp,sp,32
 310:	8082                	ret
    return -1;
 312:	597d                	li	s2,-1
 314:	bfc5                	j	304 <stat+0x34>

0000000000000316 <atoi>:

int
atoi(const char *s)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 31c:	00054603          	lbu	a2,0(a0)
 320:	fd06079b          	addiw	a5,a2,-48
 324:	0ff7f793          	andi	a5,a5,255
 328:	4725                	li	a4,9
 32a:	02f76963          	bltu	a4,a5,35c <atoi+0x46>
 32e:	86aa                	mv	a3,a0
  n = 0;
 330:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 332:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 334:	0685                	addi	a3,a3,1
 336:	0025179b          	slliw	a5,a0,0x2
 33a:	9fa9                	addw	a5,a5,a0
 33c:	0017979b          	slliw	a5,a5,0x1
 340:	9fb1                	addw	a5,a5,a2
 342:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 346:	0006c603          	lbu	a2,0(a3)
 34a:	fd06071b          	addiw	a4,a2,-48
 34e:	0ff77713          	andi	a4,a4,255
 352:	fee5f1e3          	bgeu	a1,a4,334 <atoi+0x1e>
  return n;
}
 356:	6422                	ld	s0,8(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret
  n = 0;
 35c:	4501                	li	a0,0
 35e:	bfe5                	j	356 <atoi+0x40>

0000000000000360 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 360:	1141                	addi	sp,sp,-16
 362:	e422                	sd	s0,8(sp)
 364:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 366:	02b57663          	bgeu	a0,a1,392 <memmove+0x32>
    while(n-- > 0)
 36a:	02c05163          	blez	a2,38c <memmove+0x2c>
 36e:	fff6079b          	addiw	a5,a2,-1
 372:	1782                	slli	a5,a5,0x20
 374:	9381                	srli	a5,a5,0x20
 376:	0785                	addi	a5,a5,1
 378:	97aa                	add	a5,a5,a0
  dst = vdst;
 37a:	872a                	mv	a4,a0
      *dst++ = *src++;
 37c:	0585                	addi	a1,a1,1
 37e:	0705                	addi	a4,a4,1
 380:	fff5c683          	lbu	a3,-1(a1)
 384:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 388:	fee79ae3          	bne	a5,a4,37c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 38c:	6422                	ld	s0,8(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret
    dst += n;
 392:	00c50733          	add	a4,a0,a2
    src += n;
 396:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 398:	fec05ae3          	blez	a2,38c <memmove+0x2c>
 39c:	fff6079b          	addiw	a5,a2,-1
 3a0:	1782                	slli	a5,a5,0x20
 3a2:	9381                	srli	a5,a5,0x20
 3a4:	fff7c793          	not	a5,a5
 3a8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3aa:	15fd                	addi	a1,a1,-1
 3ac:	177d                	addi	a4,a4,-1
 3ae:	0005c683          	lbu	a3,0(a1)
 3b2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3b6:	fee79ae3          	bne	a5,a4,3aa <memmove+0x4a>
 3ba:	bfc9                	j	38c <memmove+0x2c>

00000000000003bc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3bc:	1141                	addi	sp,sp,-16
 3be:	e422                	sd	s0,8(sp)
 3c0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3c2:	ca05                	beqz	a2,3f2 <memcmp+0x36>
 3c4:	fff6069b          	addiw	a3,a2,-1
 3c8:	1682                	slli	a3,a3,0x20
 3ca:	9281                	srli	a3,a3,0x20
 3cc:	0685                	addi	a3,a3,1
 3ce:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3d0:	00054783          	lbu	a5,0(a0)
 3d4:	0005c703          	lbu	a4,0(a1)
 3d8:	00e79863          	bne	a5,a4,3e8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3dc:	0505                	addi	a0,a0,1
    p2++;
 3de:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3e0:	fed518e3          	bne	a0,a3,3d0 <memcmp+0x14>
  }
  return 0;
 3e4:	4501                	li	a0,0
 3e6:	a019                	j	3ec <memcmp+0x30>
      return *p1 - *p2;
 3e8:	40e7853b          	subw	a0,a5,a4
}
 3ec:	6422                	ld	s0,8(sp)
 3ee:	0141                	addi	sp,sp,16
 3f0:	8082                	ret
  return 0;
 3f2:	4501                	li	a0,0
 3f4:	bfe5                	j	3ec <memcmp+0x30>

00000000000003f6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3f6:	1141                	addi	sp,sp,-16
 3f8:	e406                	sd	ra,8(sp)
 3fa:	e022                	sd	s0,0(sp)
 3fc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3fe:	00000097          	auipc	ra,0x0
 402:	f62080e7          	jalr	-158(ra) # 360 <memmove>
}
 406:	60a2                	ld	ra,8(sp)
 408:	6402                	ld	s0,0(sp)
 40a:	0141                	addi	sp,sp,16
 40c:	8082                	ret

000000000000040e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 40e:	4885                	li	a7,1
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <exit>:
.global exit
exit:
 li a7, SYS_exit
 416:	4889                	li	a7,2
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <wait>:
.global wait
wait:
 li a7, SYS_wait
 41e:	488d                	li	a7,3
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 426:	4891                	li	a7,4
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <read>:
.global read
read:
 li a7, SYS_read
 42e:	4895                	li	a7,5
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <write>:
.global write
write:
 li a7, SYS_write
 436:	48c1                	li	a7,16
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <close>:
.global close
close:
 li a7, SYS_close
 43e:	48d5                	li	a7,21
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <kill>:
.global kill
kill:
 li a7, SYS_kill
 446:	4899                	li	a7,6
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <exec>:
.global exec
exec:
 li a7, SYS_exec
 44e:	489d                	li	a7,7
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <open>:
.global open
open:
 li a7, SYS_open
 456:	48bd                	li	a7,15
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 45e:	48c5                	li	a7,17
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 466:	48c9                	li	a7,18
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 46e:	48a1                	li	a7,8
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <link>:
.global link
link:
 li a7, SYS_link
 476:	48cd                	li	a7,19
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 47e:	48d1                	li	a7,20
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 486:	48a5                	li	a7,9
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <dup>:
.global dup
dup:
 li a7, SYS_dup
 48e:	48a9                	li	a7,10
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 496:	48ad                	li	a7,11
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 49e:	48b1                	li	a7,12
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4a6:	48b5                	li	a7,13
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4ae:	48b9                	li	a7,14
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b6:	1101                	addi	sp,sp,-32
 4b8:	ec06                	sd	ra,24(sp)
 4ba:	e822                	sd	s0,16(sp)
 4bc:	1000                	addi	s0,sp,32
 4be:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c2:	4605                	li	a2,1
 4c4:	fef40593          	addi	a1,s0,-17
 4c8:	00000097          	auipc	ra,0x0
 4cc:	f6e080e7          	jalr	-146(ra) # 436 <write>
}
 4d0:	60e2                	ld	ra,24(sp)
 4d2:	6442                	ld	s0,16(sp)
 4d4:	6105                	addi	sp,sp,32
 4d6:	8082                	ret

00000000000004d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4d8:	7139                	addi	sp,sp,-64
 4da:	fc06                	sd	ra,56(sp)
 4dc:	f822                	sd	s0,48(sp)
 4de:	f426                	sd	s1,40(sp)
 4e0:	f04a                	sd	s2,32(sp)
 4e2:	ec4e                	sd	s3,24(sp)
 4e4:	0080                	addi	s0,sp,64
 4e6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e8:	c299                	beqz	a3,4ee <printint+0x16>
 4ea:	0805c863          	bltz	a1,57a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ee:	2581                	sext.w	a1,a1
  neg = 0;
 4f0:	4881                	li	a7,0
 4f2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f8:	2601                	sext.w	a2,a2
 4fa:	00000517          	auipc	a0,0x0
 4fe:	44e50513          	addi	a0,a0,1102 # 948 <digits>
 502:	883a                	mv	a6,a4
 504:	2705                	addiw	a4,a4,1
 506:	02c5f7bb          	remuw	a5,a1,a2
 50a:	1782                	slli	a5,a5,0x20
 50c:	9381                	srli	a5,a5,0x20
 50e:	97aa                	add	a5,a5,a0
 510:	0007c783          	lbu	a5,0(a5)
 514:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 518:	0005879b          	sext.w	a5,a1
 51c:	02c5d5bb          	divuw	a1,a1,a2
 520:	0685                	addi	a3,a3,1
 522:	fec7f0e3          	bgeu	a5,a2,502 <printint+0x2a>
  if(neg)
 526:	00088b63          	beqz	a7,53c <printint+0x64>
    buf[i++] = '-';
 52a:	fd040793          	addi	a5,s0,-48
 52e:	973e                	add	a4,a4,a5
 530:	02d00793          	li	a5,45
 534:	fef70823          	sb	a5,-16(a4)
 538:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 53c:	02e05863          	blez	a4,56c <printint+0x94>
 540:	fc040793          	addi	a5,s0,-64
 544:	00e78933          	add	s2,a5,a4
 548:	fff78993          	addi	s3,a5,-1
 54c:	99ba                	add	s3,s3,a4
 54e:	377d                	addiw	a4,a4,-1
 550:	1702                	slli	a4,a4,0x20
 552:	9301                	srli	a4,a4,0x20
 554:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 558:	fff94583          	lbu	a1,-1(s2)
 55c:	8526                	mv	a0,s1
 55e:	00000097          	auipc	ra,0x0
 562:	f58080e7          	jalr	-168(ra) # 4b6 <putc>
  while(--i >= 0)
 566:	197d                	addi	s2,s2,-1
 568:	ff3918e3          	bne	s2,s3,558 <printint+0x80>
}
 56c:	70e2                	ld	ra,56(sp)
 56e:	7442                	ld	s0,48(sp)
 570:	74a2                	ld	s1,40(sp)
 572:	7902                	ld	s2,32(sp)
 574:	69e2                	ld	s3,24(sp)
 576:	6121                	addi	sp,sp,64
 578:	8082                	ret
    x = -xx;
 57a:	40b005bb          	negw	a1,a1
    neg = 1;
 57e:	4885                	li	a7,1
    x = -xx;
 580:	bf8d                	j	4f2 <printint+0x1a>

0000000000000582 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 582:	7119                	addi	sp,sp,-128
 584:	fc86                	sd	ra,120(sp)
 586:	f8a2                	sd	s0,112(sp)
 588:	f4a6                	sd	s1,104(sp)
 58a:	f0ca                	sd	s2,96(sp)
 58c:	ecce                	sd	s3,88(sp)
 58e:	e8d2                	sd	s4,80(sp)
 590:	e4d6                	sd	s5,72(sp)
 592:	e0da                	sd	s6,64(sp)
 594:	fc5e                	sd	s7,56(sp)
 596:	f862                	sd	s8,48(sp)
 598:	f466                	sd	s9,40(sp)
 59a:	f06a                	sd	s10,32(sp)
 59c:	ec6e                	sd	s11,24(sp)
 59e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a0:	0005c903          	lbu	s2,0(a1)
 5a4:	18090f63          	beqz	s2,742 <vprintf+0x1c0>
 5a8:	8aaa                	mv	s5,a0
 5aa:	8b32                	mv	s6,a2
 5ac:	00158493          	addi	s1,a1,1
  state = 0;
 5b0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5b2:	02500a13          	li	s4,37
      if(c == 'd'){
 5b6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5ba:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5be:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5c2:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5c6:	00000b97          	auipc	s7,0x0
 5ca:	382b8b93          	addi	s7,s7,898 # 948 <digits>
 5ce:	a839                	j	5ec <vprintf+0x6a>
        putc(fd, c);
 5d0:	85ca                	mv	a1,s2
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	ee2080e7          	jalr	-286(ra) # 4b6 <putc>
 5dc:	a019                	j	5e2 <vprintf+0x60>
    } else if(state == '%'){
 5de:	01498f63          	beq	s3,s4,5fc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5e2:	0485                	addi	s1,s1,1
 5e4:	fff4c903          	lbu	s2,-1(s1)
 5e8:	14090d63          	beqz	s2,742 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5ec:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5f0:	fe0997e3          	bnez	s3,5de <vprintf+0x5c>
      if(c == '%'){
 5f4:	fd479ee3          	bne	a5,s4,5d0 <vprintf+0x4e>
        state = '%';
 5f8:	89be                	mv	s3,a5
 5fa:	b7e5                	j	5e2 <vprintf+0x60>
      if(c == 'd'){
 5fc:	05878063          	beq	a5,s8,63c <vprintf+0xba>
      } else if(c == 'l') {
 600:	05978c63          	beq	a5,s9,658 <vprintf+0xd6>
      } else if(c == 'x') {
 604:	07a78863          	beq	a5,s10,674 <vprintf+0xf2>
      } else if(c == 'p') {
 608:	09b78463          	beq	a5,s11,690 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 60c:	07300713          	li	a4,115
 610:	0ce78663          	beq	a5,a4,6dc <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 614:	06300713          	li	a4,99
 618:	0ee78e63          	beq	a5,a4,714 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 61c:	11478863          	beq	a5,s4,72c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 620:	85d2                	mv	a1,s4
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	e92080e7          	jalr	-366(ra) # 4b6 <putc>
        putc(fd, c);
 62c:	85ca                	mv	a1,s2
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	e86080e7          	jalr	-378(ra) # 4b6 <putc>
      }
      state = 0;
 638:	4981                	li	s3,0
 63a:	b765                	j	5e2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 63c:	008b0913          	addi	s2,s6,8
 640:	4685                	li	a3,1
 642:	4629                	li	a2,10
 644:	000b2583          	lw	a1,0(s6)
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	e8e080e7          	jalr	-370(ra) # 4d8 <printint>
 652:	8b4a                	mv	s6,s2
      state = 0;
 654:	4981                	li	s3,0
 656:	b771                	j	5e2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 658:	008b0913          	addi	s2,s6,8
 65c:	4681                	li	a3,0
 65e:	4629                	li	a2,10
 660:	000b2583          	lw	a1,0(s6)
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	e72080e7          	jalr	-398(ra) # 4d8 <printint>
 66e:	8b4a                	mv	s6,s2
      state = 0;
 670:	4981                	li	s3,0
 672:	bf85                	j	5e2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 674:	008b0913          	addi	s2,s6,8
 678:	4681                	li	a3,0
 67a:	4641                	li	a2,16
 67c:	000b2583          	lw	a1,0(s6)
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e56080e7          	jalr	-426(ra) # 4d8 <printint>
 68a:	8b4a                	mv	s6,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	bf91                	j	5e2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 690:	008b0793          	addi	a5,s6,8
 694:	f8f43423          	sd	a5,-120(s0)
 698:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 69c:	03000593          	li	a1,48
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	e14080e7          	jalr	-492(ra) # 4b6 <putc>
  putc(fd, 'x');
 6aa:	85ea                	mv	a1,s10
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	e08080e7          	jalr	-504(ra) # 4b6 <putc>
 6b6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b8:	03c9d793          	srli	a5,s3,0x3c
 6bc:	97de                	add	a5,a5,s7
 6be:	0007c583          	lbu	a1,0(a5)
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	df2080e7          	jalr	-526(ra) # 4b6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6cc:	0992                	slli	s3,s3,0x4
 6ce:	397d                	addiw	s2,s2,-1
 6d0:	fe0914e3          	bnez	s2,6b8 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6d4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	b721                	j	5e2 <vprintf+0x60>
        s = va_arg(ap, char*);
 6dc:	008b0993          	addi	s3,s6,8
 6e0:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6e4:	02090163          	beqz	s2,706 <vprintf+0x184>
        while(*s != 0){
 6e8:	00094583          	lbu	a1,0(s2)
 6ec:	c9a1                	beqz	a1,73c <vprintf+0x1ba>
          putc(fd, *s);
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	dc6080e7          	jalr	-570(ra) # 4b6 <putc>
          s++;
 6f8:	0905                	addi	s2,s2,1
        while(*s != 0){
 6fa:	00094583          	lbu	a1,0(s2)
 6fe:	f9e5                	bnez	a1,6ee <vprintf+0x16c>
        s = va_arg(ap, char*);
 700:	8b4e                	mv	s6,s3
      state = 0;
 702:	4981                	li	s3,0
 704:	bdf9                	j	5e2 <vprintf+0x60>
          s = "(null)";
 706:	00000917          	auipc	s2,0x0
 70a:	23a90913          	addi	s2,s2,570 # 940 <malloc+0xf4>
        while(*s != 0){
 70e:	02800593          	li	a1,40
 712:	bff1                	j	6ee <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 714:	008b0913          	addi	s2,s6,8
 718:	000b4583          	lbu	a1,0(s6)
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	d98080e7          	jalr	-616(ra) # 4b6 <putc>
 726:	8b4a                	mv	s6,s2
      state = 0;
 728:	4981                	li	s3,0
 72a:	bd65                	j	5e2 <vprintf+0x60>
        putc(fd, c);
 72c:	85d2                	mv	a1,s4
 72e:	8556                	mv	a0,s5
 730:	00000097          	auipc	ra,0x0
 734:	d86080e7          	jalr	-634(ra) # 4b6 <putc>
      state = 0;
 738:	4981                	li	s3,0
 73a:	b565                	j	5e2 <vprintf+0x60>
        s = va_arg(ap, char*);
 73c:	8b4e                	mv	s6,s3
      state = 0;
 73e:	4981                	li	s3,0
 740:	b54d                	j	5e2 <vprintf+0x60>
    }
  }
}
 742:	70e6                	ld	ra,120(sp)
 744:	7446                	ld	s0,112(sp)
 746:	74a6                	ld	s1,104(sp)
 748:	7906                	ld	s2,96(sp)
 74a:	69e6                	ld	s3,88(sp)
 74c:	6a46                	ld	s4,80(sp)
 74e:	6aa6                	ld	s5,72(sp)
 750:	6b06                	ld	s6,64(sp)
 752:	7be2                	ld	s7,56(sp)
 754:	7c42                	ld	s8,48(sp)
 756:	7ca2                	ld	s9,40(sp)
 758:	7d02                	ld	s10,32(sp)
 75a:	6de2                	ld	s11,24(sp)
 75c:	6109                	addi	sp,sp,128
 75e:	8082                	ret

0000000000000760 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 760:	715d                	addi	sp,sp,-80
 762:	ec06                	sd	ra,24(sp)
 764:	e822                	sd	s0,16(sp)
 766:	1000                	addi	s0,sp,32
 768:	e010                	sd	a2,0(s0)
 76a:	e414                	sd	a3,8(s0)
 76c:	e818                	sd	a4,16(s0)
 76e:	ec1c                	sd	a5,24(s0)
 770:	03043023          	sd	a6,32(s0)
 774:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 778:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 77c:	8622                	mv	a2,s0
 77e:	00000097          	auipc	ra,0x0
 782:	e04080e7          	jalr	-508(ra) # 582 <vprintf>
}
 786:	60e2                	ld	ra,24(sp)
 788:	6442                	ld	s0,16(sp)
 78a:	6161                	addi	sp,sp,80
 78c:	8082                	ret

000000000000078e <printf>:

void
printf(const char *fmt, ...)
{
 78e:	711d                	addi	sp,sp,-96
 790:	ec06                	sd	ra,24(sp)
 792:	e822                	sd	s0,16(sp)
 794:	1000                	addi	s0,sp,32
 796:	e40c                	sd	a1,8(s0)
 798:	e810                	sd	a2,16(s0)
 79a:	ec14                	sd	a3,24(s0)
 79c:	f018                	sd	a4,32(s0)
 79e:	f41c                	sd	a5,40(s0)
 7a0:	03043823          	sd	a6,48(s0)
 7a4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7a8:	00840613          	addi	a2,s0,8
 7ac:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b0:	85aa                	mv	a1,a0
 7b2:	4505                	li	a0,1
 7b4:	00000097          	auipc	ra,0x0
 7b8:	dce080e7          	jalr	-562(ra) # 582 <vprintf>
}
 7bc:	60e2                	ld	ra,24(sp)
 7be:	6442                	ld	s0,16(sp)
 7c0:	6125                	addi	sp,sp,96
 7c2:	8082                	ret

00000000000007c4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c4:	1141                	addi	sp,sp,-16
 7c6:	e422                	sd	s0,8(sp)
 7c8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ca:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ce:	00000797          	auipc	a5,0x0
 7d2:	1927b783          	ld	a5,402(a5) # 960 <freep>
 7d6:	a805                	j	806 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7d8:	4618                	lw	a4,8(a2)
 7da:	9db9                	addw	a1,a1,a4
 7dc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e0:	6398                	ld	a4,0(a5)
 7e2:	6318                	ld	a4,0(a4)
 7e4:	fee53823          	sd	a4,-16(a0)
 7e8:	a091                	j	82c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ea:	ff852703          	lw	a4,-8(a0)
 7ee:	9e39                	addw	a2,a2,a4
 7f0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7f2:	ff053703          	ld	a4,-16(a0)
 7f6:	e398                	sd	a4,0(a5)
 7f8:	a099                	j	83e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fa:	6398                	ld	a4,0(a5)
 7fc:	00e7e463          	bltu	a5,a4,804 <free+0x40>
 800:	00e6ea63          	bltu	a3,a4,814 <free+0x50>
{
 804:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 806:	fed7fae3          	bgeu	a5,a3,7fa <free+0x36>
 80a:	6398                	ld	a4,0(a5)
 80c:	00e6e463          	bltu	a3,a4,814 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 810:	fee7eae3          	bltu	a5,a4,804 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 814:	ff852583          	lw	a1,-8(a0)
 818:	6390                	ld	a2,0(a5)
 81a:	02059713          	slli	a4,a1,0x20
 81e:	9301                	srli	a4,a4,0x20
 820:	0712                	slli	a4,a4,0x4
 822:	9736                	add	a4,a4,a3
 824:	fae60ae3          	beq	a2,a4,7d8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 828:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 82c:	4790                	lw	a2,8(a5)
 82e:	02061713          	slli	a4,a2,0x20
 832:	9301                	srli	a4,a4,0x20
 834:	0712                	slli	a4,a4,0x4
 836:	973e                	add	a4,a4,a5
 838:	fae689e3          	beq	a3,a4,7ea <free+0x26>
  } else
    p->s.ptr = bp;
 83c:	e394                	sd	a3,0(a5)
  freep = p;
 83e:	00000717          	auipc	a4,0x0
 842:	12f73123          	sd	a5,290(a4) # 960 <freep>
}
 846:	6422                	ld	s0,8(sp)
 848:	0141                	addi	sp,sp,16
 84a:	8082                	ret

000000000000084c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 84c:	7139                	addi	sp,sp,-64
 84e:	fc06                	sd	ra,56(sp)
 850:	f822                	sd	s0,48(sp)
 852:	f426                	sd	s1,40(sp)
 854:	f04a                	sd	s2,32(sp)
 856:	ec4e                	sd	s3,24(sp)
 858:	e852                	sd	s4,16(sp)
 85a:	e456                	sd	s5,8(sp)
 85c:	e05a                	sd	s6,0(sp)
 85e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 860:	02051493          	slli	s1,a0,0x20
 864:	9081                	srli	s1,s1,0x20
 866:	04bd                	addi	s1,s1,15
 868:	8091                	srli	s1,s1,0x4
 86a:	0014899b          	addiw	s3,s1,1
 86e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 870:	00000517          	auipc	a0,0x0
 874:	0f053503          	ld	a0,240(a0) # 960 <freep>
 878:	c515                	beqz	a0,8a4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 87c:	4798                	lw	a4,8(a5)
 87e:	02977f63          	bgeu	a4,s1,8bc <malloc+0x70>
 882:	8a4e                	mv	s4,s3
 884:	0009871b          	sext.w	a4,s3
 888:	6685                	lui	a3,0x1
 88a:	00d77363          	bgeu	a4,a3,890 <malloc+0x44>
 88e:	6a05                	lui	s4,0x1
 890:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 894:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 898:	00000917          	auipc	s2,0x0
 89c:	0c890913          	addi	s2,s2,200 # 960 <freep>
  if(p == (char*)-1)
 8a0:	5afd                	li	s5,-1
 8a2:	a88d                	j	914 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8a4:	00000797          	auipc	a5,0x0
 8a8:	0c478793          	addi	a5,a5,196 # 968 <base>
 8ac:	00000717          	auipc	a4,0x0
 8b0:	0af73a23          	sd	a5,180(a4) # 960 <freep>
 8b4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8b6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ba:	b7e1                	j	882 <malloc+0x36>
      if(p->s.size == nunits)
 8bc:	02e48b63          	beq	s1,a4,8f2 <malloc+0xa6>
        p->s.size -= nunits;
 8c0:	4137073b          	subw	a4,a4,s3
 8c4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8c6:	1702                	slli	a4,a4,0x20
 8c8:	9301                	srli	a4,a4,0x20
 8ca:	0712                	slli	a4,a4,0x4
 8cc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ce:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8d2:	00000717          	auipc	a4,0x0
 8d6:	08a73723          	sd	a0,142(a4) # 960 <freep>
      return (void*)(p + 1);
 8da:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8de:	70e2                	ld	ra,56(sp)
 8e0:	7442                	ld	s0,48(sp)
 8e2:	74a2                	ld	s1,40(sp)
 8e4:	7902                	ld	s2,32(sp)
 8e6:	69e2                	ld	s3,24(sp)
 8e8:	6a42                	ld	s4,16(sp)
 8ea:	6aa2                	ld	s5,8(sp)
 8ec:	6b02                	ld	s6,0(sp)
 8ee:	6121                	addi	sp,sp,64
 8f0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8f2:	6398                	ld	a4,0(a5)
 8f4:	e118                	sd	a4,0(a0)
 8f6:	bff1                	j	8d2 <malloc+0x86>
  hp->s.size = nu;
 8f8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8fc:	0541                	addi	a0,a0,16
 8fe:	00000097          	auipc	ra,0x0
 902:	ec6080e7          	jalr	-314(ra) # 7c4 <free>
  return freep;
 906:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 90a:	d971                	beqz	a0,8de <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90e:	4798                	lw	a4,8(a5)
 910:	fa9776e3          	bgeu	a4,s1,8bc <malloc+0x70>
    if(p == freep)
 914:	00093703          	ld	a4,0(s2)
 918:	853e                	mv	a0,a5
 91a:	fef719e3          	bne	a4,a5,90c <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 91e:	8552                	mv	a0,s4
 920:	00000097          	auipc	ra,0x0
 924:	b7e080e7          	jalr	-1154(ra) # 49e <sbrk>
  if(p == (char*)-1)
 928:	fd5518e3          	bne	a0,s5,8f8 <malloc+0xac>
        return 0;
 92c:	4501                	li	a0,0
 92e:	bf45                	j	8de <malloc+0x92>
