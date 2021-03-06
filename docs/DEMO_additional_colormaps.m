%% DEMO_additional_colormaps
% Below is a demonstration for:
% 
% * Additional colormaps available in GIBBON

%%
clear; close all; clc;

%%
%Plot settings
fontSize=25;

% Create example data for visualizations
n=150;
s=5;
[X,Y]=ndgrid(linspace(-4*s,4*s,n));
Z=10*exp( -0.5.*((X./s).^2+(Y./s).^2));
Z(X<0)=-Z(X<0);

[F,V,C]=surf2patch(X,Y,Z,Z);
% F=[F(:,[1 2 3]);F(:,[3 4 1]);];

colormapset={'gjet','grayjet','graygjet','warmcold','wjet','bloodbone','fireice','che','wcbp','viridis','magma','inferno','plasma'};

%% The gibbon color maps
% A jet like colormap inspired by the Google colors. Has quite a
% homogeneous color intensity.

for q=1:1:numel(colormapset)    
cFigure; 
gtitle(colormapset{q},fontSize);

subplot(1,2,1); hold on; 
gpatch(F,V,C,'none');
colormap(colormapset{q}); colorbar;
axisGeom; 
camlight headlight; 

subplot(1,2,2); hold on; 
imagesc(Z);
colormap(colormapset{q}); colorbar;
axis tight; axis equal; axis xy; box on;
end
drawnow; 

%%
%
% <<gibbVerySmall.gif>>
%
% _*GIBBON*_
% <www.gibboncode.org>
%
% _Kevin Mattheus Moerman_, <gibbon.toolbox@gmail.com>
 
%% 
% _*GIBBON footer text*_ 
% 
% License: <https://github.com/gibbonCode/GIBBON/blob/master/LICENSE>
% 
% GIBBON: The Geometry and Image-based Bioengineering add-On. A toolbox formax(abs(Z(:)))
% image segmentation, image-based modeling, meshing, and finite element
% analysis.
% 
% Copyright (C) 2018  Kevin Mattheus Moerman
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
