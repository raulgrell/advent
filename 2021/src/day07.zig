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

    var crabs = std.ArrayList(isize).init(kk);
    defer crabs.deinit();

    var positions = std.mem.tokenize(u8, bytes, ",\r\n");

    while (positions.next()) |p| {
        const pos = try std.fmt.parseInt(isize, p, 10);
        try crabs.append(pos);
    }

    var targets = try kk.alloc(isize, crabs.items.len);
    defer kk.free(targets);

    var index: usize = 0;
    var cost: isize = std.math.maxInt(isize);
    for (targets) |_, i| {
        var sum: isize = 0;
        for (crabs.items) |c| {
            const d = try std.math.absInt(c - @intCast(isize, i));
            const v = @divExact(d * (d + 1), 2);
            sum += v;
            if(sum > cost) break;
        } else {
            index = i;
            cost = sum;
        }
    }

    print("Position: {}\nCost: {}", .{ index, cost });
}
