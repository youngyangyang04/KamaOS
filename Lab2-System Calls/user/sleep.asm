
user/_sleep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char **argv) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84ae                	mv	s1,a1
	if(argc < 2) {
   c:	4785                	li	a5,1
   e:	02a7d063          	bge	a5,a0,2e <main+0x2e>
		printf("usage: sleep <ticks>\n");
	}
	sleep(atoi(argv[1]));
  12:	6488                	ld	a0,8(s1)
  14:	00000097          	auipc	ra,0x0
  18:	1a2080e7          	jalr	418(ra) # 1b6 <atoi>
  1c:	00000097          	auipc	ra,0x0
  20:	32a080e7          	jalr	810(ra) # 346 <sleep>
	exit(0);
  24:	4501                	li	a0,0
  26:	00000097          	auipc	ra,0x0
  2a:	290080e7          	jalr	656(ra) # 2b6 <exit>
		printf("usage: sleep <ticks>\n");
  2e:	00000517          	auipc	a0,0x0
  32:	7a250513          	addi	a0,a0,1954 # 7d0 <malloc+0xe4>
  36:	00000097          	auipc	ra,0x0
  3a:	5f8080e7          	jalr	1528(ra) # 62e <printf>
  3e:	bfd1                	j	12 <main+0x12>

0000000000000040 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  40:	1141                	addi	sp,sp,-16
  42:	e422                	sd	s0,8(sp)
  44:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  46:	87aa                	mv	a5,a0
  48:	0585                	addi	a1,a1,1
  4a:	0785                	addi	a5,a5,1
  4c:	fff5c703          	lbu	a4,-1(a1)
  50:	fee78fa3          	sb	a4,-1(a5)
  54:	fb75                	bnez	a4,48 <strcpy+0x8>
    ;
  return os;
}
  56:	6422                	ld	s0,8(sp)
  58:	0141                	addi	sp,sp,16
  5a:	8082                	ret

000000000000005c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  5c:	1141                	addi	sp,sp,-16
  5e:	e422                	sd	s0,8(sp)
  60:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  62:	00054783          	lbu	a5,0(a0)
  66:	cb91                	beqz	a5,7a <strcmp+0x1e>
  68:	0005c703          	lbu	a4,0(a1)
  6c:	00f71763          	bne	a4,a5,7a <strcmp+0x1e>
    p++, q++;
  70:	0505                	addi	a0,a0,1
  72:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  74:	00054783          	lbu	a5,0(a0)
  78:	fbe5                	bnez	a5,68 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  7a:	0005c503          	lbu	a0,0(a1)
}
  7e:	40a7853b          	subw	a0,a5,a0
  82:	6422                	ld	s0,8(sp)
  84:	0141                	addi	sp,sp,16
  86:	8082                	ret

0000000000000088 <strlen>:

uint
strlen(const char *s)
{
  88:	1141                	addi	sp,sp,-16
  8a:	e422                	sd	s0,8(sp)
  8c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  8e:	00054783          	lbu	a5,0(a0)
  92:	cf91                	beqz	a5,ae <strlen+0x26>
  94:	0505                	addi	a0,a0,1
  96:	87aa                	mv	a5,a0
  98:	4685                	li	a3,1
  9a:	9e89                	subw	a3,a3,a0
  9c:	00f6853b          	addw	a0,a3,a5
  a0:	0785                	addi	a5,a5,1
  a2:	fff7c703          	lbu	a4,-1(a5)
  a6:	fb7d                	bnez	a4,9c <strlen+0x14>
    ;
  return n;
}
  a8:	6422                	ld	s0,8(sp)
  aa:	0141                	addi	sp,sp,16
  ac:	8082                	ret
  for(n = 0; s[n]; n++)
  ae:	4501                	li	a0,0
  b0:	bfe5                	j	a8 <strlen+0x20>

00000000000000b2 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b2:	1141                	addi	sp,sp,-16
  b4:	e422                	sd	s0,8(sp)
  b6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  b8:	ce09                	beqz	a2,d2 <memset+0x20>
  ba:	87aa                	mv	a5,a0
  bc:	fff6071b          	addiw	a4,a2,-1
  c0:	1702                	slli	a4,a4,0x20
  c2:	9301                	srli	a4,a4,0x20
  c4:	0705                	addi	a4,a4,1
  c6:	972a                	add	a4,a4,a0
    cdst[i] = c;
  c8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  cc:	0785                	addi	a5,a5,1
  ce:	fee79de3          	bne	a5,a4,c8 <memset+0x16>
  }
  return dst;
}
  d2:	6422                	ld	s0,8(sp)
  d4:	0141                	addi	sp,sp,16
  d6:	8082                	ret

