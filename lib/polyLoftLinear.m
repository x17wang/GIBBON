function [varargout]=polyLoftLinear(varargin)

% function [F,V,indStart,indEnd]=polyLoftLinear(Vc_start,Vc_end,cPar)
% ------------------------------------------------------------------------
%
% This function creates a loft between the two input curves i.e. it
% connects a surface from one curve to the other in a linear and stepwise
% fashion. The validity of the output surfaces is not checked and depends
% on the directionality of the input curves.
%
%
% Kevin Mattheus Moerman
% gibbon.toolbox@gmail.com
%
% 2016/01/13 Updated function description
% 2016/01/13 Fixed 'tri' surface type for even steps such that end curve is
% unaltered on output surface.
% 2017/09/20 Added additional outputs for start and end curve points
%------------------------------------------------------------------------

%% Parse input

switch nargin
    case 3
        Vc_start=varargin{1};
        Vc_end=varargin{2};
        cPar=varargin{3};
        untwistOpt=0;
    case 4
        Vc_start=varargin{1};
        Vc_end=varargin{2};
        cPar=varargin{3};
        untwistOpt=varargin{4};
    otherwise
        error('Wrong number of input arguments');
end

if isfield(cPar,'numSteps')
    numSteps=cPar.numSteps;
else
    numSteps=[];
end

%Derive numSteps from point spacings if missing (empty)
if isempty(numSteps)
    d1=sqrt(sum(diff(Vc_start,1,1).^2,2));
    d2=sqrt(sum(diff(Vc_end,1,1).^2,2));
    d=mean([d1(:);d2(:)]);
    dd=mean(sqrt(sum((Vc_start-Vc_end).^2,2)));
    numSteps=ceil(dd./d);
    numSteps=numSteps+iseven(numSteps);
end

% if numSteps==1
%     numSteps=2;
% end

%% Remove twist
if untwistOpt
    [Vc_end,~,~]=minPolyTwist(Vc_start,Vc_end);
end

%% Create coordinate matrices
X=linspacen(Vc_start(:,1),Vc_end(:,1),numSteps)';
Y=linspacen(Vc_start(:,2),Vc_end(:,2),numSteps)';
Z=linspacen(Vc_start(:,3),Vc_end(:,3),numSteps)';

%% Create patch data
c=(1:1:size(Z,1))';
C=c(:,ones(1,size(Z,2)));

%Create quad patch data
[F,V,C] = surf2patch(X,Y,Z,C);

indStart=1:numSteps:size(V,1);
indEnd=numSteps:numSteps:size(V,1);

%% Close patch if required
if cPar.closeLoopOpt
    I=[(2:size(Z,1))' (2:size(Z,1))' (1:size(Z,1)-1)' (1:size(Z,1)-1)'];
    J=[ones(size(Z,1)-1,1) size(Z,2).*ones(size(Z,1)-1,1) size(Z,2).*ones(size(Z,1)-1,1) ones(size(Z,1)-1,1)];
    F_sub=sub2ind(size(Z),I,J);
    F=[F;F_sub];
    [C]=vertexToFaceMeasure(F,C);
    C(end-size(F_sub,1):end,:)=C(end-size(F_sub,1):end,:)+0.5;
else
    [C]=vertexToFaceMeasure(F,C);
end
C=round(C);

%% Change mesh type if required
meshTypes={'quad','tri_slash','tri'};
if ~ismember(cPar.patchType,meshTypes)
    error([cPar.patchType,' is not a valid patch type, use quad, tri_slash, or tri instead'])
else
    switch cPar.patchType
        case 'quad'
        case 'tri_slash' %Convert quads to triangles by slashing
%             F=fliplr([F(:,1) F(:,3) F(:,2); F(:,1) F(:,4) F(:,3)]);
            [F]=quad2tri(F,V);
        case 'tri' %Convert quads to approximate equilateral triangles
            
            logicSlashType=repmat(iseven(C),2,1);
            
            Xi=X;
            x=X(1,:);
            dx=diff(x)/2;
            dx(end+1)=(x(1)-x(end))/2;
            for q=2:2:size(X,1)
                X(q,:)=X(q,:)+dx;
            end
            if ~cPar.closeLoopOpt
                X(:,1)=Xi(:,1);
                X(:,end)=Xi(:,end);
            end
            
            Yi=Y;
            y=Y(1,:);
            dy=diff(y)/2;
            dy(end+1)=(y(1)-y(end))/2;
            for q=2:2:size(Y,1)
                Y(q,:)=Y(q,:)+dy;
            end
            if ~cPar.closeLoopOpt
                Y(:,1)=Yi(:,1);
                Y(:,end)=Yi(:,end);
            end
            
            Zi=Z;
            z=Z(1,:);
            dz=diff(z)/2;
            dz(end+1)=(z(1)-z(end))/2;
            for q=2:2:size(Z,1)
                Z(q,:)=Z(q,:)+dz;
            end
            if ~cPar.closeLoopOpt
                Z(:,1)=Zi(:,1);
                Z(:,end)=Zi(:,end);
            end
            
            V=[X(:) Y(:) Z(:)];
            
            %Ensure end curve is unaltered if numSteps is even
            if iseven(numSteps)
                indBottom=numSteps:numSteps:size(V,1);
                V(indBottom,:)=Vc_end;
            end
            
            F1=[F(:,1) F(:,3) F(:,2); F(:,1) F(:,4) F(:,3)];
            F2=[F(:,1) F(:,4) F(:,2); F(:,2) F(:,4) F(:,3)];
            F=fliplr([F1(~logicSlashType,:);F2(logicSlashType,:)]);
            
            %         C=repmat(C,2,1);
            %         C=[C(~logicSlashType,:);C(logicSlashType,:)];
            
    end
end

varargout{1}=F;
varargout{2}=V;
varargout{3}=indStart;
varargout{4}=indEnd;
 
%% 
% _*GIBBON footer text*_ 
% 
% License: <https://github.com/gibbonCode/GIBBON/blob/master/LICENSE>
% 
% GIBBON: The Geometry and Image-based Bioengineering add-On. A toolbox for
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
