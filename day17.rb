require 'ap'

input_lines = File.new('day-17-input-sample.txt').readlines
input_lines = File.new('day-17-input.txt').readlines

DIRECTIONS = {
  :down => {x: 0, y: 1},
  :right => {x: 1, y: 0},
  :left => {x: -1, y: 0}
}

def parse(string)
  regex = /(x|y)=(\d+), (x|y)=(\d+)\.\.(\d+)/
  matches = regex.match(string).captures
  {
    matches[0] => matches[1].to_i,
    matches[2] => (matches[3].to_i)..(matches[4].to_i)
  }
end

def build_grid(scans)
  # x_max = scans.map {|scan| scan["x"].is_a?(Range) ? scan["x"].max : scan["x"] }.max
  y_max = scans.map {|scan| scan["y"].is_a?(Range) ? scan["y"].max : scan["y"] }.max
  x_max = 5000

  grid = (y_max + 1).times.map { |_| Array.new(x_max).fill('.').join() }
  scans.each do |scan|
    if scan["y"].is_a?(Range)
      scan["y"].each {|y| grid[y][scan["x"]] = '#'}
    else
      scan["x"].each {|x| grid[scan["y"]][x] = '#'}
    end
  end

  grid[0][500] = '+'

  grid
end

def print_grid(grid)
  puts
  grid.each {|r| puts r.slice(400, 200)}
end

def check_bounded(grid, x, y)
  return false if grid[y][x].nil?
  return true if grid[y][x] == '#'
  return false unless grid[y + 1]
  below = grid[y + 1][x]
  return false if below == '.'
  return false unless below == '#' || below == '~'
  nil
end

def check_bounded_right(grid, x, y)
  result = check_bounded(grid, x, y)
  return result.nil? ? check_bounded_right(grid, x + 1, y) : result
end

def check_bounded_left(grid, x, y)
  result = check_bounded(grid, x, y)
  return result.nil? ? check_bounded_left(grid, x - 1, y) : result
end

def drip(grid)
  queue = []
  visited = []
  queue.push([500, 1])

  while !queue.empty?
    x, y = queue.pop
    next if grid[y].nil? || grid[y][x].nil?

    cell = grid[y][x]
    next if cell == '#'

    floor_below = grid[y + 1] && grid[y + 1][x] == '#'
    water_below = grid[y + 1] && grid[y + 1][x] == '~'
    left = [x - 1, y]
    right = [x + 1, y]

    if cell == '.' && (floor_below || water_below)
      queue.push(left)
      queue.push(right)

      if check_bounded_right(grid, x, y) && check_bounded_left(grid, x, y)
        grid[y][x] = '~'
      else
        grid[y][x] = '|'
      end
    elsif cell == '.'
      queue.push([x, y])
      queue.push([x, y + 1])
      grid[y][x] = '|'
    elsif cell == '|' && (water_below || floor_below)
      queue.push(left) unless visited.include?(left)
      queue.push(right) unless visited.include?(right)

      if check_bounded_right(grid, x, y) && check_bounded_left(grid, x, y)
        grid[y][x] = '~'
        queue.push(left)
        queue.push(right)
      end
    elsif cell == '|' && (right == '~' || left == '~')
      grid[y][x] = '~'
    end

    visited.push([x, y])
  end

  grid
end

def count_water(grid)
  rows_with_wall_idx = grid.
    map.with_index {|row, idx| [row.include?('#'), idx]}.
    select {|keep, idx| keep == true}.
    map {|keep, idx| idx}

  first = rows_with_wall_idx.min
  last = rows_with_wall_idx.max

  grid.slice(first, last - first + 1).
    map {|row| row.count("|~") }.
    sum
end

scans = input_lines.map {|line| parse(line.strip)}
grid = build_grid(scans)

grid = drip(grid)
print_grid(grid)
ap count_water(grid)