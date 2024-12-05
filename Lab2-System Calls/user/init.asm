
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	88250513          	addi	a0,a0,-1918 # 890 <malloc+0xe4>
  16:	00000097          	auipc	ra,0x0
  1a:	398080e7          	jalr	920(ra) # 3ae <open>
  1e:	06054363          	bltz	a0,84 <main+0x84>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	3c2080e7          	jalr	962(ra) # 3e6 <dup>
  dup(0);  // stderr
  2c:	4501                	li	a0,0
  2e:	00000097          	auipc	ra,0x0
  32:	3b8080e7          	jalr	952(ra) # 3e6 <dup>

  for(;;){
    printf("init: starting sh\n");
  36:	00001917          	auipc	s2,0x1
  3a:	86290913          	addi	s2,s2,-1950 # 898 <malloc+0xec>
  3e:	854a                	mv	a0,s2
  40:	00000097          	auipc	ra,0x0
  44:	6ae080e7          	jalr	1710(ra) # 6ee <printf>
    pid = fork();
  48:	00000097          	auipc	ra,0x0
  4c:	31e080e7          	jalr	798(ra) # 366 <fork>
  50:	84aa                	mv	s1,a0
    if(pid < 0){
  52:	04054d63          	bltz	a0,ac <main+0xac>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  56:	c925                	beqz	a0,c6 <main+0xc6>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  58:	4501                	li	a0,0
  5a:	00000097          	auipc	ra,0x0
  5e:	31c080e7          	jalr	796(ra) # 376 <wait>
      if(wpid == pid){
  62:	fca48ee3          	beq	s1,a0,3e <main+0x3e>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  66:	fe0559e3          	bgez	a0,58 <main+0x58>
        printf("init: wait returned an error\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	87e50513          	addi	a0,a0,-1922 # 8e8 <malloc+0x13c>
  72:	00000097          	auipc	ra,0x0
  76:	67c080e7          	jalr	1660(ra) # 6ee <printf>
        exit(1);
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	2f2080e7          	jalr	754(ra) # 36e <exit>
    mknod("console", CONSOLE, 0);
  84:	4601                	li	a2,0
  86:	4585                	li	a1,1
  88:	00001517          	auipc	a0,0x1
  8c:	80850513          	addi	a0,a0,-2040 # 890 <malloc+0xe4>
  90:	00000097          	auipc	ra,0x0
  94:	326080e7          	jalr	806(ra) # 3b6 <mknod>
    open("console", O_RDWR);
  98:	4589                	li	a1,2
  9a:	00000517          	auipc	a0,0x0
  9e:	7f650513          	addi	a0,a0,2038 # 890 <malloc+0xe4>
  a2:	00000097          	auipc	ra,0x0
  a6:	30c080e7          	jalr	780(ra) # 3ae <open>
  aa:	bfa5                	j	22 <main+0x22>
      printf("init: fork failed\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	80450513          	addi	a0,a0,-2044 # 8b0 <malloc+0x104>
  b4:	00000097          	auipc	ra,0x0
  b8:	63a080e7          	jalr	1594(ra) # 6ee <printf>
      exit(1);
  bc:	4505                	li	a0,1
  be:	00000097          	auipc	ra,0x0
  c2:	2b0080e7          	jalr	688(ra) # 36e <exit>
      exec("sh", argv);
  c6:	00001597          	auipc	a1,0x1
  ca:	86258593          	addi	a1,a1,-1950 # 928 <argv>
  ce:	00000517          	auipc	a0,0x0
  d2:	7fa50513          	addi	a0,a0,2042 # 8c8 <malloc+0x11c>
  d6:	00000097          	auipc	ra,0x0
  da:	2d0080e7          	jalr	720(ra) # 3a6 <exec>
      printf("init: exec sh failed\n");
  de:	00000517          	auipc	a0,0x0
  e2:	7f250513          	addi	a0,a0,2034 # 8d0 <malloc+0x124>
  e6:	00000097          	auipc	ra,0x0
  ea:	608080e7          	jalr	1544(ra) # 6ee <printf>
      exit(1);
  ee:	4505                	li	a0,1
  f0:	00000097          	auipc	ra,0x0
  f4:	27e080e7          	jalr	638(ra) # 36e <exit>

00000000000000f8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e422                	sd	s0,8(sp)
  fc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  fe:	87aa                	mv	a5,a0
 100:	0585                	addi	a1,a1,1
 102:	0785                	addi	a5,a5,1
 104:	fff5c703          	lbu	a4,-1(a1)
 108:	fee78fa3          	sb	a4,-1(a5)
 10c:	fb75                	bnez	a4,100 <strcpy+0x8>
    ;
  return os;
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret

0000000000000114 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cb91                	beqz	a5,132 <strcmp+0x1e>
 120:	0005c703          	lbu	a4,0(a1)
 124:	00f71763          	bne	a4,a5,132 <strcmp+0x1e>
    p++, q++;
 128:	0505                	addi	a0,a0,1
 12a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 12c:	00054783          	lbu	a5,0(a0)
 130:	fbe5                	bnez	a5,120 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 132:	0005c503          	lbu	a0,0(a1)
}
 136:	40a7853b          	subw	a0,a5,a0
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret

0000000000000140 <strlen>:

uint
strlen(const char *s)
{
 140:	1141                	addi	sp,sp,-16
 142:	e422                	sd	s0,8(sp)
 144:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 146:	00054783          	lbu	a5,0(a0)
 14a:	cf91                	beqz	a5,166 <strlen+0x26>
 14c:	0505                	addi	a0,a0,1
 14e:	87aa                	mv	a5,a0
 150:	4685                	li	a3,1
 152:	9e89                	subw	a3,a3,a0
 154:	00f6853b          	addw	a0,a3,a5
 158:	0785                	addi	a5,a5,1
 15a:	fff7c703          	lbu	a4,-1(a5)
 15e:	fb7d                	bnez	a4,154 <strlen+0x14>
    ;
  return n;
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret
  for(n = 0; s[n]; n++)
 166:	4501                	li	a0,0
 168:	bfe5                	j	160 <strlen+0x20>

000000000000016a <memset>:

void*
memset(void *dst, int c, uint n)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 170:	ce09                	beqz	a2,18a <memset+0x20>
 172:	87aa                	mv	a5,a0
 174:	fff6071b          	addiw	a4,a2,-1
 178:	1702                	slli	a4,a4,0x20
 17a:	9301                	srli	a4,a4,0x20
 17c:	0705                	addi	a4,a4,1
 17e:	972a                	add	a4,a4,a0
    cdst[i] = c;
 180:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 184:	0785                	addi	a5,a5,1
 186:	fee79de3          	bne	a5,a4,180 <memset+0x16>
  }
  return dst;
}
 18a:	6422                	ld	s0,8(sp)
 18c:	0141                	addi	sp,sp,16
 18e:	8082                	ret

0000000000000190 <strchr>:

char*
strchr(const char *s, char c)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  for(; *s; s++)
 196:	00054783          	lbu	a5,0(a0)
 19a:	cb99                	beqz	a5,1b0 <strchr+0x20>
    if(*s == c)
 19c:	00f58763          	beq	a1,a5,1aa <strchr+0x1a>
  for(; *s; s++)
 1a0:	0505                	addi	a0,a0,1
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	fbfd                	bnez	a5,19c <strchr+0xc>
      return (char*)s;
  return 0;
 1a8:	4501                	li	a0,0
}
 1aa:	6422                	ld	s0,8(sp)
 1ac:	0141                	addi	sp,sp,16
 1ae:	8082                	ret
  return 0;
 1b0:	4501                	li	a0,0
 1b2:	bfe5                	j	1aa <strchr+0x1a>

00000000000001b4 <gets>:

char*
gets(char *buf, int max)
{
 1b4:	711d                	addi	sp,sp,-96
 1b6:	ec86                	sd	ra,88(sp)
 1b8:	e8a2                	sd	s0,80(sp)
 1ba:	e4a6                	sd	s1,72(sp)
 1bc:	e0ca                	sd	s2,64(sp)
 1be:	fc4e                	sd	s3,56(sp)
 1c0:	f852                	sd	s4,48(sp)
 1c2:	f456                	sd	s5,40(sp)
 1c4:	f05a                	sd	s6,32(sp)
 1c6:	ec5e                	sd	s7,24(sp)
 1c8:	1080                	addi	s0,sp,96
 1ca:	8baa                	mv	s7,a0
 1cc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ce:	892a                	mv	s2,a0
 1d0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d2:	4aa9                	li	s5,10
 1d4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d6:	89a6                	mv	s3,s1
 1d8:	2485                	addiw	s1,s1,1
 1da:	0344d863          	bge	s1,s4,20a <gets+0x56>
    cc = read(0, &c, 1);
 1de:	4605                	li	a2,1
 1e0:	faf40593          	addi	a1,s0,-81
 1e4:	4501                	li	a0,0
 1e6:	00000097          	auipc	ra,0x0
 1ea:	1a0080e7          	jalr	416(ra) # 386 <read>
    if(cc < 1)
 1ee:	00a05e63          	blez	a0,20a <gets+0x56>
    buf[i++] = c;
 1f2:	faf44783          	lbu	a5,-81(s0)
 1f6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1fa:	01578763          	beq	a5,s5,208 <gets+0x54>
 1fe:	0905                	addi	s2,s2,1
 200:	fd679be3          	bne	a5,s6,1d6 <gets+0x22>
  for(i=0; i+1 < max; ){
 204:	89a6                	mv	s3,s1
 206:	a011                	j	20a <gets+0x56>
 208:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 20a:	99de                	add	s3,s3,s7
 20c:	00098023          	sb	zero,0(s3)
  return buf;
}
 210:	855e                	mv	a0,s7
 212:	60e6                	ld	ra,88(sp)
 214:	6446                	ld	s0,80(sp)
 216:	64a6                	ld	s1,72(sp)
 218:	6906                	ld	s2,64(sp)
 21a:	79e2                	ld	s3,56(sp)
 21c:	7a42                	ld	s4,48(sp)
 21e:	7aa2                	ld	s5,40(sp)
 220:	7b02                	ld	s6,32(sp)
 222:	6be2                	ld	s7,24(sp)
 224:	6125                	addi	sp,sp,96
 226:	8082                	ret

0000000000000228 <stat>:

int
stat(const char *n, struct stat *st)
{
 228:	1101                	addi	sp,sp,-32
 22a:	ec06                	sd	ra,24(sp)
 22c:	e822                	sd	s0,16(sp)
 22e:	e426                	sd	s1,8(sp)
 230:	e04a                	sd	s2,0(sp)
 232:	1000                	addi	s0,sp,32
 234:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 236:	4581                	li	a1,0
 238:	00000097          	auipc	ra,0x0
 23c:	176080e7          	jalr	374(ra) # 3ae <open>
  if(fd < 0)
 240:	02054563          	bltz	a0,26a <stat+0x42>
 244:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 246:	85ca                	mv	a1,s2
 248:	00000097          	auipc	ra,0x0
 24c:	17e080e7          	jalr	382(ra) # 3c6 <fstat>
 250:	892a                	mv	s2,a0
  close(fd);
 252:	8526                	mv	a0,s1
 254:	00000097          	auipc	ra,0x0
 258:	142080e7          	jalr	322(ra) # 396 <close>
  return r;
}
 25c:	854a                	mv	a0,s2
 25e:	60e2                	ld	ra,24(sp)
 260:	6442                	ld	s0,16(sp)
 262:	64a2                	ld	s1,8(sp)
 264:	6902                	ld	s2,0(sp)
 266:	6105                	addi	sp,sp,32
 268:	8082                	ret
    return -1;
 26a:	597d                	li	s2,-1
 26c:	bfc5                	j	25c <stat+0x34>

000000000000026e <atoi>:

int
atoi(const char *s)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 274:	00054603          	lbu	a2,0(a0)
 278:	fd06079b          	addiw	a5,a2,-48
 27c:	0ff7f793          	andi	a5,a5,255
 280:	4725                	li	a4,9
 282:	02f76963          	bltu	a4,a5,2b4 <atoi+0x46>
 286:	86aa                	mv	a3,a0
  n = 0;
 288:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 28a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 28c:	0685                	addi	a3,a3,1
 28e:	0025179b          	slliw	a5,a0,0x2
 292:	9fa9                	addw	a5,a5,a0
 294:	0017979b          	slliw	a5,a5,0x1
 298:	9fb1                	addw	a5,a5,a2
 29a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 29e:	0006c603          	lbu	a2,0(a3)
 2a2:	fd06071b          	addiw	a4,a2,-48
 2a6:	0ff77713          	andi	a4,a4,255
 2aa:	fee5f1e3          	bgeu	a1,a4,28c <atoi+0x1e>
  return n;
}
 2ae:	6422                	ld	s0,8(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret
  n = 0;
 2b4:	4501                	li	a0,0
 2b6:	bfe5                	j	2ae <atoi+0x40>

00000000000002b8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2be:	02b57663          	bgeu	a0,a1,2ea <memmove+0x32>
    while(n-- > 0)
 2c2:	02c05163          	blez	a2,2e4 <memmove+0x2c>
 2c6:	fff6079b          	addiw	a5,a2,-1
 2ca:	1782                	slli	a5,a5,0x20
 2cc:	9381                	srli	a5,a5,0x20
 2ce:	0785                	addi	a5,a5,1
 2d0:	97aa                	add	a5,a5,a0
  dst = vdst;
 2d2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d4:	0585                	addi	a1,a1,1
 2d6:	0705                	addi	a4,a4,1
 2d8:	fff5c683          	lbu	a3,-1(a1)
 2dc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2e0:	fee79ae3          	bne	a5,a4,2d4 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
    dst += n;
 2ea:	00c50733          	add	a4,a0,a2
    src += n;
 2ee:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2f0:	fec05ae3          	blez	a2,2e4 <memmove+0x2c>
 2f4:	fff6079b          	addiw	a5,a2,-1
 2f8:	1782                	slli	a5,a5,0x20
 2fa:	9381                	srli	a5,a5,0x20
 2fc:	fff7c793          	not	a5,a5
 300:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 302:	15fd                	addi	a1,a1,-1
 304:	177d                	addi	a4,a4,-1
 306:	0005c683          	lbu	a3,0(a1)
 30a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 30e:	fee79ae3          	bne	a5,a4,302 <memmove+0x4a>
 312:	bfc9                	j	2e4 <memmove+0x2c>

0000000000000314 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 314:	1141                	addi	sp,sp,-16
 316:	e422                	sd	s0,8(sp)
 318:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 31a:	ca05                	beqz	a2,34a <memcmp+0x36>
 31c:	fff6069b          	addiw	a3,a2,-1
 320:	1682                	slli	a3,a3,0x20
 322:	9281                	srli	a3,a3,0x20
 324:	0685                	addi	a3,a3,1
 326:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 328:	00054783          	lbu	a5,0(a0)
 32c:	0005c703          	lbu	a4,0(a1)
 330:	00e79863          	bne	a5,a4,340 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 334:	0505                	addi	a0,a0,1
    p2++;
 336:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 338:	fed518e3          	bne	a0,a3,328 <memcmp+0x14>
  }
  return 0;
 33c:	4501                	li	a0,0
 33e:	a019                	j	344 <memcmp+0x30>
      return *p1 - *p2;
 340:	40e7853b          	subw	a0,a5,a4
}
 344:	6422                	ld	s0,8(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret
  return 0;
 34a:	4501                	li	a0,0
 34c:	bfe5                	j	344 <memcmp+0x30>

000000000000034e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 34e:	1141                	addi	sp,sp,-16
 350:	e406                	sd	ra,8(sp)
 352:	e022                	sd	s0,0(sp)
 354:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 356:	00000097          	auipc	ra,0x0
 35a:	f62080e7          	jalr	-158(ra) # 2b8 <memmove>
}
 35e:	60a2                	ld	ra,8(sp)
 360:	6402                	ld	s0,0(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret

0000000000000366 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 366:	4885                	li	a7,1
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <exit>:
.global exit
exit:
 li a7, SYS_exit
 36e:	4889                	li	a7,2
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <wait>:
.global wait
wait:
 li a7, SYS_wait
 376:	488d                	li	a7,3
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 37e:	4891                	li	a7,4
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <read>:
.global read
read:
 li a7, SYS_read
 386:	4895                	li	a7,5
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <write>:
.global write
write:
 li a7, SYS_write
 38e:	48c1                	li	a7,16
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <close>:
.global close
close:
 li a7, SYS_close
 396:	48d5                	li	a7,21
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <kill>:
.global kill
kill:
 li a7, SYS_kill
 39e:	4899                	li	a7,6
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3a6:	489d                	li	a7,7
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <open>:
.global open
open:
 li a7, SYS_open
 3ae:	48bd                	li	a7,15
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3b6:	48c5                	li	a7,17
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3be:	48c9                	li	a7,18
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3c6:	48a1                	li	a7,8
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <link>:
.global link
link:
 li a7, SYS_link
 3ce:	48cd                	li	a7,19
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3d6:	48d1                	li	a7,20
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3de:	48a5                	li	a7,9
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3e6:	48a9                	li	a7,10
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ee:	48ad                	li	a7,11
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3f6:	48b1                	li	a7,12
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3fe:	48b5                	li	a7,13
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 406:	48b9                	li	a7,14
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <trace>:
.global trace
trace:
 li a7, SYS_trace
 40e:	48d9                	li	a7,22
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 416:	1101                	addi	sp,sp,-32
 418:	ec06                	sd	ra,24(sp)
 41a:	e822                	sd	s0,16(sp)
 41c:	1000                	addi	s0,sp,32
 41e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 422:	4605                	li	a2,1
 424:	fef40593          	addi	a1,s0,-17
 428:	00000097          	auipc	ra,0x0
 42c:	f66080e7          	jalr	-154(ra) # 38e <write>
}
 430:	60e2                	ld	ra,24(sp)
 432:	6442                	ld	s0,16(sp)
 434:	6105                	addi	sp,sp,32
 436:	8082                	ret

0000000000000438 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 438:	7139                	addi	sp,sp,-64
 43a:	fc06                	sd	ra,56(sp)
 43c:	f822                	sd	s0,48(sp)
 43e:	f426                	sd	s1,40(sp)
 440:	f04a                	sd	s2,32(sp)
 442:	ec4e                	sd	s3,24(sp)
 444:	0080                	addi	s0,sp,64
 446:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 448:	c299                	beqz	a3,44e <printint+0x16>
 44a:	0805c863          	bltz	a1,4da <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 44e:	2581                	sext.w	a1,a1
  neg = 0;
 450:	4881                	li	a7,0
 452:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 456:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 458:	2601                	sext.w	a2,a2
 45a:	00000517          	auipc	a0,0x0
 45e:	4b650513          	addi	a0,a0,1206 # 910 <digits>
 462:	883a                	mv	a6,a4
 464:	2705                	addiw	a4,a4,1
 466:	02c5f7bb          	remuw	a5,a1,a2
 46a:	1782                	slli	a5,a5,0x20
 46c:	9381                	srli	a5,a5,0x20
 46e:	97aa                	add	a5,a5,a0
 470:	0007c783          	lbu	a5,0(a5)
 474:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 478:	0005879b          	sext.w	a5,a1
 47c:	02c5d5bb          	divuw	a1,a1,a2
 480:	0685                	addi	a3,a3,1
 482:	fec7f0e3          	bgeu	a5,a2,462 <printint+0x2a>
  if(neg)
 486:	00088b63          	beqz	a7,49c <printint+0x64>
    buf[i++] = '-';
 48a:	fd040793          	addi	a5,s0,-48
 48e:	973e                	add	a4,a4,a5
 490:	02d00793          	li	a5,45
 494:	fef70823          	sb	a5,-16(a4)
 498:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 49c:	02e05863          	blez	a4,4cc <printint+0x94>
 4a0:	fc040793          	addi	a5,s0,-64
 4a4:	00e78933          	add	s2,a5,a4
 4a8:	fff78993          	addi	s3,a5,-1
 4ac:	99ba                	add	s3,s3,a4
 4ae:	377d                	addiw	a4,a4,-1
 4b0:	1702                	slli	a4,a4,0x20
 4b2:	9301                	srli	a4,a4,0x20
 4b4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4b8:	fff94583          	lbu	a1,-1(s2)
 4bc:	8526                	mv	a0,s1
 4be:	00000097          	auipc	ra,0x0
 4c2:	f58080e7          	jalr	-168(ra) # 416 <putc>
  while(--i >= 0)
 4c6:	197d                	addi	s2,s2,-1
 4c8:	ff3918e3          	bne	s2,s3,4b8 <printint+0x80>
}
 4cc:	70e2                	ld	ra,56(sp)
 4ce:	7442                	ld	s0,48(sp)
 4d0:	74a2                	ld	s1,40(sp)
 4d2:	7902                	ld	s2,32(sp)
 4d4:	69e2                	ld	s3,24(sp)
 4d6:	6121                	addi	sp,sp,64
 4d8:	8082                	ret
    x = -xx;
 4da:	40b005bb          	negw	a1,a1
    neg = 1;
 4de:	4885                	li	a7,1
    x = -xx;
 4e0:	bf8d                	j	452 <printint+0x1a>

