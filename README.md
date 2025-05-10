# REP0006 - Base-N Magic Explainer

An Assembly application that converts a Base-N number to another Base-N format, explaining the process step by step.

---

## Features

This MASM-based program allows you to:
1. **Select a source Base-N system.**
2. **Input a number to evaluate.**
3. **Choose a target Base-N system.**
4. **Display a step-by-step explanation of the conversion process from one base to another.**

### Additional Functionality:
- At any step, the program allows you to return to **Step 1**.
- At any step, the program allows you to return to the **previous step**.

### Supported Bases:
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

1. Ensure you have MASM, DOS-Box and Emu8086 installed on your system.
   1. if not, you can download from:
      1. Emu8086 - https://www.mediafire.com/file/cmlywa0zjr6p5bj/emu-8086.rar/file
      2. Dos-Box - https://www.dosbox.com/download.php?main=1
      3. MASM611 - https://www.mediafire.com/file/qel4nxtcsg93n68/masm611.rar/file
   2. Install Emu8086
   3. Unzip MASM611 into the 'C:/MASM/masm611/' directory. You should see directories like 'BIN', 'LIB', 'HELP', etc...
   4. Install DOS-Box
   5. Open DOS-Box. In the terminal, DON'T CLOSE IT.
2. Download the project and locate it into the 'c:\MASM\masm611\BIN\' folder.
3. Mount the directory into the DOS-Box terminal
```bash
mount c: c:\\MASM\\masm611
```
4. In the terminal, write to navigate to the program directory:
```bash
c:
cd BIN\\CODE\\Base-N Magic Explainer
```
6. In the terminal, write to compile the program:
    ```bash
    ml converser_init.asm
    ```
<!-- 7. Link the program:
    ```bash
    link /subsystem:console program.obj
    ``` -->
7. In the terminal, write to run the executable:
    ```bash
    converser_init.exe
    ```

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Author

Developed by [![LinkedIn](https://img.shields.io/badge/linkedin-%230077B5.svg?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/public-profile/settings?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_self_edit_contact-info%3B%2BsZaSk%2FlS8i%2BxArI%2FXc%2FyA%3D%3D) [![Outlook](https://img.shields.io/badge/Microsoft_Outlook-0078D4?style=for-the-badge&logo=microsoft-outlook&logoColor=white)](mailto:Adolfoalejandroarenasramos@outlook.com). Feel free to reach out for questions or suggestions!

---

Enjoy converting numbers with ease and clarity!
