input_lines = File.new('day-03-input.txt').readlines

def parse_claim(string)
  regex = /#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/
  matches = regex.match(string).captures
  {
    :id => matches[0],
    :x => matches[1].to_i,
    :y => matches[2].to_i,
    :width => matches[3].to_i,
    :height => matches[4].to_i
  }
end

# Part 1

def claim_includes?(x, y, claim)
  return true if (
    x >= claim[:x] &&
    x < claim[:x] + claim[:width] &&
    y >= claim[:y] &&
    y < claim[:y] + claim[:height]
  )
  false
end

def count_claims_at(x, y, claims)
  claims.map {|claim| claim_includes?(x, y, claim)}.count(true)
end

def part_1(claims)
  intersect_count = 0

  (0...1000).each do |x|
    (0...1000).each do |y|
      intersect_count += 1 if count_claims_at(x, y, claims) >= 2
    end
  end

  intersect_count
end

# Part 2

def check_pure(claim, claims)
  (claim[:x]...(claim[:x] + claim[:width])).each do |x|
    (claim[:y]...(claim[:y] + claim[:height])).each do |y|
      return false if count_claims_at(x, y, claims) > 1
    end
  end
  true
end

def part_2(claims)
  claims.select {|c| check_pure(c, claims) }
end

claims = input_lines.map { |line| parse_claim(line) }
puts part_1(claims)
puts part_2(claims)