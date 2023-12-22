const std = @import("std");

// const data = @embedFile("sample.txt");
const data = @embedFile("puz4.txt");

pub fn main() !void {
    var sum: u32 = 0;

    try partTwo(&sum);
    std.debug.print("\nSum: {d}\n", .{sum});
    //discard game num
    // while (wins_nums.next()) |game| {
    //     std.debug.print("{s}\n", .{game});
    // }
}

pub fn partOne(sum: *u32) !void {
    var cards = std.mem.tokenizeAny(u8, data, "\n\r");
    while (cards.next()) |game| {
        var win = std.ArrayList(u32).init(std.heap.page_allocator);
        var num = std.ArrayList(u32).init(std.heap.page_allocator);
        defer win.deinit();
        defer num.deinit();
        var match_count: u32 = 0;
        var wins_nums = std.mem.splitAny(u8, game, ":|");
        //Discard Card Number
        _ = wins_nums.next();
        const wins = wins_nums.next().?;
        var winning_numbers = std.mem.splitAny(u8, wins, " ");
        while (winning_numbers.next()) |x| {
            // for (x) |c| std.debug.print("{d}-", .{c});
            // std.debug.print("  || {s}\n", .{x});
            if (x.len < 1) continue;
            if (x[0] > '9' or x[0] < '0') continue;
            const n = try std.fmt.parseInt(u32, x, 10);
            try win.append(n);
        }
        const nums = wins_nums.next().?;
        var played_nums = std.mem.splitAny(u8, nums, " ");
        while (played_nums.next()) |x| {
            if (x.len < 1) continue;
            if (x[0] > '9' or x[0] < '0') continue;

            const n = try std.fmt.parseInt(u32, x, 10);
            try num.append(n);
        }
        for (win.items) |x| {
            for (num.items) |y| {
                if (x != y) continue;
                match_count += 1;
            }
        }
        if (match_count == 0) continue;
        const p = std.math.pow(u32, 2, match_count - 1);
        // std.debug.print("CURRENT MATCH COUNT: {d} -- TOTAL: {d} \n", .{ match_count, p });
        sum.* += p;
        match_count = 0;
    }
}

const Card = struct {
    id: u32,
    card_count: u32,
    win_count: u32,
};
pub fn partTwo(sum: *u32) !void {
    var card_list = std.ArrayList(Card).init(std.heap.page_allocator);
    defer card_list.deinit();
    var cards = std.mem.tokenizeAny(u8, data, "\n\r");
    while (cards.next()) |game| {
        var win = std.ArrayList(u32).init(std.heap.page_allocator);
        var num = std.ArrayList(u32).init(std.heap.page_allocator);
        defer win.deinit();
        defer num.deinit();
        var match_count: u32 = 0;
        var wins_nums = std.mem.splitAny(u8, game, ":|");
        //Discard Card Number
        const card_game = wins_nums.next().?;
        const game_id = std.mem.trim(u8, card_game, "Card ");
        const card_id = try std.fmt.parseInt(u32, game_id, 10);
        const wins = wins_nums.next().?;
        var winning_numbers = std.mem.splitAny(u8, wins, " ");
        while (winning_numbers.next()) |x| {
            if (x.len < 1) continue;
            if (x[0] > '9' or x[0] < '0') continue;
            const n = try std.fmt.parseInt(u32, x, 10);
            try win.append(n);
        }
        const nums = wins_nums.next().?;
        var played_nums = std.mem.splitAny(u8, nums, " ");
        while (played_nums.next()) |x| {
            if (x.len < 1) continue;
            if (x[0] > '9' or x[0] < '0') continue;

            const n = try std.fmt.parseInt(u32, x, 10);
            try num.append(n);
        }
        for (win.items) |x| {
            for (num.items) |y| {
                if (x != y) continue;
                match_count += 1;
            }
        }
        try card_list.append(Card{ .id = card_id, .card_count = 1, .win_count = match_count });
        match_count = 0;
    }
    for (card_list.items, 0..) |c, i| {
        for (0..c.win_count + 1) |k| {
            if (i + k > card_list.items.len - 1 or k == 0) continue;
            card_list.items[i + k].card_count += 1 * c.card_count;
        }
    }
    std.debug.print("\n", .{});
    for (card_list.items) |c| {
        std.debug.print("{any}\n", .{c});
        sum.* += c.card_count;
    }
}
