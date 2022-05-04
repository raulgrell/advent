const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const Map = std.AutoArrayHashMap(u8, usize);

pub fn main() !void {
    var k = std.heap.GeneralPurposeAllocator(.{}){};
    var kk = k.allocator();
    defer _ = k.deinit();

    const stdin = std.io.getStdIn().reader();
    var bytes = try stdin.readAllAlloc(kk, 32000);
    defer kk.free(bytes);

    var parts = std.mem.split(u8, bytes, "\r\n\r\n");
    const template = parts.next() orelse return error.BadInput;
    const rules = parts.next() orelse return error.BadInput;

    var map = std.StringHashMap([]const u8).init(kk);
    defer map.deinit();

    var ruleLines = std.mem.tokenize(u8, rules, "\r\n");
    while (ruleLines.next()) |l| {
        var mapping = std.mem.split(u8, l, " -> ");
        const from = mapping.next() orelse return error.BadInput;
        const to = mapping.next() orelse return error.BadInput;
        try map.putNoClobber(from, to);
    }

    var current = template;
    defer if (current.ptr != template.ptr) kk.free(current);

    print("{s}\n", .{current});

    var step: usize = 0;
    var total_steps: usize = 20;
    while (step < total_steps) : (step += 1) {
        var next = try kk.alloc(u8, current.len * 2 - 1);
        for (current[0 .. current.len - 1]) |_, i| {
            var pair = current[i .. i + 2];
            const new = map.get(pair) orelse unreachable;
            std.mem.copy(u8, next[2 * i .. 2 * i + 3], &[3]u8{ pair[0], new[0], pair[1] });
        }

        if (current.ptr != template.ptr) kk.free(current);
        current = next;
    }

    print("{s}\n", .{current});
    print("Length: {}\n", .{current.len});

    var count = Map.init(kk);
    defer count.deinit();

    for (current) |c| {
        const v = try count.getOrPut(c);
        if (v.found_existing) v.value_ptr.* += 1 else v.value_ptr.* = 0;
    }

    var min: usize = std.math.maxInt(usize);
    var iMin: usize = 0;
    var max: usize = 0;
    var iMax: usize = 0;

    const key = count.keys();
    for (count.values()) |c, i| {
        if (c > max) {
            max = c;
            iMax = i;
        }
        if (c < min) {
            min = c;
            iMin = i;
        }
        print("{c} - {d: >4}\n", .{ key[i], c });
    }

    print("Result: {}", .{max - min});
}
