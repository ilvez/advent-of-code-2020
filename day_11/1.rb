require 'amazing_print'
require 'pry'

OCCUPIED = '#'
FREE = 'L'
FLOOR = '.'

def columns_count
  @map.first.size
end

def rows_count
  @map.size
end

def print_map(map)
  map.each { puts(_1.join) }
  ''
end

def occupied?(map, row, column)
  map[row][column] == OCCUPIED
end

def free?(map, row, column)
  map[row][column] == FREE
end

def floor?(map, row, column)
  map[row][column] == FLOOR
end

def occupied_around(map, row, column)
  (row - 1..row + 1).flat_map { |r|
    next if r < 0 || r >= rows_count
    (column - 1..column + 1).map { |c|
      next if c < 0 || c >= columns_count
      next if c == column && r == row
      occupied?(map, r, c)
    }
  }.compact
end

def adjacent_occupied?(map, row, column)
  occupied_around(map, row, column).any?
end

def can_sit?(map, row, column)
  free?(map, row, column) && !adjacent_occupied?(map, row, column)
end

def must_leave?(map, row, column)
  !floor?(map, row, column) && occupied_around(map, row, column).select { true == _1 }.size >= 4
end


def get_map_copy(map)
  Marshal.load(Marshal.dump(map))
end

def resolve_round(current_round)
  next_round = get_map_copy(current_round)
  rows_count.times.each { |row|
    columns_count.times.each { |column|
      if can_sit?(current_round, row, column)
        next_round[row][column] = OCCUPIED
      elsif must_leave?(current_round, row, column)
        next_round[row][column] = FREE
      end
    }
  }
  next_round
end

def import_map(file_name)
  map = []
  IO.readlines(file_name, chomp: true).each do
    map << _1.chars
  end
  map
end

@map = import_map('input')
current_round = @map

loop do
  previous_round = get_map_copy(current_round)
  current_round = resolve_round(previous_round)
  break if current_round == previous_round
end

puts(current_round.flatten.select { _1 == OCCUPIED }.count)
