const std = @import("std");
const ctx = @import("context");

fn foo() noreturn {
    std.debug.print("you called foo\n", .{});
    std.process.exit(0);
}

pub fn main() void {
    var data: [4096]u8 = undefined;

    // convert array → slice
    const stack = data[0..];

    // stack grows downward → start at end
    const sp = @as(*u8, @ptrCast(stack.ptr + stack.len));

    var c: ctx.Context = undefined;

    c.rip = @as(*u64, @ptrFromInt(@intFromPtr(&foo)));
    c.rsp = @as(*u64, @ptrFromInt(@intFromPtr(sp)));

    ctx.set_context(&c);
}
