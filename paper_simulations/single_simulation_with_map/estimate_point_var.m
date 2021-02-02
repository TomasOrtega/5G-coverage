function y_map = estimate_point_var(P, data, lambda, Lmax) 
% Variation of estimate_point function, no reuse of prob_data, due to
% nature in the calculation of estimation approximated

% Given a point P in our cell of study, and the labeled data [x,y,label]
% the function returns the estimated value of light/shadow at the point P.
% It does so, comparing the prob of P^data to gamma = prob_data/2

%prob_light = points_probability_eps([P,1;data], lambda, Lmax, 0) * ...
%			 1/points_probability_eps(data, lambda, Lmax, 0);
global skips;
prob_data = points_probability_eps(data, lambda, Lmax, 1e-4);
data = [P,1;data]; %para reaprovechar codigo

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

gamma = 0.5 * prob_data/prob_OK_W;

conditional_probability = 0;  % Initialize the first term, P(KO|OK).

for k = 1:(M-W)
	sum = 0;
    % Subsets of [W+1,M] with size k
    subsets = nchoosek(W+1:M, k);
    % Sum over all subsets of size k
    for j=1:size(subsets, 1)
        numerator = probability_OK([points(1:W, :); points(subsets(j,:), :)], lambda, Lmax);
        sum = sum + numerator/prob_OK_W;
    end
    %Inclusion Exclusion Formula
	conditional_probability = conditional_probability + ((-1)^(k+1)) * sum; 
    
    % Check Bonferroni bounds
    if (mod(k, 2)) % k is odd
        if (conditional_probability <= 1-gamma) 
            y_map = 1; skips = skips+1; return;   % light
        end
    else % k is even
        if (1-gamma <= conditional_probability) 
            y_map = 0; skips = skips+1; return;  % shadow
        end
    end
end

if (conditional_probability <= 1-gamma) 
    y_map = 1;  % light
else
    y_map = 0;  % shadow
end


end




