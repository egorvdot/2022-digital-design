# Дизассемблирование ELF под RISC-V

- установить [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
   - для Apple M1 проще устновить [RISC-V Toolchain](https://github.com/riscv-software-src/homebrew-riscv)
- подготовить исходный код на C/C++
   ```C++
   // test.c

   int add(int x, int y){
     return x + y;
   }

   int main(){
      add(1, 2);
      return 0;
   }
   ```
- скомпилировать объектный файл
   ```sh
   riscv64-unknown-elf-gcc -O0 -march=rv32i -mabi=ilp32 -c -I./ test.c -o test.o
   ```
- скомпоновать ELF-файл
   ```sh
   riscv64-unknown-elf-gcc -o test.elf test.o -nostartfiles -nostdlib -lc -lgcc -march=rv32i -mabi=ilp32
   ```
- дизассемблировать ELF-файл
   ```sh
   riscv64-unknown-elf-objdump -D test.elf > test.dump
   ```

