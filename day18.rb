require 'ap'

input_lines = File.new('day-18-input.txt').readlines

# [[-1, -1], [-1, 0], ... [1, 1]]
DIRECTIONS = [-1, 0, 1].repeated_permutation(2).to_a - [[0,0]]

def safe_access(grid, x, y)
  return nil if x < 0
  return nil if y < 0
  return nil if y >= grid.size
  return nil if x >= grid.first.size

  grid[y][x]
end

def step(grid)
  new_grid = grid.dup.map {|r| r.dup}

  (0...grid.size).each do |y|
    (0...(grid.first.size)).each do |x|
      neighbors = DIRECTIONS.
        map {|delta_x, delta_y| safe_access(grid, x + delta_x, y + delta_y)}.
        reject(&:nil?)

      if grid[y][x] == '.' && neighbors.count('|') >= 3
        new_grid[y][x] = '|'
      elsif grid[y][x] == '|' && neighbors.count('#') >= 3
        new_grid[y][x] = '#'
      elsif grid[y][x] == '#'
        new_grid[y][x] = '.' unless neighbors.include?('#') && neighbors.include?('|')
      end
    end
  end

  new_grid
end

grid = input_lines.map(&:strip)
grid.each {|line| puts line}
(0...10).each do |i|
  puts
  grid = step(grid)
  grid.each {|line| puts line}
  trees = grid.flatten.join.each_char.to_a.count('|')
  lumber = grid.flatten.join.each_char.to_a.count('#')
  puts "#{i}: #{trees}, #{lumber}"
end
