const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const common = @import("../common.zig");
//const common = @import("common.zig");
const isDigit = common.isDigit;
const toDigit = common.toDigit;

pub fn numWord(str: []const u8) ?u64 {
    for (0..10) |windex| {
        if (std.mem.indexOf(u8, str, numberWords[windex]) != null) {
            return windex;
        }
    }
    return null;
}
pub fn outerdigits(str: []const u8) u64 {
    var out: u64 = 0;
    const l = str.len;

    var foundr: bool = false;
    var foundl: bool = false;
    //print("inp: {s}\n", .{str});
    for (0..l) |i| {
        if (!foundl) {
            if (isDigit(str[i])) {
                foundl = true;
                out += 10 * toDigit(str[i]);
                //print("found left digit {}\n", .{out});
            }
        }
        if (!foundr) {
            if (isDigit(str[l - i - 1])) {
                foundr = true;
                out += toDigit(str[l - i - 1]);
                //print("found right digit {}\n", .{out});
            }
        }
        if (foundl and foundr) {
            break;
        }
    }
    return out;
}
pub fn outernums(str: []const u8) u64 {
    var out: u64 = 0;
    const l = str.len;

    var foundr: bool = false;
    var foundl: bool = false;
    //print("inp: {s}\n", .{str});
    for (0..l) |i| {
        if (!foundl) {
            if (isDigit(str[i])) {
                foundl = true;
                out += 10 * toDigit(str[i]);
                //print("found left digit {}\n", .{out});
            }
            if (numWord(str[0 .. i + 1])) |foundnum| {
                foundl = true;
                out += 10 * foundnum;
                //print("found left word {}\n", .{out});
            }
        }
        if (!foundr) {
            if (isDigit(str[l - i - 1])) {
                foundr = true;
                out += toDigit(str[l - i - 1]);
                //print("found right digit {}\n", .{out});
            }
            if (numWord(str[l - i - 1 .. l])) |foundnum| {
                foundr = true;
                out += foundnum;
                //print("found right word {}\n", .{out});
            }
        }
        if (foundl and foundr) {
            break;
        }
    }
    return out;
}

const numberWords = [10][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
const fname = "src/day1/input.txt";
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var inputs = try common.getInputIterator(alloc, fname);
    var pt1: u64 = 0;
    var pt2: u64 = 0;
    while (inputs.next()) |inp| {
        pt1 += outerdigits(inp);
        pt2 += outernums(inp);
    }
    print("\n[day 1] part 1: {d}, part 2: {d}", .{ pt1, pt2 });
}
