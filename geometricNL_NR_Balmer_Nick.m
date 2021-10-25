% Developed by Damien Balmer and Hugo Nick
% Nonlinear analysis of structures : Assignment 4
% Ecole Polytechnique Federale de Lausanne, Switzerland
% Last Update: October 20, 2021
%
%
% This code computes the response using the load-controlled Newton-Raphson 
% method including geometric nonlinearity but neglecting material 
% nonlinearity

clear all
close all
clc

%% Input datas

% Connectivity of the system
connectivity = [1 2;                                                       
                2 3];

% Index of degree of freedom in the global matrix
equations = numEq_Balmer_Nick(connectivity);

% Nodal coordinates [x, y]
Node1 = 1000*[0 0];            % mm          
Node2 = 1000*[3 4];            % mm
Node3 = 1000*[6 0];            % mm
Nodes = [Node1; Node2; Node3]; % mm

% Characteristics of the system
NDoF = 6;
free = [3 4];
E0 = 200e3;      % N/mm^2
E = [E0 E0];     % N/mm^2
A = [15e3 2e3];  % mm^2

% External forces
P = zeros(NDoF, 1);
P_ref=1e+09;                 % N                                            % the force is fixed to a value for wich the stress on the last bar to yield is 15% bigger than the stress yield limit
P(free(1)) = P_ref*cosd(60); % N
P(free(2)) = P_ref*sind(60); % N

% Geometric functions
length =  @(NodeA, NodeB) sqrt(sum((NodeB - NodeA).^2));                    % length of member  [mm]
c = @(NodeA, NodeB) ((NodeB(1) - NodeA(1))/length(NodeA, NodeB));           % cosine            [rad]
s = @(NodeA, NodeB) ((NodeB(2) - NodeA(2))/length(NodeA, NodeB));           % sine              [rad]

% Initial length of the elements
l0 = [];
for e = 1:(size(Nodes, 1) - 1)
    l0 = [l0, length(Nodes(e, :), Nodes(e+1, :))];
end

% Local material stiffness matrix
k_M_loc = [ 1 0 -1 0;
            0 0  0 0;
           -1 0  1 0;
            0 0  0 0]; 

% Local geometric stiffness matrix
k_G_loc = [0  0 0  0;
           0  1 0 -1;
           0  0 0  0;
           0 -1 0  1];

% Define the theory used to update the strain inside the element
get_strain = @(l, l0) (l-l0)/l0;                                            % engineering strain

% Parameters
load_steps = 100;                                                           % number of load steps
error_threshold = 10^-3;                                                    % allowable error for convergance for NR
max_iterations = 100;                                                       % max. iterations for NR

%% Newton-Raphson solver

% Initialization
R = P(free); % N                                                            % residual forces
d = [0 0]';  % mm                                                           % total displacements
du = [0 0]'; % mm                                                           % displacements corrector
updated_Node2 = [Node2(1), Node2(2)];                                       % new coordinates for the node 2 (here du = 0)

% Collect of data for the plots
monitor_R = [0; 0];                                                         % vector to collect the residual force R in each iteration
loading_history = [0; 0];                                                   % vector to collect the loads F_ext in each iteration
displacements_history = [0; 0];                                             % vector to collect the displacements d in each iteration

