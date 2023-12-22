const std = @import("std");

const PUZ_INPUT = "./src/puz.txt";

const Direction = enum {
    up,
    down,
    forward,
    back,
    none,

    pub fn parse(d: *Direction, cmd: []const u8) void {
        if (std.mem.eql(u8, cmd, "up")) d.* = Direction.up;
        if (std.mem.eql(u8, cmd, "down")) d.* = Direction.down;
        if (std.mem.eql(u8, cmd, "forward")) d.* = Direction.forward;
        if (std.mem.eql(u8, cmd, "back")) d.* = Direction.back;
    }
};

const Point = struct {
    x: i32,
    y: i32,
    aim: i32,

    pub fn updateVal(d: *Point, command: Direction, val: i32) void {
        switch (command) {
            Direction.up => d.*.aim -= val,
            Direction.down => d.*.aim += val,
            Direction.forward => {
                d.*.x += val;
                d.*.y += val * d.*.aim;
            },
            Direction.back => {
                d.*.x -= val;
                d.*.y -= val * d.*.aim;
            },
            else => return,
        }
    }
};

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    var file = try std.fs.cwd().openFile(PUZ_INPUT, .{});
    defer file.close();

    var buf_rdr = std.io.bufferedReader(file.reader());
    var buf_stream = buf_rdr.reader();
    var buf: [2048]u8 = undefined;
    var idx: usize = 0;
    var p: Point = Point{ .x = 0, .y = 0, .aim = 0 };
    var cmd = Direction.none;
    while (try buf_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (idx += 1) {
        const stripped = std.mem.trim(u8, line, "\r");
        var split = std.mem.split(u8, stripped, " ");
        cmd.parse(split.next().?);
        const num = try std.fmt.parseInt(i32, split.next().?, 10);
        p.updateVal(cmd, num);
    }

    std.debug.print("CURRENT LOCATION: {d}\n", .{p.x * p.y});
}