00000000000000d8 <strchr>:

char*
strchr(const char *s, char c)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cb99                	beqz	a5,f8 <strchr+0x20>
    if(*s == c)
  e4:	00f58763          	beq	a1,a5,f2 <strchr+0x1a>
  for(; *s; s++)
  e8:	0505                	addi	a0,a0,1
  ea:	00054783          	lbu	a5,0(a0)
  ee:	fbfd                	bnez	a5,e4 <strchr+0xc>
      return (char*)s;
  return 0;
  f0:	4501                	li	a0,0
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret
  return 0;
  f8:	4501                	li	a0,0
  fa:	bfe5                	j	f2 <strchr+0x1a>

00000000000000fc <gets>:

char*
gets(char *buf, int max)
{
  fc:	711d                	addi	sp,sp,-96
  fe:	ec86                	sd	ra,88(sp)
 100:	e8a2                	sd	s0,80(sp)
 102:	e4a6                	sd	s1,72(sp)
 104:	e0ca                	sd	s2,64(sp)
 106:	fc4e                	sd	s3,56(sp)
 108:	f852                	sd	s4,48(sp)
 10a:	f456                	sd	s5,40(sp)
 10c:	f05a                	sd	s6,32(sp)
 10e:	ec5e                	sd	s7,24(sp)
 110:	1080                	addi	s0,sp,96
 112:	8baa                	mv	s7,a0
 114:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 116:	892a                	mv	s2,a0
 118:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 11a:	4aa9                	li	s5,10
 11c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 11e:	89a6                	mv	s3,s1
 120:	2485                	addiw	s1,s1,1
 122:	0344d863          	bge	s1,s4,152 <gets+0x56>
    cc = read(0, &c, 1);
 126:	4605                	li	a2,1
 128:	faf40593          	addi	a1,s0,-81
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	1a0080e7          	jalr	416(ra) # 2ce <read>
    if(cc < 1)
 136:	00a05e63          	blez	a0,152 <gets+0x56>
    buf[i++] = c;
 13a:	faf44783          	lbu	a5,-81(s0)
 13e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 142:	01578763          	beq	a5,s5,150 <gets+0x54>
 146:	0905                	addi	s2,s2,1
 148:	fd679be3          	bne	a5,s6,11e <gets+0x22>
  for(i=0; i+1 < max; ){
 14c:	89a6                	mv	s3,s1
 14e:	a011                	j	152 <gets+0x56>
 150:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 152:	99de                	add	s3,s3,s7
 154:	00098023          	sb	zero,0(s3)
  return buf;
}
 158:	855e                	mv	a0,s7
 15a:	60e6                	ld	ra,88(sp)
 15c:	6446                	ld	s0,80(sp)
 15e:	64a6                	ld	s1,72(sp)
 160:	6906                	ld	s2,64(sp)
 162:	79e2                	ld	s3,56(sp)
 164:	7a42                	ld	s4,48(sp)
 166:	7aa2                	ld	s5,40(sp)
 168:	7b02                	ld	s6,32(sp)
 16a:	6be2                	ld	s7,24(sp)
 16c:	6125                	addi	sp,sp,96
 16e:	8082                	ret

0000000000000170 <stat>:

int
stat(const char *n, struct stat *st)
{
 170:	1101                	addi	sp,sp,-32
 172:	ec06                	sd	ra,24(sp)
 174:	e822                	sd	s0,16(sp)
 176:	e426                	sd	s1,8(sp)
 178:	e04a                	sd	s2,0(sp)
 17a:	1000                	addi	s0,sp,32
 17c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17e:	4581                	li	a1,0
 180:	00000097          	auipc	ra,0x0
 184:	176080e7          	jalr	374(ra) # 2f6 <open>
  if(fd < 0)
 188:	02054563          	bltz	a0,1b2 <stat+0x42>
 18c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 18e:	85ca                	mv	a1,s2
 190:	00000097          	auipc	ra,0x0
 194:	17e080e7          	jalr	382(ra) # 30e <fstat>
 198:	892a                	mv	s2,a0
  close(fd);
 19a:	8526                	mv	a0,s1
 19c:	00000097          	auipc	ra,0x0
 1a0:	142080e7          	jalr	322(ra) # 2de <close>
  return r;
}
 1a4:	854a                	mv	a0,s2
 1a6:	60e2                	ld	ra,24(sp)
 1a8:	6442                	ld	s0,16(sp)
 1aa:	64a2                	ld	s1,8(sp)
 1ac:	6902                	ld	s2,0(sp)
 1ae:	6105                	addi	sp,sp,32
 1b0:	8082                	ret
    return -1;
 1b2:	597d                	li	s2,-1
 1b4:	bfc5                	j	1a4 <stat+0x34>

00000000000001b6 <atoi>:

int
atoi(const char *s)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1bc:	00054603          	lbu	a2,0(a0)
 1c0:	fd06079b          	addiw	a5,a2,-48
 1c4:	0ff7f793          	andi	a5,a5,255
 1c8:	4725                	li	a4,9
 1ca:	02f76963          	bltu	a4,a5,1fc <atoi+0x46>
 1ce:	86aa                	mv	a3,a0
  n = 0;
 1d0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1d2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1d4:	0685                	addi	a3,a3,1
 1d6:	0025179b          	slliw	a5,a0,0x2
 1da:	9fa9                	addw	a5,a5,a0
 1dc:	0017979b          	slliw	a5,a5,0x1
 1e0:	9fb1                	addw	a5,a5,a2
 1e2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e6:	0006c603          	lbu	a2,0(a3)
 1ea:	fd06071b          	addiw	a4,a2,-48
 1ee:	0ff77713          	andi	a4,a4,255
 1f2:	fee5f1e3          	bgeu	a1,a4,1d4 <atoi+0x1e>
  return n;
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret
  n = 0;
 1fc:	4501                	li	a0,0
 1fe:	bfe5                	j	1f6 <atoi+0x40>

0000000000000200 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 206:	02b57663          	bgeu	a0,a1,232 <memmove+0x32>
    while(n-- > 0)
 20a:	02c05163          	blez	a2,22c <memmove+0x2c>
 20e:	fff6079b          	addiw	a5,a2,-1
 212:	1782                	slli	a5,a5,0x20
 214:	9381                	srli	a5,a5,0x20
 216:	0785                	addi	a5,a5,1
 218:	97aa                	add	a5,a5,a0
  dst = vdst;
 21a:	872a                	mv	a4,a0
      *dst++ = *src++;
 21c:	0585                	addi	a1,a1,1
 21e:	0705                	addi	a4,a4,1
 220:	fff5c683          	lbu	a3,-1(a1)
 224:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 228:	fee79ae3          	bne	a5,a4,21c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret
    dst += n;
 232:	00c50733          	add	a4,a0,a2
    src += n;
 236:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 238:	fec05ae3          	blez	a2,22c <memmove+0x2c>
 23c:	fff6079b          	addiw	a5,a2,-1
 240:	1782                	slli	a5,a5,0x20
 242:	9381                	srli	a5,a5,0x20
 244:	fff7c793          	not	a5,a5
 248:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 24a:	15fd                	addi	a1,a1,-1
 24c:	177d                	addi	a4,a4,-1
 24e:	0005c683          	lbu	a3,0(a1)
 252:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 256:	fee79ae3          	bne	a5,a4,24a <memmove+0x4a>
 25a:	bfc9                	j	22c <memmove+0x2c>

000000000000025c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 25c:	1141                	addi	sp,sp,-16
 25e:	e422                	sd	s0,8(sp)
 260:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 262:	ca05                	beqz	a2,292 <memcmp+0x36>
 264:	fff6069b          	addiw	a3,a2,-1
 268:	1682                	slli	a3,a3,0x20
 26a:	9281                	srli	a3,a3,0x20
 26c:	0685                	addi	a3,a3,1
 26e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 270:	00054783          	lbu	a5,0(a0)
 274:	0005c703          	lbu	a4,0(a1)
 278:	00e79863          	bne	a5,a4,288 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 27c:	0505                	addi	a0,a0,1
    p2++;
 27e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 280:	fed518e3          	bne	a0,a3,270 <memcmp+0x14>
  }
  return 0;
 284:	4501                	li	a0,0
 286:	a019                	j	28c <memcmp+0x30>
      return *p1 - *p2;
 288:	40e7853b          	subw	a0,a5,a4
}
 28c:	6422                	ld	s0,8(sp)
 28e:	0141                	addi	sp,sp,16
 290:	8082                	ret
  return 0;
 292:	4501                	li	a0,0
 294:	bfe5                	j	28c <memcmp+0x30>

