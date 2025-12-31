const std = @import("std");
const aoc = @import("../root.zig");

const Solution = aoc.Solution;

pub fn solve() !void {
    const input = @embedFile("../inputs/day03.txt");
    try aoc.runSolution("Day 03", input, mullItOver, .{});
}

fn mullItOver(allocator: std.mem.Allocator, input: []const u8) !Solution {
    const part1 = try parseMulInstructions(input);

    // Build cleaned input with do()/don't() logic
    var cleaned: std.ArrayList(u8) = .empty;
    defer cleaned.deinit(allocator);

    var removes = std.mem.splitSequence(u8, input, "don't()");
    const first_section = removes.next() orelse "";
    try cleaned.appendSlice(allocator, first_section);

    while (removes.next()) |chunk| {
        var keeps = std.mem.splitSequence(u8, chunk, "do()");
        _ = keeps.next(); // Skip disabled section

        while (keeps.next()) |keep| {
            try cleaned.appendSlice(allocator, keep);
        }
    }

    const part2 = try parseMulInstructions(cleaned.items);

    return .{ .part1 = part1, .part2 = part2 };
}

fn parseMulInstructions(input: []const u8) !usize {
    var result: usize = 0;

    var chunks = std.mem.splitSequence(u8, input, "mul(");
    _ = chunks.next(); // Skip before first "mul("

    while (chunks.next()) |chunk| {
        if (parseMulArgs(chunk)) |product| {
            result += product;
        }
    }

    return result;
}

fn parseMulArgs(chunk: []const u8) ?usize {
    const close_paren = std.mem.indexOfScalar(u8, chunk, ')') orelse return null;
    const args = chunk[0..close_paren];

    const comma_pos = std.mem.indexOfScalar(u8, args, ',') orelse return null;
    if (std.mem.indexOfScalarPos(u8, args, comma_pos + 1, ',') != null) return null;

    const first_str = args[0..comma_pos];
    const second_str = args[comma_pos + 1 ..];

    if (first_str.len == 0 or first_str.len > 3) return null;
    if (second_str.len == 0 or second_str.len > 3) return null;

    const num1 = std.fmt.parseInt(usize, first_str, 10) catch return null;
    const num2 = std.fmt.parseInt(usize, second_str, 10) catch return null;

    return num1 * num2;
}

test "part 1" {
    const input = @embedFile("../inputs/tests/day03_test_case1.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const part1 = (try mullItOver(allocator, input)).part1.?;
    try std.testing.expectEqual(161, part1);
}

test "part 2" {
    const input = @embedFile("../inputs/tests/day03_test_case2.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const part2 = (try mullItOver(allocator, input)).part2.?;
    try std.testing.expectEqual(48, part2);
}
