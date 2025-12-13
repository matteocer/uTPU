==========
## SPEC
==========

========Overview==========

Takes in commands from an ESP32 communicating over UART (
Maybe SPI later) directly with the FPGA pins, 


========Modules===========
### UART Module
    Is used retrieve information from the user. 
    

    TODO: Figure what else this is going to do


### 2x2 MAC Array:
    Has a accumulate resgister inside storing weights
    Every clock it takes its inputs, multiplies them and
    adds to the accumulated value passed to it
    This output is then sent down the array 
    Can be put into modes to load weights

### MAC:
    Performs a multiply and then adds result to the accumulator
    Each are loaded with a weight and that multiplies to input
    After every multiply the accumulator sum is outputted


### Quantizer:
    The int16 output from the MAC array will be quantized 
    into a int4. 

    [-32768, 32767] -> [-8, 7]

    All this does is >> 12


### LeakyReLU Unit:
    Takes the int4 output of the Quantizer and performs ReLU
    
    leakyReLU = x if x>0 else ax

    a is stored in a register in the unit




=========TODO================
1. Make the all the modules
- Quantizer DONE
- Relu
- MAC Array

2. Test the individual modules
- Quantizer DONE
- Relu
- MAC Array

3. Make the datapath

4. Get the top function done

5. Make a full testbench

6. Get it working on the Tang

