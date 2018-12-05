input_lines = File.new('day-04-input.txt').readlines

def parse_sleeps(lines)
  regex_shift_begin = /\[\d+-\d+-\d+ \d+:(\d+)\] Guard #(\d+) begins shift/
  regex_fall = /\[\d+-\d+-\d+ \d+:(\d+)\] falls asleep/
  regex_wake = /\[\d+-\d+-\d+ \d+:(\d+)\] wakes up/

  last_guard = 0
  last_asleep = 0
  sleeps = []

  lines.each do |line|
    rsb = regex_shift_begin.match(line)
    rf = regex_fall.match(line)
    rw = regex_wake.match(line)

    if rsb
      last_guard = rsb.captures[1].to_i
    elsif rf
      last_asleep = rf.captures[0].to_i
    else
      woke = rw.captures[0].to_i
      sleeps.push({guard: last_guard, start: last_asleep, end: woke})
    end
  end

  sleeps
end

def slept_most(sleeps)
  sleeps.
    group_by {|s| s[:guard]}.
    map {|guard, sleeps| [guard, sleeps.map {|s| s[:end] - s[:start]}.reduce(&:+)]}.
    max_by {|guard, sum| sum}.
    first
end

def most_freq_minute(sleeps)
  (0...60).
    map {|min| [min, sleeps.count {|s| min >= s[:start] && min < s[:end]}]}.
    max_by {|min, count| count}.
    first
end

def part_1(sleeps)
  guard = slept_most(sleeps)
  sleeps_for_guard = sleeps.select {|s| s[:guard] == guard}
  min = most_freq_minute(sleeps_for_guard)
  guard * min
end

def most_frequent_guard(sleeps)
  sleeps.
    group_by {|s| s[:guard]}.
    map{|guard, tallies| [guard, tallies.count]}.
    max_by {|guard, count| count}
end

def part_2(sleeps)
  min, guard, count = (0...60).
    map { |min| [min, sleeps.select {|s| min >= s[:start] && min < s[:end]}] }.
    map { |min, slps| [min, most_frequent_guard(slps)].flatten }.
    max_by {|min, guard, count| count ? count : 0 }
  min * guard
end

sleeps = parse_sleeps(input_lines)
puts part_1(sleeps)
puts part_2(sleeps)
