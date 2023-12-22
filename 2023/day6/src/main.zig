const std = @import("std");
// const data = @embedFile("sample.txt");
const data = @embedFile("puz6.txt");

pub fn main() !void {
    var result: usize = 1;
    // try partOne(&result);
    try partTwo(&result);
}

pub fn partOne(sum: *usize) !void {
    var races: [4]Race = undefined;
    var lines = std.mem.tokenizeAny(u8, data, "\n\r");
    var i: usize = 0;
    // while (lines.next()) |m| std.debug.print("{s}\n", .{m});
    const times = lines.next().?;
    const distance = lines.next().?;
    try parseRace(times, &races, true);
    try parseRace(distance, &races, false);
    std.debug.print("{any}\n", .{races});
    while (i < races.len) : (i += 1) races[i].calculateWins(sum);

    std.debug.print("RESULT: {d}\n", .{sum.*});
}

pub fn partTwo(sum: *usize) !void {
    var race: Race = undefined;
    var lines = std.mem.tokenizeAny(u8, data, "\n\r");
    // while (lines.next()) |m| std.debug.print("{s}\n", .{m});
    const times = lines.next().?;
    const distance = lines.next().?;
    try parseRace2(times, &race, true);
    try parseRace2(distance, &race, false);
    std.debug.print("{any}\n", .{race});

    race.calculateWins(sum);

    std.debug.print("RESULT: {d}\n", .{sum.*});
}

pub fn parseRace(text: []const u8, races: []Race, time: bool) !void {
    var nums = std.mem.splitAny(u8, text, " ");
    var i: usize = 0;
    while (nums.next()) |n| {
        const n_ws = std.mem.trim(u8, n, " ");
        if (n.len < 1 or n_ws[0] < '0' or n_ws[0] > '9') continue;
        const num = try std.fmt.parseInt(usize, n_ws, 10);
        switch (time) {
            true => races[i].time = num,
            false => races[i].distance = num,
        }
        i += 1;
    }
}

pub fn parseRace2(text: []const u8, race: *Race, time: bool) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var nums = std.mem.splitAny(u8, text, " ");
    var digits: []const u8 = "";
    var i: usize = 0;
    std.debug.print("{s}\n", .{text});
    while (nums.next()) |n| {
        const n_ws = std.mem.trim(u8, n, " ");
        if (n.len < 1 or n_ws[0] < '0' or n_ws[0] > '9') continue;
        const slices = [2][]const u8{ digits, n_ws };
        digits = try std.mem.join(alloc, "", &slices);
        i += 1;
    }
    const num = try std.fmt.parseInt(usize, digits, 10);
    switch (time) {
        true => race.*.time = num,
        false => race.*.distance = num,
    }
}

pub const Race = struct {
    time: usize,
    distance: usize,

    pub fn calculateWins(self: *Race, result: *usize) void {
        var t = self.time;
        var d = self.distance;
        var speed: usize = 0;
        while (t > 0) {
            t -= 1;
            speed += 1;
            if (t * speed > d) {
                std.debug.print("{d} * {d} = {d} |||| {d} - {d} = {d}\n", .{ t, speed, t * speed, t, speed, t - speed + 1 });
                result.* *= @max(t, speed) - @min(t, speed) + 1;
                return;
            }
        }
    }
};
