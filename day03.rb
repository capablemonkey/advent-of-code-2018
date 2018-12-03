input_lines = File.new('day-03-input.txt').readlines

def parse_claim(string)
  regex = /#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/
  matches = regex.match(string).captures
  {
    :id => matches[0],
    :x => matches[1].to_i,
    :y => matches[2].to_i,
    :width => matches[3].to_i,
    :height => matches[4].to_i
  }
end

def each_cell_of(claim)
  (claim[:x]...(claim[:x] + claim[:width])).each do |x|
    (claim[:y]...(claim[:y] + claim[:height])).each do |y|
      yield [x, y]
    end
  end
end

def build_grid(claims)
  grid = (0...1000).map {|_| [0] * 1000}

  claims.each do |claim|
    each_cell_of(claim) {|x, y| grid[y][x] += 1}
  end

  grid
end

def part_1(claims, grid)
  grid.map {|column| column.count {|point| point >= 2}}.reduce(:+)
end

def check_pure(claim, grid)
  each_cell_of(claim) {|x, y| return false if grid[y][x] > 1 }
  true
end

def part_2(claims, grid)
  claims.select {|c| check_pure(c, grid) }
end

claims = input_lines.map { |line| parse_claim(line) }
grid = build_grid(claims)
puts part_1(claims, grid)
puts part_2(claims, grid)