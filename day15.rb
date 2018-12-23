require 'ap'

input_lines = File.new('day-15-input-sample.txt').readlines
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

  # ap :neighbors
  # ap neighbors
  # ap :targets
  # ap targets

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

# return shortest path between two points
def djikstra(world, from_x, from_y, to_x, to_y)
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

  # w = world.dup
  # nodes.each do |x, y|
  #   world[y][x] = dist[[x,y]].to_s
  # end
  # ap w

  # ap prev
  # ap dist
  # ap queue

  path = []
  target = [to_x, to_y]

  return [source] if target == source

  # raise "cannot reach target! #{target}" if prev[target].nil?
  # cannot reach target:
  return nil if prev[target].nil?

  while target
    path.push(target)
    target = prev[target]
  end

  path = path.reverse

  # w = world.dup
  # path.each.with_index do |node, i|
  #   world[node[1]][node[0]] = i.to_s
  # end
  # ap w

  path
end

def deep_copy(state)
  {
    world: state[:world].map(&:dup),
    units: state[:units].map(&:dup)
  }
end

def act(unit, state)
  new_state = deep_copy(state)

  return new_state if unit[:deleted] == true
  return new_state if unit[:moved] == true

  target = find_attack_target(unit, new_state)

  ap "unit"
  ap unit
  ap "target"
  ap target

  new_unit = new_state[:units].detect {|u| u == unit}

  if target # then attack
    target[:hp] -= new_unit[:attack]

    # if HP 0, remove unit from world and units list
    if target[:hp] <= 0
      target[:deleted] = true
      new_state[:world][target[:y]][target[:x]] = '.'
    end
  else
    # determine all enemies
    enemies = new_state[:units].
      reject {|u| u[:deleted]}.
      select {|u| u[:type] != new_unit[:type]}

    if enemies.empty?
      total_hp = new_state[:units].
        reject {|u| u[:deleted]}.
        map {|u| u[:hp]}.
        sum
      raise "no enemies left! total hp: #{total_hp}"
    end

    # ap :enemies
    # ap enemies

    # determine cells adjacent to those enemies
    adjacent_cells = enemies.
      map {|e| DIRECTIONS.values.map {|d| [e[:x] + d[:x], e[:y] + d[:y]] } }.
      flatten(1).
      select {|x, y| new_state[:world][y][x] == '.' }.
      uniq

    # determine which cells it can reach
    reachable_cells = reachable_cells(new_unit[:x], new_unit[:y], new_state[:world])
    candidate_destinations = adjacent_cells & reachable_cells

    # preview_world = new_state[:world].map(&:dup)
    # # show possible locations
    # candidate_destinations.each do |x,y|
    #   preview_world[y][x] = '*'
    # end
    # ap preview_world

    # find the closest location by shortest parth
    # break location ties by reading order
    distances = candidate_destinations.
      map {|x, y| [[x,y], djikstra(new_state[:world], new_unit[:x], new_unit[:y], x, y).size]}.
      sort_by {|destination, dist| [dist, destination[1], destination[0]]}

    # ap "distances to candidate destinations"
    # ap distances

    if distances.empty?
      new_unit[:moved] = true
      return new_state
    end

    target_location = distances.first[0]

    # ap "target"
    # ap target_location

    # find shortest path for target location
    # break tie by taking the step by reading order
    adjacent_dots = DIRECTIONS.values.
      map {|d| [new_unit[:x] + d[:x], new_unit[:y] + d[:y]] }.
      select {|x,y| state[:world][y][x] == '.'}

    move = adjacent_dots.
      map {|x, y| [[x,y], djikstra(state[:world], x, y, target_location[0], target_location[1])]}.
      reject {|pos, path| path.nil? }.
      sort_by {|pos, path| [path.size, pos[1], pos[0]]}.
      first

    raise 'no moves left' unless move

    move = move[0]

    # ap "move"
    # ap move

    # move one step in that direction
    # update world
    new_state[:world][new_unit[:y]][new_unit[:x]] = '.'
    new_state[:world][move[1]][move[0]] = new_unit[:type]
    new_unit[:x] = move[0]
    new_unit[:y] = move[1]

    target = find_attack_target(new_unit, new_state)

    if target # then attack
      target[:hp] -= new_unit[:attack]

      # if HP 0, remove unit from world and units list
      if target[:hp] <= 0
        target[:deleted] = true
        new_state[:world][target[:y]][target[:x]] = '.'
      end
    end
  end

  new_unit[:moved] = true
  # ap "new unit"
  # ap new_unit

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

def part_1(world)
  units = parse_units(world)
  initial_state = {world: world, units: units}
  round = 0

  ap world

  s = deep_copy(initial_state)

  (1..1000).each do |round|
    puts "round #{round}"

    s = reset_moved_flag(s)
    s = prune_dead_units(s)

    next_unit = s[:units].
      reject {|u| u[:moved] || u[:deleted]}.
      sort_by {|u| [u[:y], u[:x]]}.
      first

    while !next_unit.nil?
      s = act(next_unit, s)
      next_unit = s[:units].
        reject {|u| u[:moved] || u[:deleted]}.
        sort_by {|u| [u[:y], u[:x]]}.
        first
      ap next_unit
      ap :units
      ap s[:units].reject {|u| u[:deleted]}
      ap s[:world]
    end
  end
end


world = input_lines.map(&:strip)
part_1(world)
