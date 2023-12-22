with open("puz2.txt") as file:
    games = [i.split(':')[1] for i in file.read().strip().split("\n")]


def get_max_values(game):
    red = 0
    blue = 0
    green = 0
    subgames = [i.strip() for i in game.split(";")]
    for subgame in subgames:
        dice = subgame.split(",")
        for die in dice:
            die = die.split()
            value = int(die[0])
            color = die[1]

            if color == 'red':
                red = max(red, value)
            elif color == 'blue':
                blue = max(blue, value)
            elif color == 'green':
                green = max(green, value)

    print(f"GAME: {game}\n RGB: {red},{green},{blue} => {red*green*blue}")
    return red, blue, green


game_sum = 0
for game in games:
    red, blue, green = get_max_values(game)
    game_sum += red * blue * green

print("Part 2: ", game_sum)
