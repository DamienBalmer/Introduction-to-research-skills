# CIVIL 449 Assignment 4
# EPFL 2019
wipe

# Create ModelBuilder (with three-dimensions (-ndm) and 6 DOF/node (-ndf))
model basic -ndm 2 -ndf 2

#VARIABLES ------------------------------------------------------------ 
set E         200e9;
set A1        0.015; 
set A2        0.002; 
set Fx        0.5e8;  
set Fy        0.866e8;  
set iter      50;
set tol       10.0e-4;

#NODES ----------------------------------------------------------------- 
# Definition of the geometry
# Create nodes
#       tag     X         Y         
node      1     0.000     0.000     
node      2     3.000     4.000     
node      3     6.000     0.000    
#END NODES -------------------------------------------------------------

#CONSTRAINTS -----------------------------------------------------------
fix       1    1   1 
fix       3    1   1 
#END Constraints--------------------------------------------------------

#MATERIALS--------------------------------------------------------------
#uniaxialMaterial Elastic $matTag $E <$eta> <$Eneg>
uniaxialMaterial Elastic 1 $E
#END Elements-----------------------------------------------------------

#ELEMENTS --------------------------------------------------------- 
#element corotTruss $eleTag $iNode $jNode $A $matTag <-rho $rho> <-cMass $cFlag> <-doRayleigh $rFlag>
element  corotTruss 1       1      2      $A1 1
element  corotTruss 2       2      3      $A2 1 
puts "Elements defined." 
#END Elements-----------------------------------------------------------


# Define recorders
recorder Node -file "AllDispl.out"  -time -nodeRange 1 3 -dof 1 2  disp
recorder Node -file "force.out"     -time -nodeRange 1 3 -dof 1 2  reaction
printA -file "allMemory.out"
test NormUnbalance $tol $iter 4


#FORCE APPLICATION ------------------------------------------------ 
pattern Plain 1 "Linear" {     
	 load   2    $Fx  $Fy 
}
	
# Define analysis parameters
#system SparseGEN;
system FullGeneral;
numberer Plain;
constraints Plain; 
	
integrator LoadControl 1
test NormUnbalance 1.0e-4  50 1
algorithm Newton
analysis Static
analyze 1
puts "Vertical load applied."
wipe
