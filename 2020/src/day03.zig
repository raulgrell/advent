const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var lines = std.ArrayList([]const u8).init(&gpa.allocator);
    defer lines.deinit();

    while (true) {
        const line = try stdin.readUntilDelimiterOrEofAlloc(&gpa.allocator, '\n', 1024);
        if (line.len == 0) break;
        try lines.append(line);
    }
    defer {
        for (lines.items) |l| gpa.allocator.free(l);
    }

    const slopes = [_][2] usize {
        .{1, 1},
        .{3, 1},
        .{5, 1},
        .{7, 1},
        .{1, 2},
    };

    var trees = std.mem.zeroes([slopes.len]usize);
    for (slopes) |s, i| trees[i] = slopeCount(lines.items, s[0], s[1]);

    for (trees) |t| try stdout.print("{}\n", .{t});
    
    const result = product(trees[0..]);
    try stdout.print("Product: {}", .{result});
}

fn product(nums: []usize) usize {
    var k: usize = 1;
    for (nums) |n| k *= n;
    return k;
}

fn at(list: [][]const u8, w: usize, x: usize, y: usize) u8 {
    const r = y;
    const c = x % w;
    return list[r][c];
}

fn slopeCount(list: [][]const u8, sx: usize, sy: usize) usize {
    const w = list[0].len;
    const h = list.len;
    var cx: usize = 0;
    var cy: usize = 0;
    var i: usize = 0;
    var k: usize = 0;

    while (cy < h) {
        if (at(list, w, cx, cy) == '#') k += 1;
        cx += sx;
        cy += sy;
    }

    return k;
}