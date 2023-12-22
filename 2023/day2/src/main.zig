const std = @import("std");

const PUZ_FILE = "./src/puz2.txt";
const RED_LIMIT: u32 = 12;
const GREEN_LIMIT: u32 = 13;
const BLUE_LIMIT: u32 = 14;

pub fn main() !void {
    var puz = try std.fs.cwd().openFile(PUZ_FILE, .{});
    defer puz.close();
    std.debug.print("\n", .{});

    var buf_rdr = std.io.bufferedReader(puz.reader());
    var buf_stream = buf_rdr.reader();
    var buf: [2048]u8 = undefined;
    var sum: u32 = 0;
    while (try buf_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const stripped = std.mem.trim(u8, line, "\r");
        const game_stripped = std.mem.trim(u8, stripped, "Game ");
        var colon_split = std.mem.split(u8, game_stripped, ":");
        const colon_index = std.mem.indexOf(u8, game_stripped, ":").?;
        var trim_colon = game_stripped[colon_index + 1 ..];
        const cur_game = try std.fmt.parseInt(u32, colon_split.next().?, 10);
        std.debug.print("{s}\n", .{stripped});
        try getColor(trim_colon, cur_game, &sum);
    }
    std.debug.print("Result: {d} \n", .{sum});
}

pub const Colors = enum { r, b, g };
pub const Squares = struct {
    color: Colors,
    value: u32,
    pub fn getColor(text: []const u8) Squares {
        return std.meta.stringToEnum(Squares, text);
    }
};

pub fn getColor(text: []const u8, game_id: u32, sum: *u32) !void {
    _ = game_id;
    var semi_split = std.mem.split(u8, text, ";");
    var red: u32 = 0;
    var green: u32 = 0;
    var blue: u32 = 0;
    while (semi_split.next()) |round| {
        var split_by_colors = std.mem.split(u8, round, ",");
        // var red = Squares{ .color = Colors.red, .value = 0 };
        // var green = Squares{ .color = Colors.green, .value = 0 };
        // var blue = Squares{ .color = Colors.blue, .value = 0 };
        while (split_by_colors.next()) |colors| {
            const remove_left_spaces = std.mem.trimLeft(u8, colors, " ");
            var split_space = std.mem.split(u8, remove_left_spaces, " ");
            const n = split_space.next().?;
            const c = split_space.next().?[0..1];
            const num = try std.fmt.parseInt(u32, n, 10);
            const color = std.meta.stringToEnum(Colors, c);
            while (color) |col| {
                switch (col) {
                    Colors.r => red = @max(num, red),
                    Colors.g => green = @max(num, green),
                    Colors.b => blue = @max(num, blue),
                }
                break;
            }
        }

        // std.debug.print(" RBG: {d}, {d}, {d}, \n _______\n", .{ red.value, blue.value, green.value });
    }
    const power = (red * green * blue);
    sum.* += power;
    std.debug.print("  RGB: {d}, {d}, {d} => {d} \n", .{ red, green, blue, power });
    // std.debug.print("Added game_id: {d}\n", .{game_id});
}