for i = 1:load_steps
    
    counter = 0;                                                            % iterations counter
    F_ext = P(free)/load_steps*i;                                           % load stepper
    fprintf('\nLoad step No. %i, current load = %3.10f\n', i, F_ext)
    
    while (norm(R(end, :)) > error_threshold...
            && max_iterations >= counter) || counter ==0
        fprintf('\nIteration No. %i, current R = %3.10f\n', counter,...
            max(abs(R)))
        monitor_R = [monitor_R, R];
        
        % Update of the nodal coordinates
        updated_Node2 = [updated_Node2(1)+du(1), updated_Node2(2)+du(2)];   % nodes 1 and 3 are fixed
        Nodes(2,:) = updated_Node2;
        
        % Initialization
        f_r_e = [];
        f_r_e_GCS=[];
        K_t = zeros(NDoF, NDoF);
        
        for e = 1:(size(Nodes, 1) - 1)
            % Update of the elements orientations according to the nodes
            c_e = c(Nodes(e, :), Nodes(e+1, :));                            % allocate a new value of the cosinus
            s_e = s(Nodes(e, :), Nodes(e+1, :));                            % allocate a new value of the sinus
            l_e = length(Nodes(e, :), Nodes(e+1, :));                       % allocate a new value of the length
            % Update of the internal forces vector
            eps_e = get_strain(l_e, l0(e));                                 % strain inside the element
            dl_e = l_e - l0(e);                                             % change in length
            q_e = eps_e*E(e)*A(e);                                          % internal axial force
            % Update of the axial forces
            if e == 1
                f_r_e = [f_r_e, q_e*[-c_e; -s_e;c_e; s_e;0;0]];                     
            else
                f_r_e = [f_r_e, q_e*[0;0;-c_e; -s_e;c_e; s_e]];
            end
            % Update of the material stiffness matrix
            T_e = [ c_e s_e    0   0;
                   -s_e c_e    0   0;
                      0   0  c_e s_e;
                      0   0 -s_e c_e];
            K_M_e = E(e)*A(e)/l0(e)*T_e'*k_M_loc*T_e;
            % Update of the geometric stiffness matrix
            N_e = E(e)*A(e)/l0(e)*dl_e;
            K_G_e = q_e/l_e*T_e'*k_G_loc*T_e;
            % Update of the final global tangiential stiffness matrix
            dof = equations(e, :);                                          % get the degrees of freedom of the element e
            K_t(dof, dof) = K_t(dof, dof) + K_M_e + K_G_e;                  % assemble the global stiffness matrix
        end
        
        % Reduction of the global tangiential stiffness matrix
        K_t = K_t(free, free);                                              % only the free degrees of freedom are of interest
        
        % Updates   
        f_r = sum(f_r_e, 2);                                                % nodal forces (at node 1 2 and 3) including both elements                                                
        R = F_ext - f_r(free);                                              % residual forces in node 2
        
        % Correction of the displacements
        du = K_t\R;                                                         % displacement increments due to R
        d = d + du;                                                         % total displacements
        
        % Update of the iterations counter
        counter = counter + 1;
        fprintf('updated R = %3.10f\n',  max(abs(R)))
    end
    
    % Update of the results
    loading_history = [loading_history, F_ext];
    displacements_history = [displacements_history, d];
end

%% Printer

fprintf('----------------------------------\n')
fprintf('\nThe final results for the displacements %5.10f\n', d')
m_s = size(monitor_R, 2);
figure
plot(1:m_s, monitor_R(1, :))                                                % residual forces in x direction
hold on
plot(1:m_s, monitor_R(2, :))                                                % residual forces in y direction
legend ('U_x','U_y','Location', 'Best')
xlabel('Iterations')
ylabel('Residual Forces [N]')
xlim([1 m_s])
title('Convergence')
fprintf('\nThe final forces at the nodes %5.10f\n', f_r')

if load_steps > 1
    figure
    plot(abs(displacements_history(1,:))/1000,...                           % loads and displacements in x direction
        abs(loading_history(1,:))/1000, 'LineWidth', 2.5)
    grid on
    title('Equilibrium path')
    ylabel('Horizontal load [kN]')
    xlabel('Horizontal displacement [m]')
end

if load_steps > 1
    figure
    plot(abs(displacements_history(2,:))/1000,...                           % loads and displacements in y direction
        abs(loading_history(2,:))/1000, 'LineWidth', 2.5)
    grid on
    title('Equilibrium path')
    ylabel('Vertical load [kN]')
    xlabel('Vertical displacement [m]')
end

if load_steps > 1
    figure
    plot(abs(displacements_history(1,:))/1000,...                           % loads and displacements in y direction
        abs(displacements_history(2,:))/1000, 'LineWidth', 2.5)
    grid on
    title('Displacement ratio')
    xlabel('Horizontal displacement [m]')
    ylabel('Vertical displacement [m]')
end
