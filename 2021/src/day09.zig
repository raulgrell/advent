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

    var vals = std.ArrayList(u32).init(kk);
    defer vals.deinit();

    var max: usize = 0;
    var lines = std.mem.split(u8, bytes, "\r\n");
    while (lines.next()) |l| {
        max = std.math.max(max, l.len);
        for (l) |c| try vals.append(c - '0');
    }

    const width = max;
    const height = vals.items.len / max;

    var lows = std.AutoArrayHashMap(usize, usize).init(kk);
    defer lows.deinit();

    var row: usize = 0;
    while (row < height) : (row += 1) {
        var col: usize = 0;
        while (col < width) : (col += 1) {
            var i = index(width, row, col);
            var h = vals.items[i];
            var low = if (row == 0)
                (if (col == 0)
                    vals.items[index(width, row, col + 1)] > h and vals.items[index(width, row + 1, col)] > h
                else if (col == width - 1)
                    vals.items[index(width, row, col - 1)] > h and vals.items[index(width, row + 1, col)] > h
                else
                    vals.items[index(width, row, col - 1)] > h and vals.items[index(width, row, col + 1)] > h and vals.items[index(width, row + 1, col)] > h)
            else if (row == height - 1)
                (if (col == 0)
                    vals.items[index(width, row, col + 1)] > h and vals.items[index(width, row - 1, col)] > h
                else if (col == width - 1)
                    vals.items[index(width, row, col - 1)] > h and vals.items[index(width, row - 1, col)] > h
                else
                    vals.items[index(width, row, col - 1)] > h and vals.items[index(width, row, col + 1)] > h and vals.items[index(width, row - 1, col)] > h)
            else
                (if (col == 0)
                    vals.items[index(width, row, col + 1)] > h and vals.items[index(width, row - 1, col)] > h and vals.items[index(width, row + 1, col)] > h
                else if (col == width - 1)
                    vals.items[index(width, row, col - 1)] > h and vals.items[index(width, row - 1, col)] > h and vals.items[index(width, row + 1, col)] > h
                else
                    (vals.items[index(width, row, col - 1)] > h and vals.items[index(width, row, col + 1)] > h and
                        vals.items[index(width, row - 1, col)] > h and vals.items[index(width, row + 1, col)] > h));
                        
            if (low) {
                var risk = h + 1;
                try lows.putNoClobber(i, risk);
                print("Low {}\n", .{risk});
            }
        }
    }

    var r: usize = 0;
    for (lows.values()) |v| {
        r += v;
        print("{: >2}, {: >2}\n", .{ v, r });
    }

    print("Result: {}\n", .{r});
}

fn index(width: usize, row: usize, col: usize) usize {
    return row * width + col;
}
