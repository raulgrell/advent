const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const x = @import("lib/scan.zig");

const endl = "\r\n";

pub fn main() !void {
    var k = std.heap.GeneralPurposeAllocator(.{}){};
    var kk = k.allocator();
    defer _ = k.deinit();

    const stdin = std.io.getStdIn().reader();
    var bytes = try stdin.readAllAlloc(kk, 32000);
    defer kk.free(bytes);

    var boards = std.ArrayList([]u8).init(kk);
    defer {
        for (boards.items) |i| kk.free(i);
        boards.deinit();
    }

    var parts = std.mem.split(u8, bytes, endl ** 2);
    var game = parts.next() orelse return error.BadInput;

    var q: usize = 0;
    while (parts.next()) |p| {
        q += 1;
        var board = try std.ArrayList(u8).initCapacity(kk, 25);
        defer board.deinit();

        print("Loading board: {}", .{q});
        var nums = std.mem.tokenize(u8, p, " " ++ endl);
        while (nums.next()) |n| {
            const val = try std.fmt.parseInt(u8, n, 10);
            try board.append(val);
        }
        print("\n", .{});

        try boards.append(board.toOwnedSlice());
        if (p.len == 0) break;
    }

    print("Game: {s}\n", .{game});
    for (boards.items) |b, i| {
        print("Board: {}\n", .{i});
        for (b) |e| {
            print("{d:0>2}", .{e});
        }
        print("\n", .{});
    }

    var val: usize = 0;
    var brd: usize = 0;
    var calls = std.mem.split(u8, game, ",");
    blk: while (calls.next()) |n| {
        const nv = try std.fmt.parseInt(u8, n, 10);
        print("Calling {}\n", .{nv});
        for (boards.items) |b, bi| {
            print("Marking board {} for call {}\n", .{bi, nv});
            const a = markBoard(b, nv) orelse continue;
            print("Checking board {} for call {} on {}, {}.\n", .{bi, nv, a[0], a[1]});
            if (checkBoard(b, a[0], a[1])) {
                val = nv;
                brd = bi;
                break :blk;
            }
        }
    }

    var bsum: usize = 0;
    for (boards.items[brd]) |n| bsum += n;

    print("Board: {}\nVal: {}\nResult: {}\n", .{ brd, val, bsum * val });
}

fn markBoard(board: []u8, number: u8) ?[2]usize {
    for (board) |*n, i| {
        if (n.* == number) {
            n.* = 0;
            const row: usize = i / 5;
            const col: usize = i % 5;
            return [2]usize{ row, col };
        }
    }
    return null;
}

fn checkBoard(board: []u8, row: usize, col: usize) bool {
    if (checkRow(board, row)) return true;
    if (checkCol(board, col)) return true;
    if (checkDiags(board, row, col)) return true;
    return false;
}

const range = [_]usize{ 0, 1, 2, 3, 4};

fn checkRow(board: []u8, index: usize) bool {
    for (range) |i| if (board[5 * index + i] != 0) return false;
    return true;
}

fn checkCol(board: []u8, index: usize) bool {
    for (range) |i| if (board[5 * i + index] != 0) return false;
    return true;
}

fn checkDiags(board: []u8, row: usize, col: usize) bool {
    if (row == col) {
        for (range) |i| if (board[i * 5 + i] != 0) return false;
        return true;
    } else if (row + col == 4) {
        for (range) |i| if (board[5 * i + i] != 0) return false;
        return true;
    }
    return false;
}

