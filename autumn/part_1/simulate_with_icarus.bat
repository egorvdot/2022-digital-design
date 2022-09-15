set project_path=%1sim
set verilog_file=%2
rem recreate a temp folder for all the simulation files
rd /s /q %project_path%
md %project_path%
cd %project_path%
rem compile Verilog files for simulation
iVerilog -s testbench ..\testbench.v ..\%verilog_file%
rem run the simulation
vvp -la.lst -n a.out -vcd
rem show the simulation results in GTKWave
GTKWave dump.vcd
rem return to the parent folder
cd ..
