require 'ap'

# input_lines = File.new('day-15-input-sample.txt').readlines
input_lines = File.new('day-15-input.txt').readlines

DIRECTIONS = {
  'v' => {x: 0, y: 1},
  '>' => {x: 1, y: 0},
  '^' => {x: 0, y: -1},
  '<' => {x: -1, y: 0}
}

def parse_units(world)
  units = world.map.with_index do |row, y|
    row.each_char.map.with_index do |cell, x|
      if cell == 'E' || cell == 'G'
        {type: cell, x: x, y: y, attack: 3, hp: 200}
      else
        nil
      end
    end
  end

  units.flatten.reject(&:nil?)
end

# determine which adjacent cell to attack, return nil if none
def find_attack_target(unit, state)
  # determine if in range to attack
  neighbors = DIRECTIONS.values.
    map {|d| [unit[:x] + d[:x], unit[:y] + d[:y]] }.
    map {|x, y| state[:units].detect {|u| u[:x] == x && u[:y] == y} }.
    reject(&:nil?).
    reject {|u| u[:deleted] }

  # find neighbor with fewest hit points
  targets = neighbors.
    reject {|n| unit[:type] == n[:type]}.
    sort_by {|t| t[:hp]} # todo: use multi value sort

  # break ties by "up-down, left-right" order
  ties = targets.partition {|t| t[:hp] == targets.first[:hp]}.first

  return targets.first unless !ties.empty?
  ties.sort_by {|t| [t[:y], t[:x]]}.first
end

# BFS search for all reachable cells
def reachable_cells(x, y, world)
  visited = []
  queue = [[x, y]]

  while !queue.empty?
    start = queue.pop
    neighbors = DIRECTIONS.values.
      map {|d| [start[0] + d[:x], start[1] + d[:y]]}.
      select {|x,y| world[y][x] == '.' }
    new_cells = neighbors - visited
    queue = queue + new_cells
    visited.push(start)
  end

  visited
end

INFINITY = 9e9

def map_each_cell(world)
  world.map.with_index do |row, y|
    row.each_char.map.with_index do |cell, x|
      yield cell, x, y
    end
  end
end

DJ_GRAPH_MEMO = {}

# return shortest path between two points
def djikstra(world, from_x, from_y, to_x, to_y)
  key = [world.join, from_x, from_y].join(',')
  cached_prev = DJ_GRAPH_MEMO[key]

  prev = cached_prev

  unless cached_prev
    nodes = map_each_cell(world) {|cell, x, y| cell == '.' ? [x, y] : nil }.
      flatten(1).
      reject(&:nil?)

    source = [from_x, from_y]
    dist = Hash[nodes.zip([INFINITY].cycle)]
    queue = nodes.dup
    queue.push(source) unless queue.include?(source)
    dist[source] = 0
    prev = {}

    while !queue.empty?
      queue.sort_by! {|node| dist[node]}
      u = queue.shift

      neighbors = DIRECTIONS.values.map {|d| [u[0] + d[:x], u[1] + d[:y]] }
      neighbors = neighbors & nodes

      neighbors.each do |v|
        alt = dist[u] + 1

        if alt < dist[v]
          dist[v] = alt
          prev[v] = u
        end
      end
    end

    DJ_GRAPH_MEMO[key] ||= prev
  end

  path = []
  target = [to_x, to_y]

  return [source] if target == source

  # cannot reach target:
  return nil if prev[target].nil?

  while target
    path.push(target)
    target = prev[target]
  end

  path = path.reverse
  path
end

def deep_copy(state)
  {
    world: state[:world].map(&:dup),
    units: state[:units].map(&:dup)
  }
end

def print_world(world, highlight_coordinates)
  temp_world = world.map(&:dup)
  highlight_coordinates.each do |x,y|
    temp_world[y][x] = '*'
  end
  ap temp_world
end