00000000000004e2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4e2:	7119                	addi	sp,sp,-128
 4e4:	fc86                	sd	ra,120(sp)
 4e6:	f8a2                	sd	s0,112(sp)
 4e8:	f4a6                	sd	s1,104(sp)
 4ea:	f0ca                	sd	s2,96(sp)
 4ec:	ecce                	sd	s3,88(sp)
 4ee:	e8d2                	sd	s4,80(sp)
 4f0:	e4d6                	sd	s5,72(sp)
 4f2:	e0da                	sd	s6,64(sp)
 4f4:	fc5e                	sd	s7,56(sp)
 4f6:	f862                	sd	s8,48(sp)
 4f8:	f466                	sd	s9,40(sp)
 4fa:	f06a                	sd	s10,32(sp)
 4fc:	ec6e                	sd	s11,24(sp)
 4fe:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 500:	0005c903          	lbu	s2,0(a1)
 504:	18090f63          	beqz	s2,6a2 <vprintf+0x1c0>
 508:	8aaa                	mv	s5,a0
 50a:	8b32                	mv	s6,a2
 50c:	00158493          	addi	s1,a1,1
  state = 0;
 510:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 512:	02500a13          	li	s4,37
      if(c == 'd'){
 516:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 51a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 51e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 522:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 526:	00000b97          	auipc	s7,0x0
 52a:	3eab8b93          	addi	s7,s7,1002 # 910 <digits>
 52e:	a839                	j	54c <vprintf+0x6a>
        putc(fd, c);
 530:	85ca                	mv	a1,s2
 532:	8556                	mv	a0,s5
 534:	00000097          	auipc	ra,0x0
 538:	ee2080e7          	jalr	-286(ra) # 416 <putc>
 53c:	a019                	j	542 <vprintf+0x60>
    } else if(state == '%'){
 53e:	01498f63          	beq	s3,s4,55c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 542:	0485                	addi	s1,s1,1
 544:	fff4c903          	lbu	s2,-1(s1)
 548:	14090d63          	beqz	s2,6a2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 54c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 550:	fe0997e3          	bnez	s3,53e <vprintf+0x5c>
      if(c == '%'){
 554:	fd479ee3          	bne	a5,s4,530 <vprintf+0x4e>
        state = '%';
 558:	89be                	mv	s3,a5
 55a:	b7e5                	j	542 <vprintf+0x60>
      if(c == 'd'){
 55c:	05878063          	beq	a5,s8,59c <vprintf+0xba>
      } else if(c == 'l') {
 560:	05978c63          	beq	a5,s9,5b8 <vprintf+0xd6>
      } else if(c == 'x') {
 564:	07a78863          	beq	a5,s10,5d4 <vprintf+0xf2>
      } else if(c == 'p') {
 568:	09b78463          	beq	a5,s11,5f0 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 56c:	07300713          	li	a4,115
 570:	0ce78663          	beq	a5,a4,63c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 574:	06300713          	li	a4,99
 578:	0ee78e63          	beq	a5,a4,674 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 57c:	11478863          	beq	a5,s4,68c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 580:	85d2                	mv	a1,s4
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	e92080e7          	jalr	-366(ra) # 416 <putc>
        putc(fd, c);
 58c:	85ca                	mv	a1,s2
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	e86080e7          	jalr	-378(ra) # 416 <putc>
      }
      state = 0;
 598:	4981                	li	s3,0
 59a:	b765                	j	542 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 59c:	008b0913          	addi	s2,s6,8
 5a0:	4685                	li	a3,1
 5a2:	4629                	li	a2,10
 5a4:	000b2583          	lw	a1,0(s6)
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	e8e080e7          	jalr	-370(ra) # 438 <printint>
 5b2:	8b4a                	mv	s6,s2
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	b771                	j	542 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b8:	008b0913          	addi	s2,s6,8
 5bc:	4681                	li	a3,0
 5be:	4629                	li	a2,10
 5c0:	000b2583          	lw	a1,0(s6)
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	e72080e7          	jalr	-398(ra) # 438 <printint>
 5ce:	8b4a                	mv	s6,s2
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	bf85                	j	542 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5d4:	008b0913          	addi	s2,s6,8
 5d8:	4681                	li	a3,0
 5da:	4641                	li	a2,16
 5dc:	000b2583          	lw	a1,0(s6)
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	e56080e7          	jalr	-426(ra) # 438 <printint>
 5ea:	8b4a                	mv	s6,s2
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	bf91                	j	542 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5f0:	008b0793          	addi	a5,s6,8
 5f4:	f8f43423          	sd	a5,-120(s0)
 5f8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5fc:	03000593          	li	a1,48
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	e14080e7          	jalr	-492(ra) # 416 <putc>
  putc(fd, 'x');
 60a:	85ea                	mv	a1,s10
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	e08080e7          	jalr	-504(ra) # 416 <putc>
 616:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 618:	03c9d793          	srli	a5,s3,0x3c
 61c:	97de                	add	a5,a5,s7
 61e:	0007c583          	lbu	a1,0(a5)
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	df2080e7          	jalr	-526(ra) # 416 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 62c:	0992                	slli	s3,s3,0x4
 62e:	397d                	addiw	s2,s2,-1
 630:	fe0914e3          	bnez	s2,618 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 634:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 638:	4981                	li	s3,0
 63a:	b721                	j	542 <vprintf+0x60>
        s = va_arg(ap, char*);
 63c:	008b0993          	addi	s3,s6,8
 640:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 644:	02090163          	beqz	s2,666 <vprintf+0x184>
        while(*s != 0){
 648:	00094583          	lbu	a1,0(s2)
 64c:	c9a1                	beqz	a1,69c <vprintf+0x1ba>
          putc(fd, *s);
 64e:	8556                	mv	a0,s5
 650:	00000097          	auipc	ra,0x0
 654:	dc6080e7          	jalr	-570(ra) # 416 <putc>
          s++;
 658:	0905                	addi	s2,s2,1
        while(*s != 0){
 65a:	00094583          	lbu	a1,0(s2)
 65e:	f9e5                	bnez	a1,64e <vprintf+0x16c>
        s = va_arg(ap, char*);
 660:	8b4e                	mv	s6,s3
      state = 0;
 662:	4981                	li	s3,0
 664:	bdf9                	j	542 <vprintf+0x60>
          s = "(null)";
 666:	00000917          	auipc	s2,0x0
 66a:	2a290913          	addi	s2,s2,674 # 908 <malloc+0x15c>
        while(*s != 0){
 66e:	02800593          	li	a1,40
 672:	bff1                	j	64e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 674:	008b0913          	addi	s2,s6,8
 678:	000b4583          	lbu	a1,0(s6)
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	d98080e7          	jalr	-616(ra) # 416 <putc>
 686:	8b4a                	mv	s6,s2
      state = 0;
 688:	4981                	li	s3,0
 68a:	bd65                	j	542 <vprintf+0x60>
        putc(fd, c);
 68c:	85d2                	mv	a1,s4
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	d86080e7          	jalr	-634(ra) # 416 <putc>
      state = 0;
 698:	4981                	li	s3,0
 69a:	b565                	j	542 <vprintf+0x60>
        s = va_arg(ap, char*);
 69c:	8b4e                	mv	s6,s3
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	b54d                	j	542 <vprintf+0x60>
    }
  }
}
 6a2:	70e6                	ld	ra,120(sp)
 6a4:	7446                	ld	s0,112(sp)
 6a6:	74a6                	ld	s1,104(sp)
 6a8:	7906                	ld	s2,96(sp)
 6aa:	69e6                	ld	s3,88(sp)
 6ac:	6a46                	ld	s4,80(sp)
 6ae:	6aa6                	ld	s5,72(sp)
 6b0:	6b06                	ld	s6,64(sp)
 6b2:	7be2                	ld	s7,56(sp)
 6b4:	7c42                	ld	s8,48(sp)
 6b6:	7ca2                	ld	s9,40(sp)
 6b8:	7d02                	ld	s10,32(sp)
 6ba:	6de2                	ld	s11,24(sp)
 6bc:	6109                	addi	sp,sp,128
 6be:	8082                	ret

00000000000006c0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6c0:	715d                	addi	sp,sp,-80
 6c2:	ec06                	sd	ra,24(sp)
 6c4:	e822                	sd	s0,16(sp)
 6c6:	1000                	addi	s0,sp,32
 6c8:	e010                	sd	a2,0(s0)
 6ca:	e414                	sd	a3,8(s0)
 6cc:	e818                	sd	a4,16(s0)
 6ce:	ec1c                	sd	a5,24(s0)
 6d0:	03043023          	sd	a6,32(s0)
 6d4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6d8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6dc:	8622                	mv	a2,s0
 6de:	00000097          	auipc	ra,0x0
 6e2:	e04080e7          	jalr	-508(ra) # 4e2 <vprintf>
}
 6e6:	60e2                	ld	ra,24(sp)
 6e8:	6442                	ld	s0,16(sp)
 6ea:	6161                	addi	sp,sp,80
 6ec:	8082                	ret

00000000000006ee <printf>:

void
printf(const char *fmt, ...)
{
 6ee:	711d                	addi	sp,sp,-96
 6f0:	ec06                	sd	ra,24(sp)
 6f2:	e822                	sd	s0,16(sp)
 6f4:	1000                	addi	s0,sp,32
 6f6:	e40c                	sd	a1,8(s0)
 6f8:	e810                	sd	a2,16(s0)
 6fa:	ec14                	sd	a3,24(s0)
 6fc:	f018                	sd	a4,32(s0)
 6fe:	f41c                	sd	a5,40(s0)
 700:	03043823          	sd	a6,48(s0)
 704:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 708:	00840613          	addi	a2,s0,8
 70c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 710:	85aa                	mv	a1,a0
 712:	4505                	li	a0,1
 714:	00000097          	auipc	ra,0x0
 718:	dce080e7          	jalr	-562(ra) # 4e2 <vprintf>
}
 71c:	60e2                	ld	ra,24(sp)
 71e:	6442                	ld	s0,16(sp)
 720:	6125                	addi	sp,sp,96
 722:	8082                	ret

0000000000000724 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 724:	1141                	addi	sp,sp,-16
 726:	e422                	sd	s0,8(sp)
 728:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 72a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72e:	00000797          	auipc	a5,0x0
 732:	20a7b783          	ld	a5,522(a5) # 938 <freep>
 736:	a805                	j	766 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 738:	4618                	lw	a4,8(a2)
 73a:	9db9                	addw	a1,a1,a4
 73c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 740:	6398                	ld	a4,0(a5)
 742:	6318                	ld	a4,0(a4)
 744:	fee53823          	sd	a4,-16(a0)
 748:	a091                	j	78c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 74a:	ff852703          	lw	a4,-8(a0)
 74e:	9e39                	addw	a2,a2,a4
 750:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 752:	ff053703          	ld	a4,-16(a0)
 756:	e398                	sd	a4,0(a5)
 758:	a099                	j	79e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 75a:	6398                	ld	a4,0(a5)
 75c:	00e7e463          	bltu	a5,a4,764 <free+0x40>
 760:	00e6ea63          	bltu	a3,a4,774 <free+0x50>
{
 764:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 766:	fed7fae3          	bgeu	a5,a3,75a <free+0x36>
 76a:	6398                	ld	a4,0(a5)
 76c:	00e6e463          	bltu	a3,a4,774 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 770:	fee7eae3          	bltu	a5,a4,764 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 774:	ff852583          	lw	a1,-8(a0)
 778:	6390                	ld	a2,0(a5)
 77a:	02059713          	slli	a4,a1,0x20
 77e:	9301                	srli	a4,a4,0x20
 780:	0712                	slli	a4,a4,0x4
 782:	9736                	add	a4,a4,a3
 784:	fae60ae3          	beq	a2,a4,738 <free+0x14>
    bp->s.ptr = p->s.ptr;
 788:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 78c:	4790                	lw	a2,8(a5)
 78e:	02061713          	slli	a4,a2,0x20
 792:	9301                	srli	a4,a4,0x20
 794:	0712                	slli	a4,a4,0x4
 796:	973e                	add	a4,a4,a5
 798:	fae689e3          	beq	a3,a4,74a <free+0x26>
  } else
    p->s.ptr = bp;
 79c:	e394                	sd	a3,0(a5)
  freep = p;
 79e:	00000717          	auipc	a4,0x0
 7a2:	18f73d23          	sd	a5,410(a4) # 938 <freep>
}
 7a6:	6422                	ld	s0,8(sp)
 7a8:	0141                	addi	sp,sp,16
 7aa:	8082                	ret

