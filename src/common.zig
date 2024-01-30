const std = @import("std");

pub fn getInputString(alloc: std.mem.Allocator, fname: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(fname, .{});
    defer file.close();
    const fsize = try file.getEndPos();
    return try file.readToEndAlloc(alloc, fsize);
}

pub fn getInputIterator(alloc: std.mem.Allocator, fname: []const u8) !std.mem.SplitIterator(u8, .sequence) {
    const filestr = try getInputString(alloc, fname);
    return std.mem.split(u8, filestr, "\n");
}
pub fn getInputLinesArrayList(alloc: std.mem.Allocator, fname: []const u8) !std.ArrayList([]const u8) {
    const iter = try getInputIterator(alloc, fname);
    var lines = std.ArrayList([]const u8).init(alloc);
    while (iter.next()) |line| {
        try lines.append(line);
    }
    return lines;
}
pub fn isDigit(ch: u8) bool {
    return (ch >= '0') and (ch <= '9');
}
pub fn toDigit(ch: u8) u8 {
    return ch - '0';
}
