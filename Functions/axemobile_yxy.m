%
% MobileAxis.cpp
% Implementation of functions to get angles from a rotation matrix
%
% Composed rotation matrices for all the composition orders:
%
%
%        [c(a1)*c(a3)-s(a1)*c(a2)*s(a3)   s(a1)*s(a2)  s(a1)*c(a3)+s(a1)*c(a2)*c(a3)]
% Ryxy = [s(a2)*s(a3)                     c(a2)       -s(a2)*c(a3)                  ]
%        [-c(a3)*s(a1)-c(a1)*c(a2)*s(a3)  c(a1)*s(a2)  c(a1)*c(a2)*c(a3)-s(a1)*s(a3)]
%
%
% In all of those, a1 = alpha = rotation around mobile y axis
%                  a2 = beta  = rotation around mobile x' axis
%                  a3 = gamma = rotation around mobile y'' axis
%
% All the matrices have a similar form, in which:
%
%   * The rotation around the second axis can be accessed through its sine
%   * The other two can be accessed through their tangents
%
% So all we need is a list of where to find the necessary data in the composed
% matrix, and whether we need to swap the sign of each element before taking
% the inverse trigonometric function.
%
%
%
% Get back the angles around mobile axes for a rotation matrix
%
function [OutputVector] = axemobile_yxy(M)
% Table to find the values of interest in the composed rotation matrices


a1 = NaN; a3 = NaN;
% Retrieve the second angle in the sequence by its sinus
a2 = acos( M(2,2));

% Retrieve the first angle in the sequence by its tangent
if ((M(1, 2) ~= 0) && (M(3,2) ~= 0))
    % General case, tan(ay) = FNumerator / FDenominator
    a1 = atan2(M(1, 2), M(3,2));
elseif ((M(1, 2) == 0) && (M(3,2) == 0))
    % Case where cos(ax) = 0, and the other two angles are not defined
    a1 = NaN;
elseif ((M(1, 2) == 0) && (M(3,2) ~= 0))
    % Case where sin(ay) = 0 so ay is 0° or 180°
    % Ratio of FNumerator to cos(ax) is cos(ay)
    a1 = real(acos(M(3,2) / sin(a2)));
elseif ((M(1, 2) ~= 0) && (M(3,2) == 0))
    % Case where cos(ay) = 0 so ay is -90° or 90°
    % Ratio of FDenominator to cos(ax) is sin(ay)
    a1 = real(asin(M(1, 2) / sin(a2)));
end

% Retrieve the third angle in the sequence by its tangent
if ((M(2, 1) ~= 0) && (M(2, 3) ~= 0))
    % General case, tan(az) = TNumerator / TDenominator
    a3 = atan2(-M(2, 1), M(2, 3));
elseif ((M(2, 1) == 0) && (M(2, 3) == 0))
    % Case where cos(ax) = 0, and the other two angles are not defined
    a3 = NaN;
elseif ((M(2, 3) == 0) && (M(2, 3) ~= 0))
    % Case where sin(az) = 0 so az is 0° or 180°
    % Ratio of TNumerator to cos(ax) is cos(az)
    a3 = real(acos(M(2, 3) / -sin(a2)));
elseif ((M(2, 1) ~= 0) && (M(2, 3) == 0))
    % Case where cos(az) = 0 so az is -90° or 90°
    % Ratio of TDenominator to cos(ax) is sin(az)
    a3 = real(asin(M(2, 1) / sin(a2)));
end
% Rearrange the results so we have them in the order Rx, Ry, Rz
OutputVector = [a1 a2 a3];