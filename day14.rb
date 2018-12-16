require 'ap'

initial_recipes = [3, 7]
recipes_limit = 74501

def add_new_recipes(recipes, elf1_idx, elf2_idx)
  sum = recipes[elf1_idx] + recipes[elf2_idx]
  new_recipes = sum.to_s.each_char.map(&:to_i)

  r = recipes + new_recipes
  elf1_idx_new = (elf1_idx + r[elf1_idx] + 1) % r.size
  elf2_idx_new = (elf2_idx + r[elf2_idx] + 1) % r.size

  [r, elf1_idx_new, elf2_idx_new]
end

def find_scores_at(initial_recipes, n)
  r, e1, e2 = add_new_recipes(initial_recipes, 0, 1)

  until r.size >= n + 10
    r, e1, e2 = add_new_recipes(r, e1, e2)
  end

  r.slice(n, 10)
end

def find_subsequence(initial_recipes, subsequence)
  r, e1, e2 = add_new_recipes(initial_recipes, 0, 1)
  found = false

  until found
    r, e1, e2 = add_new_recipes(r, e1, e2)
    found = (r.last(subsequence.size) == subsequence) || (r.last(subsequence.size + 1).first(subsequence.size) == subsequence)
  end

  return r.size - subsequence.size
end

# puts find_scores_at(initial_recipes, 5)
puts find_scores_at(initial_recipes, recipes_limit)
# puts find_subsequence(initial_recipes, [5,9,4,1,4])
puts find_subsequence(initial_recipes, [0, 7, 4, 5, 0, 1])