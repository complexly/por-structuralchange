function visualizeProductSpace()

global pp
announceFunction()

%====================================================================%
% Load network data
%====================================================================%
% Load edges (proximities)
load('./save/mincop_proximity.mat')

% Load node attributes
fid = fopen('./save/nodes_with_xy.tsv');
fileContents = textscan(fid,'%s%s%s%f%f%f', 'Headerlines',1, 'Delimiter','\t', 'EndOfLine','\r\n');
fclose(fid);

SITCcode_3d = fileContents{1};
% nodeColor   = fileContents{2};
nodeNames   = fileContents{3};
node_xloc   = fileContents{4};
node_yloc   = fileContents{5};
% node_PCI    = fileContents{6};

n           = length(SITCcode_3d);
A           = mincop_proximity;
groupLabels = ones(n,1);
nodeSizes   = ones(n,1);
% nGroups     = numel(unique(nodeSizes));

% Add a tiny amount to each link to avoid absolute zeros, which will screw
% up the color mapping
A = A + 1e-6;

%====================================================================%
% General appearance parameters
%====================================================================%
fontSize            = 12;
drawLinks           = true;
linkThreshold       = 0.3;

%====================================================================%
% Node appearance parameters
%====================================================================%
% Node shape mapping
nodeMarker          = 's';

% Node size mapping
markerBaseSize      = 60; %120
mappingType         = 'continuous';
dataValues          = [0 max(nodeSizes)];
functionValues      = [0 1];
exponent            = 1;
nodeSizeFunction    = datamapping(mappingType, dataValues, functionValues, exponent);

% Node edge width mapping
markerLineWidth     = 0.3;

% Node face color mapping
% Mcolors             = MatlabColors;
nodeFaceColorMap    = 0.55*[1 1 1];     %Mcolors(1:nGroups,:) 0.5*[1 1 1]

% Node edge color mapping
nodeEdgeColor       = [1 1 1]; %Mcolors(5,:) w
nodeEdgeOpacity     = 1;

% Node names
drawnNodeNames  = 'none';     %all, none, some
subsetList      = [3 8 33];
xshift_nodeName = 0.1;
yshift_nodeName = 0.0;

%====================================================================%
% Edge appearance parameters
%====================================================================%
% Edge width mapping
edgeBaseWidth       = 3;
mappingType         = 'continuous';
dataValues          = [0 max(A(:))];
functionValues      = [0 1];
exponent            = 1.0;
edgeWidthFunction   = datamapping(mappingType, dataValues, functionValues, exponent);

% Edge opacity mapping
mappingType         = 'continuous';
dataValues          = [0 max(A(:))];
functionValues      = [0 1];
exponent            = 1;
edgeOpacityFunction = datamapping(mappingType, dataValues, functionValues, exponent);

% Edge color mapping
mappingType         = 'continuous';
dataValues          = [0 max(A(:))];
functionValues      = [0 1];
exponent            = 3;
edgeColorFunction   = datamapping(mappingType, dataValues, functionValues, exponent);
nColors             = 100;

edgeColorMap        = makeColorMap(nColors, [16 88 170]/255, [1 1 1]);
edgeColorMap        = edgeColorMap(end:-1:1, :);



%====================================================================%
% Pre-compute appearance mappings
%====================================================================%
% Compute node mappings
nodeFaceColorList = nodeFaceColorMap( groupLabels, : );
nodeSizeList      = nodeSizeFunction( nodeSizes ) * markerBaseSize;

% Compute edge mappings
edgeWidthMatrix   = edgeWidthFunction( A ) * edgeBaseWidth;
edgeOpacityMatrix = edgeOpacityFunction( A );
edgeColorFactors  = edgeColorFunction( A );
edgeColorIndices  = ceil(nColors * edgeColorFactors);




