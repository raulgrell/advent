const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

pub fn main() !void {
    var k = std.heap.GeneralPurposeAllocator(.{}){};
    var kk = k.allocator();
    defer _ = k.deinit();

    const stdin = std.io.getStdIn().reader();
    var bytes = try stdin.readAllAlloc(kk, 32000);
    defer kk.free(bytes);

    var vals = std.ArrayList(u32).init(kk);
    defer vals.deinit();

    var len: usize = 0;
    var lines = std.mem.split(u8, bytes, "\r\n");
    while (lines.next()) |l| {
        len = std.math.max(len, l.len);
        for (l) |c| try vals.append(c - '0');
    }

    const target = vals.items.len;
}
