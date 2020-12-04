#!/usr/bin/env ruby

unless ARGV[0] && File.exist?(ARGV[0]) && ARGV[1]
  puts "Convert GWMON 'D'isplay output dump to binary file\n(c) 2020 The Glitch Works\nhttp://www.glitchwrks.com\n\n"
  puts "USAGE: gwmon2bin.rb input.txt output.bin"
  puts "       input.txt  - GWMON 'D' capture"
  puts "       output.bin - destination file"
  exit
end

results = []

def parse_line (line)
  line.strip!
  return if line.length < 13
  line[7..-1].split(' ').collect { |str| str.hex }
end

File.readlines(ARGV[0]).drop(1).each do |line|
  results << parse_line(line)
end

results.compact!
results.flatten!

File.open(ARGV[1], 'wb' ) do |output|
    output.write results.pack("C*")
end
