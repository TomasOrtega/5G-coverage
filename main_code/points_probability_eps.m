function probability = points_probability_eps(data, lambda, Lmax, eps)
% Given M arbitrary labeled points within the study cell, the function 
% returns the probability of them taking their corresponding value, that is:
% Pr(z_1 = d_1, ... , z_M = d_M) where d_i = 1 or 0 if z_i is in light/shadow.
% The given data, is an Mx3 matrix.

M = size(data, 1);

% First, order the M points: the first W ones will be in light (OK), 
% the missing W-M points are in shadow (KO). (i.e. data -> [OK,KO])

% The label is in the third column, and we use that 1 -> True.
OK = data(logical(data(:,3)),:);
KO = data(~logical(data(:,3)),:);

W = size(OK, 1);

% Get rid of label: since we ordered them it contains no info.
if W == 0  % All points are KO
	points = KO(:,1:2);
elseif W == M  % All points are OK
	points = OK(:,1:2);
else
	points = [OK(:,1:2); KO(:,1:2)]; 
end

% Prob = P(KO|OK) * P(OK);

prob_OK_W = probability_OK(points(1:W,:), lambda, Lmax);  % Last term, P(OK). 

if (M-W <= 0) % Base case, no points in light
    probability = prob_OK_W; 
    return;
end
 

eps = eps/prob_OK_W;
conditional_probability = 1;  % Initialize the first term, P(KO|OK).

for k = 1:(M-W) 
    sum = 0; 
    subsets = nchoosek(W+1:M, k);  % Subsets of [W+1,M] with size k
    for j=1:size(subsets, 1)  % Sum over all subsets of size k
        numerator = probability_OK([points(1:W, :); points(subsets(j,:), :)], ...
                                    lambda, Lmax);
        sum = sum + numerator/prob_OK_W;
    end
    conditional_probability = conditional_probability + ((-1)^k) * sum; %Inclusion Exclusion Formula
%     if (sum < eps) 
%         %disp("points_prob_eps epsilon break"); 
%         break;
%     end
end	

probability = conditional_probability * prob_OK_W;

end
	

