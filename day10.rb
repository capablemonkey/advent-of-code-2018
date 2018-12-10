input_lines = File.new('day-10-input.txt').readlines

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
    puts (0...250).map {|x| coords.include?([x, y]) ? '#' : '.' }.join('')
  end
end

points = input_lines.map {|line| parse_line(line)}

# assumption: we need to wait until all points are non-negative
t_for_positive_coords = (0..20_000).select {|t| state(t,points).flatten.all? {|val| val >= 0}}
t_for_positive_coords.each do |t|
  puts "\n", t, "\n"
  display(state(t, points))
end