#This script is used to plot normal coordinate outputted by "freq" task of Gaussian, see http://sobereva.com/567
#Written by Tian Lu (sobereva@sina.com, Beijing Kein Research Center for Natural Sciences), 2020-Sep-8

set filename "../example.log"
set ilinear 0

if {[info exist x]} {unset x}
set natm [molinfo top get numatoms]
if {$ilinear==0} {set nmode [expr 3*$natm-6]}
if {$ilinear==1} {set nmode [expr 3*$natm-5]}
puts "Number of modes to load: $nmode"

# Load normal coordinates
set myfile [open $filename r]
while { [gets $myfile line] >=0 } {
	if {[string first " and normal coordinates:" $line] != -1} {break}
}

set ipos 0
set nframe [expr ceil($nmode/3.0)]
for {set iframe 1} {$iframe<=$nframe} {incr iframe} {
	while { [gets $myfile line] >=0 } {
		if {[string first "Atom  AN" $line] != -1} {break}
	}
	set nleft [expr $nmode-$ipos]
	set m1 [expr $ipos+1]
	set m2 [expr $ipos+2]
	set m3 [expr $ipos+3]
	puts "Loading frame: $iframe  left: $nleft"
	if {$nleft>=3} {
		for {set iatm 1} {$iatm<=$natm} {incr iatm} {
			gets $myfile line
			scan $line "%d %d %f %f %f %f %f %f %f %f %f" itmp jtmp \
			x($iatm,$m1) y($iatm,$m1) z($iatm,$m1) \
			x($iatm,$m2) y($iatm,$m2) z($iatm,$m2) \
			x($iatm,$m3) y($iatm,$m3) z($iatm,$m3)
		}
		incr ipos 3
	} elseif {$nleft==2} {
		for {set iatm 1} {$iatm<=$natm} {incr iatm} {
			gets $myfile line
			scan $line "%d %d %f %f %f %f %f %f" itmp jtmp \
			x($iatm,$m1) y($iatm,$m1) z($iatm,$m1) \
			x($iatm,$m2) y($iatm,$m2) z($iatm,$m2)
		}
		incr ipos 2
	} elseif {$nleft==1} {
		for {set iatm 1} {$iatm<=$natm} {incr iatm} {
			gets $myfile line
			scan $line "%d %d %f %f %f" itmp jtmp x($iatm,$m1) y($iatm,$m1) z($iatm,$m1)
			puts "$x($iatm,$m1) $y($iatm,$m1) $z($iatm,$m1)"
		}
		incr ipos
	}
}
close $myfile


#Print loaded data
if {0} {
	puts "Loaded normal mode:"
	for {set imode 1} {$imode<=$nmode} {incr imode} {
		puts "Mode $imode:"
		for {set iatm 1} {$iatm<=$natm} {incr iatm} {
			puts "Atom $iatm: $x($iatm,$imode) $y($iatm,$imode) $z($iatm,$imode)"
		}
	}
}


source drawarrow.tcl

#Define command for drawing normal coordinate
proc norm {imode {sclfac 3} {rad 0.05} {colors yellow}} {
	draw delete all
	draw color $colors
	global x y z natm
	for {set i 1} {$i<=$natm} {incr i} {
	drawarrow "serial $i" $x($i,$imode) $y($i,$imode) $z($i,$imode) $sclfac $rad 0
	}
}
