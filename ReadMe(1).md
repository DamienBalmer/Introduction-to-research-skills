# Geometric non-linearity computing for a simple truss system
## Project description
The codes provided in this repository have the purpose to compute the load-displacement response of a simple 2D truss system. The computation assume a linear elastic material behaviour and non linear geometry.

The repository is composed of three programs:
- geometricNL_NR_Balmer_Nick.m - Matlab program
- numEq_Balmer_Nick.m - Matlab program
- Assignment_4.tcl - OpenSees program

OpenSees is an open access finite element model (FEM) program. The matlab code is the result of an exercise, where it was asked to create code that computes the load-displacement response of a simple 2D truss. The OpenSees program is provided to verifiy the results given by the Matlab code.

## Getting started
The manipulations are given for Windows user only. It is possible to achieve the same on other OS but this will not be treated here.
### Denpendencies
No special dependencies are mandatory.
### Installing
To run the .m programs the following feature have to be installed
- [MATLAB](https://fr.mathworks.com/campaigns/products/trials.html?gclid=CjwKCAjwq9mLBhB2EiwAuYdMtRGr5VATPFmcdyPbcvlGc4m4i_nVx-690Arudm8YGclcdcD-_bUQ6xoCw7cQAvD_BwE&ef_id=CjwKCAjwq9mLBhB2EiwAuYdMtRGr5VATPFmcdyPbcvlGc4m4i_nVx-690Arudm8YGclcdcD-_bUQ6xoCw7cQAvD_BwE:G:s&s_kwcid=AL!8664!3!278170229267!e!!g!!matlab%20download&s_eid=ppc_45107710281&q=matlab%20download) 
OR
- [Octave](https://www.gnu.org/software/octave/download) open access program similar to matlab

To run the .tcl file, the following features have to be installed
- [OpenSees](https://opensees.berkeley.edu/OpenSees/user/download.php), FEM programm

Download the file and unzipp it
- [Tcl 8.6.11 Sources](https://www.tcl.tk/software/tcltk/download.html), Tool command language is the programmation language of the OpenSees program

Download the file and unzipp it, than move the folder to the following directory (Windows user)
```sh
C:\Program Files
```
And rename the folder to "tcl" 
### Executing program
*To run the Matlab computation*
open geometricNL_NR_Balmer_Nick.m with Matlab or Octave and run it. Several plot will appear, load and displacement vector will be accessible in the stored variable.

*To run the OpenSees computation*
run OpenSees.exe
The command prompt will open
Change your current directory with the directory of Assignment_4.tcl
```sh
cd myPathToMyFile
```
Run the file using the following command
```sh
source Assignment_4.tcl
```
Finally two output files will be produced, 'AllDisp.out' and 'AllForces.out'.
These files contain the force and displacement response for the specified Force and number of diplacement increment.
### Data
Programs are set with default values that produce results without any change by the user.
## Authors
### OpenSees code
[Prof. Katerine Beyer](katerine.beyer@epfl.ch), lecturer, Nonlinear analysis of structures at EPFL
[Mahmoud Shaqfa](mahmoud.shaqfa@epfl.ch), teaching assistant, Nonlinear analysis of structures course at EPFL
[Hnat Lesiv](hnat.lesiv@epfl.ch), teaching assistant, Nonlinear analysis of structures course at EPFL

### Matlab codes
Hugo Nick, Master student in civil Enginnering at EPFL
Damien Balmer, Master student in civil Enginnering at EPFL
## License
These programs are under no known licenses.
## Acknowledgement
Inspiration,
Course of "Introduction of research skills CIVIL-465 EPFL"
Course of "Nonlinear analysis of structures CIVIL-449 EPFL"
