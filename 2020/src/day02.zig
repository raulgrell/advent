const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var lines = std.ArrayList([]const u8).init(&gpa.allocator);
    defer lines.deinit();

    var validOriginal: usize = 0;
    var validNew: usize = 0;

    var buf: [256]u8 = std.mem.zeroes([256]u8);
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const entry = try parseLine(line);
        if (validateEntry(entry, original)) validOriginal += 1;
        if (validateEntry(entry, new)) validNew += 1;
    }

    try stdout.print("original: {}, new: {}\n", .{validOriginal, validNew});
}

const Entry = struct {
    min: usize, max: usize, char: u8, pass: []const u8
};

fn parseLine(input: []const u8) !Entry {
    var terms = std.mem.tokenize(input, " ");
    const range = terms.next() orelse return error.NoRange;
    var bounds = std.mem.tokenize(range, "-");
    const min: usize = try std.fmt.parseInt(usize, bounds.next() orelse return error.NoMin, 10);
    const max: usize = try std.fmt.parseInt(usize, bounds.next() orelse return error.NoMax, 10);
    const pattern = terms.next() orelse return error.NoPattern;
    const char = pattern[0];
    const pass = terms.next() orelse return error.NoPass;
    return Entry {
        .min = min,
        .max = max,
        .char = char,
        .pass = pass,
    };
}

const ValidationFn = fn (input: Entry) bool;

fn validateEntry(entry: Entry, func: ValidationFn) bool {
    return func(entry);
}

fn original(entry: Entry) bool {
    const count = countChar(entry.pass, entry.char);
    return count >= entry.min and count <= entry.max;
}

fn countChar(input: []const u8, char: u8) usize {
    var i: usize = 0;
    for (input) |c| {
        if (c == char) i += 1;
    }
    return i;
}

fn new(entry: Entry) bool {
    return ((entry.pass[entry.min - 1] == entry.char) and (entry.pass[entry.max - 1] != entry.char))
        or ((entry.pass[entry.min - 1] != entry.char) and (entry.pass[entry.max - 1] == entry.char));
}
