# UART_Interface
edaplayground link: https://www.edaplayground.com/x/7X9C
<div align="center">
  <image width="600" src = "https://github.com/user-attachments/assets/42766639-f7b7-4d0d-8279-9aca0bed53b6">  
</div>  
    
## Introduction
-> UART - Universal asynchronous receiver transmitter.  
-> Asynchronous communication.  
-> UART speed represented in bps.(bits/sec)  
-> Baudrate - Measures the speed of the data transmission( for all bits sent, including start, stop and parity bits)  
-> common baud rate 9600.  
<div align="center">
  <img height="300" src = "https://github.com/user-attachments/assets/b6933df7-1a88-41cb-b040-69d381206408"/>  
</div>  
<div align="center">
  Transmission and receiver sampling waveform
</div>  

## UART 16550
<div align="center">
  <img width="500" height="250" alt="uart" src="https://github.com/user-attachments/assets/fc1d450e-876c-40e0-90a2-56a8e9fb6108" />
</div>  
<div align="center">
  UART 16550 Block diagram
</div>   

-> The UART_16550 IP is a Universal Asynchronous Receiver Transmitter module fully compatible with the de-facto standard 16550.  
-> This is the standard that can be found in most personal computers and for which a lot of software knowledge and programs is available.  
-> Both the transmitter and the receiver can be equipped, if selected at synthesis time, with a 16- character First In First Out (FIFO) buffer.  
-> If equipped, the software can decide to put the UART in non-FIFO (16450) mode or in FIFO (16550) mode.  
-> For designs requiring low area, the module can be implemented with a 1-character buffer instead of the 16-byte FIFO.  

## UART 16550 Registers
-> There are 8 registers. Each register width is 8bit.  
-> Operations perfomed by each register is 11.  
-> Register 0H, has two operation. when **LCR Divisor latch access bit is zero**.  
   -> while read it is act as Receiver holding register(RHR).  
   -> while writing it is transmitter holding register(THR).  
-> when **LCR Divisor latch access bit is one**.  
   -> Divisor latch LSB is stored.  
-> Register 1H - Interupt enable register, when **LCR Divisor latch access bit is zero**.  
-> Register 1H - Divisor latch MSB is stored, when **LCR Divisor latch access bit is one**.  
-> Divisor is used to create the **baud pulse**.  
-> Register 2H, has two operation.  
   -> Read - Interupt status register.  
   -> write - FIFO control register.  

<div align="center">
  <img width="650" height="800" alt="image" src="https://github.com/user-attachments/assets/c0a50c49-dc58-48eb-84a3-121166b58a44" />  
  
  UART 16550 Register Set
</div> 

### LCR - Line Control Register
-> LCR is the one of important register among UART register.  
-> It is used to control the way in which transmitted character are serialized and received characters are assembled and checked.  
<div align="center">
  <img width="765" height="127" alt="image" src="https://github.com/user-attachments/assets/723173e9-8e64-4f59-80af-27973390637b" />
  
  Line control Register
</div> 

-> Bits 0 and 1: These bits define the word length of the data being transmitted and received.
<div align="center">
  <img width="200" height="245" alt="image" src="https://github.com/user-attachments/assets/e61651e3-bf64-4489-8a7a-5c62b6b7be6d" />

  Tx and Rx word length
</div> 

-> Bit 2: This bit selects the number of stop bits to be transmitted. If cleared, only one stop bit will be transmitted.  
   -> If set, two stop bits (1.5 with 5-bit data) will be transmitted before the start bit of the next character.  
   -> The receiver always checks only one stop bit.  
-> Bits 3 to 5: These bits select the way in which parity control is performed.  
-> Bit 3 is an enable bit: it selects whether a parity bit is used or not.  
-> Bit 4 selects the polarity of this control bit.  
-> Bit 5 forces a value for this bit, independent of the data being transmitted or received.  
<div align="center">
  <img width="300" height="350" alt="image" src="https://github.com/user-attachments/assets/2f5f25dd-7e08-45e5-877b-6a0990208cf2" />

  Parity conditions
</div> 

-> Bit 7: This is Divisor Latch Access Bit (DLAB).   
-> This bit must be set in order to access the DLL and DLM registers which program the division constants for the baud rate divider.  
-> As these registers occupy the same locations as the THR and RHR, DLAB must be zero to access these other registers.  

## APPLICATIONS
-> Used to print debug messages from embedded systems to PCs.  
-> Communication with wireless modules like: Bluetooth, Wi-Fi and GSM/GPRS.  
-> Sensors (IMUs, temperature, pressure, etc.) often interface using UART when SPI/I2C is not feasible.  



