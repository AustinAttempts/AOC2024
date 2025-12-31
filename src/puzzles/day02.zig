const std = @import("std");
const aoc = @import("../root.zig");

const Solution = aoc.Solution;

pub fn solve() !void {
    const input = @embedFile("../inputs/day02.txt");
    try aoc.runSolution("Day 01", input, redNoseReports, .{});
}

fn redNoseReports(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var part1: usize = 0;
    var part2: usize = 0;
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var nums: std.ArrayList(isize) = .empty;
        defer nums.deinit(allocator);

        var iter = std.mem.tokenizeAny(u8, line, " \t");
        while (iter.next()) |token| {
            try nums.append(allocator, try std.fmt.parseInt(isize, token, 10));
        }

        if (isSafeReport(nums.items)) {
            part1 += 1;
            part2 += 1;
        } else if (try isSafeWithDampener(allocator, nums.items)) {
            part2 += 1;
        }
    }

    return .{ .part1 = part1, .part2 = part2 };
}

fn isSafeReport(levels: []const isize) bool {
    if (levels.len < 2) return false;

    const first_diff = levels[1] - levels[0];
    if (first_diff == 0) return false;

    const is_increasing = first_diff > 0;

    for (0..levels.len - 1) |i| {
        const diff = levels[i + 1] - levels[i];

        // Check if direction changed
        if ((is_increasing and diff <= 0) or (!is_increasing and diff >= 0)) {
            return false;
        }

        // Check if difference is within valid range
        const abs_diff = @abs(diff);
        if (abs_diff < 1 or abs_diff > 3) {
            return false;
        }
    }

    return true;
}

fn isSafeWithDampener(allocator: std.mem.Allocator, levels: []const isize) !bool {
    for (0..levels.len) |skip_idx| {
        var temp: std.ArrayList(isize) = .empty;
        defer temp.deinit(allocator);

        for (levels, 0..) |level, i| {
            if (i != skip_idx) {
                try temp.append(allocator, level);
            }
        }

        if (isSafeReport(temp.items)) {
            return true;
        }
    }
    return false;
}

test "part 1" {
    const input = @embedFile("../inputs/tests/day02_test_case.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const part1 = (try redNoseReports(allocator, input)).part1.?;
    try std.testing.expectEqual(2, part1);
}

test "part 2" {
    const input = @embedFile("../inputs/tests/day02_test_case.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const part2 = (try redNoseReports(allocator, input)).part2.?;
    try std.testing.expectEqual(4, part2);
}
