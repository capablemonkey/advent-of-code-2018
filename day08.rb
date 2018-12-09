input_lines = File.new('day-08-input.txt').readlines
numbers = input_lines.first.split(' ').map(&:to_i)
# numbers = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2".split(' ').map(&:to_i)

def sum_metadata(numbers)
  num_children, num_metadata = numbers.shift(2)
  children_sum = num_children.times.map {|c| sum_metadata(numbers)}.reduce(&:+) || 0
  current_sum = numbers.shift(num_metadata).reduce(&:+)
  children_sum + current_sum
end

def calc_value(numbers)
  num_children, num_metadata = numbers.shift(2)
  children_values = num_children.times.map {|c| calc_value(numbers)}
  metadata = numbers.shift(num_metadata)
  return metadata.sum if num_children == 0
  metadata.map {|m| m == 0 ? 0 : children_values[m - 1] }.reject(&:nil?).sum
end

puts sum_metadata(numbers.dup)
puts calc_value(numbers.dup)