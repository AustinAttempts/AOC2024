const std = @import("std");
const aoc = @import("../root.zig");

const Solution = aoc.Solution;

pub fn solve() !void {
    const input = @embedFile("../inputs/day01.txt");
    try aoc.runSolution("Day 01", input, historianHysteria, .{});
}

fn historianHysteria(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var left_list: std.ArrayList(usize) = .empty;
    defer left_list.deinit(allocator);
    var right_list: std.ArrayList(usize) = .empty;
    defer right_list.deinit(allocator);

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var iter = std.mem.tokenizeAny(u8, line, " \t");
        const num1 = try std.fmt.parseInt(usize, iter.next() orelse continue, 10);
        const num2 = try std.fmt.parseInt(usize, iter.next() orelse continue, 10);

        try left_list.append(allocator, num1);
        try right_list.append(allocator, num2);
    }

    std.mem.sort(usize, left_list.items, {}, std.sort.asc(usize));
    std.mem.sort(usize, right_list.items, {}, std.sort.asc(usize));

    // Part 1: Calculate total distance
    var part1: usize = 0;
    for (left_list.items, right_list.items) |value_l, value_r| {
        part1 += @max(value_l, value_r) - @min(value_l, value_r);
    }

    // Part 2: Calculate similarity score using a hash map
    var right_counts = std.AutoHashMap(usize, usize).init(allocator);
    defer right_counts.deinit();

    for (right_list.items) |value| {
        const entry = try right_counts.getOrPut(value);
        if (entry.found_existing) {
            entry.value_ptr.* += 1;
        } else {
            entry.value_ptr.* = 1;
        }
    }

    var part2: usize = 0;
    for (left_list.items) |value_l| {
        const count = right_counts.get(value_l) orelse 0;
        part2 += value_l * count;
    }

    return .{ .part1 = part1, .part2 = part2 };
}

test "part 1" {
    const input = @embedFile("../inputs/tests/day01_test_case.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const part1 = (try historianHysteria(allocator, input)).part1.?;
    try std.testing.expectEqual(11, part1);
}

test "part 2" {
    const input = @embedFile("../inputs/tests/day01_test_case.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const part2 = (try historianHysteria(allocator, input)).part2.?;
    try std.testing.expectEqual(31, part2);
}
