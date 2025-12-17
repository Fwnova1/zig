const std = @import("std");
const Fiber = @import("fiber").Fiber;
const sched = @import("scheduler");

fn func1() noreturn {
    std.debug.print("fiber 1 before\n", .{});
    const dp = @as(*i32, @ptrCast(@alignCast(sched.get_data().?)));
    std.debug.print("fiber 1: {d}\n", .{dp.*});
    dp.* += 1;

    sched.yield();

    std.debug.print("fiber 1 after\n", .{});
    std.debug.print("fiber 1 after: {d}\n", .{dp.*});

    sched.fiber_exit();
}

fn func2() noreturn {
    const dp = @as(*i32, @ptrCast(@alignCast(sched.get_data().?)));
    std.debug.print("fiber 2: {d}\n", .{dp.*});
    sched.fiber_exit();
}

pub fn main() void {
    const allocator = std.heap.page_allocator;
    sched.scheduler = sched.Scheduler.init(allocator);

    var shared: i32 = 10;

    var stack1: [8192]u8 = undefined;
    var stack2: [8192]u8 = undefined;

    var f1: Fiber = undefined;
    var f2: Fiber = undefined;

    f1.init(func1, &stack1, &shared);
    f2.init(func2, &stack2, &shared);

    sched.spawn(&f1);
    sched.spawn(&f2);

    sched.do_it();
}
