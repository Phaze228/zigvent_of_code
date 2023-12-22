const std = @import("std");

const PUZ_INPUT = "./src/puz.txt";

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    var file = try std.fs.cwd().openFile(PUZ_INPUT, .{});
    defer file.close();

    var buf_rdr = std.io.bufferedReader(file.reader());
    var buf_stream = buf_rdr.reader();
    var buf: [2048]u8 = undefined;
    var depth: i32 = 0;
    var old_depth: i32 = -1;
    var sum_count: i32 = -1;
    var window_end: usize = 0;
    var digits: [2048]i32 = undefined;
    while (try buf_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (window_end += 1) {
        const stripped = std.mem.trim(u8, line, "\r");
        // std.debug.print("{any}\n", .{stripped});
        const num = try std.fmt.parseInt(i32, stripped, 10);
        digits[window_end] = num;
    }
    var q: usize = 0;
    for (0.., digits) |p, val| {
        if (val < 0) break;
        depth += val;
        // std.debug.print("VAL: {d} \n", .{val});
        if (p >= 2) {
            if (depth > old_depth) sum_count += 1;
            // std.debug.print("CUR_DEPTH: {d} || OLD_DEPTH: {d} \n\n", .{ depth, old_depth });
            old_depth = depth;
            depth -= digits[q];
            q += 1;
        }
    }

    std.debug.print("\nDepth Increase Count: {d}\n", .{sum_count});
}
