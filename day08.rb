input_lines = File.new('day-08-input.txt').readlines
numbers = input_lines.first.split(' ').map(&:to_i)
# numbers = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2".split(' ').map(&:to_i)

def part1(numbers)
  stack = [:node]
  metadata = []

  while !numbers.empty?
    type = stack.pop
    if type == :node
      num_children, num_metadata = numbers.shift(2)
      stack += ([:metadata] * num_metadata)
      stack += ([:node] * num_children)
    else
      metadata_entry = numbers.shift
      metadata.push(metadata_entry)
    end
  end

  metadata.reduce(&:+)
end

def value(node_id, node_list)
  node = node_list[node_id]

  return node[:metadata].reduce(&:+) if node[:children].empty?

  node[:metadata].map do |child_idx|
    if child_idx == 0
      0
    elsif child_idx > node[:children].size
      0
    else
      child_node_id = node[:children][child_idx - 1]
      value(child_node_id, node_list)
    end
  end.reduce(&:+)
end

def part2(numbers)
  stack = [{type: :node, parent: :root}]
  nodes = []

  while !numbers.empty?
    item = stack.pop
    if item[:type] == :node
      node_id = nodes.size
      num_children, num_metadata = numbers.shift(2)
      stack += ([{type: :metadata, parent: node_id}] * num_metadata)
      stack += ([type: :node, parent: node_id] * num_children)
      nodes.push({children: [], metadata: []})

      unless item[:parent] == :root
        parent = nodes[item[:parent]]
        parent[:children].push(node_id)
      end
    else
      metadata_entry = numbers.shift
      parent = nodes[item[:parent]]
      parent[:metadata].push(metadata_entry)
    end
  end

  value(0, nodes)
end

puts part1(numbers.dup)
puts part2(numbers)