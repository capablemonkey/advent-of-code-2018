require 'ap'

input_lines_pt1 = File.new('day-16-input-pt1.txt').readlines
input_lines_pt2 = File.new('day-16-input-pt2.txt').readlines

def parse(lines)
  samples = []

  while !lines.empty?
    before, instr, after, _ = lines.shift(4).map(&:strip)
    before = before.split(': [')[1].split(', ').map(&:each_char).map(&:first).map(&:to_i)
    instr = instr.split(' ').map(&:to_i)
    after = after.split(':  [')[1].split(', ').map(&:each_char).map(&:first).map(&:to_i)

    samples.push({:before => before, :instr => instr, :after => after})
  end

  samples
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

OPERATIONS = [:addr, :addi, :mulr, :muli, :banr, :bani, :borr, :bori, :setr, :seti, :gtir, :gtri, :gtrr, :eqir, :eqri, :eqrr]

def matches(before, instr, after)
  matches = OPERATIONS.map do |k|
    a = instr[1]
    b = instr[2]
    c = instr[3]
    result = send(k, a, b, c, before.dup)
    result == after ? k : nil
  end

  matches.reject(&:nil?)
end

def part1(samples)
  hits = samples.map do |s|
    matches(s[:before], s[:instr], s[:after]).size >= 3
  end

  hits.count(true)
end

def infer_opcodes(samples)
  opcode_to_matches = Hash.new {|h,x| h[x] = []}
  samples.each do |s|
    opcode = s[:instr][0]
    opcode_to_matches[opcode].push(matches(s[:before], s[:instr], s[:after]))
  end

  opcode_to_possible_operations = opcode_to_matches.map {|opcode, matches| [opcode, matches.reduce {|acc, m| acc & m}] }
  opcodes = {}

  until opcode_to_possible_operations.empty?
    opcode, possible_ops = opcode_to_possible_operations.detect {|opcode, possible_ops| possible_ops.size == 1 }
    opcodes[opcode] = possible_ops.first
    opcode_to_possible_operations = opcode_to_possible_operations.reject {|opc, possible_ops| opc == opcode}
    opcode_to_possible_operations = opcode_to_possible_operations.map {|opc, possible_ops| [opc, possible_ops - [opcodes[opcode]]] }
  end

  opcodes
end

def part2(samples, instructions)
  opcodes = infer_opcodes(samples)
  registers = [0, 0, 0, 0]

  instructions.each do |i|
    instr = opcodes[i[0]]
    registers = send(instr, i[1], i[2], i[3], registers.dup)
  end

  registers[0]
end

samples = parse(input_lines_pt1)
ap part1(samples)

pt2_instructions = input_lines_pt2.map(&:strip).map {|l| l.split(' ').map(&:to_i)}
ap part2(samples, pt2_instructions)