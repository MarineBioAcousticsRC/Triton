/*
 * stQuickSelect
 * see stQuickSelect.m for usage
 *
 * This is currently only implemented for real vectors.
 * It would be fairly easy to add other types, but this is all we need for now.
 *
 * See Stefan Bird's excellent quick select tutorial or a standard
 * algorithm text for more information on the algorithm.
 *
 * Stefan Bird's quick select description:
 * http://goanna.cs.rmit.edu.au/~stbird/Tutorials/QuickSelect.html
 *
 * Author:  Marie Roch, 2009
 *
 * Benchmark:  Intel Core 2 Duo U9600 w/ 4 GB RAM, Windows Vista 64
 * lightly loaded machine, averaged over 1e6 iterations
 * Benchmark vector size 1000 averaged over 1000000.000000 iterations
 * Matlab's built-in quicksort 96.466432 us/call
 * stQuickSelect 33.266379 us/call
 * stQuickSelect / sort: 0.344849
 * compiled with:  mex -O -inline -largeArrayDims stQuickSelect.cpp
 *
 * N=1000; I=1e6;
 * inner = 100;
 * outer = I/inner;
 * tsort = 0;
 * tselect = 0;
 * for m=1:outer
 *   x = randperm(N);
 *   
 *   tic;
 *   for n=1:inner
 *     s = sort(x);
 *   end
 *   tsort = tsort + toc;
 *   
 *   tic;
 *   for n=1:inner
 *     % rem(n,N)+1 is fairly quick, about .146 us per call on
 *     % on the test machine 
 *     v = stQuickSelect(x, rem(n,N)+1);
 *   end
 *   tselect = tselect + toc;
 * end
 * fprintf('Benchmark vector size %d averaged over %f iterations\n', N, I);
 * fprintf('quicksort %f us/call\n', tsort);
 * fprintf('stQuickSelect %f us/call\n', tselect);
 * fprintf('stQuickSelect / sort: %f\n', tselect / tsort)
 *
 */

#include <mex.h>
#include <matrix.h>
#include <stdio.h>
#include <math.h>
#include <memory.h>

// These will need to be redefined if you wish to handle
// non-primitive types.
#define min(A,B)	(((A) < (B)) ? (A) : (B))
#define max(A,B)	(((A) > (B)) ? (A) : (B))
#define swap(A,B,Temp)  (Temp) = A; (A) = B; (B) = Temp

/* return index of median(V[i], V[j], V[k]) */
template<class T> 
int median(T V[], mwSize i, mwSize j, mwSize k) {
  mwSize median_idx;
  if (V[i] < V[j]) {
    if (V[j] < V[k])
      median_idx = j;
    else
      // V[j] > V[i] && V[j] > V[k]
      median_idx = (V[i] > V[k]) ? i : k;
  } else {
    // V[i] > V[j]
    if (V[j] > V[k])
      median_idx = j;  // V[i] > V[j] > V[k]
    else
      median_idx = (V[i] < V[k]) ? i : k; // V[i] > V[j]  V[k] > V[j]
  }
  return median_idx;
}

// debug - dump section of array
// only designed for very small arrays,
// e.g. v = stQuickSelect(randperm(20), 10)
template<class T>
void print_array(T V[], mwSize nth, mwSize first, mwSize last) 
{
  int bufidx = 0;
  for (int i=first; i <= last; i++) {
    mexPrintf("%2d ", i);
  }
  mexPrintf("\n");
  for (mwSize i=first; i <= last; i++) {
    mexPrintf("%2d ", static_cast<int>(V[i]));
  }
  mexPrintf("\n");
}

