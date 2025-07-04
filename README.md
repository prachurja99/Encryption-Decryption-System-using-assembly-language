# 🔐 Encryption-Decryption System using Assembly Language

This project is a simple yet functional **Encryption and Decryption System** implemented in **x86 Assembly Language** as part of the **CSE341 (Microprocessors)** course at **BRAC University**.

## 📌 Project Overview

The program provides a text-based user interface to:
- **Encrypt** a user-input string using a basic Caesar cipher-like logic.
- **Decrypt** an encrypted string back to its original form.
- Handle and store string inputs securely in memory.
- Exit the program gracefully.

All operations are implemented in **8086 Assembly (MASM/TASM)**, using **BIOS interrupts**, memory operations, and string manipulation instructions.

## 🧠 Features

- Menu-driven interface using keyboard input (INT 21h).
- Accepts and processes ASCII character strings.
- Custom encryption and decryption algorithm.
- Limits string input length for buffer safety.
- Fully written using low-level assembly instructions, showcasing memory management and register-level control.

## 🛠 Technologies

- **Language:** x86 Assembly Language
- **Assembler:** TASM / MASM
- **Platform:** DOSBox / 16-bit Real Mode
- **Tools:** Turbo Assembler (TASM), Turbo Debugger, DOSBox

## 🚀 How to Run

1. Open the project in **DOSBox** or any x86 emulator.
2. Assemble the `.asm` file using:
   ```bash
   tasm filename.asm
   tlink filename.obj
