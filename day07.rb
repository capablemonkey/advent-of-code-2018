input_lines = File.new('day-07-input.txt').readlines

require 'ap'

def parse_line(line)
  regex = /Step (.) must be finished before step (.) can begin/
  captures = regex.match(line).captures

  {
    :parent => captures[0],
    :child => captures[1]
  }
end

def eligible_children(parent, relationships, history)
  relationships.
    select {|r| r[:parent] == parent }.
    select {|r| !history.include?(r[:child]) }.
    map {|r| r[:child] }.
    select {|c| can_start?(c, relationships, history)}
end

def can_start?(step, relationships, history)
  parents = relationships.
    select{|r| r[:child] == step }.
    map {|r| r[:parent] }

  (parents - history).empty?
end

def step1(relationships)
  all_steps = relationships.map {|r| [r[:parent], r[:child]]}.flatten.uniq

  history = []
  frontier = all_steps.
    select {|step| relationships.none? {|r| r[:child] == step}}.
    sort

  while history.size != all_steps.size
    step = frontier.shift
    history.push(step)

    frontier += eligible_children(step, relationships, history)
    frontier = frontier.uniq.sort
  end

  history
end

relationships = input_lines.map {|line| parse_line(line)}
ap step1(relationships).join('')