template<class T> 
void QuickSelect(T V[], mwSize nth, mwSize first, mwSize last)
{
  T swap_tmp;

  if ((last - first) >= 2) {
    // non-trivial case, 3 or more elements
    mwSize pivot;


    // at least 3 items, pick pivot as median of
    // first, middle, and last elements.
    mwSize middle = (last + first) / 2;
    if (V[first] < V[middle]) {
      if (V[middle] < V[last])
	pivot = middle;
      else
	// V[middle] > V[first] && V[middle] > V[last]
	pivot = (V[first] > V[last]) ? first : last;
    } else {
      // V[first] > V[middle]
      if (V[middle] > V[last])
	pivot = middle;  // V[first] > V[middle] > V[last]
      else {
	// V[first] > V[middle]  V[last] > V[middle]
	pivot = (V[first] < V[last]) ? first : last; 
      }
    }

    // move pivot to far right
    if (pivot != last) {
      swap(V[pivot], V[last], swap_tmp);
    }
      
    bool done = false;
    mwSize left = first;
    mwSize right = last - 1;
      
    done = left >= right;
    while (! done) {
      // move left index right until we have something larger than
      // the pivot or we meet right index
      while (left < right && V[left] <= V[last])
	left++;
      // move the right index left until we have something smaller
      // than the pivot or we meet the left index
      while (right > left && V[right] >= V[last])
	right--;
	
      // If left and right have not converged, we need to 
      done = left >= right;
      if (! done) {
	// V[left] > pivot && V[right] <= pivot, swap
	swap(V[left], V[right], swap_tmp);
      }
    }
      
    // swap the pivot with the left/right index
    swap(V[left], V[last], swap_tmp);

    //#define DEBUG
#ifdef DEBUG
    mexPrintf("Partitioned:  left=%d right=%d, nth=%d, pivot=%g\n",
	      left, right, nth, V[left]);
    print_array(V, nth, first, last); // debug
#endif

    if (left == nth) {
      return;	// V[left] is the Nth element in a sorted vector
    } else if (nth < left) {
      QuickSelect(V, nth, first, left-1);  // must be in left side
    } else {
      QuickSelect(V, nth, left+1, last);
    }
  } else {
    // trivial case:  only 1 or 2 elements
    if (first < last) {
      // 2 elements, swap if out of order
      if (V[first] > V[last]) {
	swap(V[first], V[last], swap_tmp);
      }
    }
  }
  return;
}

/*
 * value = stQuickSelect(Vector, Nth)
 *
 * Vector must be a vector of doubles, Nth specifies which
 * element of a sorted array is to be used.  Following Matlab
 * convention, 1 <= Nth <= length(Vector)
 */

void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  /* Verify arguments */
  if (nlhs != 1)
    mexErrMsgIdAndTxt("STat:", "Output value required");
  if (nrhs != 2)
    mexErrMsgIdAndTxt("STat:", "Vector and position required");
  
  /* positional parameter indices */
  const int	VectorPos = 0;		// In
  const int	NthPos = 1;
  const int	NthValuePos = 0;	// Out
  
  // check inputs
  const mxArray *vector_mx = prhs[VectorPos];
  const mxArray *nth_mx = prhs[NthPos];

  if (! mxIsDouble(vector_mx) || mxIsComplex(vector_mx))
    mexErrMsgIdAndTxt("STat", "Input vector must be real and double");
  if (min(mxGetM(vector_mx), mxGetN(vector_mx)) != 1)
    mexErrMsgIdAndTxt("STat", "Expecting input vector");

  size_t size = max(mxGetM(vector_mx), mxGetN(vector_mx));


  if (! mxIsDouble(nth_mx) || mxIsComplex(nth_mx))
    mexErrMsgIdAndTxt("STat", "Nth must be real and double");
  if (mxGetM(nth_mx) != 1 || mxGetN(nth_mx) != 1)
    mexErrMsgIdAndTxt("STat", "Nth must be scalar");


  // make a copy as the resultant vector will be partially sorted.
  double *v = static_cast<double *>
    (mxMalloc(sizeof(double) * size));  // returns on failure
  memcpy(v, mxGetPr(vector_mx), sizeof(double)*size);

  int nth = static_cast<int>(*mxGetPr(nth_mx));
  if (nth < 1 || nth > size)
    mexErrMsgIdAndTxt("STat", "Nth out of range");
  else
    nth = nth - 1;  // Matlab starts index 1, C++ index 0
  
  // create output scalar and grab pointer
  plhs[NthValuePos] = mxCreateDoubleMatrix(1, 1, mxREAL);
  double *result = mxGetPr(plhs[NthValuePos]);
  
  // perform partial sort of vector.
  // v[nth] is guaranteed to be in the correct place.
  QuickSelect(v, static_cast<mwSize>(nth), 0, size - 1);
  *result = v[nth];
  mxFree(v);
  
}

