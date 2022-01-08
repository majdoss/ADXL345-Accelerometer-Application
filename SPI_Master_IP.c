

/***************************** Include Files *******************************/
#include "SPI_Master_IP.h"
#include "xil_types.h"
#include "xstatus.h"
#include "xil_io.h"
#include "xparameters.h"
/************************** Function Definitions ***************************/

void Config_SPI(){
	// Configuration
	// SPI Mode = 11 (CPOL=1 and CPHA=1)
	// CS_INACTIVE_CLKS = 20
	// CLK_SCALE = x24
	SPI_MASTER_IP_mWriteReg(SPI_MASTER_BASEADDR, REG0_OFFSET, 0x00530018);
	for (int i=0; i<4000; i++);
}

void Init_SPI(){
	// Initialize ADXL345
	// Multi-byte bit is always set to HIGH since all transactions are multi-bytess

	// Measure acceleration in the range +-4g
	SPI_MASTER_IP_mWriteReg(SPI_MASTER_BASEADDR, REG2_OFFSET, 0x00000971);
	// Write TX_Count to REG1 to initiate the transaction
	SPI_MASTER_IP_mWriteReg(SPI_MASTER_BASEADDR, REG1_OFFSET, 0x2);

	for (int i=0; i<4000; i++);

	// Configure accelerometer to start measuring acceleration
	SPI_MASTER_IP_mWriteReg(SPI_MASTER_BASEADDR, REG2_OFFSET, 0x0000086D);
	// Write TX_Count to REG1 to initiate the transaction
	SPI_MASTER_IP_mWriteReg(SPI_MASTER_BASEADDR, REG1_OFFSET, 0x2);

	for (int i=0; i<4000; i++);
}

int ReadID_SPI(){
	// Read from address 0x00 (DEVID)
	SPI_MASTER_IP_mWriteReg(SPI_MASTER_BASEADDR, REG2_OFFSET, 0x000000C0);
	// Write TX_Count to REG1 to initiate the transaction
	SPI_MASTER_IP_mWriteReg(SPI_MASTER_BASEADDR, REG1_OFFSET, 0x2);

	for (int i=0; i<4000; i++);

	// We read device ID
	int devID = (SPI_MASTER_IP_mReadReg(SPI_MASTER_BASEADDR, REG6_OFFSET) & 0x0000FF00) >> 8;

	for (int i=0; i<1000; i++);

	return devID;
}


