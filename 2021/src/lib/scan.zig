const std = @import("std");

pub const endl = "\r\n";

pub const Token = enum {
    Space,
    Number,
    Word,
    Eof,
};

pub fn scan(buffer: []const u8) Scan {
    return Scan{ .rest = buffer };
}

pub const Scan = struct {
    rest: []const u8,

    /// Returns a slice with the rest of the buffer after skipping the bytes in delimiters
    pub fn skip(self: *@This(), delimiters: []const u8) ?[]const u8 {
        while (self.rest.len != 0) : (self.rest = self.rest[1..]) {
            if (!isAny(self.rest[0], delimiters)) return self.rest;
        } else return null;
    }

    /// Returns a slice of the next token, or null if tokenization is complete.
    pub fn token(self: *@This(), delimiters: []const u8) ?[]const u8 {
        self.rest = self.skip(delimiters) orelse return null;
        const end = std.mem.indexOfAny(u8, self.rest, delimiters) orelse self.rest.len;
        defer self.rest = self.rest[end..];
        return self.rest[0..end];
    }

    /// Returns a slice of the next field, or null if splitting is complete.
    pub fn split(self: *@This(), delimiter: []const u8) ?[]const u8 {
        if (self.rest.len == 0) return null;
        const end = std.mem.indexOf(u8, self.rest, delimiter) orelse self.rest.len;
        defer self.rest = self.rest[end..];
        return self.rest[0..end];
    }

    /// Returns a slice of consecutive bytes that match the predicate
    pub fn read(self: *@This(), pred: fn (c: u8) bool) ?[]const u8 {
        if (self.rest.len == 0) return null;
        var end: usize = 0;
        while (end < self.rest.len and pred(self.rest[end])) : (end += 1) {}
        defer self.rest = self.rest[end..];
        return self.rest[0..end];
    }

    // Advances the scanner if it starts with the expected character
    pub fn match(self: *@This(), expected: u8) bool {
        if (self.rest.len == 0) return false;
        if (self.rest[0] != expected) return false;
        self.rest = self.rest[1..];
        return true;
    }

    // Advances the scanner if it starts with expected str
    pub fn consume(self: *@This(), str: []const u8) bool {
        if (std.mem.eql(u8, self.rest[self.current..str.len], str))
            return false;
        self.rest = self.rest[str.len..];
        return true;
    }
};

pub fn isAny(c: u8, delimiters: []const u8) bool {
    for (delimiters) |d| if (c == d) return true;
    return false;
}

pub fn isDigit(c: u8) bool {
    return c >= '0' and c <= '9';
}

pub fn isAlpha(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z');
}

pub fn isHex(c: u8) bool {
    return (c >= '0' and c <= '9') or (c >= 'a' and c <= 'f') or (c >= 'A' and c <= 'F');
}

pub fn isChar(c: u8) bool {
    return (' ' <= c and c <= '~');
}

pub fn isWhitespace(c: u8) bool {
    return switch (c) {
        ' ', '\n', '\t', '\r' => true,
        else => false,
    };
}
