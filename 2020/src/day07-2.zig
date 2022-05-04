const std = @import("std");
const Allocator = std.mem.Allocator;

usingnamespace @import("lib/scan.zig");

const Context = struct {
    a: *Allocator,
    r: std.StringArrayHashMap([][]const u8),
    c: std.StringArrayHashMap(bool),
    e: std.ArrayList(Edge),
    d: usize = 0,

    const Edge = struct {
        from: []const u8, to: []const u8
    };

    pub fn new(a: *Allocator) Context {
        return .{
            .a = a,
            .r = std.StringArrayHashMap([][]const u8).init(a),
            .c = std.StringArrayHashMap(bool).init(a),
            .e = std.ArrayList(Edge).init(a),
        };
    }

    pub fn deinit(c: *Context) void {
        c.e.deinit();
    }
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer gpa.deinit();

    var c = Context.new(&gpa.allocator);
    var lines = std.ArrayList([]const u8).init(c.a);
    defer lines.deinit();

    while (true) {
        var line = stdin.readUntilDelimiterOrEofAlloc(c.a, '\n', 256) catch return;
        if (line.len == 0) break;

        // Remove final dot
        line = line[0 .. line.len - 1];

        var terms = std.mem.split(line, " bags contain ");
        const name = terms.next().?;
        const rules = terms.next().?;

        var ruleList = std.ArrayList([]const u8).init(c.a);
        var ruleTerms = std.mem.split(rules, ", ");
        while (ruleTerms.next()) |n| {
            try ruleList.append(n);
            try c.e.append(.{ .from = name, .to = n });
        }

        try c.r.putNoClobber(name, ruleList.items);
        try lines.append(line);
    }

    const k = countStartsToTarget(&c, "shiny gold");

    try stdout.print("Outer bags: {}", .{k});
}

pub fn countStartsToTarget(c: *Context, target: []const u8) usize {
    var k: usize = 0;
    for (c.r.items()) |r| {
        if (std.mem.eql(u8, r.key, target)) continue;
        if (find(c, r.key, r.key, target)) k += 1;
    }
    return k;
}

pub fn find(c: *Context, start: []const u8, current: []const u8, target: []const u8) bool {
    if (std.mem.eql(u8, current, target)) return true;
    const subrules = c.r.get(start).?;
    for (subrules) |s| {
        if (s[0] == 'n') return false;
        if (findRule(current, s)) continue;
        if (findRule(target, s)) return true;
        if (find(c, current, s, target)) return true;
    }
    return false;
}

pub fn findRule(a: []const u8, b: []const u8) bool {
    if (std.mem.indexOf(u8, b, a)) |i| return true;
    return false;
}
