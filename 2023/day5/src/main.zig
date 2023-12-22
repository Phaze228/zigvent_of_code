const std = @import("std");
// const data = @embedFile("sample.txt");
const data = @embedFile("puz5.txt");

pub fn main() !void {
    // try partOne();
    try partTwo();
}

pub fn partOne() !void {
    var lines = std.mem.tokenizeAny(u8, data, ":\r\n");
    var curr: Options = undefined;
    var map: Map = undefined;
    var seeds = std.ArrayList(usize).init(std.heap.page_allocator);
    var seed_soil = std.ArrayList(Map).init(std.heap.page_allocator);
    var soil_fert = std.ArrayList(Map).init(std.heap.page_allocator);
    var fert_water = std.ArrayList(Map).init(std.heap.page_allocator);
    var water_light = std.ArrayList(Map).init(std.heap.page_allocator);
    var light_temp = std.ArrayList(Map).init(std.heap.page_allocator);
    var temp_humid = std.ArrayList(Map).init(std.heap.page_allocator);
    var humid_loc = std.ArrayList(Map).init(std.heap.page_allocator);
    std.debug.print("\n", .{});
    defer seeds.deinit();
    defer seed_soil.deinit();
    defer soil_fert.deinit();
    defer fert_water.deinit();
    defer water_light.deinit();
    defer light_temp.deinit();
    defer temp_humid.deinit();
    defer humid_loc.deinit();
    while (lines.next()) |line| {
        var i: usize = 0;
        const trim = std.mem.trimLeft(u8, line, " ");
        var split = std.mem.splitAny(u8, trim, " ");
        var sdr: [3]u64 = undefined;
        while (split.next()) |item| : (i += 1) {
            if (item.len < 1) continue;
            if (item[0] > '9' or item[0] < '0') {
                std.debug.print("{s}\n", .{item});
                curr = std.meta.stringToEnum(Options, item) orelse curr;
                break;
            }
            const num = try std.fmt.parseInt(u64, item, 10);
            if (curr == Options.seeds) {
                try seeds.append(num);
                continue;
            }
            sdr[i] = num;
        }

        std.debug.print("CURRENT: {any}\n", .{curr});
        if (i == 3) {
            map = Map{ .source = sdr[1], .destination = sdr[0], .range = sdr[2] };
            switch (curr) {
                Options.seeds => continue,
                Options.seed_to_soil => try seed_soil.append(map),
                Options.soil_to_fertilizer => try soil_fert.append(map),
                Options.fertilizer_to_water => try fert_water.append(map),
                Options.water_to_light => try water_light.append(map),
                Options.light_to_temperature => try light_temp.append(map),
                Options.temperature_to_humidity => try temp_humid.append(map),
                Options.humidity_to_location => try humid_loc.append(map),
            }
            std.debug.print("{any}\n", .{sdr});
        }

        std.debug.print("---\n", .{});
    }
    var next_map: u64 = 0;
    var min_location: u64 = std.math.maxInt(u64);
    for (seeds.items) |seed| {
        next_map = seed;
        next_map = checkMap(seed_soil.items, &next_map);
        next_map = checkMap(soil_fert.items, &next_map);
        next_map = checkMap(fert_water.items, &next_map);
        next_map = checkMap(water_light.items, &next_map);
        next_map = checkMap(light_temp.items, &next_map);
        next_map = checkMap(temp_humid.items, &next_map);
        next_map = checkMap(humid_loc.items, &next_map);
        std.debug.print("SEED: {d} => LOCATION: {d}\n", .{ seed, next_map });
        min_location = @min(min_location, next_map);
    }
    std.debug.print("LOWEST LOCATION => {d}\n", .{min_location});
}

