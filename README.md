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

1. Ensure you have MASM installed on your system.
2. Navigate to the program directory:
    ```bash
    cd /c:/MASM/MASM611/BIN/CODE/Base-N Magic Explainer/
    ```
3. Compile the program:
    ```bash
    ml /c /coff program.asm
    ```
4. Link the program:
    ```bash
    link /subsystem:console program.obj
    ```
5. Run the executable:
    ```bash
    program.exe
    ```

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Author

Developed by [Your Name]. Feel free to reach out for questions or suggestions!

---

Enjoy converting numbers with ease and clarity!