0000000000000296 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 296:	1141                	addi	sp,sp,-16
 298:	e406                	sd	ra,8(sp)
 29a:	e022                	sd	s0,0(sp)
 29c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 29e:	00000097          	auipc	ra,0x0
 2a2:	f62080e7          	jalr	-158(ra) # 200 <memmove>
}
 2a6:	60a2                	ld	ra,8(sp)
 2a8:	6402                	ld	s0,0(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret

00000000000002ae <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ae:	4885                	li	a7,1
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2b6:	4889                	li	a7,2
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <wait>:
.global wait
wait:
 li a7, SYS_wait
 2be:	488d                	li	a7,3
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2c6:	4891                	li	a7,4
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <read>:
.global read
read:
 li a7, SYS_read
 2ce:	4895                	li	a7,5
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <write>:
.global write
write:
 li a7, SYS_write
 2d6:	48c1                	li	a7,16
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <close>:
.global close
close:
 li a7, SYS_close
 2de:	48d5                	li	a7,21
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2e6:	4899                	li	a7,6
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <exec>:
.global exec
exec:
 li a7, SYS_exec
 2ee:	489d                	li	a7,7
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <open>:
.global open
open:
 li a7, SYS_open
 2f6:	48bd                	li	a7,15
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2fe:	48c5                	li	a7,17
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 306:	48c9                	li	a7,18
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 30e:	48a1                	li	a7,8
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <link>:
.global link
link:
 li a7, SYS_link
 316:	48cd                	li	a7,19
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 31e:	48d1                	li	a7,20
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 326:	48a5                	li	a7,9
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <dup>:
.global dup
dup:
 li a7, SYS_dup
 32e:	48a9                	li	a7,10
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 336:	48ad                	li	a7,11
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 33e:	48b1                	li	a7,12
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 346:	48b5                	li	a7,13
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 34e:	48b9                	li	a7,14
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 356:	1101                	addi	sp,sp,-32
 358:	ec06                	sd	ra,24(sp)
 35a:	e822                	sd	s0,16(sp)
 35c:	1000                	addi	s0,sp,32
 35e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 362:	4605                	li	a2,1
 364:	fef40593          	addi	a1,s0,-17
 368:	00000097          	auipc	ra,0x0
 36c:	f6e080e7          	jalr	-146(ra) # 2d6 <write>
}
 370:	60e2                	ld	ra,24(sp)
 372:	6442                	ld	s0,16(sp)
 374:	6105                	addi	sp,sp,32
 376:	8082                	ret

