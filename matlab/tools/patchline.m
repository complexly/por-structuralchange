function h = patchline(X,Y,varargin)
% h = patchline(X,Y,varargin) creates a line using the patch function.  The
% advantage is that patches can be made transparent, while lines can't
% currently in matlab.

% Ensure row vectors
if iscolumn(X)
   X = X';
end
if iscolumn(Y)
   Y = Y';
end

% Plot
Xloop = [X(1:end-1) fliplr(X)];
Yloop = [Y(1:end-1) fliplr(Y)];
h = patch(Xloop, Yloop, 'r', 'FaceColor', 'none', 'EdgeColor','r');

% Set styling properties, if any passed in
if nargin > 2
   properties = varargin;
   for iProp = 1:2:length(properties) - 1
      set(h, properties{iProp}, properties{iProp+1})
   end
end
