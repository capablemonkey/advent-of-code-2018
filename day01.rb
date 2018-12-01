input_lines = File.new('day-01-input.txt').readlines
numbers = input_lines.map(&:to_i)

# part 1
sum = numbers.reduce(&:+)
puts sum

# part 2

def prefix_sums(arr, start_value)
  arr.reduce([start_value]) {|sums, x| sums.push(sums.last + x) }
end

def find_dupe_frequency(arr)
  last_frequency = 0
  frequencies_seen = {0 => true}

  while true
    frequencies = prefix_sums(arr, last_frequency).drop(1)
    frequencies.each do |sum|
      return sum if frequencies_seen[sum]
      frequencies_seen[sum] = true
    end

    last_frequency = frequencies.last
  end
end

puts find_dupe_frequency(numbers)