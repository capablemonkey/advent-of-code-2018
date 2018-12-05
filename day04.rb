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
    map {|s| [s[:guard], s[:end] - s[:start]]}.
    group_by {|guard, durations| guard}.
    map {|guard, durations| [guard, durations.map(&:last).reduce(&:+)]}.
    max_by {|guard, sum| sum}.
    first
end

def most_freq_minute(sleeps)
  (0...60).
    map {|min| [min, sleeps.count {|s| min >= s[:start] && min < s[:end]}]}.
    max_by {|min, count| count}[0]
end

def part_1(sleeps)
  guard = slept_most(sleeps)
  sleeps_for_guard = sleeps.select {|s| s[:guard] == guard}
  min = most_freq_minute(sleeps_for_guard)
  guard * min
end

def part_2(sleeps)
  (0...60).
    map {|min| [min, sleeps.select {|s| min >= s[:start] && min < s[:end]}]}.
    map {|min, slps| [min, slps.group_by {|slp| slp[:guard]}.map{|guard, tallies| [guard, tallies.count]}.max_by {|guard, count| count}]}.
    max_by {|min, k| k[1] }
end

sleeps = parse_sleeps(input_lines)
puts part_1(sleeps)
puts part_2(sleeps)
