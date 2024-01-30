const std = @import("std");
const print = std.debug.print;
const testing = std.testing;
const ArrayList = std.ArrayList;
const splitter = std.mem.SplitIterator(u8, .sequence);
const common = @import("common.zig");
const isDigit = common.isDigit;
const digit = common.digit;

const numIterator = struct {
    input: []const u8,
    index: usize,
    pub fn init(input: []const u8) numIterator {
        return numIterator{ .input = input, .index = 0 };
    }
    pub fn next(self: *numIterator) ?u64 {
        var i: usize = self.index;
        var n: ?u64 = null;
        while (i < self.input.len) : (i += 1) {
            if (isDigit(self.input[i])) {
                n = (n orelse 0) * 10 + digit(self.input[i]);
            } else if (n != null or i + 1 == self.input.len) {
                self.index = i + 1;
                return n;
            }
        }
        return null;
    }
};

pub fn getSeeds(almanac: *splitter, alloc: std.mem.Allocator) ArrayList(u64) {
    const line: []const u8 = almanac.next().?;
    var seeds = ArrayList(u64).init(alloc);
    var iter = numIterator.init(line);
    while (iter.next()) |seed| {
        seeds.append(seed) catch unreachable;
    }
    return seeds;
}

const Map = struct {
    ngroups: u64,
    sourceLowers: ArrayList(u64),
    destLowers: ArrayList(u64),
    ranges: ArrayList(u64),
    pub fn init(allocator: std.mem.Allocator) Map {
        const alu64 = ArrayList(u64);
        return Map{ .sourceLowers = alu64.init(allocator), .destLowers = alu64.init(allocator), .ranges = alu64.init(allocator), .ngroups = 0 };
    }
    pub fn out(self: *Map, in: u64) u64 {
        var loweri: u64 = 0;
        var rangei: u64 = 0;
        for (0..self.ngroups) |i| {
            loweri = self.sourceLowers.items[i];
            rangei = self.ranges.items[i];
            if (loweri <= in and in < loweri + rangei) {
                return in - loweri + self.destLowers.items[i];
            }
        }
    }
    pub fn add(self: *Map, srcLow: ?u64, destLow: ?u64, range: ?u64) void {
        self.sourceLowers.append(srcLow.?) catch unreachable;
        self.destLowers.append(destLow.?) catch unreachable;
        self.ranges.append(range.?) catch unreachable;
        self.ngroups += 1;
    }
    pub fn desc(self: *Map) void {
        print("Map{{\n", .{});
        var sl: u64 = 0;
        var dl: u64 = 0;
        var r: u64 = 0;
        for (0..self.ngroups) |i| {
            sl = self.sourceLowers.items[i];
            dl = self.destLowers.items[i];
            r = self.ranges.items[i];
            print("{}..{}->{}..{}\n", .{ sl, sl + r, dl, dl + r });
        }
        print("}}\n", .{});
    }
};

pub fn nextMap(almanac: *splitter, allocator: std.mem.Allocator) Map {
    var map = Map.init(allocator);
    while (almanac.next()) |line| {
        if (line.len > 2 and !std.mem.containsAtLeast(u8, line, 1, ":")) {
            print("line: {s}\n", .{line});
            var iter = numIterator.init(line);
            print("{?d}\n", .{iter.next()});
            print("{?d}\n", .{iter.next()});
            print("{?d}\n", .{iter.next()});
            iter = numIterator.init(line);
            map.add(iter.next(), iter.next(), iter.next());
        } else if (map.ngroups != 0) return map;
    }
    unreachable;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const fname: []const u8 = "inputtest.txt";
    var almanac = try getInputIterator(alloc, fname);

    const seeds = getSeeds(&almanac, alloc);
    var seed2soil = nextMap(&almanac, alloc);
    var soil2fert = nextMap(&almanac, alloc);
    var fert2water = nextMap(&almanac, alloc);
    var water2light = nextMap(&almanac, alloc);
    var light2temp = nextMap(&almanac, alloc);
    var temp2humid = nextMap(&almanac, alloc);
    var humid2loc = nextMap(&almanac, alloc);

    print("{d}, {}\n", .{ seeds.items, @TypeOf(seeds.items) });
    seed2soil.desc();
    soil2fert.desc();
    fert2water.desc();
    water2light.desc();
    light2temp.desc();
    temp2humid.desc();
    humid2loc.desc();
}
