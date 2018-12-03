input_lines = File.new('day-02-input.txt').readlines
words = input_lines.map(&:strip)

# part 1
def count_characters(word)
  word.
    each_char.
    group_by(&:itself).
    map {|letter, occurences| [letter, occurences.size]}
end

def contains_n_of_one_letter?(word, n)
  count_characters(word).any? { |letter, occurences| occurences == n }
end

def checksum(words)
  contains_2_count = words.map {|word| contains_n_of_one_letter?(word, 2) }.count(true)
  contains_3_count = words.map {|word| contains_n_of_one_letter?(word, 3) }.count(true)
  contains_2_count * contains_3_count
end

puts checksum(words)

# part 2

def differ_by_1_char?(word_a, word_b)
  word_a.
    each_char.
    zip(word_b.each_char).
    map {|a, b| a == b}.
    count(false) == 1
end

def find_similar(words)
  words.each do |word_a|
    words.each do |word_b|
      next if word_a == word_b
      return [word_a, word_b] if differ_by_1_char?(word_a, word_b)
    end
  end
end

puts find_similar(words)