require 'ap'

# input_lines = File.new('day-13-input-sample.txt').readlines
input_lines = File.new('day-13-input.txt').readlines

initial_state = input_lines.map {|l| l.gsub("\n", '')}
puts initial_state

DIRECTIONS = {
  'v' => {x: 0, y: 1},
  '>' => {x: 1, y: 0},
  '^' => {x: 0, y: -1},
  '<' => {x: -1, y: 0}
}

TRACK_TURNS = {
  '^' => {'\\' => '<', '/' => '>'},
  '>' => {'\\' => 'v', '/' => '^'},
  'v' => {'\\' => '>', '/' => '<'},
  '<' => {'\\' => '^', '/' => 'v'},
}

DIRECTIONAL_TURNS = {
  '^' => {:left => '<', :right => '>'},
  '>' => {:left => '^', :right => 'v', },
  'v' => {:left => '>', :right => '<', },
  '<' => {:left => 'v', :right => '^', },
}

def parse_carts(state)
  state.map.with_index do |row, y|
    row.each_char.map.with_index do |cell, x|
      if DIRECTIONS[cell]
        underlying_track = (cell == '>' || cell == '<') ? '-' : '|'
        {
          x: x,
          y: y,
          direction: cell,
          underlying_track: underlying_track,
          next_turn: [:left, :straight, :right]
        }
      else
        nil
      end
    end
  end.flatten.reject(&:nil?)
end

def tick(state, carts)
  carts = carts.sort_by {|c| [c[:y], c[:x]] }

  carts = carts.map do |c|
    next if c[:crashed]

    # determine if direction needs to be changed based on the kind of track the cart is on
    if c[:underlying_track] == '/' || c[:underlying_track] == '\\'
      c[:direction] = TRACK_TURNS[c[:direction]][c[:underlying_track]]
    elsif c[:underlying_track] == '+'
      next_turn = c[:next_turn][0]

      unless next_turn == :straight
        c[:direction] = DIRECTIONAL_TURNS[c[:direction]][next_turn]
      end

      c[:next_turn] = c[:next_turn].rotate
    end

    # based on direction, determine where the next cell is
    direction = DIRECTIONS[c[:direction]]
    next_cell_y = c[:y] + direction[:y]
    next_cell_x = c[:x] + direction[:x]
    next_cell = state[next_cell_y][next_cell_x]

    # handle collision
    if DIRECTIONS.keys.include?(next_cell)
      # find the other cart
      crashee = carts.detect {|k| k[:x] == next_cell_x && k[:y] == next_cell_y}

      # replace the tiles
      state[c[:y]][c[:x]] = c[:underlying_track]
      state[crashee[:y]][crashee[:x]] = crashee[:underlying_track]

      # flag carts as crashed
      c[:crashed] = true
      crashee[:crashed] = true
    else
      # mutate state to move to that cell
      state[c[:y]][c[:x]] = c[:underlying_track]
      c[:underlying_track] = next_cell
      state[next_cell_y][next_cell_x] = c[:direction]
      c[:x] = next_cell_x
      c[:y] = next_cell_y
    end

    c
  end

  # raise if only one cart left
  remaining_carts = carts.reject(&:nil?).reject{ |c| c[:crashed] == true }
  raise "last one! #{remaining_carts.first}" if remaining_carts.size == 1

  [state, remaining_carts]
end

def show(state)
  state.each {|row| puts row }
end

carts = parse_carts(initial_state)

s = initial_state
c = carts

(1..20_000).each do |i|
  puts "turn #{i}"
  s, c = tick(s, c)
  # show(s)
  # ap c
end
