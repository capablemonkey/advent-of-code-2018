def print_state(current_player, marbles, current_marble_idx)
  m = marbles.map.with_index {|value, idx| idx == current_marble_idx ? "(#{value})" : value}
  puts "[#{current_player + 1}] #{m.join(' ')}"
end

def highest_score(players, last_marble)
  scores = Hash.new {|h,k| h[k] = 0}
  current_player = 0
  marbles = [0]
  last_marble_number = 0
  current_marble_idx = 0

  while last_marble_number < last_marble
    new_marble = last_marble_number + 1
    last_marble_number += 1

    # puts new_marble if new_marble % 10_000 == 0

    if new_marble % 23 == 0
      marble_to_remove_idx = current_marble_idx - 7
      scores[current_player] += (new_marble + marbles[marble_to_remove_idx])

      marbles.delete_at(marble_to_remove_idx)
      current_marble_idx = marble_to_remove_idx % (marbles.size + 1)
    else
      new_position = current_marble_idx + 2
      if new_position == (marbles.size + 1)
        new_position = 1
      end

      marbles.insert(new_position, new_marble)
      current_marble_idx = new_position
    end

    # print_state(current_player, marbles, current_marble_idx)

    current_player = (current_player + 1) % players
  end

  scores.max_by {|player, score| score}[1]
end

class LinkedListNode
  attr_accessor :value, :prev, :next

  def initialize(value, prev, next_)
    @value = value
    @prev = prev || self
    @next = next_ || self
  end

  def insert_after(value)
    new_node = LinkedListNode.new(value, self, @next)
    @next.prev = new_node
    @next = new_node
    new_node
  end

  def delete
    @prev.next = @next
    @next.prev = @prev
    @next
  end
end

def highest_score_optimized(players, last_marble)
  scores = Hash.new {|h,k| h[k] = 0}
  last_marble_number = 0
  current_marble = LinkedListNode.new(0, nil, nil)

  while last_marble_number < last_marble
    new_marble = last_marble_number += 1

    if new_marble % 23 == 0
      marble_to_remove = current_marble.prev.prev.prev.prev.prev.prev.prev
      current_player = last_marble_number % players
      scores[current_player] += (new_marble + marble_to_remove.value)
      current_marble = marble_to_remove.delete
    else
      current_marble = current_marble.next.insert_after(new_marble)
    end
  end

  scores.max_by {|player, score| score}[1]
end

# puts highest_score(9, 25)
# puts highest_score(9, 100)
# puts highest_score(10, 1618)
puts highest_score_optimized(425, 70848)
puts highest_score_optimized(425, 70848 * 100)