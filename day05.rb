input_lines = File.new('day-05-input.txt').readlines
input = input_lines[0].strip

def react(string)
  input = string.each_char.to_a
  output = [input.shift]

  until input.empty?
    output += input.shift(1)

    if (output[-2]) && (output[-2] != output[-1]) && (output[-2].downcase == output[-1].downcase)
      output.pop(2)
    end
  end

  output.join('')
end

def part_2(string)
  ('a'..'z').
    map {|letter| string.gsub(letter, '').gsub(letter.upcase, '')}.
    map {|str| react(str).size}.
    min
end

reacted = react(input)
puts reacted.size
puts part_2(reacted)