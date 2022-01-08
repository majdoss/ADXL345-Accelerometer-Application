
#ifndef SPI_MASTER_IP_H
#define SPI_MASTER_IP_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"
#include "xil_io.h"
#include "xparameters.h"
#include <math.h>

#define SPI_MASTER_IP_S00_AXI_SLV_REG0_OFFSET 0
#define SPI_MASTER_IP_S00_AXI_SLV_REG1_OFFSET 4
#define SPI_MASTER_IP_S00_AXI_SLV_REG2_OFFSET 8
#define SPI_MASTER_IP_S00_AXI_SLV_REG3_OFFSET 12
#define SPI_MASTER_IP_S00_AXI_SLV_REG4_OFFSET 16
#define SPI_MASTER_IP_S00_AXI_SLV_REG5_OFFSET 20
#define SPI_MASTER_IP_S00_AXI_SLV_REG6_OFFSET 24
#define SPI_MASTER_IP_S00_AXI_SLV_REG7_OFFSET 28
#define SPI_MASTER_IP_S00_AXI_SLV_REG8_OFFSET 32
#define SPI_MASTER_IP_S00_AXI_SLV_REG9_OFFSET 36

#define SPI_MASTER_BASEADDR		XPAR_SPI_MASTER_IP_0_S00_AXI_BASEADDR
#define REG0_OFFSET				SPI_MASTER_IP_S00_AXI_SLV_REG0_OFFSET
#define REG1_OFFSET				SPI_MASTER_IP_S00_AXI_SLV_REG1_OFFSET
#define REG2_OFFSET				SPI_MASTER_IP_S00_AXI_SLV_REG2_OFFSET
#define REG3_OFFSET				SPI_MASTER_IP_S00_AXI_SLV_REG3_OFFSET
#define REG4_OFFSET				SPI_MASTER_IP_S00_AXI_SLV_REG4_OFFSET
#define REG5_OFFSET				SPI_MASTER_IP_S00_AXI_SLV_REG5_OFFSET
#define REG6_OFFSET				SPI_MASTER_IP_S00_AXI_SLV_REG6_OFFSET
#define REG7_OFFSET				SPI_MASTER_IP_S00_AXI_SLV_REG7_OFFSET
#define REG8_OFFSET				SPI_MASTER_IP_S00_AXI_SLV_REG8_OFFSET
#define REG9_OFFSET				SPI_MASTER_IP_S00_AXI_SLV_REG9_OFFSET

#define PI	3.14159265 //defines the value of PI


/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a SPI_MASTER_IP register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the SPI_MASTER_IPdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void SPI_MASTER_IP_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define SPI_MASTER_IP_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a SPI_MASTER_IP register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the SPI_MASTER_IP device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 SPI_MASTER_IP_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define SPI_MASTER_IP_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the SPI_MASTER_IP instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus SPI_MASTER_IP_Reg_SelfTest(void * baseaddr_p);
void Config_SPI();
void Init_SPI();
int ReadID_SPI();

#endif // SPI_MASTER_IP_H


