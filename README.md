# SystemOT

## What is SystemOT?

SystemOT is just an open-source customizable system-on-chip soft-core. In a word, SystemOT is another **home-brew CPU** core.

## What is Included in the Project?

### Hardware
* **CPU**: 5-stage pipelined harvard architecture RISC processor with 32 32-bit general registers, 32-bit instruction word and 32-bit address lines. Load/store structure, support multi-cycle instructions (such as unaligned load/store), branch prediction, advance exceptions, vector interrupt, and self-modifying code synchronization.
* **System BUS**: a very simple 32-bit tri-state parallel bus with a bus controller, supporting DMA operation, can work with any number of master and slave devices.
* **Cache**: 2-way set associative configuration, the replacement strategy is random replacement, the write strategy is write-through, and the hit data is ready in one cycle. The synchronization mechanism is completely implemented by hardware.
* **DRAM Controller**: simplified DRAM controller, its timing can be set by parameters, 32-bit word length, access by word.
* **I/O System**: memory mapped IO, UART, timer, GPIO and other I/O modules are directly connected to the system bus.
  
## Software

* Ported **LCC** 3.6 ANSI C Compiler
* Ported **customASM** Assembler
* **Pre-assembler** Written by Python
* **Software Multiply and Division** Ported from **Libgcc**
* Demo Programs and Functions
* Ported **Dhrystone 2.1** performance benchmark program

## Hierarchy in Files and Modules

```
SystemOT
|-- src\                         Verilog HDL source code of SystemOT
|   |-- soc.v                       SystemOT's top-level design
|   |   |-- cpu.v                       the processor module in SystemOT
|   |   |   |-- cache.v                     the cache module
|   |   |   |-- regfile.v                   the register file
|   |   |   |-- control_unit.v              the control unit
|   |   |   |-- alu.v                       the arithmetic unit
|   |   |   |   |-- add_sub.v                   module for addition and subtraction
|   |   |   |   |-- clo_clz.v                   module for the counting leading zeros and ones
|   |   |   |   |-- shifter.v                   module for the shifting operations
|   |   |-- bus_control.v               the BUS controller module in SystemOT
|   |   |-- dummy_slave.v               the Demo RAM controller module in SystemOT
|   |   |   |-- *.mif                       memory files contain the binary executable
|   |   |-- uart_tx.v                   the Demo UART TX and timer module in SystemOT
|   |   |-- timer.v                     the timer module
|   |   |-- dummy_master.v              the dummy DMA device for validation
|-- testbench\                   testbenches for SystemOT
|   |-- *.vwf                       wave form file for Intel Quartus
|   |-- *.v                         test bench written in Verilog HDL
|-- sim\                         simulation programs and result
|   |-- programs\                   programs used in simulations
|   |   |-- *.c                         programs written in C language
|   |   |-- *.asm                       programs in assembly
|   |   |-- otsys.asm                   assembly instruction template for customASM
|   |   |-- lib.asm                     function library for mul div mod timer and UART 
|   |-- results\                    simulation results
|   |   |-- *.vcd                       value change dump files of the simulations
|   |   |-- *.png                       screen shots of GTKwave
|--- some files generate by the Quartus software
```


