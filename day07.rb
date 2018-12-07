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
  history = []
  all_steps = relationships.map {|r| [r[:parent], r[:child]]}.flatten.uniq
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

def duration(step)
  60 + (step.ord - 'A'.ord + 1)
end

def step2(relationships)
  history = []
  all_steps = relationships.map {|r| [r[:parent], r[:child]]}.flatten.uniq
  frontier = all_steps.
    select {|step| relationships.none? {|r| r[:child] == step}}.
    sort

  time = 0
  workers = []

  while history.size != all_steps.size
    # find workers who have finished
    finished_workers = workers.select {|w| w[:finishes_at] == time}
    finished_steps = finished_workers.map {|w| w[:step] }
    history += finished_steps
    workers = workers - finished_workers

    # calculate frontier
    children = finished_steps.map { |step| eligible_children(step, relationships, history) }.flatten.uniq
    children = children - workers.map {|w| w[:step]} # filter out those already being worked on
    frontier += children
    frontier = frontier.uniq.sort

    # farm out work
    free_workers_count = 10 - workers.size
    steps = frontier.shift(free_workers_count)
    workers += steps.map {|step| {:step => step, :finishes_at => time + duration(step)} }
    frontier = frontier - workers.map {|w| w[:step]} # filter out those already being worked on
    time += 1
  end

  time - 1
end

relationships = input_lines.map {|line| parse_line(line)}
ap step1(relationships).join('')
ap step2(relationships)
