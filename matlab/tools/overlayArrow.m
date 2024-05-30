function overlayArrow(Xcurve,Ycurve,s,varargin)
% overlayArrows(Xcurve,Ycurve,s) draws a directional arrowhead on the
% current axes on top of the 2D curve given by [Xcurve,Ycurve].  The tip of
% the arrow appears at the point (x0(s), y0(s)).  Letting N be the number
% of points in the vectors Xcurve and Ycurve, s must be in the range
%
%    s in [0 1]
%
% and represents the normalized arc-length along the curve.

% Appearance parameters
defaultArrowLength = 0.05; %20
defaultArrowWidth  = 0.02; %5
defaultArrowColor  = 'k';
lineStyle          = 'none';
edgeColor          = 'k';
%MatlabColors(1);

% Check for changes to defaults
ip = inputParser;
addParameter(ip, 'arrowLength', defaultArrowLength, @isnumeric);
addParameter(ip, 'arrowWidth',  defaultArrowWidth,  @isnumeric);
addParameter(ip, 'arrowColor',  defaultArrowColor,  @isnumeric);
parse(ip,varargin{:});
arrowLength = ip.Results.arrowLength;
arrowWidth  = ip.Results.arrowWidth;
arrowColor  = ip.Results.arrowColor;

% Get location of arrow tip
[X0,Y0] = arcLengthInterpolate(Xcurve,Ycurve,s);

% Identify direction of the arrow
[Xprev,Yprev] = arcLengthInterpolate(Xcurve,Ycurve,0.9*s);

% Convert to an absolute units temporarily
%conversionMode = 'data2pixels';
%[X0,Y0]        = convertcoords(gca, X0, Y0, conversionMode);
%[Xprev,Yprev]  = convertcoords(gca, Xprev, Yprev, conversionMode);
theta = atan2d(Y0 - Yprev, X0 - Xprev);                  %angle of arrow in degrees   


% Get location of arrow side corners
locL = [-arrowLength  arrowWidth]';
locR = [-arrowLength -arrowWidth]';
R = rotz(theta);                       %rotation matrix around z axis (ie perpendicular to plane)
R = R(1:2,1:2);                        %get 2x2 portion of matrix
locL = R * locL;                       %rotate
locR = R * locR;
locL = locL + [X0 Y0]';                 %translate 
locR = locR + [X0 Y0]';

% Convert back to data units
%conversionMode = 'pixels2data';
%[X0,Y0]        = convertcoords(gca, X0, Y0, conversionMode);
%[l1,l2]        = convertcoords(gca, locL(1), locL(2), conversionMode);
%locL           = [l1 l2];
%[r1,r2]        = convertcoords(gca, locR(1), locR(2), conversionMode);
%locR           = [r1 r2];

% Draw triangle
Xfill = [locL(1) X0 locR(1)];
Yfill = [locL(2) Y0 locR(2)];
fill(Xfill,Yfill,arrowColor, 'LineStyle',lineStyle, 'EdgeColor',edgeColor)



% Check locations of points
%plot(X0,Y0,'o')
%plot(Xprev,Yprev,'p')
%plot(locL(1),locL(2),'+')
%plot(locR(1),locR(2),'+')