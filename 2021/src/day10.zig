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

    var corrupted = std.ArrayList(State).init(kk);
    defer corrupted.deinit();

    var lines = std.mem.split(u8, bytes, "\r\n");
    while (lines.next()) |l| {
        if (l.len == 0) break;
        const state = try validate(kk, l);
        switch (state) {
            .Valid, .Incomplete => {},
            .Corrupted => try corrupted.append(state),
        }
    }

    var total: usize = 0;
    for (corrupted.items) |l| {
        total += score(l.Corrupted.found);
        print("Expected: {c}, Found: {c}\n", .{ l.Corrupted.expected, l.Corrupted.found });
    }

    print("Total: {}\n", .{total});
}

const Trace = struct { expected: u8, found: u8 };
const State = union(enum) {
    Valid: []const u8,
    Incomplete: []const u8,
    Corrupted: Trace,
};

fn close(char: u8) u8 {
    return switch (char) {
        '(' => ')',
        '[' => ']',
        '{' => '}',
        '<' => '>',
        else => unreachable,
    };
}

fn score(c: u8) u32 {
    return switch (c) {
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
        else => unreachable,
    };
}

fn validate(kk: Allocator, line: []const u8) !State {
    print("Testing: {s}\n", .{line});
    var stack = std.ArrayList(u8).init(kk);
    defer stack.deinit();

    for (line) |c| {
        switch (c) {
            '(', '[', '{', '<' => {
                try stack.append(c);
            },
            ']', ')', '}', '>' => {
                if (stack.items.len == 0) return State{ .Corrupted = .{ .expected = ' ', .found = c } };
                const curr = stack.pop();
                const t = Trace{ .expected = close(curr), .found = c };
                switch (curr) {
                    '(' => if (c != ')') return State{ .Corrupted = t },
                    '{' => if (c != '}') return State{ .Corrupted = t },
                    '[' => if (c != ']') return State{ .Corrupted = t },
                    '<' => if (c != '>') return State{ .Corrupted = t },
                    else => continue,
                }
            },
            else => unreachable,
        }
    }

    return if (stack.items.len == 0) State{ .Valid = line } else State{ .Incomplete = line };
}
