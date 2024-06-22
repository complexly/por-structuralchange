function phasePortrait()
global pp
announceFunction()

%========================================================================%
% Set parameters for the phase trajectories
%========================================================================%
% Times at which to plot phase trajectories
t         = [linspace(0,0.09,10), logspace(-1,1,50)]';
%t         = linspace(0,10,100)';

% Set the time scales and eigenvalues
delta_t   = 25;
tau2      = 50; %from Yang
tau3      = 50/4; %from Yang
lambda2   = exp(-delta_t / tau2);
lambda3   = exp(-delta_t / tau3);

% Set the angle between eigenvectors
%eigenvectorAngle = acosd( V(:,1)' * V(:,2) / (norm(V(:,1)) * norm(V(:,2))) );
%eigenvectorAngle = acosd(0.03466);
eigenvectorAngle  = 64;

% Set start points around the perimeter of the plot
xintercepts = [0.25 0.75]';
yintercepts = [0.1 0.5]';

startPointList = [
   -ones(length(yintercepts),1)  yintercepts;
   -ones(length(yintercepts),1) -yintercepts;
   ones(length(yintercepts),1)  yintercepts;
   ones(length(yintercepts),1) -yintercepts;
   -xintercepts                 ones(length(xintercepts),1);
   xintercepts                 ones(length(xintercepts),1);
   -xintercepts                -ones(length(xintercepts),1);
   xintercepts                -ones(length(xintercepts),1);
   ];


%========================================================================%
% Plot
%========================================================================%
% Plot parameters
fontSize                = 14;

xLim                    = [-1 1];
yLim                    = [-1 1];
lineWidth_paths         = 1;
lineWidth_2ndEV         = 3;
lineWidth_3rdEV         = 1;
lineColor_paths         = MatlabColors(1);
lineColor_2ndEV         = 'k';
lineColor_3rdEV         = MatlabColors(3);
centerLineWidth         = 0.5;
centerMarkerSize        = 7;
negativeBackgroundColor = 'w';
positiveBackgroundColor = 'w';%0.9*[1 1 1];   %0.8*[1 1 1];

% Temporarily convert start points from the (x,y)-plane to the (u,v)-plane
% of the 2nd and 3rd eigenvectors
startPointList_u = startPointList(:,1) - startPointList(:,2) / tand(eigenvectorAngle);
startPointList_v = startPointList(:,2) / sind(eigenvectorAngle);
startPointList_uv = [startPointList_u startPointList_v];

% Compute phase portrait trajectories from these startpoints
curveList = {};
for iCurve = 1:length(startPointList_uv)
   a20       = startPointList_uv(iCurve,1);
   a30       = startPointList_uv(iCurve,2);
   a2_curve  = a20 * lambda2.^t;
   a3_curve  = a30 * lambda3.^t;
   
   curveList = [curveList; [a2_curve a3_curve]];
end

% Skew the coordinate system to account for the fact that the
% eigenvectors are not orthogonal:
%   *Interpret the projections as coordinates (u,v)
%   *Map from (u,v) ---> (x,y)
%      x = u + v*cos(theta)
%      y = v*sin(theta)
for iCurve = 1:length(startPointList)
   a2_curve = curveList{iCurve}(:,1);
   a3_curve = curveList{iCurve}(:,2);
   
   a2_curve = a2_curve + a3_curve * cosd(eigenvectorAngle);
   a3_curve = 0        + a3_curve * sind(eigenvectorAngle);
   
   curveList{iCurve}(:,1) = a2_curve;
   curveList{iCurve}(:,2) = a3_curve;
end

% Compute the v-axis / 3rd eigenvector axis
u_3rd = [0 0];
v_3rd = [-1.2 1.2];
x_3rd = u_3rd + v_3rd * cosd(eigenvectorAngle);
y_3rd = 0     + v_3rd * sind(eigenvectorAngle);

% Fill area for negative and positive ECI values
XnegativeECI = [-1 x_3rd(2) x_3rd(1) -1];
YnegativeECI = [y_3rd(2) y_3rd(2) y_3rd(1) y_3rd(1)];
XpositiveECI = [x_3rd(2) 1 1 x_3rd(1)];
YpositiveECI = [y_3rd(2) y_3rd(2) y_3rd(1) y_3rd(1)];

% Setup figure
newFigure( [mfilename,'.phasePlane'] );
clf
figpos = get(gcf, 'Position');
set(gcf, 'Position',[figpos(1) figpos(2) 560   420])

% Setup axes
axes('Position',[0.15    0.15    0.7    0.7])
set(gca, 'ClippingStyle','rectangle'); %clips line at axes borders

% Plot
hold on
fill(XnegativeECI,YnegativeECI, negativeBackgroundColor, 'LineStyle','none')
fill(XpositiveECI,YpositiveECI, positiveBackgroundColor, 'LineStyle','none')
for iCurve = 1:length(startPointList)
   a2_curve = curveList{iCurve}(:,1);
   a3_curve = curveList{iCurve}(:,2);
   plot(a2_curve,a3_curve,'-', 'LineWidth',lineWidth_paths ,'Color',lineColor_paths)
   
   s = 0.36;
   overlayArrow(a2_curve,a3_curve,s,'arrowColor',lineColor_paths)
end
plot(x_3rd,y_3rd,'-', 'LineWidth',lineWidth_3rdEV ,'Color',lineColor_3rdEV)
plot([-1 1],[0 0],'-', 'LineWidth',lineWidth_2ndEV ,'Color',lineColor_2ndEV)
overlayArrow(x_3rd,y_3rd,0.99, 'arrowLength',0.1, 'arrowWidth',0.04, 'arrowColor',lineColor_3rdEV)
overlayArrow([-1 1.06],[0 0],1, 'arrowLength',0.1, 'arrowWidth',0.04)
plot(0,0,'ko', 'MarkerSize',centerMarkerSize, 'LineWidth',centerLineWidth, 'MarkerFaceColor','w')
hold off

% Axis labels
%text(1.08, 0, '2nd eigenmode', 'Color','k', 'FontSize',fontSize)
%text(x_3rd(1)-0.02, y_3rd(1)+0.09, '3rd eigenmode', 'Color','k', 'FontSize',pp.fontSize, 'Rotation',eigenvectorAngle, 'FontSize',fontSize)
text(1.08,        0, '2nd eigenvector v_2', 'Color','k', 'FontSize',fontSize)
text(0.1274, 0.3720, '3rd eigenvector v_3', 'Color','k', 'FontSize',pp.fontSize, 'Rotation',eigenvectorAngle, 'FontSize',fontSize)

% Positive and negative ECI text
xECI = 0.78;
yECI = 0.78;
text(-xECI,yECI,{'ECI* < 0','c_3 > 0'},'HorizontalAlignment','center', 'BackgroundColor',negativeBackgroundColor, 'FontSize',fontSize)
text(+xECI,yECI,{'ECI* > 0','c_3 > 0'},'HorizontalAlignment','center', 'BackgroundColor',positiveBackgroundColor, 'FontSize',fontSize)
text(-xECI,-yECI,{'ECI* < 0','c_3 < 0'},'HorizontalAlignment','center', 'BackgroundColor',negativeBackgroundColor, 'FontSize',fontSize)
text(+xECI,-yECI,{'ECI* > 0','c_3 < 0'},'HorizontalAlignment','center', 'BackgroundColor',positiveBackgroundColor, 'FontSize',fontSize)
%text(-0.4,0.15,{'ECI* < 0'},'HorizontalAlignment','center', 'BackgroundColor',negativeBackgroundColor, 'FontSize',fontSize)
%text(+0.4,0.15,{'ECI* > 0'},'HorizontalAlignment','center', 'BackgroundColor',positiveBackgroundColor, 'FontSize',fontSize)

% Refine
set(gca, 'Box','off')
set(gca, 'Visible','off')
set(gca, 'XLim',xLim)
set(gca, 'YLim',yLim)
set(gca, 'DataAspectRatio', [1 1 1])
%set(gca, 'XAxisLocation','origin')
set(gca, 'XTick',[])
set(gca, 'YTick',[])
set(gca, 'XColor','w', 'YColor','w')
%consistentTickPrecision(gca,'x',1)
%consistentTickPrecision(gca,'y',1)
set(gca, 'FontSize',pp.fontSize)
%xlabel('2nd eigenmode (PCI)', 'Color','k', 'Position',[1.448980545511051 0.0517006802721085 -1])
%ylabel('3rd eigenmode',       'Color','k', 'Rotation',eigenvectorAngle, 'Position',[0.31700680272108855 0.6870757836062906 -1])

% Save
if pp.saveFigures
   h         = gcf;
   folder    = pp.outputFolder;
   fileName  = 'ECIphasePortrait';
   fileName  = fullfile(folder, fileName);
   savemode  = 'painters_pdf';
   save_image(h, fileName, savemode)
end