0000000000000378 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 378:	7139                	addi	sp,sp,-64
 37a:	fc06                	sd	ra,56(sp)
 37c:	f822                	sd	s0,48(sp)
 37e:	f426                	sd	s1,40(sp)
 380:	f04a                	sd	s2,32(sp)
 382:	ec4e                	sd	s3,24(sp)
 384:	0080                	addi	s0,sp,64
 386:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 388:	c299                	beqz	a3,38e <printint+0x16>
 38a:	0805c863          	bltz	a1,41a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 38e:	2581                	sext.w	a1,a1
  neg = 0;
 390:	4881                	li	a7,0
 392:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 396:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 398:	2601                	sext.w	a2,a2
 39a:	00000517          	auipc	a0,0x0
 39e:	45650513          	addi	a0,a0,1110 # 7f0 <digits>
 3a2:	883a                	mv	a6,a4
 3a4:	2705                	addiw	a4,a4,1
 3a6:	02c5f7bb          	remuw	a5,a1,a2
 3aa:	1782                	slli	a5,a5,0x20
 3ac:	9381                	srli	a5,a5,0x20
 3ae:	97aa                	add	a5,a5,a0
 3b0:	0007c783          	lbu	a5,0(a5)
 3b4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3b8:	0005879b          	sext.w	a5,a1
 3bc:	02c5d5bb          	divuw	a1,a1,a2
 3c0:	0685                	addi	a3,a3,1
 3c2:	fec7f0e3          	bgeu	a5,a2,3a2 <printint+0x2a>
  if(neg)
 3c6:	00088b63          	beqz	a7,3dc <printint+0x64>
    buf[i++] = '-';
 3ca:	fd040793          	addi	a5,s0,-48
 3ce:	973e                	add	a4,a4,a5
 3d0:	02d00793          	li	a5,45
 3d4:	fef70823          	sb	a5,-16(a4)
 3d8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3dc:	02e05863          	blez	a4,40c <printint+0x94>
 3e0:	fc040793          	addi	a5,s0,-64
 3e4:	00e78933          	add	s2,a5,a4
 3e8:	fff78993          	addi	s3,a5,-1
 3ec:	99ba                	add	s3,s3,a4
 3ee:	377d                	addiw	a4,a4,-1
 3f0:	1702                	slli	a4,a4,0x20
 3f2:	9301                	srli	a4,a4,0x20
 3f4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3f8:	fff94583          	lbu	a1,-1(s2)
 3fc:	8526                	mv	a0,s1
 3fe:	00000097          	auipc	ra,0x0
 402:	f58080e7          	jalr	-168(ra) # 356 <putc>
  while(--i >= 0)
 406:	197d                	addi	s2,s2,-1
 408:	ff3918e3          	bne	s2,s3,3f8 <printint+0x80>
}
 40c:	70e2                	ld	ra,56(sp)
 40e:	7442                	ld	s0,48(sp)
 410:	74a2                	ld	s1,40(sp)
 412:	7902                	ld	s2,32(sp)
 414:	69e2                	ld	s3,24(sp)
 416:	6121                	addi	sp,sp,64
 418:	8082                	ret
    x = -xx;
 41a:	40b005bb          	negw	a1,a1
    neg = 1;
 41e:	4885                	li	a7,1
    x = -xx;
 420:	bf8d                	j	392 <printint+0x1a>

