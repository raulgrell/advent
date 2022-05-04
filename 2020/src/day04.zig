const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

usingnamespace @import("lib/scan.zig");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var validCount: usize = 0;
    const rules = [8]Rule{
        .{ .k = "byr", .v = numberBetween(1920, 2002) },
        .{ .k = "iyr", .v = numberBetween(2010, 2020) },
        .{ .k = "eyr", .v = numberBetween(2020, 2030) },
        .{ .k = "hgt", .v = validHeight },
        .{ .k = "hcl", .v = validHair },
        .{ .k = "ecl", .v = validEye },
        .{ .k = "pid", .v = validPass },
        .{ .k = "cid", .v = validCountry },
    };

    var values = std.mem.zeroes([8]bool);
    var buf: [256]u8 = std.mem.zeroes([256]u8);
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len != 0) {
            var terms = std.mem.split(line, " ");
            while (terms.next()) |t| validateField(rules[0..], values[0..], t);
        } else {
            if (!anyEqual(bool, values[0..7], false)) validCount += 1;
            values = std.mem.zeroes([8]bool);
        }
    }

    try stdout.print("{}\n", .{validCount});
}


fn validateField(rules: []const Rule, values: []bool, term: []const u8) void {
    for (rules) |r, i| {
        if (std.mem.eql(u8, term[0..3], r.k)) {
            if (r.v(term[4..])) values[i] = true;
            break;
        }
    }
}

const Rule = struct { k: []const u8, v: ValidationFn};
const ValidationFn = fn (value: []const u8) bool;

fn numberBetween(comptime min: usize, comptime max: usize) ValidationFn {
    return struct {
        fn valid(value: []const u8) bool {
            const num = std.fmt.parseInt(isize, value, 10) catch return false;
            return num >= min and num <= max;
        }
    }.valid;
}

fn validHeight(value: []const u8) bool {
    var s = scan(value);
    const num = s.read(isDigit) orelse return false;
    const str = s.read(isAlpha) orelse return false;
    const numVal = std.fmt.parseInt(usize, num, 10) catch return false;
    if (std.mem.eql(u8, str, "cm")) return (numVal >= 150 and numVal <= 193);
    if (std.mem.eql(u8, str, "in")) return (numVal >= 59 and numVal <= 76);
    return false;
}

fn validHair(value: []const u8) bool {
    var s = scan(value);
    if (!s.match('#')) return false;
    const hex = s.read(isHex) orelse return false;
    return hex.len == 6;
}

fn validEye(value: []const u8) bool {
    var vals = [_][]const u8{ "amb", "blu", "brn", "gry", "grn", "hzl", "oth" };
    return anyEqualMem([]const u8, &vals, value);
}

fn validPass(value: []const u8) bool {
    var s = scan(value);
    const num = s.read(isDigit) orelse return false;
    return num.len == 9;
}

fn validCountry(value: []const u8) bool {
    return true;
}

pub fn anyEqual(comptime T: type, slice: []const T, mem: T) bool {
    for (slice) |item| if (item == mem) return true;
    return false;
}

pub fn anyEqualMem(comptime T: type, slice: []const T, mem: T) bool {
    for (slice) |item| if (std.mem.eql(u8, item, mem)) return true;
    return false;
}
