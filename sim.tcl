# Vivado TCL Simulation Script
# This script compiles, elaborates, and runs the RISC-V simulation

puts "========================================"
puts "RISC-V SystemVerilog Simulation"
puts "========================================"

# Set working directory
cd [file dirname [info script]]

# Clean previous simulation files
if {[file exists xsim.dir]} {
    file delete -force xsim.dir
}
foreach file [glob -nocomplain *.jou *.log *.pb *.wdb] {
    file delete $file
}

puts "\n\[1/3\] Compiling SystemVerilog files..."
if {[catch {
    exec xvlog --sv {*}[glob *.sv]
} result]} {
    puts "ERROR: Compilation failed!"
    puts $result
    exit 1
}

puts "\n\[2/3\] Elaborating design..."
if {[catch {
    exec xelab -debug typical top -s top_sim
} result]} {
    puts "ERROR: Elaboration failed!"
    puts $result
    exit 1
}

puts "\n\[3/3\] Running simulation..."
if {[catch {
    exec xsim top_sim -runall
} result]} {
    puts "ERROR: Simulation failed!"
    puts $result
    exit 1
}

puts "\n========================================"
puts "Simulation completed successfully!"
puts "========================================"
