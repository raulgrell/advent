const std = @import("std");
const Allocator = std.mem.Allocator;

usingnamespace @import("lib/scan.zig");

const Context = struct {
    a: *Allocator,
    r: std.StringArrayHashMap([][]const u8),
    c: std.StringArrayHashMap(bool),
    e: std.ArrayList(Edge),
    d: usize = 0,
    children: std.StringArrayHashMap(std.ArrayList([]const u8)),
    parents: std.StringArrayHashMap(std.ArrayList([]const u8)),

    const Edge = struct {
        from: []const u8, to: []const u8
    };

    pub fn new(a: *Allocator) Context {
        return .{
            .a = a,
            .r = std.StringArrayHashMap([][]const u8).init(a),
            .children = std.StringArrayHashMap(std.ArrayList([]const u8)).init(a),
            .parents = std.StringArrayHashMap(std.ArrayList([]const u8)).init(a),
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

        // clear final dot
        line[line.len - 1] = ' ';

        var terms = std.mem.split(line, " bags contain ");
        const name = terms.next().?;
        const rules = terms.next().?;

        var ruleList = std.ArrayList([]const u8).init(c.a);
        var ruleTerms = std.mem.split(rules, ", ");

        var inner = try c.children.getOrPutValue(name, std.ArrayList([]const u8).init(c.a));
        while (ruleTerms.next()) |n| {
            const ruleEnd = if (n[0] == 1) n.len - 3 else n.len - 4;
            const ruleString = n[2..ruleEnd];
            var outer = try c.parents.getOrPutValue(ruleString, std.ArrayList([]const u8).init(c.a));
            try ruleList.append(n);
            try c.e.append(.{ .from = name, .to = ruleString });
            try inner.value.append(ruleString);
            try outer.value.append(name);
        }

        try c.r.putNoClobber(name, ruleList.items);
        try lines.append(line);
    }

    for (c.children.items()) |r| {
        std.debug.print("{} =>", .{r.key});
        defer std.debug.print("\n", .{});
        for (r.value.items) |k| {
            std.debug.print(" {}", .{k});
        }
    }

    const k = countStartsToTarget(&c, "shiny gold");

    try stdout.print("Outer bags: {}", .{k});
}

pub fn countStartsToTarget(c: *Context, target: []const u8) usize {
    var k: usize = 0;
    for (c.r.items()) |r| {
        if (hasParent(c, r.key, target)) k += 1;
    }
    return k;
}

pub fn hasChild(c: *Context, current: []const u8, target: []const u8) bool {
    const vals = c.children.get(current) orelse return false;
    for (vals.items) |v| {
        if (std.mem.indexOf(u8, target, v)) |_| return true;
        if (hasChild(c, target, v)) return true;
    }
    return false;
}

pub fn hasParent(c: *Context, current: []const u8, target: []const u8) bool {
    const vals = c.parents.get(current) orelse return false;
    for (vals.items) |v| {
        if (std.mem.indexOf(u8, target, v)) |_| return true;
        if (hasParent(c, target, v)) return true;
    }
    return false;
}
