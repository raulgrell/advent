const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const x = @import("lib/scan.zig");

const Dir = enum { forward, up, down };

pub fn main() !u8 {
    const stdin = std.io.getStdIn().reader();
    var dirs = std.enums.EnumArray(Dir, isize).initFill(0);
    var buf: [256]u8 = std.mem.zeroes([256]u8);
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var s = x.scan(line[0..line.len-1]);
        const dir_str = s.token(" \n") orelse return error.Invalid;
        const amt_str = s.token(" \n") orelse return error.Invalid;
        const dir = try match(Dir, dir_str);
        const amt = try std.fmt.parseInt(isize, amt_str, 10);
        dirs.getPtr(dir).* += amt;
    }
    print("Forward: {d}, Up: {d}, Down: {d}\n", .{ dirs.get(.forward), dirs.get(.up), dirs.get(.down) });
    print("Result: {d}\n", .{dirs.get(.forward) * (dirs.get(.down) - dirs.get(.up))});
    return 0;
}

pub fn match(comptime T: type, value: []const u8) !T {
    inline for (std.meta.fields(T)) |n| {
        if (std.mem.eql(u8, n.name, value)) return @intToEnum(T, n.value);
    }
    return error.NotFound;
}
