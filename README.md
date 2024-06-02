# Assembly Projects Repository

Welcome to this repository containing various Assembly programs (including implementation of the classic Snake game) designed to run on DOSBox 0.74-3. Each program in this repository demonstrates different aspects of Assembly language programming, from matrix operations to game development and system utilities.

## Prerequisites

Before running these programs, ensure you have the following setup:

- **DOSBox 0.74-3:** Download and install DOSBox 0.74-3 from [the official DOSBox website](https://www.dosbox.com/download.php?main=1).
- **MASM or TASM:** These programs are written for the Microsoft Macro Assembler (MASM) or Turbo Assembler (TASM). Ensure you have one of these installed in your DOSBox environment.

## Running the Programs

To run any of the programs, follow these steps:

1. **Start DOSBox:** Open DOSBox 0.74-3.
2. **Mount your directory:** Mount the directory containing the ASM files. For example:
   ```
   mount c c:\assembly
   c:
   ```
3. **Assemble and link the program:** Depending on whether you use MASM or TASM, the commands might slightly vary. Here’s an example using MASM:
   ```
   masm program.asm;
   link program.obj;
   ```
4. **Run the executable:** 
   ```
   program.exe
   ```

## Repository Contents

### 1: Matrix Multiplication (`mulMat.asm`)

This program performs matrix multiplication, extending the concept of vector multiplication to matrices. It showcases the use of nested loops, data segment manipulation, and screen memory handling.

### 2: Matrix-Vector Multiplication (`mulvec.asm`)

Similar to Exercise 1 but focuses on multiplying a matrix with a vector. This is a simplification of matrix multiplication, suitable for understanding basic assembly operations and loop handling.

### 3: Recursive GCD and Hexadecimal Display (`GCD.asm`, `exPrefix.asm`)

- **`GCD.asm`**: Calculates the greatest common divisor (GCD) of an array of integers using recursion.
- **`exPrefix.asm`**: Displays a hexadecimal number recursively by removing the least significant digit each iteration.

### 4: Snake Game (`ex4.asm`)

implementation of the classic snake game. It handles user input, game logic, and screen display updates.

Game Features
Real-Time Movement: The game uses the system clock to trigger movements at consistent intervals, ensuring smooth gameplay.

Directional Controls: Players use the keyboard to direct the snake around the game area:

W for up
S for down
A for left
D for right
Q to quit the game
Scoring and Points: Points are randomly placed throughout the game area. The snake must move over these points to 'eat' them, at which a new point appears, and the score increases.

Game Over Conditions: The game ends if the snake runs into itself or the edge of the game area. A game over message displays along with the final score.

Code Description
Interrupt Service Routine (ISR): A custom ISR (ISR_New_int_1c) handles the timing of the snake's movement. This routine increments a counter and moves the snake when the counter hits a specific value, ensuring movement occurs at a steady pace.

Point Generation: The newPoint procedure generates a new point at a random location not occupied by the snake. It ensures that the new point does not overlap with the snake's current position.

Keyboard Input: The printMove procedure handles keyboard input, reading scan codes from the keyboard hardware and adjusting the snake's direction accordingly.

Game Initialization and Loop: The main game loop initializes game variables, sets up the screen, and enters a polling loop that checks for keyboard input and updates the game state based on the input and the passage of time.

### 5: Clock TSR and Printing Control (`clocklTSR.asm`, `print.asm`)

- **`clocklTSR.asm`**: A terminate and stay resident (TSR) program that updates and displays a real-time clock on the screen.
- **`print.asm`**: Allows the user to control the speed of text display on the screen using keyboard inputs.
