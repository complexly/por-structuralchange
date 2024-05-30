function varargout = drawColorBar(figureHandle,dataTicks,colorTicks,opacityTicks,colorMap,varargin)

% Create colorbar
hColorBar = axes(figureHandle);
set(hColorBar, 'Position',[0.9   0.0743    0.05   0.8150])

% Plot colors
hold on
x          = [1:2];
colorTicks = repmat(colorTicks', [1 2]);
hSurface = pcolor(x, dataTicks, colorTicks);
set(hSurface, 'AlphaData',repmat(opacityTicks', [1 2]))


% Setup colormap
colormap(hColorBar,colorMap)

% Put numbers on right
set(hColorBar, 'YAxisLocation','right')

% Prevent distortion
set(hColorBar, 'DataAspectRatioMode','auto')



%nTicks    = length(dataTicks);





if false
% Eliminate tick marks by default
%set(hColorBar, 'TickLength',0.0)

% Set the (full) data limits of the colorbar axis
dataMin = dataLimits(1);
dataMax = dataLimits(2);
%caxis(axesHandle, [dataMin - 0.5 dataMax + 0.5] )

% Set the portion of the colorbar axis that should be made visible
if nargin == 4
   dataDisplayLimits = varargin{1};
   set(hColorBar, 'YLim',dataDisplayLimits)
end

% Set where color axis tick labels appear
if nargin == 5
   colorTick = varargin{2};
else
   colorTick = [dataMin : dataMax];
end
%set(hColorBar, 'YTick',colorTick);


 



% Return object handle if asked for
if nargout == 1
   varargout{1} = hColorBar;
end
end