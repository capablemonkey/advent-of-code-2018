input_lines = File.new('day-08-input.txt').readlines
numbers = input_lines.first.split(' ').map(&:to_i)
# numbers = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2".split(' ').map(&:to_i)

def part1(numbers)
  stack = [:node]
  metadata = []

  while !numbers.empty?
    type = stack.pop
    if type == :node
      num_children, num_metadata = numbers.shift(2)
      stack += ([:metadata] * num_metadata)
      stack += ([:node] * num_children)
    else
      metadata_entry = numbers.shift
      metadata.push(metadata_entry)
    end
  end

  metadata.reduce(&:+)
end

puts part1(numbers)