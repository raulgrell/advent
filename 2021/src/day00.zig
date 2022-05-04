const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub fn main() anyerror!void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // var lines = std.ArrayList([]const u8).init(&gpa.allocator);
    // defer lines.deinit();
    // while (true) {
    //     const line = try stdin.readUntilDelimiterOrEofAlloc(&gpa.allocator, '\n', 1024);
    //     if (line.len == 0) break;
    //     try lines.append(line);
    // }

    // var buf: [256]u8 = std.mem.zeroes([256]u8);
    // while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
    //     const value = try std.fmt.parseInt(isize, line, 10);
    // }

    // var bytes: std.ArrayList(u8).init(&gpa.allocator);
    // while (true) {
    //     try stdin.readUntilDelimiterOrEofArrayList(&gpa.allocator, '\n', 1024);
    //     if (line.len == 0) break;
    // }

    // var bytes: std.ArrayList(u8).init(&gpa.allocator);
    // var contents = stdin.readAllArrayList(bytes, 32000);

    try stdout.print("{}\n", .{"Done"});
}