0000000000000422 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 422:	7119                	addi	sp,sp,-128
 424:	fc86                	sd	ra,120(sp)
 426:	f8a2                	sd	s0,112(sp)
 428:	f4a6                	sd	s1,104(sp)
 42a:	f0ca                	sd	s2,96(sp)
 42c:	ecce                	sd	s3,88(sp)
 42e:	e8d2                	sd	s4,80(sp)
 430:	e4d6                	sd	s5,72(sp)
 432:	e0da                	sd	s6,64(sp)
 434:	fc5e                	sd	s7,56(sp)
 436:	f862                	sd	s8,48(sp)
 438:	f466                	sd	s9,40(sp)
 43a:	f06a                	sd	s10,32(sp)
 43c:	ec6e                	sd	s11,24(sp)
 43e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 440:	0005c903          	lbu	s2,0(a1)
 444:	18090f63          	beqz	s2,5e2 <vprintf+0x1c0>
 448:	8aaa                	mv	s5,a0
 44a:	8b32                	mv	s6,a2
 44c:	00158493          	addi	s1,a1,1
  state = 0;
 450:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 452:	02500a13          	li	s4,37
      if(c == 'd'){
 456:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 45a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 45e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 462:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 466:	00000b97          	auipc	s7,0x0
 46a:	38ab8b93          	addi	s7,s7,906 # 7f0 <digits>
 46e:	a839                	j	48c <vprintf+0x6a>
        putc(fd, c);
 470:	85ca                	mv	a1,s2
 472:	8556                	mv	a0,s5
 474:	00000097          	auipc	ra,0x0
 478:	ee2080e7          	jalr	-286(ra) # 356 <putc>
 47c:	a019                	j	482 <vprintf+0x60>
    } else if(state == '%'){
 47e:	01498f63          	beq	s3,s4,49c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 482:	0485                	addi	s1,s1,1
 484:	fff4c903          	lbu	s2,-1(s1)
 488:	14090d63          	beqz	s2,5e2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 48c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 490:	fe0997e3          	bnez	s3,47e <vprintf+0x5c>
      if(c == '%'){
 494:	fd479ee3          	bne	a5,s4,470 <vprintf+0x4e>
        state = '%';
 498:	89be                	mv	s3,a5
 49a:	b7e5                	j	482 <vprintf+0x60>
      if(c == 'd'){
 49c:	05878063          	beq	a5,s8,4dc <vprintf+0xba>
      } else if(c == 'l') {
 4a0:	05978c63          	beq	a5,s9,4f8 <vprintf+0xd6>
      } else if(c == 'x') {
 4a4:	07a78863          	beq	a5,s10,514 <vprintf+0xf2>
      } else if(c == 'p') {
 4a8:	09b78463          	beq	a5,s11,530 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4ac:	07300713          	li	a4,115
 4b0:	0ce78663          	beq	a5,a4,57c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4b4:	06300713          	li	a4,99
 4b8:	0ee78e63          	beq	a5,a4,5b4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4bc:	11478863          	beq	a5,s4,5cc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4c0:	85d2                	mv	a1,s4
 4c2:	8556                	mv	a0,s5
 4c4:	00000097          	auipc	ra,0x0
 4c8:	e92080e7          	jalr	-366(ra) # 356 <putc>
        putc(fd, c);
 4cc:	85ca                	mv	a1,s2
 4ce:	8556                	mv	a0,s5
 4d0:	00000097          	auipc	ra,0x0
 4d4:	e86080e7          	jalr	-378(ra) # 356 <putc>
      }
      state = 0;
 4d8:	4981                	li	s3,0
 4da:	b765                	j	482 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4dc:	008b0913          	addi	s2,s6,8
 4e0:	4685                	li	a3,1
 4e2:	4629                	li	a2,10
 4e4:	000b2583          	lw	a1,0(s6)
 4e8:	8556                	mv	a0,s5
 4ea:	00000097          	auipc	ra,0x0
 4ee:	e8e080e7          	jalr	-370(ra) # 378 <printint>
 4f2:	8b4a                	mv	s6,s2
      state = 0;
 4f4:	4981                	li	s3,0
 4f6:	b771                	j	482 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4f8:	008b0913          	addi	s2,s6,8
 4fc:	4681                	li	a3,0
 4fe:	4629                	li	a2,10
 500:	000b2583          	lw	a1,0(s6)
 504:	8556                	mv	a0,s5
 506:	00000097          	auipc	ra,0x0
 50a:	e72080e7          	jalr	-398(ra) # 378 <printint>
 50e:	8b4a                	mv	s6,s2
      state = 0;
 510:	4981                	li	s3,0
 512:	bf85                	j	482 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 514:	008b0913          	addi	s2,s6,8
 518:	4681                	li	a3,0
 51a:	4641                	li	a2,16
 51c:	000b2583          	lw	a1,0(s6)
 520:	8556                	mv	a0,s5
 522:	00000097          	auipc	ra,0x0
 526:	e56080e7          	jalr	-426(ra) # 378 <printint>
 52a:	8b4a                	mv	s6,s2
      state = 0;
 52c:	4981                	li	s3,0
 52e:	bf91                	j	482 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 530:	008b0793          	addi	a5,s6,8
 534:	f8f43423          	sd	a5,-120(s0)
 538:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 53c:	03000593          	li	a1,48
 540:	8556                	mv	a0,s5
 542:	00000097          	auipc	ra,0x0
 546:	e14080e7          	jalr	-492(ra) # 356 <putc>
  putc(fd, 'x');
 54a:	85ea                	mv	a1,s10
 54c:	8556                	mv	a0,s5
 54e:	00000097          	auipc	ra,0x0
 552:	e08080e7          	jalr	-504(ra) # 356 <putc>
 556:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 558:	03c9d793          	srli	a5,s3,0x3c
 55c:	97de                	add	a5,a5,s7
 55e:	0007c583          	lbu	a1,0(a5)
 562:	8556                	mv	a0,s5
 564:	00000097          	auipc	ra,0x0
 568:	df2080e7          	jalr	-526(ra) # 356 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 56c:	0992                	slli	s3,s3,0x4
 56e:	397d                	addiw	s2,s2,-1
 570:	fe0914e3          	bnez	s2,558 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 574:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 578:	4981                	li	s3,0
 57a:	b721                	j	482 <vprintf+0x60>
        s = va_arg(ap, char*);
 57c:	008b0993          	addi	s3,s6,8
 580:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 584:	02090163          	beqz	s2,5a6 <vprintf+0x184>
        while(*s != 0){
 588:	00094583          	lbu	a1,0(s2)
 58c:	c9a1                	beqz	a1,5dc <vprintf+0x1ba>
          putc(fd, *s);
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	dc6080e7          	jalr	-570(ra) # 356 <putc>
          s++;
 598:	0905                	addi	s2,s2,1
        while(*s != 0){
 59a:	00094583          	lbu	a1,0(s2)
 59e:	f9e5                	bnez	a1,58e <vprintf+0x16c>
        s = va_arg(ap, char*);
 5a0:	8b4e                	mv	s6,s3
      state = 0;
 5a2:	4981                	li	s3,0
 5a4:	bdf9                	j	482 <vprintf+0x60>
          s = "(null)";
 5a6:	00000917          	auipc	s2,0x0
 5aa:	24290913          	addi	s2,s2,578 # 7e8 <malloc+0xfc>
        while(*s != 0){
 5ae:	02800593          	li	a1,40
 5b2:	bff1                	j	58e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5b4:	008b0913          	addi	s2,s6,8
 5b8:	000b4583          	lbu	a1,0(s6)
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	d98080e7          	jalr	-616(ra) # 356 <putc>
 5c6:	8b4a                	mv	s6,s2
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	bd65                	j	482 <vprintf+0x60>
        putc(fd, c);
 5cc:	85d2                	mv	a1,s4
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	d86080e7          	jalr	-634(ra) # 356 <putc>
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	b565                	j	482 <vprintf+0x60>
        s = va_arg(ap, char*);
 5dc:	8b4e                	mv	s6,s3
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	b54d                	j	482 <vprintf+0x60>
    }
  }
}
 5e2:	70e6                	ld	ra,120(sp)
 5e4:	7446                	ld	s0,112(sp)
 5e6:	74a6                	ld	s1,104(sp)
 5e8:	7906                	ld	s2,96(sp)
 5ea:	69e6                	ld	s3,88(sp)
 5ec:	6a46                	ld	s4,80(sp)
 5ee:	6aa6                	ld	s5,72(sp)
 5f0:	6b06                	ld	s6,64(sp)
 5f2:	7be2                	ld	s7,56(sp)
 5f4:	7c42                	ld	s8,48(sp)
 5f6:	7ca2                	ld	s9,40(sp)
 5f8:	7d02                	ld	s10,32(sp)
 5fa:	6de2                	ld	s11,24(sp)
 5fc:	6109                	addi	sp,sp,128
 5fe:	8082                	ret

0000000000000600 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 600:	715d                	addi	sp,sp,-80
 602:	ec06                	sd	ra,24(sp)
 604:	e822                	sd	s0,16(sp)
 606:	1000                	addi	s0,sp,32
 608:	e010                	sd	a2,0(s0)
 60a:	e414                	sd	a3,8(s0)
 60c:	e818                	sd	a4,16(s0)
 60e:	ec1c                	sd	a5,24(s0)
 610:	03043023          	sd	a6,32(s0)
 614:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 618:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 61c:	8622                	mv	a2,s0
 61e:	00000097          	auipc	ra,0x0
 622:	e04080e7          	jalr	-508(ra) # 422 <vprintf>
}
 626:	60e2                	ld	ra,24(sp)
 628:	6442                	ld	s0,16(sp)
 62a:	6161                	addi	sp,sp,80
 62c:	8082                	ret

000000000000062e <printf>:

void
printf(const char *fmt, ...)
{
 62e:	711d                	addi	sp,sp,-96
 630:	ec06                	sd	ra,24(sp)
 632:	e822                	sd	s0,16(sp)
 634:	1000                	addi	s0,sp,32
 636:	e40c                	sd	a1,8(s0)
 638:	e810                	sd	a2,16(s0)
 63a:	ec14                	sd	a3,24(s0)
 63c:	f018                	sd	a4,32(s0)
 63e:	f41c                	sd	a5,40(s0)
 640:	03043823          	sd	a6,48(s0)
 644:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 648:	00840613          	addi	a2,s0,8
 64c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 650:	85aa                	mv	a1,a0
 652:	4505                	li	a0,1
 654:	00000097          	auipc	ra,0x0
 658:	dce080e7          	jalr	-562(ra) # 422 <vprintf>
}
 65c:	60e2                	ld	ra,24(sp)
 65e:	6442                	ld	s0,16(sp)
 660:	6125                	addi	sp,sp,96
 662:	8082                	ret

0000000000000664 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 664:	1141                	addi	sp,sp,-16
 666:	e422                	sd	s0,8(sp)
 668:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 66a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 66e:	00000797          	auipc	a5,0x0
 672:	19a7b783          	ld	a5,410(a5) # 808 <freep>
 676:	a805                	j	6a6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 678:	4618                	lw	a4,8(a2)
 67a:	9db9                	addw	a1,a1,a4
 67c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 680:	6398                	ld	a4,0(a5)
 682:	6318                	ld	a4,0(a4)
 684:	fee53823          	sd	a4,-16(a0)
 688:	a091                	j	6cc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 68a:	ff852703          	lw	a4,-8(a0)
 68e:	9e39                	addw	a2,a2,a4
 690:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 692:	ff053703          	ld	a4,-16(a0)
 696:	e398                	sd	a4,0(a5)
 698:	a099                	j	6de <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 69a:	6398                	ld	a4,0(a5)
 69c:	00e7e463          	bltu	a5,a4,6a4 <free+0x40>
 6a0:	00e6ea63          	bltu	a3,a4,6b4 <free+0x50>
{
 6a4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a6:	fed7fae3          	bgeu	a5,a3,69a <free+0x36>
 6aa:	6398                	ld	a4,0(a5)
 6ac:	00e6e463          	bltu	a3,a4,6b4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b0:	fee7eae3          	bltu	a5,a4,6a4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6b4:	ff852583          	lw	a1,-8(a0)
 6b8:	6390                	ld	a2,0(a5)
 6ba:	02059713          	slli	a4,a1,0x20
 6be:	9301                	srli	a4,a4,0x20
 6c0:	0712                	slli	a4,a4,0x4
 6c2:	9736                	add	a4,a4,a3
 6c4:	fae60ae3          	beq	a2,a4,678 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6c8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6cc:	4790                	lw	a2,8(a5)
 6ce:	02061713          	slli	a4,a2,0x20
 6d2:	9301                	srli	a4,a4,0x20
 6d4:	0712                	slli	a4,a4,0x4
 6d6:	973e                	add	a4,a4,a5
 6d8:	fae689e3          	beq	a3,a4,68a <free+0x26>
  } else
    p->s.ptr = bp;
 6dc:	e394                	sd	a3,0(a5)
  freep = p;
 6de:	00000717          	auipc	a4,0x0
 6e2:	12f73523          	sd	a5,298(a4) # 808 <freep>
}
 6e6:	6422                	ld	s0,8(sp)
 6e8:	0141                	addi	sp,sp,16
 6ea:	8082                	ret

