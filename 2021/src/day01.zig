const std = @import("std");
const Allocator = std.mem.Allocator;
const Reader = std.fs.File.Reader;
const print = std.debug.print;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var k = try Kernel(2, 1).init(stdin);
    var result: usize = 0;
    while (k.next()) |line| {
        if (k.vals[0] < k.vals[1]) result += 1;
        if (line == null) break;
    } else |e| return e;

    print("Result: {d}\n", .{result});
}

fn Kernel(comptime window: usize, comptime step: usize) type {
    return struct {
        reader: Reader,
        vals: [window]usize = undefined,

        pub fn init(reader: Reader) !@This() {
            var k: @This() = .{ .reader = reader };
            k.vals = (try k.pull()) orelse return error.InvalidInput;
            return k;
        }

        pub fn next(self: *@This()) !?[window]usize {
            for (self.vals[0..step]) |*v, i| v.* = self.vals[i + step];
            return self.pull();
        }

        fn pull(self: *@This()) !?[window]usize {
            var buf: [64]u8 = undefined;
            for (self.vals[step..]) |*v| {
                if (try self.reader.readUntilDelimiterOrEof(&buf, '\n')) |l| {
                    v.* = try std.fmt.parseInt(usize, l[0 .. l.len - 1], 10);
                } else return null;
            }
            return self.vals;
        }
    };
}
