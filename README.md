# Hobis_Kinematics_Simulation

Download the file 
Add the path to the downloaded file to your matlab session 
Change the paths in MainBatch.m to match your location
Unzip all files in .\Ressources\BDD
Launch MainBatch.m
Fill the MainBatch popup using the desired inputs
Add the folder to the Matlab path with subfolder


Dependencies : DSP System Toolbox ; Signal Processing Toolbox

# Lines of command : 

To select manually the different entries
- Simulation_Cinematique 

To launch a batch of simulations by harcoding the entries 
- Simulation_Cinematique_Batch

# Main Objects

I used 'struct' a lot... sorry for that...

- Markers : A set of marker from a .c3d file (from 'btkgetmarkers') or from a .txt file for a model (from 'HobisDataParser'). Contains the markers XYZ coordinates in fields sorted by name 'Markers.RFWT, Markers.LFWT, ...'

- KinModel : Defined using 'Loadc3dKinModel'. Contains data from a .c3d Mocap file, processed to build a Kinematic Model with fields :
'AC' with subfields 'Pelvis, RHip, ...' XYZ coordinates of the articular centres in the Pelvic Coordinate System (PCS) 
'Markers'
'Reperes' the segments coordinate systems
'ParamPhy' Deprecated - segments lengths
'Angles' the Articular trajectories of the various joints 
'TA' the filtered (low pass) Articular trajectories easier for manips Right side first
'TX' the filtered (low pass) markers trajectories. Right then Left
'Poulaine' the filterd Ankle trajectory (easier for manips)

- PolA : Articular Trajectories splined Polynomials. set as a Nx7 matrix. Each line is a 3rd degree polynomial, its designated interval and the degree of freedom it represents. 
Col 1 is the degree of freedom (1-11)
Col 2-3 is the interval of the spline (from 0.00 to 1.9)(e.g [0.1 0.5]) . The total length of a degree of freedom's (DOF) interval is 1 (100% of a walk cycle)(e.g [0.1 0.5] and [0.5 1.1] for a DOF with 2 intervals) . 
Col 4-7 are the coefficients of the 3rd degree polynomial - descending order (e.g N4 * X^3 + N5 * X^2 + N6 * X + N7).




Important remark : The 'Markers' issued from a .txt model and a .c3d Mocap are not compatible ! 
More fields (more markers) exist in the text files. When it is necessary to compare .txt model file 'Txt_Markers' in conjunction with a .c3d Mocap file 'C3D_Markers' (e.g. for scaling), I use 'AdaptMarkers' function to force the MarkerSet compatibilty 

# Main Functions

Display :

type 'Display' the tab for the available :

- DisplayCurves(P) / (P,n) : Takes a curve 'P' (Poulaine, Articular Trajectory, ...) and displays it in a new figure / the nth figure as square subplots. P/TA are matrices  
- Display3DCurves(P) / (P,n) : Displays a 3xN matrix as a 3D XYZ continuous curve in figure 'n'
- Display3DPoints(P) : Displays points in a 3D figure
- DisplayMarkers(Markers) : Takes a 'Markers' structure
- DisplayModel() : Display a scuffed 3D Model
- DisplayGait : Takes 

Important in the code :

- Loadc3dKinModel(.c3dPath, .xlsxPath) : Prend un fichier .c3d de Mocap et un .xlsx de sélection des frames du cycle de marche, renvoie un  

- Sampling_txt(PolA) : Prend des splines de trajectoires angulaires sous la forme de Polynôme et bornes d'évaluation, et retourne les courbes de Poulaine et de Trajectoire Articulaire associées échantillonnées sur 100 points

- ECShort : Energetical Cost computation
- ArticularCostPC : Articular Cost computation for splines

- fcinematique(...) : Kinematic function   
- calc_jacobien_PC_4D : Jacobian for all the optimization costs : Distance to the FootPrints, energetical cost, articular cost, ...





