input_lines = File.new('day-10-input.txt').readlines

require 'ap'

def parse_line(line)
  regex = /position=<([\-|\s]\d+), ([\-|\s]\d+)> velocity=<([\-|\s]\d+), ([\-|\s]\d+)>/
  matches = regex.match(line).captures
  {
    :x => matches[0].strip.to_i,
    :y => matches[1].strip.to_i,
    :v_x => matches[2].strip.to_i,
    :v_y => matches[3].strip.to_i,
  }
end

def state(t, points)
  points.map {|p| [p[:x] + p[:v_x] * t, p[:y] + p[:v_y] * t]}
end

def display(coords)
  (0...250).each do |y|
    row = (0...250).map do |x|
      if coords.include?([x, y])
        "#"
      else
        "."
      end
    end

    puts row.join('')
  end
end

points = input_lines.map {|line| parse_line(line)}

# assumption: we need to wait until all points are non-negative
# so find values of t such that all coordinates are positive
t_for_positive_coords = (0..20_000).select {|t| state(t,points).flatten.all? {|val| val >= 0}}
t_for_positive_coords.each do |t|
  puts
  puts t
  puts
  s = state(t, points)
  display(s)
end
