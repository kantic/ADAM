 
# ginSim-converter $n_nodes $p_value $filename

# Takes input from dvd website and passes it to M2 to compute fixed points
# returns 0 (no errors) or 1 (errors) 

unless ARGV.size == 1
  puts "Usage: ruby ginSim-converter.rb n_nodes p_value functionFile"
  exit 0
end

#n_nodes = ARGV[0] 
#p_value = ARGV[1]
functionFile = ARGV[0] 

m2_result = `cd lib/M2code/; M2 convertToPDS.m2 --stop --no-debug --silent -q -e 'toString converter("#{functionFile}"); exit 0'`
puts m2_result

#get functions
functions = m2_result.split("{").fetch(1)
functions.chop!

puts functions
puts "<br>"

#m2_system =  "{{"

#largestI = 0
#File.open( functionFile, 'r').each {|line|
  # puts "#{line}<br>"
#  ll = line.split(/=/)
#  m2_system = m2_system + ll.last 
#  m2_system =  m2_system + ","
#  largestI = ll.first.split(/f/).last.to_i
#}

#if (largestI != n_nodes.to_i ) 
#  puts "There should be #{n_nodes} functions in order in the function
#  input, but the last funtion I read was f#{largestI}. Exiting. <br>"
#  exit 1
#end

# remove last comma
#m2_system.chop!
#m2_system = m2_system + "}}"

#puts "<br>"
#puts m2_system
#puts "<br>"
#puts "Running fixed point calculation now ...<br>"


#end



exit 0

###