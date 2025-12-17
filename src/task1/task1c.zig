const std = @import("std");
const ctx = @import("context");

// Global context for goo so foo can access it
var goo_ctx: ctx.Context = undefined;

// --------------------
// Fiber: goo
// --------------------
fn goo() noreturn {
    std.debug.print("you entered goo\n", .{});
    std.process.exit(0);
}

// --------------------
// Fiber: foo
// --------------------
fn foo() noreturn {
    std.debug.print("you called foo\n", .{});

    // Directly jump to goo (NO get_context here!)
    ctx.set_context(@ptrCast(&goo_ctx));

    unreachable;
}

// --------------------
// main
// --------------------
pub fn main() void {
    const stack_size = 4096;

    // ---------- foo stack ----------
    var foo_stack: [stack_size]u8 = undefined;
    var foo_sp: [*]u8 = @ptrCast(&foo_stack);
    foo_sp += stack_size;
    foo_sp = @ptrFromInt(@intFromPtr(foo_sp) & ~(@as(usize, 16) - 1));
    foo_sp = @ptrFromInt(@intFromPtr(foo_sp) - 128);

    var foo_ctx: ctx.Context = undefined;
    foo_ctx.rip = @ptrCast(@alignCast(@constCast(&foo)));
    foo_ctx.rsp = @ptrCast(@alignCast(foo_sp));

    // ---------- goo stack ----------
    var goo_stack: [stack_size]u8 = undefined;
    var goo_sp: [*]u8 = @ptrCast(&goo_stack);
    goo_sp += stack_size;
    goo_sp = @ptrFromInt(@intFromPtr(goo_sp) & ~(@as(usize, 16) - 1));
    goo_sp = @ptrFromInt(@intFromPtr(goo_sp) - 128);

    goo_ctx.rip = @ptrCast(@alignCast(@constCast(&goo)));
    goo_ctx.rsp = @ptrCast(@alignCast(goo_sp));

    // Start execution in foo
    ctx.set_context(@ptrCast(&foo_ctx));
}
