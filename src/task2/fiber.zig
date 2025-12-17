const ctx = @import("context");

pub const Fiber = struct {
    context: ctx.Context,
    data: ?*anyopaque = null,

    pub fn init(
        self: *Fiber,
        entry: *const fn () noreturn,
        stack: []u8,
        data: ?*anyopaque,
    ) void {
        var sp: [*]u8 = @ptrCast(stack.ptr);
        sp += stack.len;

        sp = @ptrFromInt(@intFromPtr(sp) & ~(@as(usize, 16) - 1));
        sp = @ptrFromInt(@intFromPtr(sp) - 128);

        self.context.rip = @ptrCast(@alignCast(@constCast(entry)));
        self.context.rsp = @ptrCast(@alignCast(sp));
        self.data = data;
    }
};
