const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

// 3,4,3,1,2

pub fn main() !void {
    var k = std.heap.GeneralPurposeAllocator(.{}){};
    var kk = k.allocator();
    defer _ = k.deinit();

    const stdin = std.io.getStdIn().reader();
    var bytes = try stdin.readAllAlloc(kk, 32000);
    defer kk.free(bytes);

    var fish = std.ArrayList(Fish).init(kk);
    defer fish.deinit();

    var ages = std.mem.tokenize(u8, bytes, ",\r\n");
    while (ages.next()) |a| {
        const age = try std.fmt.parseInt(u8, a, 10);
        try fish.append(Fish{ .timer = age });
    }

    var day: usize = 1;
    while (day <= 80) : (day += 1) {
        try step(&fish);
        print("Day {d: >2}, {d: >2} fish\n", .{ day, fish.items.len });
    }
}

const Fish = packed struct { timer: u8 };

fn step(fish: *std.ArrayList(Fish)) !void {
    const len = fish.items.len;
    var i: usize = 0;
    while (i < len) : (i += 1) {
        const f = &fish.items[i];
        if (f.timer == 0) {
            f.timer = 6;
            try fish.append(Fish{ .timer = 8 });
        } else {
            f.timer -= 1;
        }
    }
}
