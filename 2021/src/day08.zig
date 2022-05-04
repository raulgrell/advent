const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

pub fn main() !u8 {
    var k = std.heap.GeneralPurposeAllocator(.{}){};
    var kk = k.allocator();
    defer _ = k.deinit();

    const stdin = std.io.getStdIn().reader();
    var bytes = try stdin.readAllAlloc(kk, 32000);
    defer kk.free(bytes);

    var unique_count: usize = 0;
    var lines = std.mem.split(u8, bytes, "\r\n");
    while (lines.next()) |l| {
        if (l.len == 0) break;
        var parts = std.mem.split(u8, l, " | ");
        _ = parts.next() orelse return error.BadInput;
        const rest = parts.next() orelse return error.BadInput;

        var counts = std.mem.zeroes([7]u32);
        var letters = std.mem.tokenize(u8, rest, " ");
        while (letters.next()) |s| {
            const index = s.len - 1;
            counts[index] += 1;
            print("Checking {s: >7}, {}, {}\n", .{ s, index, counts[index] });
        }

        var unique_here: usize = 0;
        for (counts) |c| {
            if (c == 1) {
                unique_count += 1;
                unique_here += 1;
            }
        }
        print("Unique: {: >14}, Total: {d: >3}\n\n", .{ unique_here, unique_count });
    }

    print("Result: {}", .{unique_count});
    return 0;
}
