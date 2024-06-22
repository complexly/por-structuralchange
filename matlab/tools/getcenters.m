function Xc = getcenters(Xe,mode);
% Xc = getcenters(Xe) returns the centers of the intervals defined by
% the edges vector Xe.
%
% Xc = getcenters(Xe,'linear') returns centers which are the arithmetic
% mean of the bin edges. This is also the default behavior when there is no
% second argument.
%
% Xc = getcenters(Xe,'log') returns centers which are the geometric mean
% of the bin edges.

if (nargin == 1) | ((nargin == 2) & strcmp(mode,'linear'))
   dx     = diff(Xe);
   Xc     = Xe(1:end-1) + dx/2;
elseif (nargin == 2) & strcmp(mode,'log')
   Xe_log = log(Xe);
   dx_log = diff(Xe_log);
   Xc_log = Xe_log(1:end-1) + dx_log/2;
   Xc     = exp(Xc_log);
else
   disp('Bad input.')
end