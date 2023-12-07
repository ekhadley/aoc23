const std = @import("std");
const print = std.debug.print;

pub fn getinputs(alloc: std.mem.Allocator, comptime fname: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(fname, .{});
    defer file.close();

    const fsize = try file.getEndPos();
    return try file.readToEndAlloc(alloc, fsize);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    const fname: []const u8 = "d1input.txt";
    const inputstring = try getinputs(alloc, fname);
    
    var inputs = std.mem.split(u8, inputstring, "\n");
    while (inputs.next()) |inp| {
        print("{d}, {}\n\n\n", .{ inp, @TypeOf(inp) });
    }
}
