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

  scores
end

# puts highest_score(9, 25)
# puts highest_score(9, 100)
# puts highest_score(10, 1618).max_by {|player, score| score}
puts highest_score(425, 70848).max_by {|player, score| score}[1]
puts highest_score(425, 70848 * 100).max_by {|player, score| score}[1]