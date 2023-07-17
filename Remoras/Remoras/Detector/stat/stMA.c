/* Moving Average MEX implementation */

#include <mex.h>
#include <matrix.h>
#include <stdio.h>
#include <math.h>

#define min(A,B)	(((A) < (B)) ? (A) : (B))

/*
 * stMA(Matrix, N, Shift)
 *
 * Assuming column oriented data, compute the N point moving average
 * for each column and return a matrix of the same size containing the
 * the moving average values.  The first M<N values will be MA(M).
 * A uniformly weighted window is assumed.
 *
 * LHS Arguments:
 *	Matrix with MA(n) values
 *
 * RHS Arguments:
 *	Matrix - column oriented data matrix
 *	N - MA window
 *	Optional arguments:
 *		Shift
 *			Default behavior for each column is the N point
 *			causal process:
 *
 *				MA(t) = 1/N sum_{k=t-N+1}^{k=t} x(t)
 *
 *			When Shift is specified, the process is shifted:
 *
 *				MA(t) = 1/N
 *					sum_{k=t+Shift-N+1}^{k=t+Shift} x(t)
 *
 *			To have a centered MA window, choose odd N and
 *			set Shift=(N-1)/2.  S must be >= 0.  When Shift > 0,
 *			both the beginning and ending samples will be of
 *			MA(M) where M < N.
 *
 * Caveats:  For efficiency, the MA process uses a running sum rather than
 * recomputing the average each time.  This may lead to errors in precision
 * over time.
 *
 * This code is copyrighted 1999 by Marie Roch.
 * e-mail:  marie-roch@uiowa.edu
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
  const int	DataPos = 0;		/* In */
  const int	NPos = 1;
  const int	ShiftPos = 2;
  const int	MinInArgCount = 2;
  const int	MaxInArgCount = 3;

  const int	MAPos = 0;		/* Out */

  int		N, rows, cols, r, c;
  int    Shift, Remaining, Length, Future, missing_samples;
  
  /*
   * Given a column (transposed) from the input matrix: 
   *             |-----------|     |-------|
   *             v           v     v       v
   *
   *	[c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 ...]'
   *             ^                         ^
   *             |-- trailing_ptr          |-- leading_ptr
   *
   * Pointers to input data:
   * starting_ptr points to the first data item in the MA range
   * trailing_ptr points to the last data item.
   * data_base points to row 1, col 1 in the matrix and is used to
   *    compute the initial starting/trailing ptr for each column.
   */
  double	*data_base, *leading_ptr, *trailing_ptr;
  /*
   * A column (transposed) of the output MA matrix
   *                        |- ma_ptr
   *                        v
   *	[o1 o2 o3 o4 o5 o6 o7 o8 o9 o10 o11 o12 o13 o14 ...]'
   *
   * Pointers to the output data:
   * ma_ptr points to the next output to be created.  Depending upon the
   *   value of shift, it is somewhere between the positions corresponding
   *   to starting_ptr and trailing_ptr:
   *
   *                        |- ma_ptr
   *                        v
   *	[o1 o2 o3 o4 o5 o6 o7 o8 o9 o10 o11 o12 o13 o14 ...]'
   *	[c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 ...]'
   *             ^                         ^
   *             |-- trailing_ptr          |-- starting_ptr
   * 
   * ma_base points to row 1, col 1 in the matrix and is used to
   *   compute ma_ptr's starting position in each column.
   */
  double *ma_base, *ma_ptr;
  double	running_sum;
  
  /* Access data and error checking */
  if (nrhs < MinInArgCount || nrhs > MaxInArgCount)
    mexErrMsgTxt("Invalid number of input arguments");

  if (mxIsComplex(prhs[DataPos]))
    mexErrMsgTxt("MA of a complex sequence not supported.");
  if (! mxIsDouble(prhs[DataPos]))
    mexErrMsgTxt("MA of non double matrices not supported.");

  if (! mxIsDouble(prhs[NPos]) || mxIsComplex(prhs[NPos]) ||
      mxGetM(prhs[NPos]) != 1 || mxGetN(prhs[NPos]) != 1)
    mexErrMsgTxt("Window size must be a real scalar double.");
  
  rows = mxGetM(prhs[DataPos]);
  cols = mxGetN(prhs[DataPos]);
  N = (int) mxGetScalar(prhs[NPos]);	/* convert to int */

  Shift = (nrhs > ShiftPos) ?
    (int) mxGetScalar(prhs[ShiftPos]) : 0;
    
  if (Shift > rows)
      mexErrMsgTxt("Row size must be greater than Shift.");

  plhs[MAPos] = mxCreateDoubleMatrix(rows, cols, mxREAL);

  ma_base = mxGetPr(plhs[MAPos]);
  data_base = mxGetPr(prhs[DataPos]);

  for (c=0; c < cols; c++) {
    ma_ptr = ma_base + c * rows;	/* top row of c'th column */
    trailing_ptr = leading_ptr = data_base + c * rows;
    running_sum = 0.0;

    /* If non causal, add first Shift frames to the running sum -------- */
    r = 0;
    while (r < Shift && r < rows) {
      r++;
      running_sum += *leading_ptr++;
    }

    /* Process enough samples such that the N point window is filled ------ */
    while (r < N && r < rows) {
      r++;
      running_sum += *leading_ptr++;
      *ma_ptr++ = running_sum / r;
    }

    /* process until leading edge at end -------- */

    while (r < rows) {
      running_sum -= *trailing_ptr++;		/* pull out trailing edge */
      running_sum += *leading_ptr++;		/* add leading edge */
      *ma_ptr++ = running_sum / N;
      r++;
    }

    /*
     * If non causal, the leading edge of the window will reach
     * the end before we have computed all the moving averages.
     * Complete by shifting out trailing edges.  In some cases,
     * the MA process may be so long that the left side was 
     * never filled.
     */
    if (Shift) {
      missing_samples = r - N;   /* < 0 indicates # missing */
      Length = min(rows, N);		/* Current window size */
      
      for (Remaining = Shift; Remaining > 0; Remaining--) {
        if (missing_samples < 0) {
          missing_samples++;
        } else {
          /* trailing edge in N point window */
          running_sum -= *trailing_ptr++;      /* pull out trailing edge */
          Length--;
        }
        *ma_ptr++ = running_sum / Length;
      }
    }
  }
}

