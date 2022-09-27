echo ALL PROBLEMS > log.txt

for %%f in (*.sv) do (
    iverilog -g2005-sv %%f >> log.txt 2>&1
    vvp a.out >> log.txt 2>&1
    rem gtkwave dump.vcd
)

del /q a.out

findstr PASS  log.txt
findstr FAIL  log.txt
findstr error log.txt
