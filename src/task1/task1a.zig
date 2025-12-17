const std = @import("std");
const ctx = @import("context");

// set x to 0
var x: i32 = 0;

pub fn main() void {
    // set c to get_context
    var c: ctx.Context = undefined;

    _ = ctx.get_context(@ptrCast(&c));

    // output "a message"
    std.debug.print("a message\n", .{});

    // if x == 0
    if (x == 0) {
        // set x to x PLUS 1
        x += 1;
        // call set_context with c
        ctx.set_context(@ptrCast(&c));
    }
}
