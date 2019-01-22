#include <mex.h>
#include <matrix.h>
#include <stdio.h>
#include <math.h>

#include "ArrayMajor.h"

/*
 * RandomVars = stDiscreteDrawAux(DiscreteDistributions, RandomValues)
 *
 * Given a series of independent discrete distributions whose pdfs
 * form column vectors in matrix DiscreteDistributions, and a set
 * of corresponding RandomValues, find the value of each random
 * variable by mapping the RandomValues onto the DiscreteDistributions.
 *
 * LHS Arguments:
 *	RandomVars - Column vector of instances of the random variables,
 *		one for each RandomValue/Distribution pair. 
 *
 * RHS Arguments:
 *	DiscreteDistributions - column oriented discrete pdfs
 *	RandomValues - Values in [0,1] which let us determine
 *		the mapping to specific probability density bins
 *		based on a dynamically computed cdf.
 *
 * This code is copyrighted 2001 by Marie Roch.
 * e-mail:  marie.roch@ieee.org
 *
 * Permission is granted to use this code for non-commercial research
 * purposes.  Use of this code, or programs derived from this code for
 * commercial purposes without the consent of the author is strictly
 * prohibited. 
 *
 */


void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  /* positional parameter indices */
  const int	DiscreteDistributionsPos = 0;		/* In */
  const int	RandomValuesPos = 1;
  const int	InArgCount = 2;

  const int	RandomVarsPos = 0;			/* Out */
  const int	OutArgCount = 1;

  int		DistributionCount, MassCount;
  const double	*Distributions, *Distribution, *Random;
  double	*Values;
  double	Cumulative;
  int		DistIdx, MassIdx;


  /* retrieve dimensions and check if valid */
  MassCount = mxGetM(prhs[DiscreteDistributionsPos]);
  DistributionCount = mxGetN(prhs[DiscreteDistributionsPos]);

  if (mxGetM(prhs[RandomValuesPos]) * mxGetN(prhs[RandomValuesPos])
      != DistributionCount) {
    mexErrMsgTxt("Number of distributions and random values do not match");
  }

  /* retrieve data */
  Distributions = mxGetPr(prhs[DiscreteDistributionsPos]);
  Random = mxGetPr(prhs[RandomValuesPos]);

  /* allocate the output labels and grab a pointer to it */
  plhs[RandomVarsPos] = mxCreateDoubleMatrix(DistributionCount, 1, mxREAL);
  Values = mxGetPr(plhs[RandomVarsPos]);
  
  /* dynamically compute cdf values and find labels */
  Distribution = Distributions;
  DistIdx = 0;
  while (DistIdx < DistributionCount) {
    MassIdx = 0;
    Cumulative = Distribution[MassIdx];

    while (Cumulative <= Random[DistIdx] && MassIdx < MassCount)
      Cumulative += Distribution[++MassIdx];
    
    /* MassIdx now contains draw in range [0:MassCount-1] */
    Values[DistIdx] = MassIdx + 1;	/* [1:MassCount] */
       
    DistIdx++;
    COL_INCCOL(Distribution, MassCount, DistributionCount);
  }
}
