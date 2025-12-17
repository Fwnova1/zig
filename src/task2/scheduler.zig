const std = @import("std");
const ctx = @import("context");
const Fiber = @import("fiber").Fiber;

pub const Scheduler = struct {
    allocator: std.mem.Allocator,
    fibers: std.ArrayList(*Fiber),
    context: ctx.Context = undefined,
    current_fiber: ?*Fiber = null,

    pub fn init(allocator: std.mem.Allocator) Scheduler {
        return Scheduler{
            .allocator = allocator,
            .fibers = std.ArrayList(*Fiber){},
        };
    }

    pub fn spawn(self: *Scheduler, f: *Fiber) void {
        self.fibers.append(self.allocator, f) catch unreachable;
    }

    pub fn do_it(self: *Scheduler) void {
        if (ctx.get_context(@ptrCast(&self.context)) != 0) return;

        if (self.fibers.items.len == 0) return;

        const f = self.fibers.orderedRemove(0);
        self.current_fiber = f;
        ctx.set_context(@ptrCast(&f.context));
    }

    pub fn fiber_exit(self: *Scheduler) noreturn {
        self.current_fiber = null;
        ctx.set_context(@ptrCast(&self.context));
        unreachable;
    }

    pub fn get_data(self: *Scheduler) ?*anyopaque {
        if (self.current_fiber) |f| return f.data;
        return null;
    }
};

// --------------------
// Global scheduler API
// --------------------
pub var scheduler: Scheduler = undefined;

pub fn spawn(f: *Fiber) void {
    scheduler.spawn(f);
}

pub fn do_it() void {
    scheduler.do_it();
}

pub fn fiber_exit() noreturn {
    scheduler.fiber_exit();
}

pub fn get_data() ?*anyopaque {
    return scheduler.get_data();
}
