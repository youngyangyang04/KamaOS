#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "e1000_dev.h"
#include "net.h"

#define TX_RING_SIZE 16
static struct tx_desc tx_ring[TX_RING_SIZE] __attribute__((aligned(16)));
static struct mbuf *tx_mbufs[TX_RING_SIZE];

#define RX_RING_SIZE 16
static struct rx_desc rx_ring[RX_RING_SIZE] __attribute__((aligned(16)));
static struct mbuf *rx_mbufs[RX_RING_SIZE];

// remember where the e1000's registers live.
static volatile uint32 *regs;

struct spinlock e1000_lock;

// called by pci_init().
// xregs is the memory address at which the
// e1000's registers are mapped.
void
e1000_init(uint32 *xregs)
{
  int i;

  initlock(&e1000_lock, "e1000");

  regs = xregs;

  // Reset the device
  regs[E1000_IMS] = 0; // disable interrupts
  regs[E1000_CTL] |= E1000_CTL_RST;
  regs[E1000_IMS] = 0; // redisable interrupts
  __sync_synchronize();

  // [E1000 14.5] Transmit initialization
  memset(tx_ring, 0, sizeof(tx_ring));
  for (i = 0; i < TX_RING_SIZE; i++) {
    tx_ring[i].status = E1000_TXD_STAT_DD;
    tx_mbufs[i] = 0;
  }
  regs[E1000_TDBAL] = (uint64) tx_ring;
  if(sizeof(tx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_TDLEN] = sizeof(tx_ring);
  regs[E1000_TDH] = regs[E1000_TDT] = 0;
  
  // [E1000 14.4] Receive initialization
  memset(rx_ring, 0, sizeof(rx_ring));
  for (i = 0; i < RX_RING_SIZE; i++) {
    rx_mbufs[i] = mbufalloc(0);
    if (!rx_mbufs[i])
      panic("e1000");
    rx_ring[i].addr = (uint64) rx_mbufs[i]->head;
  }
  regs[E1000_RDBAL] = (uint64) rx_ring;
  if(sizeof(rx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_RDH] = 0;
  regs[E1000_RDT] = RX_RING_SIZE - 1;
  regs[E1000_RDLEN] = sizeof(rx_ring);

  // filter by qemu's MAC address, 52:54:00:12:34:56
  regs[E1000_RA] = 0x12005452;
  regs[E1000_RA+1] = 0x5634 | (1<<31);
  // multicast table
  for (int i = 0; i < 4096/32; i++)
    regs[E1000_MTA + i] = 0;

  // transmitter control bits.
  regs[E1000_TCTL] = E1000_TCTL_EN |  // enable
    E1000_TCTL_PSP |                  // pad short packets
    (0x10 << E1000_TCTL_CT_SHIFT) |   // collision stuff
    (0x40 << E1000_TCTL_COLD_SHIFT);
  regs[E1000_TIPG] = 10 | (8<<10) | (6<<20); // inter-pkt gap

  // receiver control bits.
  regs[E1000_RCTL] = E1000_RCTL_EN | // enable receiver
    E1000_RCTL_BAM |                 // enable broadcast
    E1000_RCTL_SZ_2048 |             // 2048-byte rx buffers
    E1000_RCTL_SECRC;                // strip CRC
  
  // ask e1000 for receive interrupts.
  regs[E1000_RDTR] = 0; // interrupt after every received packet (no timer)
  regs[E1000_RADV] = 0; // interrupt after every packet (no timer)
  regs[E1000_IMS] = (1 << 7); // RXDW -- Receiver Descriptor Write Back
}

int
e1000_transmit(struct mbuf *m)
{
  //
  // Your code here.
  //
  // the mbuf contains an ethernet frame; program it into
  // the TX descriptor ring so that the e1000 sends it. Stash
  // a pointer so that it can be freed after sending.
  //
  
    acquire(&e1000_lock);                               // 获取E1000锁，线程安全

    uint32 idx = regs[E1000_TDT];                       // 获取传输buf环的下一个可用索引
    struct tx_desc* desc = &tx_ring[idx];               // 获取当前传输buf的描述符指针

    if ((desc->status & E1000_TXD_STAT_DD) == 0) {      // E1000没有完成之前的传输请求，返回错误（此时已经用完了环形buf列表，缓冲区无空闲）
        release(&e1000_lock);
        return -1;
    }

    if (tx_mbufs[idx]) {                                // 该idx是否关联了一个mbuf
        mbuffree(tx_mbufs[idx]);                        // 表示之前该idx释放完毕了但未释放mbuf
        tx_mbufs[idx] = 0;
    }

    desc->addr = (uint64)m->head;                       // mbuf的地址填入发送描述符中
    desc->length = m->len;                              // mbuf的长度填入发送描述符中
    desc->cmd = E1000_TXD_CMD_EOP | E1000_TXD_CMD_RS;   // EOP表示以太网帧的结束，RS表示需要报告发送状态
    tx_mbufs[idx] = m;                                  // 将mbuf关联到发送描述符

    // 更新发送描述符环的尾指针
    regs[E1000_TDT] = (regs[E1000_TDT] + 1) % TX_RING_SIZE;

    release(&e1000_lock);
    return 0;

    return 0;
}

static void
e1000_recv(void)
{
  //
  // Your code here.
  //
  // Check for packets that have arrived from the e1000
  // Create and deliver an mbuf for each packet (using net_rx()).
  //

    // 循环检查接收描述符环中的数据包
    while (1) {
        uint32 idx = (regs[E1000_RDT] + 1) % RX_RING_SIZE;      // 下一个接收描述符的索引

        struct rx_desc* desc = &rx_ring[idx];                   // 当前接收描述符的指针

        if ((desc->status & E1000_RXD_STAT_DD) == 0)            // 接收描述符环中已经没有数据包需要结束，退出函数
            return;

        rx_mbufs[idx]->len = desc->length;                      // 接受描述符中数据包的长度设置到mbuf的长度字段中

        net_rx(rx_mbufs[idx]);                                  // 将mbuf传递给网络层进行处理，网络层负责释放mbuf

        // 分配一个新的mbuf,将新的mbuf的地址设置为接收描述符的地址，状态清空，以便下一次使用该下标使用
        rx_mbufs[idx] = mbufalloc(0);
        desc->addr = (uint64)rx_mbufs[idx]->head;
        desc->status = 0;

        // 将接收描述符环的尾指针设置为当前索引
        regs[E1000_RDT] = idx;
    }
}

void
e1000_intr(void)
{
  // tell the e1000 we've seen this interrupt;
  // without this the e1000 won't raise any
  // further interrupts.
  regs[E1000_ICR] = 0xffffffff;

  e1000_recv();
}
