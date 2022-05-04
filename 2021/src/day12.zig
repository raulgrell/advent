const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const StringSet = std.StringHashMap(void);
const Node = *[]const u8;
const Edge = struct { from: Node, to: Node };

pub fn main() !void {
    var k = std.heap.GeneralPurposeAllocator(.{}){};
    var kk = k.allocator();
    defer _ = k.deinit();

    const stdin = std.io.getStdIn().reader();
    var bytes = try stdin.readAllAlloc(kk, 32000);
    defer kk.free(bytes);

    var nodes = StringSet.init(kk);
    defer nodes.deinit();

    var edges = std.ArrayList(Edge).init(kk);
    defer edges.deinit();

    var lines = std.mem.tokenize(u8, bytes, "\r\n");
    while (lines.next()) |l| {
        var parts = std.mem.split(u8, l, "-");
        const a = parts.next() orelse return error.BadInput;
        const b = parts.next() orelse return error.BadInput;
        const from = try nodes.getOrPut(a);
        const to = try nodes.getOrPut(b);
        try edges.append(Edge{ .from = from.key_ptr, .to = to.key_ptr });
    }
  
    const start = nodes.getKeyPtr("start") orelse return error.StartNotFound;
    const end = nodes.getKeyPtr("end") orelse return error.EndNotFound;

    var adj = std.AutoArrayHashMap(Node, std.ArrayList(Node)).init(kk);
    defer adj.deinit();

    for (edges) |e| {
        const f = try adj.getOrPut(e.from);
        if (f.found_existing) {
            f.value_ptr.append(e.to);
        } else {
            f.value_ptr.* = std.ArrayList(Node).init(kk);
            f.value_ptr.append(e.to);
        }
        const t = try adj.getOrPut(e.to);
        if (f.found_existing) {
            f.value_ptr.append(e.from);
        } else {
            f.value_ptr.* = std.ArrayList(Node).init(kk);
            f.value_ptr.append(e.from);
        }
    }

    var paths = std.ArrayList([]Node).init(kk);
    defer paths.deinit();

    var current = start;

    var visited = StringSet.init(kk);
    defer visited.deinit();

    var path = std.ArrayList(Node).init(kk);
    defer path.deinit();

    var open = std.ArrayList(Node).init(kk);
    defer open.deinit();

    while (current != end) {
        try visited.putNoClobber(current, {});
        try path.append(current);
        var a = adj.get(current) orelse return error.NoAdjacent;
        for (a.items) |b| {
            if (!visited.contains(b)) {
                open.append(b);
            }
        }

        break;
    }
}
