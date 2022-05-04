const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const Point = struct { x: usize, y: usize };
const Fold = union(enum) { X: usize, Y: usize };

pub fn main() !void {
    var k = std.heap.GeneralPurposeAllocator(.{}){};
    var kk = k.allocator();
    defer _ = k.deinit();

    const stdin = std.io.getStdIn().reader();
    var bytes = try stdin.readAllAlloc(kk, 32000);
    defer kk.free(bytes);

    var parts = std.mem.split(u8, bytes, "\r\n\r\n");
    const points = parts.next() orelse return error.BadInput;
    const folds = parts.next() orelse return error.BadInput;

    const xMax: usize = 0;
    const yMax: usize = 0;

    var pointMap = std.AutoArrayHashMap(Point, usize).init(kk);
    var pointLines = std.mem.tokenize(u8, points, "\r\n");
    while (pointLines.next()) |l| {
        const coord = std.mem.split(u8, l, ",");
        const c = std.fmt.parseInt(usize, coord.next().?, 10);
        const r = std.fmt.parseInt(usize, coord.next().?, 10);
        try points.putNoClobber(.{ .x = c, .y = r }, 1);
        xMax = std.math.max(xMax, c);
        yMax = std.math.max(yMax, r);
    }

    var foldList = std.ArrayList(Point).init(kk);
    var foldLines = std.mem.tokenize(u8, folds, "\r\n");
    while (foldLines.next()) |f| {
        var line = std.mem.tokenize(u8, f, "=");
        var axis = line.next().?[11];
        var val = std.fmt.parseInt(usize, line.next().?, 10);
        const fold: Fold = if (axis == 'x') Fold{ .X = val } else Fold{ .Y = val };
        try foldList.append(fold);
    }

    for (foldList) |f, i| {
        var new = std.AutoArrayHashMap(Point, usize).init(kk);
        var pts = pointMap.iterator();
        switch (f) {
            .X => |v| {
                while (pts.next()) |p| {
                    if (p.x > v) {
                        new.put(.{ .x = v - (x - v), .y = p.y }, 1);
                    } else {
                        new.put(p, 1);
                    }
                }
            },
            .Y => |v| {
                while (pts.next()) |p| {
                    if (p.y > v) {
                        new.put(.{ .x = px, .y = v - (p.y - v) }, 1);
                    } else {
                        new.put(p, 1);
                    }
                }
            },
        }
    }
}
