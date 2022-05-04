const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var sum: usize = 0;
    var sumAll: usize = 0;
    var group = std.mem.zeroes([26]usize);
    var buf = std.mem.zeroes([256]u8);
    var g: usize = 0;

    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len != 0) {
            parse(line, group[0..]);
            g += 1;
        } else {
            sum += count(group[0..]);
            sumAll += countAll(group[0..], g);
            g = 0;
            group = std.mem.zeroes([26]usize);
        }
    } else {
        sum += count(group[0..]);
        sumAll += countAll(group[0..], g);
    }

    std.debug.print("----\n", .{});
    try stdout.print("{}\n", .{sum});
    try stdout.print("{}\n", .{sumAll});
}

pub fn parse(line: []const u8, group: []usize) void {
    for (line) |c| group[c - 'a'] += 1;
}

pub fn count(group: []usize) usize {
    var k: usize = 0;
    for (group) |c| {
        if (c != 0) k += 1;
    }

    std.debug.print("{:>4}: ", .{k});
    for (group) |c, i| {
        std.debug.print(" {c:>2}", .{if (c != 0) @intCast(u8, i) + 'a' else ' '});
    }
    std.debug.print("\n", .{});

    return k;
}

pub fn countAll(group: []usize, num: usize) usize {
    var k: usize = 0;
    for (group) |c| {
        if (c == num) k += 1;
    }

    std.debug.print("{:>4}: ", .{k});
    for (group) |c, i| {
        std.debug.print("{:>2}", .{c});
    }
    std.debug.print("\n", .{});

    return k;
}
