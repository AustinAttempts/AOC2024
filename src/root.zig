const std = @import("std");

pub const Solution = struct {
    part1: ?usize,
    part2: ?usize,
};

pub fn runSolution(
    comptime day_name: []const u8,
    input: []const u8,
    solveFn: anytype,
    extra_args: anytype,
) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var timer = try std.time.Timer.start();

    const args_type = @typeInfo(@TypeOf(extra_args));
    const num_args = if (args_type == .@"struct") args_type.@"struct".fields.len else 0;

    const solution = switch (num_args) {
        0 => try solveFn(allocator, input),
        1 => try solveFn(allocator, input, extra_args[0]),
        2 => try solveFn(allocator, input, extra_args[0], extra_args[1]),
        3 => try solveFn(allocator, input, extra_args[0], extra_args[1], extra_args[2]),
        else => @compileError("Too many extra args (max 3)"),
    };
    const elapsed_ns = timer.read();
    const ms = @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_ms;

    // ANSI color codes
    const cyan = "\x1b[36m";
    const yellow = "\x1b[33m";
    const reset = "\x1b[0m";
    const bold = "\x1b[1m";

    std.debug.print("{s}{s}{s}\n", .{ cyan, day_name, reset });
    std.debug.print("  {s}Part 1:{s} {?d}\n", .{ bold, reset, solution.part1 });
    std.debug.print("  {s}Part 2:{s} {?d}\n", .{ bold, reset, solution.part2 });
    std.debug.print("  {s}⏱  {d:.2}ms{s}\n\n", .{ yellow, ms, reset });
}

pub fn printSolution() !void {
    try day01.solve();
    try day02.solve();
}

pub const day01 = @import("puzzles/day01.zig");
pub const day02 = @import("puzzles/day02.zig");

test {
    std.testing.refAllDecls(@This());
    _ = @import("puzzles/day01.zig");
    _ = @import("puzzles/day02.zig");
}
