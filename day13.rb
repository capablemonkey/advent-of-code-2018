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
    if c[:underlying_track] == '/' || c[:underlying_track] == '\\'
      c[:direction] = TRACK_TURNS[c[:direction]][c[:underlying_track]]
    elsif c[:underlying_track] == '+'
      next_turn = c[:next_turn][0]

      unless next_turn == :straight
        c[:direction] = DIRECTIONAL_TURNS[c[:direction]][next_turn]
      end

      c[:next_turn] = c[:next_turn].rotate
    end

    direction = DIRECTIONS[c[:direction]]
    next_cell_y = c[:y] + direction[:y]
    next_cell_x = c[:x] + direction[:x]
    next_cell = state[next_cell_y][next_cell_x]

    raise "collision at #{next_cell_x},#{next_cell_y}!" if DIRECTIONS.keys.include?(next_cell)

    state[c[:y]][c[:x]] = c[:underlying_track]
    c[:underlying_track] = next_cell
    state[next_cell_y][next_cell_x] = c[:direction]
    c[:x] = next_cell_x
    c[:y] = next_cell_y
    c
  end

  [state, carts]
end

def show(state)
  state.each {|row| puts row }
end

carts = parse_carts(initial_state)

s = initial_state
c = carts

(1..1000).each do |i|
  puts "turn #{i}"
  s, c = tick(s, c)
  show(s)
  # ap c
end
