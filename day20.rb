require 'ap'

# string = "ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))"
# string = "WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))"
string = File.new('day-20-input.txt').readlines.first.strip

# string = "ESSWWN(EE|EEE)"

# goal: return longest path
# base case: end of string, | or )
# recursive step: return 1 + travel(string)
# recursive step for paren: travel(string) for each option
def travel(string)
  char = string[0]

  return 0 if char.nil?
  return 0 if char == ')'
  return 0 if char == '|'

  char = string.shift

  if ['N', 'W', 'E', 'S'].include?(char)
    return 1 + travel(string)
  end

  options = []
  if char == '('
    # puts 'starting paren ' + string.join

    until string[0] == ')'
      if string[0..1].join == '|)'
        options.push(:skippable)
        string.shift
      elsif string[0] == '|'
        string.shift
      end

      options.push(travel(string))
    end

    string.shift # remove closing paren
    # puts 'ended paren with options: ' + options.join(',')
  end

  max = options.include?(:skippable) ? 0 : options.max

  return max + travel(string)
end

input = string.each_char.to_a
ap travel(input)
