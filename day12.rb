input_lines = File.new('day-12-input.txt').readlines

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

def planted_pot_numbers(state, num_right_pots)
  state.each_char.
    map.with_index { |c, i| c == '#' ? i - num_right_pots : 0 }.
    reject {|p| p == 0}
end

def spread(initial_state, transforms, n_generations)
  left_pad = 10
  right_pad = 200
  padded_initial_state = ("." * left_pad) + initial_state + ("." * right_pad)
  state = padded_initial_state

  n_generations.times do |i|
    # nums = planted_pot_numbers(state, left_pad)
    # puts "#{i}, #{nums.sum}, #{nums.size} , #{nums}\n\n"
    # puts state
    state = next_generation(state, transforms)
  end

  planted_pot_numbers(state, left_pad).sum
end

initial_state = "#.##.##.##.##.......###..####..#....#...#.##...##.#.####...#..##..###...##.#..#.##.#.#.#.#..####..#"
transforms = Hash[input_lines.map {|l| l.strip.split(' => ')}]

puts spread(initial_state, transforms, 20)
# puts spread(initial_state, transforms, 200)
