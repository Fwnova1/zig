const std = @import("std");
const ctx = @import("context");
const Fiber = @import("fiber").Fiber;

pub const Scheduler = struct {
    allocator: std.mem.Allocator,
    fibers: std.ArrayList(*Fiber) = .{},
    context: ctx.Context = undefined,
    current_fiber: ?*Fiber = null,

    pub fn init(allocator: std.mem.Allocator) Scheduler {
        return .{
            .allocator = allocator,
        };
    }

    pub fn spawn(self: *Scheduler, f: *Fiber) void {
        self.fibers.append(self.allocator, f) catch unreachable;
    }

    pub fn do_it(self: *Scheduler) void {
        // Save scheduler context ONCE
        if (ctx.get_context(&self.context) != 0) {
            // resumed from a fiber
        }

        while (self.fibers.items.len > 0) {
            const f = self.fibers.orderedRemove(0);
            self.current_fiber = f;
            ctx.set_context(&f.context);
            // execution resumes here after yield or exit
        }
    }

    pub fn yield(self: *Scheduler) void {
        const f = self.current_fiber.?;
        self.current_fiber = null;

        // IMPORTANT: flipped condition
        if (ctx.get_context(&f.context) != 0) {
            // resumed after yield
            self.fibers.append(self.allocator, f) catch unreachable;
            ctx.set_context(&self.context);
        }
        // first time: just saved context, fall into scheduler
    }

    pub fn fiber_exit(self: *Scheduler) noreturn {
        self.current_fiber = null;
        ctx.set_context(&self.context);
        unreachable;
    }

    pub fn get_data(self: *Scheduler) ?*anyopaque {
        return if (self.current_fiber) |f| f.data else null;
    }
};

// --------------------
// Global API
// --------------------
pub var scheduler: Scheduler = undefined;

pub fn spawn(f: *Fiber) void {
    scheduler.spawn(f);
}

pub fn do_it() void {
    scheduler.do_it();
}

pub fn yield() void {
    scheduler.yield();
}

pub fn fiber_exit() noreturn {
    scheduler.fiber_exit();
}

pub fn get_data() ?*anyopaque {
    return scheduler.get_data();
}
