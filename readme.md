# ELEC2602 Project Code

This is a repository storing all of the project code for ELEC2602 in designing a simple processor in Verilog. Compiling it with `iverilog` should be done as so:
```
iverilog -o sim \
  processor.v pc.v status_reg.v demux2.v \
  fsm_control/*.v register_control/*.v alu/*.v \
  tb_processor.v
```