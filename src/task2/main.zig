const std = @import("std");
const Fiber = @import("fiber").Fiber;
const sched = @import("scheduler");

fn func1() noreturn {
    std.debug.print("fiber 1\n", .{});
    const dp = @as(*i32, @ptrCast(@alignCast(sched.scheduler.get_data().?)));
    std.debug.print("fiber 1: {}\n", .{dp.*});
    dp.* += 1;
    sched.scheduler.fiber_exit();
}

fn func2() noreturn {
    const dp = @as(*i32, @ptrCast(@alignCast(sched.scheduler.get_data().?)));
    std.debug.print("fiber 2: {}\n", .{dp.*});
    sched.scheduler.fiber_exit();
}

pub fn main() void {
    const allocator = std.heap.page_allocator;
    sched.scheduler = sched.Scheduler.init(allocator);

    var d: i32 = 10;

    var stack1: [4096]u8 = undefined;
    var stack2: [4096]u8 = undefined;

    var f1: Fiber = undefined;
    var f2: Fiber = undefined;

    f1.init(func1, stack1[0..], &d);
    f2.init(func2, stack2[0..], &d);

    sched.spawn(&f1);
    sched.spawn(&f2);

    sched.do_it();
}
