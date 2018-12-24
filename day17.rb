require 'ap'

input_lines = File.new('day-17-input-sample.txt').readlines
# input_lines = File.new('day-17-input.txt').readlines

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
  grid.each {|r| puts r.slice(450, 100)}
end

def check_bounded_right(grid, x, y)
  return false if grid[y][x].nil?
  return true if grid[y][x] == '#'
  return false if grid[y + 1] && (grid[y + 1][x] == '.')
  return false unless grid[y + 1] && (grid[y + 1][x] == '#' || grid[y + 1][x] == '~')
  return check_bounded_right(grid, x + 1, y)
end

def check_bounded_left(grid, x, y)
  return false if grid[y][x].nil?
  return true if grid[y][x] == '#'
  return false if grid[y + 1] && (grid[y + 1][x] == '.')
  return false unless grid[y + 1] && (grid[y + 1][x] == '#' || grid[y + 1][x] == '~')
  return check_bounded_right(grid, x - 1, y)
end

def drip(grid)
  queue = []
  levels = []
  visited = []
  queue.push([500, 1])

  while !queue.empty?
    x, y = queue.pop
    next if grid[y].nil? || grid[y][x].nil?
    cell = grid[y][x]

    next if cell == '#'

    floor_below = grid[y + 1] && grid[y + 1][x] == '#'
    water_below = grid[y + 1] && grid[y + 1][x] == '~'

    if cell == '.'
      if floor_below || water_below
        left = [x - 1, y]
        right = [x + 1, y]
        queue.push(left)
        queue.push(right)

        if check_bounded_right(grid, x, y) && check_bounded_left(grid, x, y)
          grid[y][x] = '~'
        else
          grid[y][x] = '|'
        end
      else
        # add below
        queue.push([x, y])
        queue.push([x, y + 1])
        grid[y][x] = '|'
      end

      levels.push([x, y])
    elsif cell == '|' && (water_below || floor_below)
      left = [x - 1, y]
      right = [x + 1, y]
      queue.push(left) unless visited.include?(left)
      queue.push(right) unless visited.include?(right)

      if water_below && check_bounded_right(grid, x, y) && check_bounded_left(grid, x, y)
        grid[y][x] = '~'
      end
    end

    # print_grid(grid)

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
    map {|row| row.count("~|") }.
    sum
end

scans = input_lines.map {|line| parse(line.strip)}
grid = build_grid(scans)

grid = drip(grid)
# print_grid(grid)
ap count_water(grid)