const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const day1 = @import("day1/day1.zig");
    try day1.main();

    const day2 = @import("day2/day2.zig");
    try day2.main();

    const day3 = @import("day3/day3.zig");
    try day3.main();
}
