function [Xs,Ys] = arcLengthInterpolate(X,Y,s)
% [Xs,Ys] = arcLengthInterpolate(X,Y,s) returns an interpolated point on
% the parameterized curve (X(s), Y(s)), where s in [0 1].  The parameter s
% is the normalized cumulative arc length of the curve, i.e. s = 0.5 will
% return an interpolated point half-way along the total length of the
% curve described by the data X and Y.
%
% There should be no consecutive, duplicate points in the X and Y arguments.



% Obtain the cumulative length of the curve at each point i (approximately)
% This gives a discrete mapping
%   S(i) : i --> S
if iscolumn(X); X=X'; end
if iscolumn(Y); Y=Y'; end
cumulativeArcLength = [0, cumsum( sqrt(diff(X).^2 + diff(Y).^2) )];


% Pick an arbitrary point s from 0 to 1, where s is the normalized
% cumulative arc length
totalArcLength   = cumulativeArcLength(end);
partialArcLength = s * totalArcLength;

%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Find the equivalent index value i
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% In general i will not be an integer now, so we must interpolated.  To do
% this interpolation, we should treat the -indices- as the dependent
% variable, and the cumulative arc length as the independent variable.  The
% interpolation then returns the index that corresponds to the value of s.
% The nice thing is that one can always do this because/if there is a
% monotonic relationship between indices and cumulative arc length.  Then,
% the curve with these axes swapped also constitutes a function.
%
% Note that this requires that there be no consecutive, duplicate points in
% the X and Y arguments to the function.  If so, the distance moved in this
% segment will be zero, and we will fail to have a function in the swapped
% coordinates.
indexList = [1:length(X)];
i_of_s = interp1(cumulativeArcLength, indexList, partialArcLength);

%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
% Find interpolated X and Y values that correspond to non-integer index i
%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%
Xs = interp1(indexList, X, i_of_s);
Ys = interp1(indexList, Y, i_of_s);
