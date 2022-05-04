const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var maxId: usize = 0;
    var ids = std.mem.zeroes([128 * 8]bool);
    var buf = std.mem.zeroes([256]u8);
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var rows = Range{ .min = 0, .max = 127 };
        for (line[0..7]) |c| {
            switch (c) {
                'F' => rows = lowerHalf(rows),
                'B' => rows = upperHalf(rows),
                else => unreachable,
            }
        }
        std.debug.assert(rows.min == rows.max);

        var cols = Range{ .min = 0, .max = 7 };
        for (line[7..10]) |c| {
            switch (c) {
                'L' => cols = lowerHalf(cols),
                'R' => cols = upperHalf(cols),
                else => unreachable,
            }
        }
        std.debug.assert(cols.min == cols.max);

        const id = rows.min * 8 + cols.min;
        ids[id] = true;
        if (id > maxId) {
            maxId = id;
        }
    }

    const index = std.mem.indexOf(bool, ids[8..ids.len - 8], &[_]bool {false}) orelse return error.NoSeat;
    const seat = index + 8;
    try stdout.print("max id: {}\nseat: {}", .{maxId, seat});
}

pub const Range = struct {
    min: usize, max: usize
};

pub fn lowerHalf(range: Range) Range {
    return .{ .min = range.min, .max = (range.max + range.min) / 2 };
}

pub fn upperHalf(range: Range) Range {
    return .{ .min = ((range.max + range.min) / 2) + 1, .max = range.max};
}
