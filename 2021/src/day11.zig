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

    var energy = std.ArrayList(u8).init(kk);
    defer energy.deinit();

    var lines = std.mem.tokenize(u8, bytes, "\r\n");
    while (lines.next()) |l| {
        for (l) |c| {
            const val = c - '0';
            try energy.append(val);
        }
    }

    var step: usize = 1;
    var count: usize = 0;
    var out = std.mem.zeroes([8]usize);
    var power = std.mem.zeroes([100]u8);

    while (true) : (step += 1) {
        for (energy.items) |e, i| power[i] = e + 1;

        chain: while (true) {
            var bumps = std.mem.zeroes([100]u8);
            for (power) |p, i| {
                if (p > 9) {
                    const nbrs = around(10, 10, i, &out);
                    for (nbrs) |n| bumps[n] += 1;
                    power[i] = 0;
                    count += 1;
                }
            }

            for (bumps) |b, i| {
                if (power[i] != 0) power[i] += b;
            }

            for (power) |p| {
                if (p > 9) continue :chain;
            } else {
                break :chain;
            }
        }

        std.mem.copy(u8, energy.items, power[0..]);
        if (std.mem.allEqual(u8, energy.items, 0)) break;
    }

    print_grid(energy.items, 10);
    print("Step: {}\n", .{step});
    print("Total flashes: {}\n", .{count});
}

const Pos = enum { Head, Body, Tail };

fn around(w: usize, h: usize, i: usize, out: *[8]usize) []usize {
    const col = i % w;
    const row = i / w;
    const rowPos: Pos = if (row == 0) Pos.Head else if (row == h - 1) Pos.Tail else Pos.Body;
    const colPos: Pos = if (col == 0) Pos.Head else if (col == w - 1) Pos.Tail else Pos.Body;
    const result = switch (rowPos) {
        .Head => switch (colPos) {
            .Head => &[_]usize{ i + 1, i + w, i + w + 1 },
            .Tail => &[_]usize{ i - 1, i + w - 1, i + w },
            .Body => &[_]usize{ i - 1, i + 1, i + w - 1, i + w, i + w + 1 },
        },
        .Tail => switch (colPos) {
            .Head => &[_]usize{ i - w, i - w + 1, i + 1 },
            .Tail => &[_]usize{ i - w - 1, i - w, i - 1 },
            .Body => &[_]usize{ i - w - 1, i - w, i - w + 1, i - 1, i + 1 },
        },
        .Body => switch (colPos) {
            .Head => &[_]usize{ i - w, i - w + 1, i + 1, i + w, i + w + 1 },
            .Tail => &[_]usize{ i - w - 1, i - w, i - 1, i + w - 1, i + w },
            .Body => &[_]usize{ i - w - 1, i - w, i - w + 1, i - 1, i + 1, i + w - 1, i + w, i + w + 1 },
        },
    };
    std.mem.copy(usize, out[0..result.len], result);
    return out[0..result.len];
}

fn print_grid(grid: []u8, width: usize) void {
    var i: usize = 0;
    while (i < grid.len / width) : (i += 1) {
        print("{d}\n", .{grid[i * width .. i * width + width]});
    }
    print("\n", .{});
}

fn index(width: usize, row: usize, col: usize) usize {
    return row * width + col;
}
