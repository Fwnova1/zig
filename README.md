 Zig Fiber Scheduler Assignment

Zig Fiber Scheduler
===================

* * *

Environment
-----------

*   **Language:** Zig 0.15.2
*   **Platform:** Linux (x86\_64)
*   **Architecture:** x86-64 System V ABI
*   **Context Library:** Provided `get_context` / `set_context` assembly library

* * *

Overview
--------

This project explores cooperative multitasking by manually saving and restoring CPU execution context in Zig. It starts with simple context switching experiments and gradually builds a fiber abstraction and a scheduler. The final result is a working user‑space fiber scheduler with explicit `yield` support. All scheduling is cooperative and non‑preemptive. The project demonstrates low‑level stack management and control flow manipulation.

* * *

Explanation of the Provided Context Library
-------------------------------------------

The provided library exposes two low‑level functions:

*   `get_context`: Saves the current CPU register state into a `Context` structure
*   `set_context`: Restores a previously saved CPU register state and resumes execution

Together, these functions allow programs to pause execution at one point and resume later from the exact same instruction. This mechanism forms the foundation for implementing fibers and cooperative scheduling.

* * *

Task 1a – Saving and Restoring Context
--------------------------------------

Task 1a demonstrates the simplest use of `get_context` and `set_context`. The program saves the current execution context, prints a message, and then restores the context once. A global variable is used to ensure the restore happens only once.

This task proves that execution can jump backward in time by restoring CPU state, causing the same code to execute again without using loops or function calls.

* * *

Task 1b – Switching to a New Stack
----------------------------------

Task 1b manually constructs a new execution context that runs a different function on a separate stack. A stack buffer is allocated manually, and the stack pointer (`rsp`) is set to the top of this buffer. The instruction pointer (`rip`) is set to a function that never returns.

Calling `set_context` transfers execution to this new function as if it were a new thread, demonstrating full control over program flow.

* * *

Task 1c – Chaining Context Switches
-----------------------------------

Task 1c extends the previous idea by creating two independent execution contexts. Execution begins in one function (`foo`) and then switches directly into another function (`goo`) using `set_context`, without returning.

This task demonstrates that multiple independent execution contexts can exist and transfer control explicitly. It forms the conceptual basis for implementing fibers.

* * *

Task 2 – Fiber Abstraction and Basic Scheduler
----------------------------------------------

### Fiber

The `Fiber` abstraction wraps a `Context`, a stack, and optional user data. Each fiber represents a lightweight execution unit with its own stack and entry function. The stack is manually aligned to 16 bytes and adjusted to respect the x86‑64 red zone.

### Scheduler

The scheduler maintains a queue of fibers and a scheduler context. It switches into a fiber using `set_context` and regains control when the fiber calls `fiber_exit`. The scheduler is cooperative: fibers must explicitly give control back.

### Main Program

The main program initializes the scheduler, creates two fibers with separate stacks, and passes shared data to them. Each fiber runs to completion before returning control to the scheduler.

This task establishes a minimal but functional fiber scheduler where fibers run sequentially.

* * *

Task 3 – Yielding and Cooperative Scheduling
--------------------------------------------

### Motivation

In Task 2, fibers run until completion. Task 3 adds `yield`, allowing a fiber to pause execution and allow other fibers to run. This enables cooperative multitasking patterns such as producer–consumer workflows.

### Yield Implementation

The `yield` function saves the current fiber’s context using `get_context`. On the first pass, the fiber’s context is saved and the scheduler regains control. When the scheduler later resumes the fiber, execution continues after the `yield` call.

A key detail is the flipped return value check from `get_context`, which distinguishes between the first save and the resumed execution.

### Scheduler Changes

The scheduler loop is modified to repeatedly run fibers until the queue is empty. Yielded fibers are re‑queued, while exited fibers are discarded. This creates round‑robin cooperative scheduling.

### Demonstration

Two fibers share an integer value. The first fiber modifies the value, yields, then resumes later. The second fiber observes the updated value and exits. This demonstrates correct yielding, resumption, and shared state.

* * *

Build and Run
-------------

zig build
zig build run-task1
zig build run-task2
zig build run-task3

* * *

Output Example
--------------

(Screenshot placeholder)

![Program output screenshot](screenshot.png)

* * *

Conclusion
----------

This project demonstrates how cooperative multitasking can be implemented entirely in user space. By manually controlling stacks and CPU context, we build a fiber system from first principles. The final scheduler supports yielding, shared data, and predictable execution flow.