00000000000006ec <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6ec:	7139                	addi	sp,sp,-64
 6ee:	fc06                	sd	ra,56(sp)
 6f0:	f822                	sd	s0,48(sp)
 6f2:	f426                	sd	s1,40(sp)
 6f4:	f04a                	sd	s2,32(sp)
 6f6:	ec4e                	sd	s3,24(sp)
 6f8:	e852                	sd	s4,16(sp)
 6fa:	e456                	sd	s5,8(sp)
 6fc:	e05a                	sd	s6,0(sp)
 6fe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 700:	02051493          	slli	s1,a0,0x20
 704:	9081                	srli	s1,s1,0x20
 706:	04bd                	addi	s1,s1,15
 708:	8091                	srli	s1,s1,0x4
 70a:	0014899b          	addiw	s3,s1,1
 70e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 710:	00000517          	auipc	a0,0x0
 714:	0f853503          	ld	a0,248(a0) # 808 <freep>
 718:	c515                	beqz	a0,744 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 71a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 71c:	4798                	lw	a4,8(a5)
 71e:	02977f63          	bgeu	a4,s1,75c <malloc+0x70>
 722:	8a4e                	mv	s4,s3
 724:	0009871b          	sext.w	a4,s3
 728:	6685                	lui	a3,0x1
 72a:	00d77363          	bgeu	a4,a3,730 <malloc+0x44>
 72e:	6a05                	lui	s4,0x1
 730:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 734:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 738:	00000917          	auipc	s2,0x0
 73c:	0d090913          	addi	s2,s2,208 # 808 <freep>
  if(p == (char*)-1)
 740:	5afd                	li	s5,-1
 742:	a88d                	j	7b4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 744:	00000797          	auipc	a5,0x0
 748:	0cc78793          	addi	a5,a5,204 # 810 <base>
 74c:	00000717          	auipc	a4,0x0
 750:	0af73e23          	sd	a5,188(a4) # 808 <freep>
 754:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 756:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 75a:	b7e1                	j	722 <malloc+0x36>
      if(p->s.size == nunits)
 75c:	02e48b63          	beq	s1,a4,792 <malloc+0xa6>
        p->s.size -= nunits;
 760:	4137073b          	subw	a4,a4,s3
 764:	c798                	sw	a4,8(a5)
        p += p->s.size;
 766:	1702                	slli	a4,a4,0x20
 768:	9301                	srli	a4,a4,0x20
 76a:	0712                	slli	a4,a4,0x4
 76c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 76e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 772:	00000717          	auipc	a4,0x0
 776:	08a73b23          	sd	a0,150(a4) # 808 <freep>
      return (void*)(p + 1);
 77a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 77e:	70e2                	ld	ra,56(sp)
 780:	7442                	ld	s0,48(sp)
 782:	74a2                	ld	s1,40(sp)
 784:	7902                	ld	s2,32(sp)
 786:	69e2                	ld	s3,24(sp)
 788:	6a42                	ld	s4,16(sp)
 78a:	6aa2                	ld	s5,8(sp)
 78c:	6b02                	ld	s6,0(sp)
 78e:	6121                	addi	sp,sp,64
 790:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 792:	6398                	ld	a4,0(a5)
 794:	e118                	sd	a4,0(a0)
 796:	bff1                	j	772 <malloc+0x86>
  hp->s.size = nu;
 798:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 79c:	0541                	addi	a0,a0,16
 79e:	00000097          	auipc	ra,0x0
 7a2:	ec6080e7          	jalr	-314(ra) # 664 <free>
  return freep;
 7a6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7aa:	d971                	beqz	a0,77e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ac:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ae:	4798                	lw	a4,8(a5)
 7b0:	fa9776e3          	bgeu	a4,s1,75c <malloc+0x70>
    if(p == freep)
 7b4:	00093703          	ld	a4,0(s2)
 7b8:	853e                	mv	a0,a5
 7ba:	fef719e3          	bne	a4,a5,7ac <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7be:	8552                	mv	a0,s4
 7c0:	00000097          	auipc	ra,0x0
 7c4:	b7e080e7          	jalr	-1154(ra) # 33e <sbrk>
  if(p == (char*)-1)
 7c8:	fd5518e3          	bne	a0,s5,798 <malloc+0xac>
        return 0;
 7cc:	4501                	li	a0,0
 7ce:	bf45                	j	77e <malloc+0x92>
