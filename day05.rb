input_lines = File.new('day-05-input.txt').readlines
input = input_lines[0].strip

def react(string)
  k = ""
  ignore_next = false
  string.each_char.each_with_index do |c, idx|
    if ignore_next
      ignore_next = false
      next
    end

    next_char = string[idx + 1]

    if next_char && (c != next_char) && (c.downcase == next_char.downcase)
      ignore_next = true
    else
      k += c
    end
  end

  k
end

def fully_react(string)
  k = react(string)
  return k if k == string
  fully_react(k)
end

def part_2(string)
  ('a'..'z').
    map {|letter| string.gsub(letter, '').gsub(letter.upcase, '')}.
    map {|str| fully_react(str).size}.
    min
end

fully_reacted = fully_react(input)
puts fully_reacted.size
puts part_2(fully_reacted)