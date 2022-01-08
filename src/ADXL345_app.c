#include "xparameters.h"
#include "SPI_Master_IP.h"
#include "xil_io.h"
#include "xil_types.h"
#include "xtmrctr.h"
#include "xscugic.h"

#define INTC_DEVICE_ID 			XPAR_PS7_SCUGIC_0_DEVICE_ID
#define TIMER_DEVICE_ID			XPAR_TMRCTR_0_DEVICE_ID
#define INTC_TMR_INTERRUPT_ID 		XPAR_FABRIC_AXI_TIMER_0_INTERRUPT_INTR

XTmrCtr TMRInst;
XScuGic INTCInst;

static int IntcInitFunction(u16 DeviceId, XTmrCtr *TmrCtrInstancePtr);

void TMR_Intr_Handler(void *CallBackRef, u8 TmrCtrNumber) {
  int devid, x, y0, y1, y, z;
  float accel_y, accel_z, theta;
  int ay1, ay10, ay100, az1, az10, az100, negy, negz, angle;

  if(XTmrCtr_IsExpired(&TMRInst, 0)){
  		XTmrCtr_Stop(&TMRInst,0);

  		// Write TX_Count to REG1 to initiate the transaction
  		SPI_MASTER_IP_mWriteReg(SPI_MASTER_BASEADDR, REG1_OFFSET, 0x00000007);

  		for (devid =0; devid < 10000000; devid++);

  	    	x = (SPI_MASTER_IP_mReadReg(SPI_MASTER_BASEADDR, 24) & 0x00FFFF00) >> 8;

  		if ((x >> 15) == 1) {
  			x = x | 0xFFFF0000;
  		}
  		else {
  			x = x & 0x0000FFFF;
  		}


  		y0 = (SPI_MASTER_IP_mReadReg(SPI_MASTER_BASEADDR, 24) & 0xFF000000)>>24;
  		y1 = (SPI_MASTER_IP_mReadReg(SPI_MASTER_BASEADDR, 28) & 0x000000FF)<<8;

 		y = y1 | y0;

  		if ((y >> 9) != 0) {
  			y = y | 0xFFFFFC00;
  		}
  		else {
  			y = y & 0x000003FF;
  		}

  		accel_y = y / 256.0;

  		if (accel_y < 0.0) {
  			accel_y = -1.0 * accel_y;
  			negy = 1;
  		}
  		else negy = 0;

  		ay1 = ((int) (accel_y * 100.0))/100;
  		ay10 = ((int) (accel_y * 10.0))%10;
  		ay100 = ((int) (accel_y * 100.0))%10;

  		z = (SPI_MASTER_IP_mReadReg(SPI_MASTER_BASEADDR, 28) & 0x0003FF00) >> 8;

 		if ((z >> 9) != 0) {
  			z = z | 0xFFFFFC00;
  		}
  		else {
  			z = z & 0x000003FF;
  		}

  		accel_z = z / 256.0;

  		if (accel_z < 0.0) {
  			accel_z = -1.0 * accel_z;
  			negz = 1;
  		}
  		else negz = 0;

  		az1 = ((int) (accel_z * 100.0))/100;
  		az10 = ((int) (accel_z * 10.0))%10;
  		az100 = ((int) (accel_z * 100.0))%10;

  		theta = (float)atan((double)(accel_y)/(double)(accel_z));
  		theta = (theta * 180.0)/PI;
  		angle = (int) theta;

  		if (negy == 0 && negz == 0) {
  			xil_printf("Y = %d.%d%d g, Z = %d.%d%d g, angle = %d degrees\n\r", ay1, ay10, ay100, az1, az10, az100, angle);
  		}
  		else if (negy == 0 && negz == 1) {
  			xil_printf("Y = %d.%d%d g, Z = -%d.%d%d g, angle = %d degrees\n\r", ay1, ay10, ay100, az1, az10, az100, 180-angle);
  		}
  		else if (negy == 1 && negz == 0) {
  			xil_printf("Y = -%d.%d%d g, Z = %d.%d%d g, angle = -%d degrees\n\r", ay1, ay10, ay100, az1, az10, az100, angle);
  		}
  		else if (negy == 1 && negz == 1) {
  			xil_printf("Y = -%d.%d%d g, Z = -%d.%d%d g, angle = %d degrees\n\r", ay1, ay10, ay100, az1, az10, az100, angle-180);
  		}

  		XTmrCtr_Reset(&TMRInst, 0);
  		XTmrCtr_Start(&TMRInst, 0);
  	}

}

int main() {
	int status;

	// Configuration
	Config_SPI();

	// Initialize ADXL345
	Init_SPI();

	// We read device ID
	int x = ReadID_SPI();
	xil_printf("DEVICE ID is %X \n\r", x);

	SPI_MASTER_IP_mWriteReg(SPI_MASTER_BASEADDR, REG2_OFFSET, 0x000000F2);
	// Dummy bytes
	SPI_MASTER_IP_mWriteReg(SPI_MASTER_BASEADDR, REG3_OFFSET, 0x00000000);

	// Initialize timer/counter
	status = XTmrCtr_Initialize(&TMRInst, TIMER_DEVICE_ID);
	if(status != XST_SUCCESS) return XST_FAILURE;

	/*
	   * Setup the handler for the timer counter that will be called from the
	   * interrupt context when the timer expires, specify a pointer to the
	   * timer counter driver instance as the callback reference so the
	   * handler is able to access the instance data
	   */

	XTmrCtr_SetHandler(&TMRInst, TMR_Intr_Handler, &TMRInst);

	// Timer reloads after expiring
	// Configured to count downwards
	// We added the option to enable interrupts
	XTmrCtr_SetOptions(&TMRInst, 0, (XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION | XTC_DOWN_COUNT_OPTION));

	// Start the timer
	XTmrCtr_Start(&TMRInst, 0);

	// Generate periodic interrupts at 50 msec intervals
	XTmrCtr_SetResetValue(&TMRInst, 0, 5000000);

	// Initialize interrupt controller
	status = IntcInitFunction(INTC_DEVICE_ID, &TMRInst);
	if(status != XST_SUCCESS) return XST_FAILURE;

	  while(1) {

	  }

	return 0;

}

int IntcInitFunction(u16 DeviceId, XTmrCtr *TmrCtrInstancePtr)
{
	XScuGic_Config *IntcConfig;
	int status;

	// 0. Initialize Interrupt controller
	IntcConfig = XScuGic_LookupConfig(DeviceId);
	status = XScuGic_CfgInitialize(&INTCInst, IntcConfig, IntcConfig->CpuBaseAddress);
	if(status != XST_SUCCESS) return XST_FAILURE;

	// 1. Initialize exception handling features on the ARM processor
	Xil_ExceptionInit();

        // 2. Register master interrupt handler with GIC interrupt controller
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, &INTCInst);

	// 3.2 Register Timer interrupt handler and instance (callback) reference with GIC
	status = XScuGic_Connect(&INTCInst, INTC_TMR_INTERRUPT_ID, (Xil_ExceptionHandler)TMR_Intr_Handler, (void *)TmrCtrInstancePtr);
	// Last parameter is callback reference
	if(status != XST_SUCCESS) return XST_FAILURE;

	// 4.2 Enable timer interrupts in the GIC
	XScuGic_Enable(&INTCInst, INTC_TMR_INTERRUPT_ID);

	// 6. Enable interrupt handling on the ARM processor
	Xil_ExceptionEnable();

	return XST_SUCCESS;
}



