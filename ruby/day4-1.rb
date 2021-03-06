#!/usr/bin/env ruby

def find_valid_passwords(min, max)
    total = 0
    current = min
    while current <= max
        str = current.to_s
        if has_two_adjacent(str) && digits_increasing(str)
            total += 1
        end
        current += 1
    end
    return total
end


def has_two_adjacent(str)
    last_c = nil
    str.split('').each do |c|
        if last_c != nil && last_c == c
            return true
        end
        last_c = c
    end
    return false
end

def digits_increasing(str)
    last_val = nil
    str.split('').each do |c|
        val = c.to_i
        if last_val != nil && last_val > val
            return false
        end
        last_val = val
    end
    return true
end


if __FILE__ == $0
    positions = []
    File.open(ARGV[0], "r") do |file_handle|
        file_handle.each_line do |line|
            range = line.split('-')
            puts find_valid_passwords(range[0].to_i, range[1].to_i)
        end
      end
end