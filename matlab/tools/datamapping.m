function functionName = datamapping(mappingType, domainValues, rangeValues, exponent)
% functionName = datamapping(mappingType, domainValues, rangeValues,
% exponent) creates a new function that maps data the domainValues to the
% rangeValues.
%
% To make sure it works when the desired output of the new function is a
% vector (e.g. you want to make a color map), then make sure that
%
%   *domainValues is a column vector
%   *rangeValues contains the desired row of outputs for each row of domainValues

switch mappingType
   case 'continuous'
      functionName = @(x) (interp1(domainValues, rangeValues, x)).^exponent;
      
   otherwise
      error('datamapping: Unrecognized mappingType')
end