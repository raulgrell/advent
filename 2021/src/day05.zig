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

    var pts = std.AutoArrayHashMap([2]u32, u32).init(kk);
    defer pts.deinit();

    var lines = std.mem.split(u8, bytes, "\r\n");
    while (lines.next()) |l| {
        if (l.len == 0) break;
        var points = std.mem.split(u8, l, " -> ");
        var start = points.next() orelse return error.BadInput;
        var end = points.next() orelse return error.BadInput;

        var p1 = std.mem.split(u8, start, ",");
        var x1 = try std.fmt.parseInt(u32, p1.next() orelse return error.BadInput, 10);
        var y1 = try std.fmt.parseInt(u32, p1.next() orelse return error.BadInput, 10);

        var p2 = std.mem.split(u8, end, ",");
        var x2 = try std.fmt.parseInt(u32, p2.next() orelse return error.BadInput, 10);
        var y2 = try std.fmt.parseInt(u32, p2.next() orelse return error.BadInput, 10);

        if (x1 == x2) {
            var ymin = if (y1 < y2) y1 else y2;
            var ymax = if (y1 > y2) y1 else y2;
            while (ymin <= ymax) : (ymin += 1) {
                const key = [2]u32{ x1, ymin };
                if (pts.getEntry(key)) |e| e.value_ptr.* += 1 else try pts.putNoClobber(key, 1);
            }
        }
        if (y1 == y2) {
            var xmin = if (x1 < x2) x1 else x2;
            var xmax = if (x1 > x2) x1 else x2;
            while (xmin <= xmax) : (xmin += 1) {
                const key = [2]u32{ xmin, y1 };
                if (pts.getEntry(key)) |e| e.value_ptr.* += 1 else try pts.putNoClobber(key, 1);
            }
        }
    }

    var count: usize = 0;
    for (pts.values()) |v| {
        if (v > 1) count += 1;
    }
    
    print("Result: {}", .{count});
}
