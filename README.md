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





