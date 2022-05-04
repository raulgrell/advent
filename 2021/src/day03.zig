const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var buf = std.mem.zeroes([16]u8);
    var vals = std.mem.zeroes([12]u32);
    var n: usize = 0;
    var l: []const u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        l = line[0 .. line.len - 1];
        n += 1;
        for (l) |c, i| {
            const j = l.len - i;
            const k = vals.len - j;
            if (c == '1') vals[k] += 1;
        }
    }

    var x: u32 = 0;
    var y: u32 = 0;
    for (vals) |v, i| {
        const a: u32 = if (v > (n / 2)) 1 else 0;
        const b: u32 = if (v < (n / 2)) 1 else 0;
        const k = vals.len - 1 - i;
        x |= a << @truncate(u5, k);
        y |= b << @truncate(u5, k);
    }

    print("G: {d: >12}, {b:0>12}\n", .{ x, x });
    print("E: {d: >12}, {b:0>12}\n", .{ y, y });
    print("P: {d: >12}\n", .{x * y});
}
