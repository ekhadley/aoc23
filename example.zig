const std = @import("std");
const print = std.debug.print;

pub fn afunction(alloc: *std.mem.Allocator) !void {
    const mem = try alloc.alloc(u8, 100);
    defer alloc.free(mem);
    print("{}\n", .{alloc});
}

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    defer alloc.deinit();
    try afunction(&alloc);
}
