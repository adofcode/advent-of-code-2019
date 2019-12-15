class IntCode
    def initialize(instructions)
        @instructions = instructions
        @ptr = 0
        @in_buff = []
        @out_buff = []
        @rel_base = 0
        @blocked = false
    end

    def send_input(thing)
        @in_buff.push(thing)
    end

    def read_output()
        return @out_buff.shift()
    end

    def all_output()
        return @out_buff
    end

    def inspect()
        puts @instructions.to_s
        puts @out_buff.to_s
    end

    def isBlocked()
        return @blocked
    end

    def read_mem(idx)
        if idx < 0
            puts "wat: negative index"
        end
        val = @instructions[idx]
        if val == nil
            @instructions[idx] = 0
            return 0
        else
            return val
        end
    end

    def write_mem(idx)
    end

    def run()
        @blocked = false
        while @ptr < @instructions.length do
            # puts @ptr, @instructions.to_s
            base_op = read_mem(@ptr)
            # puts base_op
            op = base_op % 100  # get last 2 digits
            flags = base_op / 100 # top n digits
            arg1 = read_value(@instructions, @ptr+1, flags%10)
            if op == 1
                flags = flags / 10
                arg2 = read_value(@instructions, @ptr+2, flags%10)
                flags = flags / 10
                arg3 = read_value(@instructions, @ptr+3, flags%10)
                r = read_mem(arg1) + read_mem(arg2)
                @instructions[arg3] = r
                @ptr += 4
            elsif op == 2
                flags = flags / 10
                arg2 = read_value(@instructions, @ptr+2, flags%10)
                flags = flags / 10
                arg3 = read_value(@instructions, @ptr+3, flags%10)
                r = read_mem(arg1) * read_mem(arg2)
                @instructions[arg3] = r
                @ptr += 4
            elsif op == 3
                if @in_buff.empty?
                    # puts "waiting for input"
                    @blocked = true
                    return false
                end
                input = @in_buff.shift()
                # puts "got input #{input}, putting in location #{arg1}"
                @instructions[arg1] = input.to_i
                @ptr += 2
            elsif op == 4
                output = read_mem(arg1)
                @out_buff.push(output)
                # puts "output: #{output}"
                @ptr += 2
            elsif op == 5
                flags = flags / 10
                arg2 = read_value(@instructions, @ptr+2, flags%10)
                if read_mem(arg1) != 0
                    @ptr = read_mem(arg2)
                else
                    @ptr += 3
                end
            elsif op == 6
                flags = flags / 10
                arg2 = read_value(@instructions, @ptr+2, flags%10)
                if read_mem(arg1) == 0
                    @ptr = read_mem(arg2)
                else
                    @ptr += 3
                end
            elsif op == 7
                flags = flags / 10
                arg2 = read_value(@instructions, @ptr+2, flags%10)
                flags = flags / 10
                arg3 = read_value(@instructions, @ptr+3, flags%10)
                if read_mem(arg1) < read_mem(arg2)
                    @instructions[arg3] = 1
                else
                    @instructions[arg3] = 0
                end
                @ptr += 4
            elsif op == 8
                flags = flags / 10
                arg2 = read_value(@instructions, @ptr+2, flags%10)
                flags = flags / 10
                arg3 = read_value(@instructions, @ptr+3, flags%10)
                if read_mem(arg1) == read_mem(arg2)
                    @instructions[arg3] = 1
                else
                    @instructions[arg3] = 0
                end
                @ptr += 4
            elsif op == 9
                @rel_base += read_mem(arg1)
                # puts "updated relative base to #{@rel_base}"
                @ptr += 2
            elsif op == 99
                # puts "halting!"
                break
            else
                puts "wat"
                return @instructions
            end
        end
        return @instructions
    end

    def read_value(instructions, arg, flag)
        if flag == 1
            return arg
        elsif flag == 2
            v = read_mem(arg) + @rel_base
            return v
        else
            return read_mem(arg)
        end
    end
end

def get_joystick_direction(output)
    score = nil
    display = [ [] ]
    
    ballx = nil
    paddlex = nil

    i = 0
    while i < output.length
        x = output[i]
        y = output[i+1]
        b = output[i+2]

        if x == -1 && y == 0
            score = b
        end
        if display[y] == nil
            display[y] = []
        end
        block = ' '
        if b == 1
            block = '#'  # wall
        elsif b == 2
            block = '^'  # block
        elsif b == 3
            block = '='  # paddle
            paddlex = x
        elsif b == 4
            block = 'O'  # ball
            ballx = x
        end
        display[y][x] = block

        i += 3
    end
    # puts "score: #{score}"
    # pp(display)
    return [sign(ballx - paddlex), score]
end

def sign(n)
    return n <=> 0
end

def pp(screen)
    screen.each do |row|
        if row == nil
            puts ""
        end
        row.each do |c|
            if c == nil
                print " "
            else
                print c
            end
        end
        puts ""
    end
end

def play(vm)
    vm.run()
    
    while vm.isBlocked
        output = vm.all_output()
        dir = get_joystick_direction(output)
        vm.send_input(dir[0])
        vm.run()
    end

    output = vm.all_output()
    dir = get_joystick_direction(output)
    return dir[1]
end


if __FILE__ == $0
    instructions = []
    File.open(ARGV[0], "r") do |file_handle|
        file_handle.each_line do |line|
            instructions = line.split(",").map { |n| n.to_i } 
            break
        end
    end

    # play for free!
    instructions[0] = 2

    vm = IntCode.new(instructions)
    puts play(vm)
end