pub fn partTwo() !void {
    var lines = std.mem.tokenizeAny(u8, data, ":\r\n");
    var curr: Options = undefined;
    var map: Map = undefined;
    var S: Seed = undefined;
    var seeds = std.ArrayList(Seed).init(std.heap.page_allocator);
    var seed_soil = std.ArrayList(Map).init(std.heap.page_allocator);
    var soil_fert = std.ArrayList(Map).init(std.heap.page_allocator);
    var fert_water = std.ArrayList(Map).init(std.heap.page_allocator);
    var water_light = std.ArrayList(Map).init(std.heap.page_allocator);
    var light_temp = std.ArrayList(Map).init(std.heap.page_allocator);
    var temp_humid = std.ArrayList(Map).init(std.heap.page_allocator);
    var humid_loc = std.ArrayList(Map).init(std.heap.page_allocator);
    std.debug.print("\n", .{});
    defer seeds.deinit();
    defer seed_soil.deinit();
    defer soil_fert.deinit();
    defer fert_water.deinit();
    defer water_light.deinit();
    defer light_temp.deinit();
    defer temp_humid.deinit();
    defer humid_loc.deinit();
    while (lines.next()) |line| {
        var i: usize = 0;
        var k: usize = 0;
        const trim = std.mem.trimLeft(u8, line, " ");
        var split = std.mem.splitAny(u8, trim, " ");
        var sdr: [3]u64 = undefined;
        while (split.next()) |item| : (i += 1) {
            if (item.len < 1) continue;
            if (item[0] > '9' or item[0] < '0') {
                // std.debug.print("{s}\n", .{item});
                curr = std.meta.stringToEnum(Options, item) orelse curr;
                break;
            }
            const num = try std.fmt.parseInt(u64, item, 10);
            if (curr == Options.seeds) {
                if (k == 1) {
                    S.range = num;
                    try seeds.append(S);
                    std.debug.print("{any}\n", .{S});
                    k = 0;
                    continue;
                }
                if (k == 0) S.start = num;
                k += 1;
                continue;
            }
            sdr[i] = num;
        }

        // std.debug.print("CURRENT: {any}\n", .{curr});
        if (i == 3) {
            map = Map{ .source = sdr[1], .destination = sdr[0], .range = sdr[2] };
            switch (curr) {
                Options.seeds => continue,
                Options.seed_to_soil => try seed_soil.append(map),
                Options.soil_to_fertilizer => try soil_fert.append(map),
                Options.fertilizer_to_water => try fert_water.append(map),
                Options.water_to_light => try water_light.append(map),
                Options.light_to_temperature => try light_temp.append(map),
                Options.temperature_to_humidity => try temp_humid.append(map),
                Options.humidity_to_location => try humid_loc.append(map),
            }
            // std.debug.print("{any}\n", .{sdr});
        }

        // std.debug.print("---\n", .{});
    }
    std.mem.sort(Seed, seeds.items, {}, cmpSeed);
    var the_maps = [_][]Map{ seed_soil.items, soil_fert.items, fert_water.items, water_light.items, light_temp.items, temp_humid.items, humid_loc.items };
    //Sort maps
    for (the_maps) |m| std.mem.sort(Map, m, {}, cmpRanges);
    // for (the_maps) |m| std.debug.print("{any}\n", .{m});
    var next_map: u64 = 0;
    var j: usize = 0;
    var min_location: u64 = std.math.maxInt(u64);
    for (seeds.items) |seed| {
        var upper_bound: usize = seed.range;
        var k: usize = seed.start;
        // var pre_map: u64 = std.math.maxInt(u64);
        while (k < seed.start + seed.range) : (k += 1) {
            upper_bound = seed.range;
            // std.debug.print("_______\nCurrent K: {d} --- Checking range: {d} - {d}\n", .{ k, seed.start, seed.start + upper_bound });
            next_map = k;
            skipRanges(&the_maps, &next_map, &upper_bound);
            j += 1;
            if (upper_bound >= 1) k += upper_bound - 1;
            min_location = @min(min_location, next_map);
        }
    }
    std.debug.print("CHECKED {d} RANGES\n", .{j});
    std.debug.print("LOWEST LOCATION => {d}\n", .{min_location});
}

const Options = enum {
    seeds,
    seed_to_soil,
    soil_to_fertilizer,
    fertilizer_to_water,
    water_to_light,
    light_to_temperature,
    temperature_to_humidity,
    humidity_to_location,
};

const Map = struct {
    source: u64,
    destination: u64,
    range: u64,

    pub fn inRange(self: *Map, value: u64) bool {
        const max = self.source + self.range;
        if (value >= self.source and value < max) return true;
        return false;
    }

    /// OUTPUT OF FUNCTION
    pub fn getDest(self: *Map, value: u64) u64 {
        return (self.destination + (value - self.source));
    }
};

pub fn checkMap(map: []Map, value: *u64) u64 {
    var i: usize = 0;
    // std.debug.print("START: {d} => END: ", .{value.*});
    while (i < map.len) : (i += 1) {
        if (!map[i].inRange(value.*)) continue;
        value.* = map[i].getDest(value.*);
        break;
    }
    // std.debug.print("{d}\n", .{value.*});
    return value.*;
}

pub fn checkMapRange(map: []Map, value: *u64, range: *usize) void {
    var i: usize = 0;
    // const x = value.*;
    // std.debug.print("{any}\n", .{map});
    while (i < map.len) : (i += 1) {
        if (value.* < map[i].source) {
            range.* = @min(map[i].source - value.*, range.*);
            break;
        }
        if (!map[i].inRange(value.*)) continue;
        range.* = @min(map[i].source + map[i].range - value.*, range.*);
        value.* = map[i].getDest(value.*);
        break;
    }
    // std.debug.print("A => B: {d} => {d} | Range: {d}\n", .{ x, value.*, range.* });
}

pub fn skipRanges(maps: [][]Map, value: *u64, range: *usize) void {
    // const s = value.*;
    for (maps) |map| {
        // std.debug.print("       RANGE BEFORE: {d}\n", .{range.*});
        checkMapRange(map, value, range);
        // std.debug.print("       RANGE AFTER: {d}\n", .{range.*});
    }
    // std.debug.print("{d} => {d} \n", .{ s, value.* });
}

pub fn cmpRanges(context: void, a: Map, b: Map) bool {
    _ = context;
    if (a.source < b.source) return true;
    return false;
}

pub fn cmpSeed(context: void, a: Seed, b: Seed) bool {
    _ = context;
    if (a.start < b.start) return true;
    return false;
}

const Seed = struct {
    start: u64,
    range: u64,
};