def determine_move(unit, state)
  # determine all enemies
  enemies = state[:units].
    reject {|u| u[:deleted]}.
    select {|u| u[:type] != unit[:type]}

  if enemies.empty?
    total_hp = state[:units].
      reject {|u| u[:deleted]}.
      map {|u| u[:hp]}.
      sum
    raise "no enemies left! total hp: #{total_hp}"
  end

  # determine cells adjacent to those enemies
  adjacent_cells = enemies.
    map {|e| DIRECTIONS.values.map {|d| [e[:x] + d[:x], e[:y] + d[:y]] } }.
    flatten(1).
    select {|x, y| state[:world][y][x] == '.' }.
    uniq

  # determine which cells it can reach
  reachable_cells = reachable_cells(unit[:x], unit[:y], state[:world])
  candidate_destinations = adjacent_cells & reachable_cells

  # print_world(state[:world], candidate_destinations)

  # find the closest location by shortest parth
  # break location ties by reading order
  distances = candidate_destinations.
    map {|x, y| [[x,y], djikstra(state[:world], unit[:x], unit[:y], x, y).size]}.
    sort_by {|destination, dist| [dist, destination[1], destination[0]]}

  return nil if distances.empty?

  target_location = distances.first[0]

  # find shortest path for target location
  # break tie by taking the step by reading order
  adjacent_dots = DIRECTIONS.values.
    map {|d| [unit[:x] + d[:x], unit[:y] + d[:y]] }.
    select {|x,y| state[:world][y][x] == '.'}

  move = adjacent_dots.
    map {|x, y| [[x,y], djikstra(state[:world], x, y, target_location[0], target_location[1])]}.
    reject {|pos, path| path.nil? }.
    sort_by {|pos, path| [path.size, pos[1], pos[0]]}.
    first

  move[0]
end

def act(unit, state)
  new_state = deep_copy(state)

  return new_state if unit[:deleted] == true
  return new_state if unit[:moved] == true

  target = find_attack_target(unit, new_state)
  new_unit = new_state[:units].detect {|u| u == unit}

  unless target
    move = determine_move(new_unit, new_state)

    if move
      # move one step in that direction & update world
      new_state[:world][new_unit[:y]][new_unit[:x]] = '.'
      new_state[:world][move[1]][move[0]] = new_unit[:type]
      new_unit[:x] = move[0]
      new_unit[:y] = move[1]

      target = find_attack_target(new_unit, new_state)
    end
  end

  if target # then attack
    target[:hp] -= new_unit[:attack]

    # if HP 0, remove unit from world and units list
    if target[:hp] <= 0
      target[:deleted] = true
      new_state[:world][target[:y]][target[:x]] = '.'
    end
  end

  new_unit[:moved] = true
  new_state
end

def reset_moved_flag(state)
  s = deep_copy(state)
  s[:units] = s[:units].map {|u| u[:moved] = false; u}

  s
end

def prune_dead_units(state)
  s = deep_copy(state)
  s[:units] = s[:units].reject {|u| u[:deleted] == true}

  s
end

def next_unit_to_move(state)
  state[:units].
    reject {|u| u[:moved] || u[:deleted]}.
    sort_by {|u| [u[:y], u[:x]]}.
    first
end

def play_until_condition(state)
  s = deep_copy(state)
  round = 0

  (1..1000).each do |round|
    puts "round #{round}"

    s = reset_moved_flag(s)
    s = prune_dead_units(s)
    next_unit = next_unit_to_move(s)

    while !next_unit.nil?
      s = act(next_unit, s)

      continue = yield(s)
      return continue unless continue == true
      # ap s[:world]
      next_unit = next_unit_to_move(s)
    end
  end
end

def part_1(initial_state)
  play_until_condition(initial_state) { true }
end

def part_2(initial_state)
  (4..100).each do |attack|
    ap "attack: #{attack}"

    s = deep_copy(initial_state)
    s[:units] = s[:units].map {|u| u[:attack] = attack if u[:type] == 'E'; u }

    result = play_until_condition(s) do |k|
      if k[:units].any? {|u| u[:deleted] && u[:type] == 'E'}
        :elf_died
      else
        true
      end
    end

    next if result == :elf_died
  end
end

world = input_lines.map(&:strip)
units = parse_units(world)
initial_state = {world: world, units: units}
ap world

part_1(initial_state)
part_2(initial_state)