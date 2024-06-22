function cmap = makeColorMap(nColors, varargin)
% cmap = makeColorMap(nColors, ...) creates colormaps.
%
% cmap = makeColorMap(nColors, matlabColorMapName) uses one of Matlab's
% colormaps.  Options are
%    autumn
%    bone
%    colorcube
%    cool
%    copper
%    flag
%    gray
%    hot
%    hsv
%    jet
%    lines
%    parula
%    pink
%    prism
%    spring
%    summer
%    white
%    winter
%
% cmap = makeColorMap(nColors, firstColor, lastColor) creates a linear
% interpolation between the two colors.
%
% cmap = makeColorMap(nColors,hueStart,hueRots,colorSat,gammaCorr,[irange2
% irange1],[domain2 domain1]) uses the cubehelix function.  See the
% documentation for that function.

if nColors == 0
   cmap = [];
   
else
   
   switch nargin
      case 1
         error('makeColorMap: not enough arguments')
         
      case 2
         % Matlab color map mode
         cmap_name  = varargin{1};
         cmap       = feval(cmap_name, nColors);
         
      case 3
         % Linear color map mode
         firstColor = varargin{1}; %make sure this is a row vector
         lastColor  = varargin{2}; %make sure this is a row vector
         t          = linspace(0,1,nColors)';
         cmap       = firstColor + (lastColor-firstColor).*t;
         
      case 9
         % Cubehelix mode
         hueStart         = varargin{1};
         hueRots          = varargin{2};
         colorSat         = varargin{3};
         gammaCorr        = varargin{4};
         irange1          = varargin{5};
         irange2          = varargin{6};
         domain1          = varargin{7};
         domain2          = varargin{8};
         cmap             = cubehelix(nColors,hueStart,hueRots,colorSat,gammaCorr,[irange2 irange1],[domain2 domain1]);
         
      otherwise
         error('makeColorMap: wrong number of arguments')
   end
end