# REP0006 - Base-N Magic Explainer

An Assembly application that converts a Base-N number to another Base-N format, explaining the process step by step.

---

## Features

This MASM-based program allows you to:

1. **Select a source Base-N system.**
2. **Input a number to evaluate.**
3. **Choose a target Base-N system.**
4. **Display a step-by-step explanation of the conversion process from one base to another.**

### Additional Functionality

- At any step, the program allows you to return to **Step 1**.
- At any step, the program allows you to return to the **previous step**.

### Supported Bases

- **Base-2** (Binary)
- **Base-8** (Octal)
- **Base-10** (Decimal)
- **Base-16** (Hexadecimal)

---

## Example Workflow

1. Select **Base-10** as the source system.
2. Input the number **255**.
3. Choose **Base-16** as the target system.
4. The program will display the conversion process, explaining each step in detail.

---

## Screenshots

> Add screenshots or diagrams here to illustrate the program's functionality.

---

## How to Run

### Prerequisites

Make sure you have the following programs installed on your system:

- **MASM**
- **DOS-Box**
- **Emu8086**

If you don't have them, you can download them from these links:

- [Download Emu8086](https://www.mediafire.com/file/cmlywa0zjr6p5bj/emu-8086.rar/file)
- [Download DOS-Box](https://www.dosbox.com/download.php?main=1)
- [Download MASM611](https://www.mediafire.com/file/qel4nxtcsg93n68/masm611.rar/file)

---

## Installation Steps

1. **Install Emu8086**  
   Follow the installation wizard to complete the setup.

2. **Unzip MASM611**  
   Extract the contents of the downloaded file into the directory:  
   `C:/MASM/masm611/`  
   Ensure that subdirectories like `BIN`, `LIB`, and `HELP` are present.

3. **Install DOS-Box**  
   Complete the installation by following the wizard.

4. **Open DOS-Box**  
   Launch DOS-Box. Keep the terminal open.

---

## Running the Project

1. **Download the Project**  
   Place the project folder *Base-N Magic Explainer* in the folder:  
   `C:/MASM/masm611/BIN/`

2. **Mount the Directory in DOS-Box Terminal**  
   In the DOS-Box terminal, run the following command:  

   ```bash
   mount c: c:\MASM\masm611
   ```

3. **Compile and Run the project**  
   In the DOS-Box terminal, run the following commands one by one:

   ```bash
   c:
   cd MASM\masm611\BIN\Base-N Magic Explainer
   ML converser_init.asm
   converser_init.exe
   ```  

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Author

Developed by [_A-Cubica-R_](https://www.linkedin.com/in/adolfo-alejandro-arenas-ramos/). Feel free to reach out for questions or suggestions!

---

Enjoy converting numbers with ease and clarity!
