const std = @import("std");
const aoc = @import("../root.zig");

const Solution = aoc.Solution;

pub fn solve() !void {
    const input = @embedFile("../inputs/day05.txt");
    try aoc.runSolution("Day 05", input, printQueue, .{});
}

fn printQueue(allocator: std.mem.Allocator, input: []const u8) !Solution {
    var rules = std.AutoHashMap(usize, std.ArrayList(usize)).init(allocator);
    defer {
        var iter = rules.valueIterator();
        while (iter.next()) |list| {
            list.deinit(allocator);
        }
        rules.deinit();
    }

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) break; // end of rules section

        var parts = std.mem.splitScalar(u8, line, '|');
        const before = try std.fmt.parseInt(usize, parts.next() orelse continue, 10);
        const after = try std.fmt.parseInt(usize, parts.next() orelse continue, 10);

        const entry = try rules.getOrPut(before);
        if (!entry.found_existing) {
            entry.value_ptr.* = .empty;
        }
        try entry.value_ptr.append(allocator, after);
    }

    var part1: usize = 0;
    var part2: usize = 0;

    // Parse and validate updates
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var pages: std.ArrayList(usize) = .empty;
        defer pages.deinit(allocator);

        var nums = std.mem.splitScalar(u8, line, ',');
        while (nums.next()) |num| {
            const trimmed = std.mem.trim(u8, num, " \t\r");
            if (trimmed.len == 0) continue;
            try pages.append(allocator, try std.fmt.parseInt(usize, trimmed, 10));
        }

        if (isValidUpdate(&rules, pages.items)) {
            const middle = pages.items[pages.items.len / 2];
            part1 += middle;
        } else {
            sortByRules(&rules, pages.items);
            const middle = pages.items[pages.items.len / 2];
            part2 += middle;
        }
    }

    return .{ .part1 = part1, .part2 = part2 };
}

fn isValidUpdate(rules: *const std.AutoHashMap(usize, std.ArrayList(usize)), pages: []const usize) bool {
    for (pages, 0..) |page, i| {
        if (rules.get(page)) |must_come_after| {
            for (pages[0..i]) |earlier_page| {
                if (contains(must_come_after.items, earlier_page)) {
                    return false;
                }
            }
        }
    }
    return true;
}

fn contains(slice: []const usize, value: usize) bool {
    for (slice) |item| {
        if (item == value) return true;
    }
    return false;
}

fn sortByRules(rules: *const std.AutoHashMap(usize, std.ArrayList(usize)), pages: []usize) void {
    // Bubble sort based on rules
    const n = pages.len;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        var j: usize = 0;
        while (j < n - i - 1) : (j += 1) {
            // Check if pages[j] should come after pages[j+1]
            if (shouldSwap(rules, pages[j], pages[j + 1])) {
                const temp = pages[j];
                pages[j] = pages[j + 1];
                pages[j + 1] = temp;
            }
        }
    }
}

fn shouldSwap(rules: *const std.AutoHashMap(usize, std.ArrayList(usize)), first: usize, second: usize) bool {
    if (rules.get(second)) |must_come_after| {
        if (contains(must_come_after.items, first)) {
            return true;
        }
    }
    return false;
}

test "part 1" {
    const input = @embedFile("../inputs/tests/day05_test_case.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const part1 = (try printQueue(allocator, input)).part1.?;
    try std.testing.expectEqual(143, part1);
}

test "part 2" {
    const input = @embedFile("../inputs/tests/day05_test_case.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const part2 = (try printQueue(allocator, input)).part2.?;
    try std.testing.expectEqual(123, part2);
}
