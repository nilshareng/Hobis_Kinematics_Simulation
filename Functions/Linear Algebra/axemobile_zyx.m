%
% MobileAxis.cpp
% Implementation of functions to get angles from a rotation matrix
%
% Composed rotation matrices for all the composition orders:
%
%        [c(ay)*c(az)  c(az)*s(ax)*s(ay)-c(ax)*s(az)  s(ax)*s(az)+c(ax)*c(az)*s(ay)]
% Rzyx = [c(ay)*s(az)  c(ax)*c(az)+s(ax)*s(ay)*s(az)  c(ax)*s(ay)*s(az)-c(az)*s(ax)]
%        [-s(ay)       c(ay)*s(ax)                    c(ax)*c(ay)                  ]
%
% In all of those, ax = alpha = rotation around mobile x axis
%                  ay = beta  = rotation around mobile y axis
%                  az = gamma = rotation around mobile z axis
%

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
function [OutputVector] = axemobile_zyx(M)
% Table to find the values of interest in the composed rotation matrices


az = NaN; ax = NaN;
% Retrieve the second angle in the sequence by its sinus
ay = asin(- M(3, 1));

% Retrieve the first angle in the sequence by its tangent
if ((M(2, 1) ~= 0) && (M(1, 1) ~= 0))
    % General case, tan(az) = FNumerator / FDenominator
    az = atan2(M(2, 1), M(1, 1));
elseif ((M(2, 1) == 0) && (M(1, 1) == 0))
    % Case where cos(ay) = 0, and the other two angles are not defined
    az = NaN;
elseif ((M(2, 1) == 0) && (M(1, 1) ~= 0))
    % Case where sin(az) = 0 so az is 0° or 180°
    % Ratio of FNumerator to cos(ay) is cos(az)
    az = real(acos(M(1, 1) / cos(ay)));
elseif ((M(2, 1) ~= 0) && (M(1, 1) == 0))
    % Case where cos(az) = 0 so az is -90° or 90°
    % Ratio of FDenominator to cos(ay) is sin(az)
    az = real(asin(M(2, 1) / cos(ay)));
end

% Retrieve the first angle in the sequence by its tangent
if ((M(3, 2) ~= 0) && (M(3, 3) ~= 0))
    % General case, tan(ax) = TNumerator / TDenominator
    ax = atan2(M(3, 2), M(3, 3));
elseif ((M(3, 2) == 0) && (M(3, 3) == 0))
    % Case where cos(ay) = 0, and the other two angles are not defined
    ax = NaN;
elseif ((M(3, 2) == 0) && (M(3, 3) ~= 0))
    % Case where sin(ax) = 0 so ax is 0° or 180°
    % Ratio of TNumerator to cos(ay) is cos(ax)
    ax = real(acos(M(3, 3) / cos(ay)));
elseif ((M(3, 2) ~= 0) && (M(3, 3) == 0))
    % Case where cos(ax) = 0 so ax is -90° or 90°
    % Ratio of TDenominator to cos(ay) is sin(ax)
    ax = real(asin(M(3, 2) / cos(ay)));
end
% Rearrange the results so we have them in the order Rx, Ry, Rz
OutputVector = [ax ay az];
