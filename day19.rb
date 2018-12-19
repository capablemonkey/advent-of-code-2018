require 'ap'

input_lines = File.new('day-19-input.txt').readlines

def parse(line)
  instr = line.split(' ')
  {
    op: instr[0],
    a: instr[1].to_i,
    b: instr[2].to_i,
    c: instr[3].to_i
  }
end

def addr(a, b, c, registers)
  registers[c] = registers[a] + registers[b]
  registers
end

def addi(a, b, c, registers)
  registers[c] = registers[a] + b
  registers
end

def mulr(a, b, c, registers)
  registers[c] = registers[a] * registers[b]
  registers
end

def muli(a, b, c, registers)
  registers[c] = registers[a] * b
  registers
end

def banr(a, b, c, registers)
  registers[c] = registers[a] & registers[b]
  registers
end

def bani(a, b, c, registers)
  registers[c] = registers[a] & b
  registers
end

def borr(a, b, c, registers)
  registers[c] = registers[a] | registers[b]
  registers
end

def bori(a, b, c, registers)
  registers[c] = registers[a] | b
  registers
end

def setr(a, b, c, registers)
  registers[c] = registers[a]
  registers
end

def seti(a, b, c, registers)
  registers[c] = a
  registers
end

def gtir(a, b, c, registers)
  registers[c] = a > registers[b] ? 1 : 0
  registers
end

def gtri(a, b, c, registers)
  registers[c] = registers[a] > b ? 1 : 0
  registers
end

def gtrr(a, b, c, registers)
  registers[c] = registers[a] > registers[b] ? 1 : 0
  registers
end

def eqir(a, b, c, registers)
  registers[c] = a == registers[b] ? 1 : 0
  registers
end

def eqri(a, b, c, registers)
  registers[c] = registers[a] == b ? 1 : 0
  registers
end

def eqrr(a, b, c, registers)
  registers[c] = registers[a] == registers[b] ? 1 : 0
  registers
end

def step1(instructions, ip_idx)
  registers = [0, 0, 0, 0, 0, 0]

  loop do |x|
    i = instructions[registers[ip_idx]]
    return registers[0] unless i
    registers = send(i[:op], i[:a], i[:b], i[:c], registers.dup)
    registers[ip_idx] += 1
  end
end

# from https://stackoverflow.com/a/3398195/1108866
require 'prime'
def factors_of(number)
  primes, powers = number.prime_division.transpose
  exponents = powers.map{|i| (0..i).to_a}
  divisors = exponents.shift.product(*exponents).map do |powers|
    primes.zip(powers).map{|prime, power| prime ** power}.inject(:*)
  end
  divisors.sort.map{|div| [div, number / div]}
end

def step2
  # sum = 0
  # r2 = 10_551_298
  # (1..(r2/2)).each do |x|
  #   (1..(r2/2)).each do |y|
  #     sum += x if x * y == r2
  #   end
  # end

  factors_of(10_551_298).map(&:first).sum
end

ip_idx = 4
instructions = input_lines.map{ |l| parse(l.strip) }
ap step1(instructions, ip_idx)
ap step2