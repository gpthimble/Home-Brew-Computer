# SystemOT

## What is SystemOT?

SystemOT is just an open-source customizable system-on-chip soft-core. In a word, SystemOT is another **home-brew CPU** core.

## What is Included in the Project?

### Hardware
* **CPU**: 5-stage pipelined harvard architecture RISC processor with 32 32-bit general registers, 32-bit instruction words and 32-bit address lines. Load/store structure, support multi-cycle instructions (such as unaligned load/store), branch prediction, advance exceptions, vector interrupt, and self-modifying code synchronization.
* **System BUS**: a very simple 32-bit tri-state parallel bus with a bus controller, supporting DMA operation, can work with any number of master and slave devices.
* **Cache**: 2-way set associative configuration, the replacement strategy is random replacement, the write strategy is write-through, and the hit data is ready in one cycle. The synchronization mechanism is completely implemented by hardware.
* **DRAM Controller**: simplified DRAM controller, its timing can be set by parameters, 32-bit word length, access by word.
* **I/O System**: memory mapped IO, UART, timer, GPIO and other I/O modules are directly connected to the system bus.
  
## Software

* Ported LCC 3.6 ANSI C Compiler
* Ported customASM Assembler
* Pre-assembler Written by Python
* Software Multiply and Division Ported from Libgcc
* Demo Programs and Functions
* Ported Dhrystone 2.1 performance benchmark program

## Hierarchy in Files and Modules

```
SystemOT
|-- soc.v                   SystemOT's top-level design
|   |-- cpu.v               the processor module in SystemOT
|   |   |-- cache.v         the cache module
|   |   |-- regfile.v       the register file
|   |   |-- control_unit.v  the control unit
|   |   |-- alu.v           the arithmetic unit
|   |-- bus_control.v       the BUS controller module in SystemOT
|   |-- dummy_slave.v       the Demo RAM controller module in SystemOT
|   |-- uart_tx.v           the Demo Uart TX and timmer module in SystemOT