00000000000007ac <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ac:	7139                	addi	sp,sp,-64
 7ae:	fc06                	sd	ra,56(sp)
 7b0:	f822                	sd	s0,48(sp)
 7b2:	f426                	sd	s1,40(sp)
 7b4:	f04a                	sd	s2,32(sp)
 7b6:	ec4e                	sd	s3,24(sp)
 7b8:	e852                	sd	s4,16(sp)
 7ba:	e456                	sd	s5,8(sp)
 7bc:	e05a                	sd	s6,0(sp)
 7be:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7c0:	02051493          	slli	s1,a0,0x20
 7c4:	9081                	srli	s1,s1,0x20
 7c6:	04bd                	addi	s1,s1,15
 7c8:	8091                	srli	s1,s1,0x4
 7ca:	0014899b          	addiw	s3,s1,1
 7ce:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7d0:	00000517          	auipc	a0,0x0
 7d4:	16853503          	ld	a0,360(a0) # 938 <freep>
 7d8:	c515                	beqz	a0,804 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7dc:	4798                	lw	a4,8(a5)
 7de:	02977f63          	bgeu	a4,s1,81c <malloc+0x70>
 7e2:	8a4e                	mv	s4,s3
 7e4:	0009871b          	sext.w	a4,s3
 7e8:	6685                	lui	a3,0x1
 7ea:	00d77363          	bgeu	a4,a3,7f0 <malloc+0x44>
 7ee:	6a05                	lui	s4,0x1
 7f0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7f4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7f8:	00000917          	auipc	s2,0x0
 7fc:	14090913          	addi	s2,s2,320 # 938 <freep>
  if(p == (char*)-1)
 800:	5afd                	li	s5,-1
 802:	a88d                	j	874 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 804:	00000797          	auipc	a5,0x0
 808:	13c78793          	addi	a5,a5,316 # 940 <base>
 80c:	00000717          	auipc	a4,0x0
 810:	12f73623          	sd	a5,300(a4) # 938 <freep>
 814:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 816:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 81a:	b7e1                	j	7e2 <malloc+0x36>
      if(p->s.size == nunits)
 81c:	02e48b63          	beq	s1,a4,852 <malloc+0xa6>
        p->s.size -= nunits;
 820:	4137073b          	subw	a4,a4,s3
 824:	c798                	sw	a4,8(a5)
        p += p->s.size;
 826:	1702                	slli	a4,a4,0x20
 828:	9301                	srli	a4,a4,0x20
 82a:	0712                	slli	a4,a4,0x4
 82c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 82e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 832:	00000717          	auipc	a4,0x0
 836:	10a73323          	sd	a0,262(a4) # 938 <freep>
      return (void*)(p + 1);
 83a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 83e:	70e2                	ld	ra,56(sp)
 840:	7442                	ld	s0,48(sp)
 842:	74a2                	ld	s1,40(sp)
 844:	7902                	ld	s2,32(sp)
 846:	69e2                	ld	s3,24(sp)
 848:	6a42                	ld	s4,16(sp)
 84a:	6aa2                	ld	s5,8(sp)
 84c:	6b02                	ld	s6,0(sp)
 84e:	6121                	addi	sp,sp,64
 850:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 852:	6398                	ld	a4,0(a5)
 854:	e118                	sd	a4,0(a0)
 856:	bff1                	j	832 <malloc+0x86>
  hp->s.size = nu;
 858:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 85c:	0541                	addi	a0,a0,16
 85e:	00000097          	auipc	ra,0x0
 862:	ec6080e7          	jalr	-314(ra) # 724 <free>
  return freep;
 866:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 86a:	d971                	beqz	a0,83e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 86c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 86e:	4798                	lw	a4,8(a5)
 870:	fa9776e3          	bgeu	a4,s1,81c <malloc+0x70>
    if(p == freep)
 874:	00093703          	ld	a4,0(s2)
 878:	853e                	mv	a0,a5
 87a:	fef719e3          	bne	a4,a5,86c <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 87e:	8552                	mv	a0,s4
 880:	00000097          	auipc	ra,0x0
 884:	b76080e7          	jalr	-1162(ra) # 3f6 <sbrk>
  if(p == (char*)-1)
 888:	fd5518e3          	bne	a0,s5,858 <malloc+0xac>
        return 0;
 88c:	4501                	li	a0,0
 88e:	bf45                	j	83e <malloc+0x92>
