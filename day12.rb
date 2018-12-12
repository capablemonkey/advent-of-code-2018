input_lines = File.new('day-12-input.txt').readlines
require 'ap'


## sample
# initial_state = "#..#.#..##......###...###"
# input = """...## => #
# ..#.. => #
# .#... => #
# .#.#. => #
# .#.## => #
# .##.. => #
# .#### => #
# #.#.# => #
# #.### => #
# ##.#. => #
# ##.## => #
# ###.. => #
# ###.# => #
# ####. => #
# """
# transforms = Hash[input.split("\n").map {|l| l.strip.split(' => ')}]

def next_generation(state, transforms)
  n_pots = state.size
  s = state.dup

  chars = s.each_char.map.with_index do |c, i|
    frame = s[i-2] + s[i-1] + c + s[(i+1) % n_pots] + s[(i+2) % n_pots]
    new_pot = transforms[frame]
    new_pot ? new_pot : '.'
  end

  chars.join
end

def part_1(initial_state, transforms)
  padded_initial_state = ("." * 20) + initial_state + ("." * 20)
  next_state = next_generation(padded_initial_state, transforms)
  19.times {|i| next_state = next_generation(next_state, transforms) }

  values = next_state.each_char.map.with_index do |c, i|
    c == '#' ? i - 20 : 0
  end

  values.sum
end

initial_state = "#.##.##.##.##.......###..####..#....#...#.##...##.#.####...#..##..###...##.#..#.##.#.#.#.#..####..#"
transforms = Hash[input_lines.map {|l| l.strip.split(' => ')}]

ap part_1(initial_state, transforms)
