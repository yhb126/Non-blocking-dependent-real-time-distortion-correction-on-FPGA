`define WIDTH 1920    
`define HEIGHT 1080

`define LDC_TYPE 0 //0:桶形 
`define FLOAT_WIDTH 24      // 24位定点数量化下对应矫正参数
`define K1 4
// width*height\k   | k1  |  k2 |
// 1920*1080        | 4   |  0  |
// 1280*720

`define OFFSET_X 0
`define OFFSET_Y 0

`define DEPTH 256     // 实现像素行缓存不冲突的最小列
`define ADDR_DEPTH 17 // ram地址位宽，却决于DEPTH，计算公式为  2^ADDR_DPETH > DEPTH*WIDTH， 注意修改RAM核对应最大地址

`define SYNC 580 // 行同步像素数量

//---- UDP RAM-----
`define RAM_INFERRED
`define XILINX_RAM
`define REG_DEL #3
`define NumberBits 8