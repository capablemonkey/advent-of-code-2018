input_lines = File.new('day-06-input.txt').readlines

require 'ap'

# idea:
# start with 400x400 grid
# for each point, fill in closest point by manhattan
# if a coordinate reaches the edge of the grid, then it is unbounded -- filter these out

def manhattan_distance(x1, y1, x2, y2)
  (x1 - x2).abs + (y1 - y2).abs
end

def build_grid(coordinates)
  grid = (0...400).map {|_| [0] * 400}
  grid.map.with_index do |column, y|
    column.map.with_index do |cell, x|
      distances = coordinates.
        map.with_index {|coordinate, i| [i, manhattan_distance(x, y,coordinate[0],coordinate[1])]}.
        sort_by {|i, distance| distance}
      tie = distances[0][1] == distances[1][1]
      closest_coordinate_id = distances[0][0]

      if tie
        -1
      else
        closest_coordinate_id
      end
    end
  end
end

def scrub_infinite_areas(grid, coordinates)
  leftmost_column = grid.first
  rightmost_column = grid.last
  top_row = grid.map(&:first)
  bottom_row = grid.map(&:last)
  infinite_coordinate_ids = (leftmost_column + rightmost_column + top_row + bottom_row).uniq

  grid.map do |column|
    column.map do |cell|
      if infinite_coordinate_ids.include?(cell)
        -2
      else
        cell
      end
    end
  end
end

def count_biggest_area(grid)
  (grid.flatten - [-1, -2]).
    group_by(&:itself).
    max_by {|cluster_id, tallies| tallies.count}.
    last.
    count
end

def find_region_size(coordinates)
  total_distances = (0...400).map do |y|
    (0...400).map do |x|
      coordinates.map {|x_c, y_c| manhattan_distance(x, y, x_c, y_c)}.reduce(&:+)
    end
  end

  total_distances.flatten.count {|d| d < 10_000}
end

def part1(coordinates)
  grid = build_grid(coordinates)
  grid = scrub_infinite_areas(grid, coordinates)
  count_biggest_area(grid)
end

coordinates = input_lines.map {|line| line.strip.split(', ').map(&:to_i)}

ap part1(coordinates)
ap find_region_size(coordinates)
