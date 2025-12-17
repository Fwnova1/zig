const std = @import("std");
const ctx = @import("context");
const Fiber = @import("fiber").Fiber;

pub const Scheduler = struct {
    allocator: std.mem.Allocator,
    fibers: std.ArrayList(*Fiber) = .{},
    context: ctx.Context = undefined,
    current_fiber: ?*Fiber = null,

    pub fn init(allocator: std.mem.Allocator) Scheduler {
        return Scheduler{
            .allocator = allocator,
        };
    }

    pub fn spawn(self: *Scheduler, f: *Fiber) void {
        self.fibers.append(self.allocator, f) catch unreachable;
    }

    pub fn do_it(self: *Scheduler) void {
        if (ctx.get_context(&self.context) != 0) return;

        while (self.fibers.items.len > 0) {
            const f = self.fibers.orderedRemove(0);
            self.current_fiber = f;
            ctx.set_context(&f.context);

            // Returned from yield or exit
            if (self.current_fiber != null) {
                // Fiber yielded — it was re-queued in yield()
                self.current_fiber = null;
            }
            // else: fiber exited
        }
    }

    pub fn yield(self: *Scheduler) void {
        if (self.current_fiber) |cf| {
            const ret = ctx.get_context(&cf.context);

            if (ret == 0) {
                // First time at yield point
                self.fibers.append(self.allocator, cf) catch unreachable;
                self.current_fiber = null;
                ctx.set_context(&self.context);
                unreachable;
            }
            // else: resumed after yield — continue
        }
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

// Global scheduler instance
pub var scheduler: Scheduler = undefined;

// Global API
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
