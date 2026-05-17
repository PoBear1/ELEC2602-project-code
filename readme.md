# ELEC2602 Project Code

This is a repository storing all of the project code for ELEC2602 in designing a simple processor in Verilog. Compiling it with `iverilog` should be done as so:
```
iverilog -o sim \
  fsm_control/*.v register_control/*.v alu/*.v full_processor/*.v \
  tb_processor.v
```