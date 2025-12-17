==========
## SPEC
==========

### Overview

Takes in commands from an ESP32 communicating over UART (
Maybe SPI later) directly with the FPGA pins, 


### Modules
#### UART Module
    Is used retrieve information from the user. 
    

    TODO: Figure what else this is going to do


#### 2x2 Systolic MAC Array:
    Has a accumulate resgister inside storing weights
    Every clock it takes its inputs, multiplies them and
    adds to the accumulated value passed to it
    This output is then sent down the array 
    Can be put into modes to load weights

    Control signals:
    - compute (this causes mac flow through array)
    - load_en (allows the internal weights to be loaded)

#### MAC:
    Performs a multiply and then adds result to the accumulator
    Each are loaded with a weight and that multiplies to input
    After every multiply the accumulator sum is outputted
    
    Control signals:
    - compute (this causes mac flow through array)
    - load_en (allows the internal weights to be loaded)


#### Quantizer:
    The int16 output from the MAC array will be quantized 
    into a int4. 

    [-32768, 32767] -> [-8, 7]

    All this does is >> 12


#### LeakyReLU Unit:
    Takes the int4 output of the Quantizer and performs ReLU
    
    leakyReLU = x if x>0 else ax

    a is stored in a register in the unit


#### Unified Buffer:
    All of the tensor are stored here
    1 KB
    0x000-0x3FF TOTAL

    0x000-0x0FF Tensor A
    0x100-0x1FF Tensor B
    0x200-0x2FF Tensor C
    0x300-0x3FF Free

    Control signals:
    - WE
    - RE
    - ARRAY_EN
    - FIFO_EN

#### FIFO:
    This is a queue between the uart module and the core
    It's values are one byte wide and is 256 B in total.
    
    0x000 - 0x0FF

    Flags:
    - Empty
    - Full

=========TODO================
1. Make the all the modules
- Quantizer DONE
- Relu DONE
- MAC Array DONE

2. Test the individual modules
- Quantizer DONE
- Relu
- MAC Array

3. Make the datapath

4. Get the top function done

5. Make a full testbench

6. Get it working on the Tang

