input_lines = File.new('day-06-input.txt').readlines

# start with 400x400 grid
# for each point, fill in closest point by manhattan
# if a coordinate reaches the edge of the grid, then it is unbounded -- filter these out

def manhattan_distance(x1, y1, x2, y2)
  (x1 - x2).abs + (y1 - y2).abs
end

def grid(width, height)
  (0...width).map do |y|
    (0...height).map do |x|
      yield [x, y]
    end
  end
end

def build_grid(coordinates)
  grid(400, 400) do |x, y|
    distances = coordinates.
      map.with_index {|coordinate, i| [i, manhattan_distance(x, y,coordinate[0],coordinate[1])]}.
      sort_by {|i, distance| distance}

    tie = distances[0][1] == distances[1][1]
    closest_coordinate_id = distances[0][0]

    if tie
      -1 # means ignore this cell
    else
      closest_coordinate_id
    end
  end
end

def scrub_infinite_areas(grid)
  leftmost_column = grid.first
  rightmost_column = grid.last
  top_row = grid.map(&:first)
  bottom_row = grid.map(&:last)
  infinite_coordinate_ids = (leftmost_column + rightmost_column + top_row + bottom_row).uniq

  grid.map do |column|
    column.map do |cell|
      if infinite_coordinate_ids.include?(cell)
        -1 # means ignore this cell
      else
        cell
      end
    end
  end
end

def count_biggest_area(grid)
  (grid.flatten - [-1]).
    group_by(&:itself).
    max_by {|cluster_id, tallies| tallies.count}.
    last.
    count
end

def find_region_size(coordinates)
  total_distances = grid(400, 400) do |x, y|
    coordinates.map {|x_c, y_c| manhattan_distance(x, y, x_c, y_c)}.reduce(&:+)
  end

  total_distances.flatten.count {|d| d < 10_000}
end

def part1(coordinates)
  grid = build_grid(coordinates)
  grid = scrub_infinite_areas(grid)
  count_biggest_area(grid)
end

coordinates = input_lines.map {|line| line.strip.split(', ').map(&:to_i)}

puts part1(coordinates)
puts find_region_size(coordinates)
