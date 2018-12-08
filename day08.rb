input_lines = File.new('day-08-input.txt').readlines
numbers = input_lines.first.split(' ').map(&:to_i)
# numbers = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2".split(' ').map(&:to_i)

def build_tree(numbers)
  stack = [{type: :node, parent: nil}]
  nodes = []

  while !numbers.empty?
    item = stack.pop
    if item[:type] == :node
      num_children, num_metadata = numbers.shift(2)

      node_id = nodes.size
      nodes.push({children: [], metadata: []})

      stack += ([{type: :metadata, parent: node_id}] * num_metadata)
      stack += ([{type: :node, parent: node_id}] * num_children)

      if item[:parent]
        parent = nodes[item[:parent]]
        parent[:children].push(node_id)
      end
    else
      metadata_entry = numbers.shift
      parent = nodes[item[:parent]]
      parent[:metadata].push(metadata_entry)
    end
  end

  nodes
end

def value(node_id, node_list)
  node = node_list[node_id]
  return node[:metadata].reduce(&:+) if node[:children].empty?

  node[:metadata].
    reject {|child_idx| child_idx == 0 || child_idx > node[:children].size }.
    map {|child_idx| node[:children][child_idx - 1] }.
    map {|child_node_id| value(child_node_id, node_list) }.
    reduce(&:+)
end

nodes = build_tree(numbers)
puts "part 1", nodes.map {|n| n[:metadata]}.flatten.reduce(&:+)
puts "part 2", value(0, nodes)