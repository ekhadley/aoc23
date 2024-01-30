const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const common = @import("../common.zig");
const isDigit = common.isDigit;
const digit = common.toDigit;

const game = struct {
    nshows: usize,
    id: u64,
    reds: []u64,
    blues: []u64,
    greens: []u64,
    pub fn init(alloc: std.mem.Allocator, input: []const u8) game {
        const nshows: usize = std.mem.count(u8, input, ";") + 1;
        var r = alloc.alloc(u64, nshows) catch unreachable;
        @memset(r, 0);
        var g = alloc.alloc(u64, nshows) catch unreachable;
        @memset(g, 0);
        var b = alloc.alloc(u64, nshows) catch unreachable;
        @memset(b, 0);

        var ID: usize = 0;
        var i: usize = 0;
        var ch: u8 = 0;
        while (true) : (i += 1) {
            ch = input[i];
            if (ch == ':') {
                break;
            }
            if (isDigit(ch)) {
                ID = ID * 10 + digit(ch);
            }
        }
        var ncubes: u64 = 0;
        for (0..nshows) |si| {
            while (true) : (i += 1) {
                if (i == input.len) {
                    break;
                }
                ch = input[i];
                if (ch == ';') {
                    i += 1;
                    break;
                }
                //print("i: {}, ch: {s}, ncubes: {}\n", .{ i, [1]u8{ch}, ncubes });
                if (isDigit(ch)) {
                    ncubes = ncubes * 10 + digit(ch);
                }
                if (ch == 'r') {
                    r[si] = ncubes;
                    ncubes = 0;
                }
                if (ch == 'g') {
                    g[si] = ncubes;
                    ncubes = 0;
                    i += 1;
                }
                if (ch == 'b') {
                    b[si] = ncubes;
                    ncubes = 0;
                }
            }
        }
        return game{ .id = ID, .nshows = nshows, .reds = r, .blues = b, .greens = g };
    }
    pub fn desc(self: *game) void {
        print("ID: {d}:   r{d},   g{d},   b{d}. possible: {}\n\n", .{ self.id, self.reds, self.greens, self.blues, self.possible() });
    }
    pub fn possible(self: *game) bool {
        return (std.mem.max(u64, self.reds) <= 12) and
            (std.mem.max(u64, self.greens) <= 13) and
            (std.mem.max(u64, self.blues) <= 14);
    }
    pub fn power(self: *game) u64 {
        return std.mem.max(u64, self.reds) * std.mem.max(u64, self.greens) * std.mem.max(u64, self.blues);
    }
};

const fname = "src/day2/input.txt";
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var inputs = try common.getInputIterator(alloc, fname);
    var pt1: u64 = 0;
    var pt2: u64 = 0;
    while (inputs.next()) |inp| {
        //print("{s}\n", .{inp});
        var g = game.init(alloc, inp);
        if (g.possible()) {
            pt1 += g.id;
        }
        pt2 += g.power();
    }
    print("\n[day 2] part 1: {d}, part 2: {d}", .{ pt1, pt2 });
}
