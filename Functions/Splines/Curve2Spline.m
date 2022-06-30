function [res, Pol] = Curve2Spline(Curve)
%   Takes a Curve and the associated sampling and returns a 3rd degree Spline approximation,
%   continuous and differentiable.
%   The curve is supposed to be a sampled cycle, with the first and last values equal
%   Due to constraints, the spline is located on a [0 1] interval and is periodical,
%   Spline(0)==Spline(1), the sampling is conserved.

% Curve = load(Filename);

SampleFreq = max(size(Curve,1), size(Curve,2))-1;

Interval = 0:1/SampleFreq:1;

PC = find_control_points(Curve, Interval');

Pol = PC_to_spline(PC,Interval(end));

NewCurve = spline_to_curve_int(Pol,SampleFreq);

% Pol = Pol(:,2:end);

% figure(1); hold on; plot(Interval, NewCurve, 'r'); plot(Interval, Curve, 'b');

res = NewCurve;
end
