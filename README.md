 Zig Fiber Scheduler – Assignment Tasks 1–3 body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; line-height: 1.6; max-width: 900px; margin: 2rem auto; padding: 0 1rem; color: #222; } h1, h2, h3 { border-bottom: 1px solid #ddd; padding-bottom: 0.3em; } code, pre { background: #f6f8fa; padding: 0.2em 0.4em; border-radius: 4px; font-family: monospace; } pre { padding: 1em; overflow-x: auto; } ul { margin-left: 1.5em; } .screenshot { border: 2px dashed #aaa; padding: 2rem; text-align: center; color: #666; margin: 1rem 0; }

Zig Fiber Scheduler – Tasks 1, 2, and 3
=======================================

This project implements a cooperative user-space fiber scheduler in [Zig](https://ziglang.org/). The assignment is divided into three incremental tasks, each building on the previous one.

**Environment:**

*   Zig version: **0.15.2**
*   Platform: **Linux x86\_64**

* * *

Overview
--------

The goal of this assignment is to understand how cooperative multitasking can be implemented without operating system threads. Fibers are lightweight execution contexts that explicitly yield control back to a scheduler.

Across the three tasks, the project evolves from:

*   Basic context switching
*   A simple scheduler that runs fibers to completion
*   A full cooperative scheduler supporting `yield` and shared data

* * *

Task 1 – Context Switching
--------------------------

### Objective

Task 1 focuses on understanding and using low-level context switching primitives. A `Context` structure is used to save and restore CPU register state.

### Key Concepts

*   Saving instruction pointer (`rip`) and stack pointer (`rsp`)
*   Manually managing stacks
*   Switching execution using `get_context` and `set_context`

### Result

By the end of Task 1, execution can jump between two contexts, proving that user-space context switching is working correctly.

* * *

Task 2 – Basic Fiber Scheduler
------------------------------

### Objective

Task 2 introduces a **scheduler** that manages multiple fibers. Each fiber runs until completion and explicitly calls `fiber_exit` to return control to the scheduler.

### Design

*   Each fiber has its own stack and context
*   The scheduler maintains a queue of fibers
*   Fibers run one after another (no yielding yet)

### Execution Model

Scheduler
  ├── Fiber A (runs → fiber\_exit)
  └── Fiber B (runs → fiber\_exit)

### Limitations

Fibers cannot pause and resume. Once started, a fiber must run until it exits.

* * *

Task 3 – Cooperative Yielding
-----------------------------

### Objective

Task 3 extends the scheduler to support `yield`, allowing fibers to pause execution and resume later.

### Key Features

*   Fibers can yield control back to the scheduler
*   Yielded fibers are re-queued
*   Shared data can be accessed via `get_data()`

### Yield Semantics

When a fiber calls `yield`:

1.  The fiber’s context is saved
2.  The fiber is placed back into the scheduler queue
3.  The scheduler resumes and runs another fiber

### Example Scenario

fiber 1 before
fiber 2
fiber 1 after

This demonstrates cooperative multitasking without preemption.

* * *

Shared Data Between Fibers
--------------------------

Fibers can share data through the scheduler using `get_data()`. This enables patterns such as:

*   Producer / consumer
*   Incremental state updates
*   Message passing via shared memory

Because scheduling is cooperative, data races are avoided as long as fibers yield at well-defined points.

* * *

Build and Run
-------------

### Build

zig build

### Run Task 3

zig build run-task3

* * *

Output Example
--------------

fiber 1 before: 10
fiber 2: 11
fiber 1 after: 11

* * *

Screenshots
-----------

Screenshot placeholder – add terminal output screenshots here

* * *

Conclusion
----------

This assignment demonstrates how cooperative multitasking can be implemented entirely in user space using Zig. By progressively building from raw context switching to a yielding scheduler, the project provides a deep understanding of execution control, stacks, and scheduler design.

The final result is a small but fully functional fiber system suitable for experimentation and learning.