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

pub extern fn get_context(c: [*c]Context) i32;
pub extern fn set_context(c: [*c]Context) void;
