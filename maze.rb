require 'byebug'

class Maze
  attr_reader :tiles, :start, :finish
  def initialize(array)
    @tiles = Array.new(array.length) {Array.new(array[0].length)}
    array.each_with_index do |row, x|
      row.chars.each_with_index do |tile, y|
        @tiles[x][y] = Tile.new(y, x, array[x][y])
      end
    end
  end

  def get_start_and_finish
    @tiles.each_with_index do |row, x|
      p row.class
      row.each_with_index do |tile, y|
        @start = tile if tile.value == "S"
        @finish = tile if tile.value == "E"
      end
    end
  end
end

class Tile
  attr_reader :x, :y, :xv, :yv, :value
  def initialize(x, y, value)
    @xv = x
    @yv = y
    @value = value
  end

  def add_neighbors
    @xv = nil
    @yv = nil
  end

  def is_wall?(str)
    str == "*" || str == "|" || str == "+" || str == "-"
  end

  def walkable_neighbours
    neighbors =[]
    unless is_wall?(@value)
      neighbors << $maze.tiles[@yv+1][@xv] if $maze.tiles[@yv+1][@xv].is_walkable?
      neighbors << $maze.tiles[@yv][@xv+1] if $maze.tiles[@yv][@xv+1].is_walkable?
      neighbors << $maze.tiles[@yv-1][@xv] if $maze.tiles[@yv-1][@xv].is_walkable?
      neighbors << $maze.tiles[@yv][@xv-1] if $maze.tiles[@yv][@xv-1].is_walkable?
    end
    neighbors
  end

  def is_walkable?
    @value == ' ' || @value == 'E' || @value == 'S'
  end
end

def maze_solver
  begin
    file = File.open(ARGV[0])
    raise
  rescue
    "File not found. Please check your file name."
  end
  array = []
  file.each_line do |line|
    array << line.chomp
  end
  file.close
  $maze = Maze.new(array)
  $maze.get_start_and_finish
  astar_solve(array)
end

# def solve_maze(maze)
#   start = nil
#   finish = nil
#   maze.each_with_index do |row, i|
#     finish = [i, /E/ =~ row] if /E/.match(row)
#     start = [i, /S/ =~ row] if /S/.match(row)
#   end
#   puts "#{start}: start"
#   puts "#{finish}: finish"
#   pos = finish
#   diff = [(finish[0]- start[0]), (finish[1] - start[1])]
#   diff[0] > 0 ? nsdir = "south" : nsdir = "north"
#   diff[0] > 0 ? ewdir = "west" : ewdir = "east"
#   north_south = diff[0]
#   east_west = diff[1]
#   puts "North/South Distance: #{north_south.to_s + ' ' + nsdir} , East/West Distance: #{east_west.to_s + ' ' + ewdir}"
#   # path = get_path(start, maze)
#   # draw_path(path, maze, pos)
#   #debugger
#   until maze[pos[0]][pos[1]] == 'S' do
#     #debugger
#     path = get_path(pos,maze)
#     path_data = draw_path(path, maze, pos)
#     path = path_data[0]
#     maze = path_data[1]
#     pos = path_data[2]
#     puts maze
#   end
#
#   puts maze
# end
#
# def draw_path(path, maze, pos)
#   # debugger
#   case path[0]
#   when 'north'
#     i = pos[0]
#     j = pos[1]
#     path[1].times do
#       i -= 1
#       maze[i][j] = 'x' unless maze[i][j] == 'S'
#     end
#     pos = [i,j]
#   when 'south'
#     i = pos[0]
#     j = pos[1]
#     path[1].times do
#       i += 1
#       maze[i][j] = 'x' unless maze[i][j] == 'S'
#     end
#     pos = [i,j]
#   when 'east'
#     i = pos[0]
#     j = pos[1]
#     path[1].times do
#       j += 1
#       maze[i][j] = 'x' unless maze[i][j] == 'S'
#     end
#     pos = [i, j]
#   when 'west'
#     i = pos[0]
#     j = pos[1]
#     path[1].times do
#       j -= 1
#       maze[i][j] = 'x' unless maze[i][j] == 'S'
#     end
#     pos = [i,j]
#   end
#   return [path, maze, pos]
# end
#
# def get_path(pos, maze)
#   dirs = Hash.new(0)
#   i = pos[0]
#   j = pos[1]
#   dist = 0
#   #debugger
#   until maze[i-1][j] == '*' ||  maze[i-1][j] == 'x'||  maze[i-1][j] == nil
#     i -= 1
#     dirs['north'] +=1
#   end
#   i = pos[0]
#   j = pos[1]
#   until maze[i+1][j] == '*' || maze[i+1][j] == 'x' ||  maze[i+1][j] == nil
#     i += 1
#     dirs['south'] +=1
#   end
#   i = pos[0]
#   j = pos[1]
#   until maze[i][j+1] == '*' || maze[i][j+1] == 'x' ||  maze[i][j+1] == nil
#     j+= 1
#     dirs['east'] +=1
#   end
#   i = pos[0]
#   j = pos[1]
#   until maze[i][j-1] == '*' || maze[i][j-1] == 'x' ||  maze[i][j-1] == nil
#     j -= 1
#     dirs['west'] +=1
#   end
#
#   dirs.max_by{|k, v| v}
# end



def astar_solve(array)
  maze = Maze.new(array)
  maze.get_start_and_finish
  maze.tiles.each do |row|
    row.each do |tile|
      print tile.value
    end
    print "\n"
  end
  path = astar(maze.start, maze.finish, array)
  system "clear" or system "cls"
  path[1...-1].each do |el|
    array[el.yv][el.xv] = "x"
  end
  puts array
  puts "#{$j} paths atempted before solution found."
end

def astar(start, finish, array)
  queue = []
  queue << [start]
  $j = 1
  until queue.empty?
    array1 = array.clone
    array1.map!.with_index{|el, i| array[i].dup}
    path = queue.shift
    path.each do |el|
      array1[el.yv][el.xv] = "o"
    end
    path.last.walkable_neighbours.each do |el|
      return [path + [el]].flatten if el.value == "E"
      queue << [[path] + [el]].flatten unless queue.any?{|x| x.include?(el)}
      array1[el.yv][el.xv] = "?"
    end
    $j += 1
    k = $j % 4
    system "clear" or system "cls"
    puts array1
    puts "Solving. Please wait" + "." * k
    puts "#{$j} paths atempted so far."
    sleep(0.15)
    queue = queue.sort_by{|el| el.length + ((((el.last.xv - finish.xv)**2) + (el.last.yv - finish.yv)**2)**(0.5))}
    queue.map!(&:flatten)
    queue = queue.uniq
  end
  p "no path"
end

if __FILE__ == $PROGRAM_NAME
  maze_solver
end
