const std = @import("std");
const aoc = @import("../root.zig");

const Solution = aoc.Solution;

const Direction = struct {
    dx: i32,
    dy: i32,
};

const directions = [_]Direction{
    .{ .dx = 0, .dy = -1 }, // North
    .{ .dx = 1, .dy = -1 }, // North East
    .{ .dx = 1, .dy = 0 }, // East
    .{ .dx = 1, .dy = 1 }, // South East
    .{ .dx = 0, .dy = 1 }, // South
    .{ .dx = -1, .dy = 1 }, // South West
    .{ .dx = -1, .dy = 0 }, // West
    .{ .dx = -1, .dy = -1 }, // North West
};

pub fn solve() !void {
    const input = @embedFile("../inputs/day04.txt");
    try aoc.runSolution("Day 04", input, ceresSearch, .{});
}

fn ceresSearch(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var grid: std.ArrayList([]const u8) = .empty;
    defer grid.deinit(allocator);

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        try grid.append(allocator, line);
    }

    const part1 = countXmas(grid.items);
    const part2 = countXMas(grid.items);

    return .{ .part1 = part1, .part2 = part2 };
}

fn countXmas(grid: [][]const u8) usize {
    var count: usize = 0;
    const target = "XMAS";

    for (grid, 0..) |row, y| {
        for (row, 0..) |cell, x| {
            if (cell == 'X') {
                for (directions) |dir| {
                    if (checkDirection(grid, x, y, dir, target)) {
                        count += 1;
                    }
                }
            }
        }
    }

    return count;
}

fn checkDirection(grid: [][]const u8, start_x: usize, start_y: usize, dir: Direction, target: []const u8) bool {
    const height: i32 = @intCast(grid.len);
    const width: i32 = @intCast(grid[0].len);

    for (target, 0..) |expected_char, i| {
        const offset: i32 = @intCast(i);
        const x = @as(i32, @intCast(start_x)) + dir.dx * offset;
        const y = @as(i32, @intCast(start_y)) + dir.dy * offset;

        // Check bounds
        if (x < 0 or x >= width or y < 0 or y >= height) {
            return false;
        }

        // Check character match
        if (grid[@intCast(y)][@intCast(x)] != expected_char) {
            return false;
        }
    }

    return true;
}

fn countXMas(grid: [][]const u8) u32 {
    var count: u32 = 0;

    // Need at least 3x3 grid
    if (grid.len < 3) return 0;

    for (1..grid.len - 1) |y| {
        for (1..grid[y].len - 1) |x| {
            if (grid[y][x] == 'A' and isXMas(grid, x, y)) {
                count += 1;
            }
        }
    }

    return count;
}

fn isXMas(grid: [][]const u8, x: usize, y: usize) bool {
    // Get the four corners
    const top_left = grid[y - 1][x - 1];
    const top_right = grid[y - 1][x + 1];
    const bottom_left = grid[y + 1][x - 1];
    const bottom_right = grid[y + 1][x + 1];

    // Check both diagonals form "MAS" or "SAM"
    const diag1_valid = (top_left == 'M' and bottom_right == 'S') or
        (top_left == 'S' and bottom_right == 'M');
    const diag2_valid = (top_right == 'M' and bottom_left == 'S') or
        (top_right == 'S' and bottom_left == 'M');

    return diag1_valid and diag2_valid;
}

test "part 1" {
    const input = @embedFile("../inputs/tests/day04_test_case.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const part1 = (try ceresSearch(allocator, input)).part1.?;
    try std.testing.expectEqual(18, part1);
}

test "part 2" {
    const input = @embedFile("../inputs/tests/day04_test_case.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const part2 = (try ceresSearch(allocator, input)).part2.?;
    try std.testing.expectEqual(9, part2);
}
