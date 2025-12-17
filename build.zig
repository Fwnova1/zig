const std = @import("std");

fn addTask(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    imports: []const std.Build.Module.Import,
    comptime name: []const u8,
    comptime path: []const u8,
    link_context: bool,
) void {
    const mod = b.createModule(.{
        .root_source_file = b.path(path),
        .target = target,
        .optimize = optimize,
        .imports = imports,
    });

    const exe = b.addExecutable(.{
        .name = name,
        .root_module = mod,
    });

    if (link_context) {
        exe.linkLibC();
        exe.addIncludePath(b.path("lib"));
        exe.addLibraryPath(b.path("lib"));
        exe.linkSystemLibrary("context");
    }

    b.installArtifact(exe);

    const run_step = b.step("run-" ++ name, "Run " ++ name);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    run_step.dependOn(&run_cmd.step);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // =====================================================
    //     Shared context module
    // =====================================================
    const context_mod = b.addModule("context_mod", .{
        .root_source_file = b.path("src/context.zig"),
        .target = target,
    });

    // =====================================================
    //     Task 2 fiber + scheduler
    // =====================================================
    const fiber_mod2 = b.addModule("fiber_mod2", .{
        .root_source_file = b.path("src/task2/fiber.zig"),
        .target = target,
        .imports = &.{.{ .name = "context", .module = context_mod }},
    });

    const scheduler_mod2 = b.addModule("scheduler_mod2", .{
        .root_source_file = b.path("src/task2/scheduler.zig"),
        .target = target,
        .imports = &.{
            .{ .name = "context", .module = context_mod },
            .{ .name = "fiber", .module = fiber_mod2 },
        },
    });

    // =====================================================
    //     Task 3 fiber + scheduler
    // =====================================================
    const fiber_mod3 = b.addModule("fiber_mod3", .{
        .root_source_file = b.path("src/task3/fiber.zig"),
        .target = target,
        .imports = &.{.{ .name = "context", .module = context_mod }},
    });

    const scheduler_mod3 = b.addModule("scheduler_mod3", .{
        .root_source_file = b.path("src/task3/scheduler.zig"),
        .target = target,
        .imports = &.{
            .{ .name = "context", .module = context_mod },
            .{ .name = "fiber", .module = fiber_mod3 },
        },
    });

    // =====================================================
    //     TASK 1  (ONLY context needed)
    // =====================================================
    addTask(
        b,
        target,
        optimize,
        &.{.{ .name = "context", .module = context_mod }},
        "task1a",
        "src/task1/task1a.zig",
        true,
    );

    addTask(
        b,
        target,
        optimize,
        &.{.{ .name = "context", .module = context_mod }},
        "task1b",
        "src/task1/task1b.zig",
        true,
    );

    addTask(
        b,
        target,
        optimize,
        &.{.{ .name = "context", .module = context_mod }},
        "task1c",
        "src/task1/task1c.zig",
        true,
    );

    // =====================================================
    //     TASK 2 MAIN
    // =====================================================
    addTask(
        b,
        target,
        optimize,
        &.{
            .{ .name = "context", .module = context_mod },
            .{ .name = "fiber", .module = fiber_mod2 },
            .{ .name = "scheduler", .module = scheduler_mod2 },
        },
        "task2",
        "src/task2/main.zig",
        true,
    );

    // =====================================================
    //     TASK 2 TESTS
    // =====================================================
    const test_mod2 = b.createModule(.{
        .root_source_file = b.path("src/task2/main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "context", .module = context_mod },
            .{ .name = "fiber", .module = fiber_mod2 },
            .{ .name = "scheduler", .module = scheduler_mod2 },
        },
    });

    const tests = b.addTest(.{
        .root_module = test_mod2,
    });

    const test_step = b.step("test-task2", "Run Task 2 tests");
    test_step.dependOn(&tests.step);

    // =====================================================
    //     TASK 3 MAIN
    // =====================================================
    addTask(
        b,
        target,
        optimize,
        &.{
            .{ .name = "context", .module = context_mod },
            .{ .name = "fiber", .module = fiber_mod3 },
            .{ .name = "scheduler", .module = scheduler_mod3 },
        },
        "task3",
        "src/task3/main.zig",
        true,
    );
}
