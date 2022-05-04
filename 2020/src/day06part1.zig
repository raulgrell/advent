const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var sum: usize = 0;
    var group = std.mem.zeroes([26]bool);
    var buf = std.mem.zeroes([256]u8);

    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len != 0) {
            parse(line, group[0..]);
        } else {
            sum += count(group[0..]);
            group = std.mem.zeroes([26]bool);
        }
    }

    std.debug.print("----\n", .{});
    try stdout.print("{}\n", .{sum});
}

pub fn parse(line: []const u8, group: []bool) void {
    for (line) |c| group[c - 'a'] = true;
}

pub fn count(group: []bool) usize {
    var k: usize = 0;
    for (group) |c| {
        if (c) k += 1;
    }

    std.debug.print("{:>4} - ", .{k});
    for (group) |c, i| {
        if (c) std.debug.print("{c}", .{@intCast(u8, i) + 'a'});
    }
    std.debug.print("\n", .{});

    return k;
}
