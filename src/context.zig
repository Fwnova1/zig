// src/context.zig
const std = @import("std");

/// Execution context saved/restored by the assembly library
pub const Context = extern struct {
    rip: ?*u64,
    rsp: ?*u64,
    rbx: ?*u64,
    rbp: ?*u64,
    r12: ?*u64,
    r13: ?*u64,
    r14: ?*u64,
    r15: ?*u64,
};

/// Save current execution context
/// Returns:
///   0  - first time
///   >0 - after set_context
pub extern fn get_context(c: [*c]Context) i32;

/// Restore a previously saved context
/// Does not return
pub extern fn set_context(c: [*c]Context) void;
