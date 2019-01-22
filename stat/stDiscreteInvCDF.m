function x = stDiscreteInvCDF(Fx, Population)
% x = stDiscreteCDF(Fx, Population)
% Given a probabilty Fx and a discrete population, determine x
% such that Fx = stDiscreteCDF(x, Population)

Sorted = sort(Population);
Index = min(floor(length(Sorted) * Fx), length(Sorted));
x = Sorted(Index);
