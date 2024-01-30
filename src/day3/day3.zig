const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const common = @import("../common.zig");
const isDigit = common.isDigit;
const toDigit = common.toDigit;

pub fn issymbol(ch: u8) bool {
    return ch != '.';
}

pub fn idx(x: usize, y: usize) usize {
    return x + y * (Width + 2);
}

pub fn isBordered(x: usize, y: usize, inp: *const []u8) bool {
    var ch: u8 = 0;
    for ((if (x == 0) x else x - 1)..(if (x == Width - 1) x + 1 else x + 2)) |i| {
        for ((if (y == 0) y else y - 1)..(if (y == Height - 1) y + 1 else y + 2)) |j| {
            ch = inp.*[idx(i, j)];
            if (issymbol(ch)) return true;
        }
    }
    return false;
}

const part = struct {
    x: usize,
    y: usize,
    val: u64,
    pub fn equals(self: *part, other: part) bool {
        return (self.x == other.x) and (self.y == other.y);
    }
    pub fn init(X: usize, Y: usize, Val: u64) part {
        return part{ .x = X, .y = Y, .val = Val };
    }
};

pub fn numberAt(x_: usize, y: usize, inp: *const []u8) part {
    var x: u64 = x_;
    var ch: u8 = '0';
    while (true) : (x -= 1) {
        ch = inp.*[idx(x, y)];
        if (!isDigit(ch)) {
            x += 1;
            break;
        }
        if (x == 0) break;
    }
    var num = part{ .x = x, .y = y, .val = 0 };
    while (true) : (x += 1) {
        ch = inp.*[idx(x, y)];
        if (isDigit(ch)) {
            num.val = num.val * 10 + toDigit(ch);
        } else return num;
    }
}

pub fn ratio(x: usize, y: usize, inp: *const []u8) ?u64 {
    var ch = inp.*[idx(x, y)];
    if (ch != '*') return null;
    var found1 = false;
    var num1 = part.init(0, 0, 0);
    var num2 = part.init(0, 0, 0);
    for ((if (y == 0) y else y - 1)..(if (y == Height - 1) y + 1 else y + 2)) |j| {
        for ((if (x == 0) x else x - 1)..(if (x == Width - 1) x + 1 else x + 2)) |i| {
            ch = inp.*[idx(i, j)];
            if (isDigit(ch)) {
                if (!found1) {
                    num1 = numberAt(i, j, inp);
                    found1 = true;
                } else {
                    num2 = numberAt(i, j, inp);
                    if (!num2.equals(num1)) return num1.val * num2.val;
                }
            }
        }
    }
    return null;
}
const fname = "src/day3/input.txt";
const Width: usize = 140;
const Height: usize = 140;
//const Width: usize = 10;
//const Height: usize = 10;
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const input = try common.getInputString(alloc, fname);

    //print("{s}\n\n", .{input});

    var pt1: u64 = 0;
    var pt2: u64 = 0;
    var ch: u8 = 0;
    var n: u64 = 0;
    var b = false;
    for (0..Height) |y| {
        for (0..Width) |x| {
            ch = input[idx(x, y)];
            if (isDigit(ch)) {
                n = numberAt(x, y, &input).val;
                b = b or isBordered(x, y, &input);
            } else if (n != 0) {
                if (b) {
                    pt1 += n;
                    b = false;
                }
                n = 0;
            }
            if (ratio(x, y, &input)) |r| {
                //print("gear found at [{}, {}] with ratio {}\n\n", .{ x, y, r });
                pt2 += r;
            }
        }
    }
    print("\n[day 3] part 1: {}, part2: {}", .{ pt1, pt2 });
}
