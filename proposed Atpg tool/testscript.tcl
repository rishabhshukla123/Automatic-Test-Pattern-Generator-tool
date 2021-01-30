#!/bin/env tclsh
#..........................................................................#
#......checks whether test_pattern_generator usage is correct or not.......#
#..........................................................................#

set working_dir [exec pwd]
set vsd_array_length [llength [split [lindex $argv 0] .]]
set input [lindex [split [lindex $argv 0] .] $vsd_array_length-1]
if {![regexp {^v} $input] || $argc!=3 } {
	puts " Error in usage"
	puts "Usage: ./testscript <.v>"
	puts "where <.v> file has been inputs"
	exit
} else {


puts "#########......            ......########"
puts "#########..reading verilog file.#########"
puts "#########......            .....#########" 

set filename [lindex $argv 0]

set nof [lindex $argv 1]

set noi [lindex $argv 2]

 for {set i 0} { $i < [expr {$nof +1}] } {incr i} {
   set fp4 [open $filename]
   set lines [ split [read $fp4] "\n"]
   close $fp4
   set var fs$i
   set lines [linsert $lines 7 "assign $var=1'b1;"]

set fp4 [open $filename$i.v w]
puts $fp4 [join $lines "\n"]
close $fp4
}


 for {set i [expr {$nof +1}]} { $i <[expr {$nof*2+2}] } {incr i} {
   set fp4 [open $filename]
   set lines [ split [read $fp4] "\n"]
   close $fp4
   set l [expr {$i-$nof-1}]
   set var fs$l
   set lines [lreplace $lines 7 7 "assign $var=1'b0;"]

set fp4 [open $filename$i.v w]
puts $fp4 [join $lines "\n"]
close $fp4
}
puts "\n"
puts "\n"
puts " preparing to convert verilog to blif "

for {set i 0} { $i < [expr {$nof*2+2}] } {incr i} {
exec yosys -o $filename$i.blif -S $filename$i.v 
exec yosys-abc -c "read_blif $filename$i.blif; strash; write_cnf $filename$i.cnf"
}



puts "\n"
puts "\n"
puts " blif....to....cnf.."



for {set i 0} { $i < [expr {$nof*2+2}] } {incr i} {
exec picosat --all $filename$i.cnf -o $filename$i.out &
}



puts "\n"
puts "\n"
puts "#########......            .....#########"
puts "######    running SAT Solver     ########"
puts "#########......            .....#########"




for {set j 0} {$j < [expr {$nof +1}]} {incr j} {

      set fp5 [open $filename$j.out]
      set lines [split [read $fp5] "\n"]
      close $fp5

      set fp [open test_patterns1.txt a+] 
      puts $fp "\n" 
      puts $fp "\n \n                 *******For fault s-a-1 at fs$j *******\n"
      close $fp

puts "\n"
puts "\n"
puts " evaluating test pattern for fault stuck at 1 fault at fs$j"


  foreach line $lines {
 
          set output [lindex $line [expr {$noi+1}]]
        
          if {$output == [expr {$noi+1}]} { 
              set fp [open test_patterns1.txt a+]  
              puts $fp "\n"
              close $fp

              for { set i 1} { $i<[expr {$noi+1}] } {incr i} {
                  set a [lindex $line $i]
                 
      
                   if {$a=="SATISFIABLE"||$a=="SOLUTIONS"} {
                      
                      break
                      } else {
   
                             set out [ expr "$a/$i"]
                            

                             if {$out==0} {
                                break 
                                }

                             if {$out == -1} {
                                 set fp [open test_patterns1.txt a+]  
                                 puts -nonewline $fp "Pi_$j/$i= 0"
                                 puts -nonewline $fp " "
                                 close $fp
                                 }

                             if {$out == 1} {
                                set fp [open test_patterns1.txt a+]  
                                puts -nonewline $fp "Pi_$j/$i= 1"
                                puts -nonewline $fp " "
                                close $fp
                                 }

                        }
  

              } 
            if {$a=="SOLUTIONS"} {
                break  
               }
 
       } else { 
        
     }

  }

}



for {set j [expr {$nof +1}]} {$j < [expr {$nof*2+2}]} {incr j} {

      set fp5 [open $filename$j.out]
      set lines [split [read $fp5] "\n"]
      close $fp5
      set k [expr {$j-$nof-1}]
      set fp [open test_patterns1.txt a+] 
      puts $fp "\n" 
      puts $fp "\n \n                 *******For fault s-a-0 at fs$k *******\n"
      close $fp

puts "\n"
puts "\n"
puts " evaluating test pattern for fault stuck at 0 fault at fs$k"


  foreach line $lines {
 
          set output [lindex $line [expr {$noi+1}]]
          
          if {$output == [expr {$noi+1}]} { 
              set fp [open test_patterns1.txt a+]  
              puts $fp "\n"
              close $fp

              for { set i 1} { $i<[expr {$noi+1}] } {incr i} {
                  set a [lindex $line $i]
                 
      
                   if {$a=="SATISFIABLE"||$a=="SOLUTIONS"} {
                      
                      break
                      } else {
   
                             set out [ expr "$a/$i"]
                            

                             if {$out==0} {
                                break 
                                }

                             if {$out == -1} {
                                 set fp [open test_patterns1.txt a+]  
                                 puts -nonewline $fp "Pi_$j/$i= 0"
                                 puts -nonewline $fp " "
                                 close $fp
                                 }

                             if {$out == 1} {
                                set fp [open test_patterns1.txt a+]  
                                puts -nonewline $fp "Pi_$j/$i= 1"
                                puts -nonewline $fp " "
                                close $fp
                                 }

                        }
  

              } 
            if {$a=="SOLUTIONS"} {
                break  
               }
 
       } else { 
        
     }

  }

}

}


puts "\n"
puts "\n"
puts "compression of the test pattern generated"

set in [open test_patterns1.txt r]
set out [open test_pattern1.txt w+]
array set seen {}
while {[gets $in line] != -1} {
    # blank lines should be printed as-is
    if {[string length [string trim $line]] == 0} {
        continue
    }

    # create the "key" for this line
    regsub {\mPoint \d+} $line {} key
    regsub {\mcolor=\w+} $key {} key

    # print the line only if the key is unique
    if { ! [info exists seen($key)]} {
        puts $out $line
        set seen($key) true
    }
}
close $in
close $out

puts " test patterns are generated in to test_pattern1.txt "