%====================================================================%
% Determine network layout
%====================================================================%
layoutMethod = 'precomputed';   %MST precomputed
switch layoutMethod
   case 'MST'
      symmetrizedGraph = graph(A + A');
      T = minspantree(symmetrizedGraph);
      hfig     = figure;         %create a temporary figure to construct the layout
      tempPlot = plot(T);
      xlocs    = tempPlot.XData;
      ylocs    = tempPlot.YData;
      close(hfig)
      
   case 'precomputed'
      xlocs = node_xloc;
      ylocs = node_yloc;
      
   otherwise
      error('Unrecognized layout method.')
end

% Set layout
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3767578/
% https://www.mathworks.com/matlabcentral/fileexchange/10922-matlabbgl


if true
%====================================================================%
% Determine edges-to-draw and drawing order
%====================================================================%
% Track edges-to-draw
drawThisEdge = false(n^2,1);

% Find the edges in the min/max spanning tree
symmetrizedGraph = graph(-A - A');     %make negative to get max spanning tree
T                = minspantree(symmetrizedGraph);
edgeList_MST     = T.Edges.EndNodes;
edgeIndices_MST  = sub2ind(size(A), edgeList_MST(:,1), edgeList_MST(:,2));
drawThisEdge(edgeIndices_MST) = true;

% Find edges that surpass the threshold
Avec = A(:);
drawThisEdge(Avec > linkThreshold) = true;

% Construct the list of drawn edges
% Note: Sort edges in ascending order of weight.  This ensures more intense
% edges are drawn later/on top.
Idraw               = find(drawThisEdge);
[~,Isort]           = sort(Avec(Idraw), 'ascend');
Idraw               = Idraw(Isort);
[Isources,Itargets] = ind2sub(size(A), Idraw);
edgeList            = [Isources Itargets];



%====================================================================%
% Draw network
%====================================================================%
% Setup figure
newFigure(mfilename);
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 700   540])
set(gcf, 'Color','w')

% Setup axes
axes('Position',[0.05    0.05    0.9    0.9])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot edges
hold on
if drawLinks
   for iEdge = 1:length(edgeList)    
      % Get the two nodes being connected and their layout positions
      iSource = edgeList(iEdge,1);
      iTarget = edgeList(iEdge,2);
      xsource = xlocs(iSource);
      ysource = ylocs(iSource);
      xtarget = xlocs(iTarget);
      ytarget = ylocs(iTarget);
      
      % Draw edge
      edgeWidth   = edgeWidthMatrix(iTarget,iSource);
      edgeOpacity = edgeOpacityMatrix(iTarget,iSource);
      edgeColor   = edgeColorMap(edgeColorIndices(iTarget,iSource), :);
      patchline([xsource xtarget],[ysource ytarget], 'LineWidth',edgeWidth, 'EdgeAlpha',edgeOpacity, 'EdgeColor',edgeColor);
      
      % Draw arrow
      %iSource
      %iTarget
      %xsource
      %xtarget
      %ysource
      %ytarget
      %overlayArrow([xsource xtarget],[ysource ytarget],0.8)
   end
end

% Plot nodes
theNodes = scatter(xlocs,ylocs,nodeSizeList,nodeFaceColorList,'filled');
set(theNodes, 'Marker',nodeMarker, 'LineWidth',markerLineWidth, 'MarkerEdgeColor',nodeEdgeColor, 'MarkerEdgeAlpha',nodeEdgeOpacity)
hold off

% Plot node names
switch drawnNodeNames
   case 'all'
      text(xlocs+xshift_nodeName, ylocs+yshift_nodeName, nodeNames)
   case 'none'
      %do nothing
   case 'some'
      text(xlocs(subsetList)+xshift_nodeName, ylocs(subsetList)+yshift_nodeName, nodeNames(subsetList,:))
   otherwise
      error('Unrecognized case for drawing node names.')
end

% Refine
set(gca, 'Box','on')
set(gca, 'DataAspectRatio', [1 1 1])
set(gca, 'FontSize',fontSize)
set(gca, 'Visible','off')

% Plot colorbar
dataTicks    = [0 : 0.1 : 1];
colorTicks   = edgeColorFunction(dataTicks);
opacityTicks = edgeOpacityFunction(dataTicks);
drawColorBar(gcf,dataTicks,colorTicks,opacityTicks,edgeColorMap)



% Save
if pp.saveFigures
   set(gca, 'Visible','off')
   
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = 'productSpace';
   fileName  = fullfile(folder, fileName);
   savemode  = '2014b';
   %save_image(h, fileName, savemode)
   
   % SAVE MANUALLY.
end
end