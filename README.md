# SystemOT

## What is SystemOT?

SystemOT is just an open-source customizable system-on-chip soft-core. In a word, SystemOT is another **home-brew CPU** core.

## Why I designed SystemOT?
SystemOT names from System of Old Technology, this means that new technology and extreme performance are not the goal of the project.
SystemOT is a processor soft core designed for scientific research and education, and I design it **just because I can**.
Generally speaking, the goal of this project is to make it work, make it simple, and make it easy to understand.
Specifically, the long-term goal of this project is to make it work like a computer we use every day, with a working operating system and graphical interface and other input and output interfaces.

## Status and Road Map

## Currently Supported Features

## What is Included in the Project?

### Hardware
<img src="./doc/img/SystemOT.PNG" width = "500" height = "370" alt="Hardware structure of SystemOT" align=center />

The hardware structure of SystemOT is shown in the figure above, which includes:
* **CPU**: 5-stage pipelined harvard architecture RISC processor with 32 32-bit general registers, 32-bit instruction word and 32-bit address lines. Load/store structure, support multi-cycle instructions (such    as unaligned load/store), branch prediction, advance exceptions, vector interrupt, and self-modifying code synchronization.
* **System BUS**: a very simple 32-bit tri-state parallel bus with a bus controller, supporting DMA operation, can work with any number of master and slave devices.
* **Cache**: 2-way set associative configuration, the replacement strategy is random replacement, the write strategy is write-through, and the hit data is ready in one cycle. The synchronization mechanism is completely implemented by hardware.
* **DRAM Controller**: simplified DRAM controller, its timing can be set by parameters, 32-bit word length, access by word.
* **I/O System**: memory mapped IO, UART, timer, GPIO and other I/O modules are directly connected to the system bus.
  
## Software

* Ported **LCC** 3.6 ANSI C [Compiler](https://github.com/gpthimble/lcc_3.6_port)
* Ported **customASM** [Assembler](https://github.com/gpthimble/customasm_port)
* [Pre-assembler](https://github.com/gpthimble/customasm_port/blob/master/pre_asm.py) Written by Python
* [Software Multiply and Division](https://github.com/gpthimble/customasm_port/blob/master/mul_div_mod.asm) Ported from **Libgcc**
* [Demo Programs and Functions](https://github.com/gpthimble/Home-Brew-Computer/tree/master/sim/programs)
* Ported [Dhrystone 2.1](https://github.com/gpthimble/Home-Brew-Computer/blob/master/sim/programs/dhrystone2_1.c) performance benchmark program

## Documents
You can find the detailed documentation and development log [here](https://gpthimble.github.io).




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

## How to Use SystemOT

## Prove of Work


## References
1. B. Buzbee, [Homebrew CPU](http://www.homebrewcpu.com/)
2. M. M. Mano, Computer system architecture
3. A. S. a. W. A. S. Tanenbaum, Operating systems: design and implementation
4. Y. a. o. Li, Computer principles and design in Verilog HDL
5. D. Sweetman, See MIPS run
6. J. L. a. P. D. A. Hennessy, Computer architecture: a quantitative approach
7. R. P. Weicker, Dhrystone: a synthetic systems programming benchmark
8. C. W. Fraser, LCC A retargetable compiler for ANSI C
9. h. a. c. a. vascofazza, [customasm](https://github.com/hlorenzi/customasm)

