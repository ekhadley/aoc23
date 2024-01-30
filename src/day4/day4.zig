const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const ArrayList = std.ArrayList;
const common = @import("common.zig");
const isDigit = common.isDigit;
const digit = common.digit;

const Card = struct {
    id: u64,
    wins: [nwin]u64,
    nums: [nnum]u64,
    points: u64,
    score: u64,
    pub fn init(inp: []const u8) Card {
        const wins: [nwin]u64 = undefined;
        const nums: [nnum]u64 = undefined;

        var card = Card{ .id = 0, .wins = wins, .nums = nums, .points = undefined, .score = undefined };
        var n: u64 = 0;
        var step: usize = 0;
        var i: usize = 0;
        while (i < inp.len) : (i += 1) {
            if (isDigit(inp[i])) n = 10 * n + digit(inp[i]);
            if (n != 0 and (!isDigit(inp[i]) or i == inp.len - 1)) {
                switch (step) {
                    0 => {
                        card.id = n;
                    },
                    1...nwin => {
                        card.wins[step - 1] = n;
                    },
                    nwin + 1...nnum + nwin => {
                        card.nums[step - nwin - 1] = n;
                    },
                    else => {},
                }
                n = 0;
                step += 1;
            }
        }
        card.points = card.getPoints();
        card.score = card.getScore();
        return card;
    }
    pub fn isInWinners(self: *const Card, num: u64) bool {
        for (self.wins) |win| {
            if (num == win) return true;
        }
        return false;
    }
    pub fn getPoints(self: *const Card) u64 {
        var s: u64 = 0;
        for (self.nums) |num| {
            if (self.isInWinners(num)) s += 1;
        }
        return s;
    }
    pub fn getScore(self: *const Card) u64 {
        if (self.points == 0) return 0;
        return std.math.pow(u64, 2, self.points - 1);
    }
};

pub fn totalYield(cards: *ArrayList(Card), cardIdx: usize) u64 {
    var total: u64 = 1;
    for (cardIdx + 1..cardIdx + 1 + cards.items[cardIdx].points) |yieldedCardIdx| {
        total += totalYield(cards, yieldedCardIdx);
    }
    return total;
}

const nwin: usize = 10;
const nnum: usize = 25;
//const nwin: usize = 5;
//const nnum: usize = 8;
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const fname: []const u8 = "input.txt";
    var inputs = try common.getInputIterator(alloc, fname);

    var cards = ArrayList(Card).init(alloc);
    defer cards.deinit();

    var out: u64 = 0;
    while (inputs.next()) |inp| {
        try cards.append(Card.init(inp));
    }
    var yield: u64 = 0;
    for (0..cards.items.len) |i| {
        yield = totalYield(&cards, i);
        out += yield;
        print("{}\nhas {} points and yields {}\n\n", .{ cards.items[i], cards.items[i].points, yield });
    }
    print("{} cards yielded\n", .{out});
    print("there were {} cards\n", .{cards.items.len});
}
