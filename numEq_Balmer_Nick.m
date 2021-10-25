function equations = numEq_Balmer_Nick(connectivity)
% This function creates a matrix, called numEq, that relates the index of a
% degree of freedom in the local matrix to its index in the global matrix
% "numEq" stands for "numerotation of the equations"

equations = zeros(size(connectivity, 1), 2*size(connectivity, 2));

for e = 1:size(equations, 1)
    for i = 1:size(connectivity, 2)
        equations(e, 2*i-1) = 2*connectivity(e, i)-1;
        equations(e, 2*i) = 2*connectivity(e, i);
    end
end

end

