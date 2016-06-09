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
    Tile.maze = self
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
  def maze
    @@maze
  end

  def self.maze=(maze)
    @@maze = maze
  end

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
      neighbors << @@maze.tiles[@yv+1][@xv] if @@maze.tiles[@yv+1][@xv].is_walkable?
      neighbors << @@maze.tiles[@yv][@xv+1] if@@maze.tiles[@yv][@xv+1].is_walkable?
      neighbors << @@maze.tiles[@yv-1][@xv] if @@maze.tiles[@yv-1][@xv].is_walkable?
      neighbors << @@maze.tiles[@yv][@xv-1] if @@maze.tiles[@yv][@xv-1].is_walkable?
    end
    neighbors
  end

  def is_walkable?
    @value == ' ' || @value == 'E' || @value == 'S'
  end
end

class Maze_solver
  attr_accessor :maze, :maze_array, :attempts
  def initialize(maze, maze_array)
    @maze = maze
    @maze_array = maze_array
  end
  def self.parse_maze(file_name)
    begin
      file = File.open(file_name)
      raise
    rescue
      "File not found. Please check your file name."
    end
    maze_array = []
    file.each_line do |line|
      maze_array << line.chomp
    end
    file.close
    maze = Maze.new(maze_array)
    Maze_solver.new(maze, maze_array)
  end

  def solve_maze
    astar_solve(@maze_array)
  end

  def astar_solve(array)
    @maze.get_start_and_finish
    @maze.tiles.each do |row|
      row.each do |tile|
        print tile.value
      end
      print "\n"
    end
    path = astar(@maze.start, @maze.finish, @maze_array)
    system "clear" or system "cls"
    path[1...-1].each do |el|
      @maze_array[el.yv][el.xv] = "x"
    end
    puts @maze_array
    puts "#{@attempts} paths atempted before solution found."
  end

  def astar(start, finish, array)
    queue = []
    queue << [start]
    @attempts = 1
    until queue.empty?
      array1 = @maze_array.clone
      array1.map!.with_index{|el, i| @maze_array[i].dup}
      path = queue.shift
      path.each do |el|
        array1[el.yv][el.xv] = "o"
      end
      path.last.walkable_neighbours.each do |el|
        return [path + [el]].flatten if el.value == "E"
        queue << [[path] + [el]].flatten unless queue.any?{|x| x.include?(el)}
        array1[el.yv][el.xv] = "?"
      end
      @attempts += 1
      k = @attempts % 4
      system "clear" or system "cls"
      puts array1
      puts "Solving. Please wait" + "." * k
      puts "#{@attempts} paths atempted so far."
      sleep(0.1)
      queue = queue.sort_by{|el| el.length + ((((el.last.xv - finish.xv)**2) + (el.last.yv - finish.yv)**2)**(0.5))}
      queue.map!(&:flatten)
      queue = queue.uniq
    end
    p "no path"
  end
end

if __FILE__ == $PROGRAM_NAME
  maze = Maze_solver.parse_maze(ARGV[0])
  puts maze.maze.tiles
  maze.solve_maze
end
