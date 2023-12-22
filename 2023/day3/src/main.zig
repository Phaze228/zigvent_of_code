const std = @import("std");

const PUZ_FILE = "./src/puz3.txt";
const RED_LIMIT: u32 = 12;
const GREEN_LIMIT: u32 = 13;
const BLUE_LIMIT: u32 = 14;
const data = @embedFile("puz3.txt");

pub fn main() !void {
    var puz = try std.fs.cwd().openFile(PUZ_FILE, .{});
    defer puz.close();
    std.debug.print("\n", .{});

    var lines = std.mem.tokenizeAny(u8, data, "\n\r");

    var input = std.ArrayList([]const u8).init(std.heap.page_allocator);
    var gears = std.ArrayList(GearRatio).init(std.heap.page_allocator);
    defer input.deinit();
    defer gears.deinit();
    // var buf_rdr = std.io.bufferedReader(puz.reader());
    // var buf_stream = buf_rdr.reader();
    // var buf: [2048]u8 = undefined;
    var sum: u32 = 0;
    while (lines.next()) |line| {
        std.debug.print("{s}\n", .{line});
        try input.append(line);
    }
    std.debug.print("------------\n", .{});

    var i: usize = 0;
    while (i < input.items.len) : (i += 1) {
        var num_start: usize = 0;
        var num_end: usize = 0;
        var k: usize = 0;
        while (k < input.items.len - 1) : (k += 1) {
            if (input.items[i][k] < '0' or input.items[i][k] > '9') {
                num_start = 0;
                num_end = 0;
                continue;
            }
            if (input.items[i][k] <= '9' and input.items[i][k] >= '0') {
                num_start = k;
                while (k < input.items.len and input.items[i][k] <= '9' and input.items[i][k] >= '0') : (k += 1) {
                    num_end = k;
                    // std.debug.print("{c}", .{input.items[i][num_end]});
                }
                // std.debug.print("\nNUMBER: {s} - RANGE: [{d}]{d}:{d}\n", .{ input.items[i][num_start .. num_end + 1], i, num_start, num_end + 1 });
                const num = try std.fmt.parseInt(u32, input.items[i][num_start .. num_end + 1], 10);
                const nearGear = try isAdjacentGear(input.items, i, num_start, num_end, &gears, num);
                if (!nearGear) continue;

                std.debug.print("[{d}], \n", .{num});
            }
        }
    }
    for (gears.items) |g| {
        std.debug.print("{any}\n", .{g});
        sum += g.a * g.b;
    }
    std.debug.print("\n", .{});
    std.debug.print("Result: {d} \n", .{sum});
}
pub fn notANumOrDot(byte: u8) bool {
    if (byte >= '0' and byte <= '9') return false;
    if (byte == '.') return false;
    return true;
}

pub fn isGear(byte: u8) bool {
    if (byte == '*') return true;
    return false;
}

//Part One Function
pub fn isAdjacent(list: [][]const u8, row: usize, col_start: usize, col_end: usize) bool {
    const num_rows = list.len;
    const num_cols = list[0].len;
    const row_as_isize: isize = @intCast(row);
    const col_end_check = if (col_start == col_end) col_end + 1 else col_end;

    var i: isize = -1;
    while (i <= 1) : (i += 1) {
        var j: isize = -1;
        while (j <= 2) : (j += 1) {
            const new_row_isize = row_as_isize + i;
            if (new_row_isize < 0) continue;
            const new_row: usize = @intCast(new_row_isize);
            for (col_start..col_end_check) |col| {
                const col_as_isize: isize = @intCast(col);
                const new_col_isize = col_as_isize + j;
                if (new_col_isize < 0) continue;
                const new_col: usize = @intCast(new_col_isize);
                if (new_row >= 0 and new_row < num_rows and new_col >= 0 and new_col < num_cols) {
                    // std.debug.print("CHECKING: {d}:{d}\n", .{ new_row, new_col });
                    if (notANumOrDot(list[new_row][new_col])) {
                        std.debug.print("{d}:{d} symbol @ {d}:{d} => {c}  ", .{ row, col, new_row, new_col, list[new_row][new_col] });
                        return true;
                    }
                }
            }
        }
    }
    return false;
}

const GearRatio = struct {
    a: u32,
    b: u32,
    x: usize,
    y: usize,

    pub fn changeNum(g: *GearRatio, num: u32, a: bool) void {
        if (a) g.*.a = num;
        if (!a) g.*.b = num;
    }
};

pub fn isAdjacentGear(list: [][]const u8, row: usize, col_start: usize, col_end: usize, gears: *std.ArrayList(GearRatio), num: u32) !bool {
    const num_rows = list.len;
    const num_cols = list[0].len;
    const row_as_isize: isize = @intCast(row);
    const col_end_check = if (col_start == col_end) col_end + 1 else col_end;

    var i: isize = -1;
    while (i <= 1) : (i += 1) {
        var j: isize = -1;
        while (j <= 2) : (j += 1) {
            const new_row_isize = row_as_isize + i;
            if (new_row_isize < 0) continue;
            const new_row: usize = @intCast(new_row_isize);
            for (col_start..col_end_check) |col| {
                const col_as_isize: isize = @intCast(col);
                const new_col_isize = col_as_isize + j;
                if (new_col_isize < 0) continue;
                const new_col: usize = @intCast(new_col_isize);
                if (new_row >= 0 and new_row < num_rows and new_col >= 0 and new_col < num_cols) {
                    if (!isGear(list[new_row][new_col])) continue;
                    std.debug.print("{d}:{d} symbol @ {d}:{d} => {c}  ", .{ row, col, new_row, new_col, list[new_row][new_col] });
                    var index: usize = 99999999999;
                    var a_or_b: bool = false;
                    var added: bool = false;
                    for (gears.items, 0..) |gear, k| {
                        if (gear.x == new_col and gear.y == new_row and gear.a != 0) {
                            std.debug.print("Found match: {any} \n", .{gear});
                            index = k;
                            added = true;
                        }
                    }
                    if (index != 99999999999) gears.items[index].changeNum(num, a_or_b);
                    if (!added) try gears.append(GearRatio{ .a = num, .b = 0, .x = new_col, .y = new_row });
                    return true;
                }
            }
        }
    }
    return false;
}
