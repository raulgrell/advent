const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const Set = std.AutoArrayHashMap(isize, void);

pub fn main() anyerror!void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var lines = std.ArrayList(isize).init(&gpa.allocator);
    defer lines.deinit();

    var buf: [256]u8 = std.mem.zeroes([256]u8);
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const value = try std.fmt.parseInt(isize, line, 10);
        try lines.append(value);
    }

    var first: isize = 0;
    var second: isize = 0;
    var third: isize = 0;
    var result: isize = 0;
    
    const pair = try findPairTotalling(&gpa.allocator, 2020, lines.items);
    if (pair) |p| {
        try stdout.print("{} * {} = {}\n", .{ p[0], p[1], p[0] * p[1] });
    } else {
        return error.NoResult;
    }

    const triplet = try findTripletTotalling(&gpa.allocator, 2020, lines.items);
    if (triplet) |t| {
        try stdout.print("{} * {} * {} = {}\n", .{ t[0], t[1], t[2], t[0] * t[1] * t[2] });
    } else {
        return error.NoResult;
    }
}

fn findPairTotalling(allocator: *Allocator, total: isize, items: []const isize) !?[2]isize {
    var set = Set.init(allocator);
    defer set.deinit();
    for (items) |line, i| {
        const target = total - line;
        if (set.contains(target)) {
            return [_]isize {line, target};
        } else {
            try set.put(line, {});
        }
    }
    return null;
}

fn findTripletTotalling(allocator: *Allocator, total: isize, items: []const isize) !?[3]isize {
    for (items) |line, i| {
        const target = total - line;
        const pair = try findPairTotalling(allocator, target, items);
        if (pair) |p| {
            return [_]isize {line, p[0], p[1]};
        }
    }
    return null;
}
