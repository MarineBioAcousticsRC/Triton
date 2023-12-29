
/*
 * custom memory allocator that uses Matlab's mxMalloc and mxFree
 */

template <class T>
class mex_allocator {
public:
	typedef size_t    size_type;
	typedef ptrdiff_t difference_type;
	typedef T*        pointer;
	typedef const T*  const_pointer;
	typedef T&        reference;
	typedef const T&  const_reference;
	typedef T         value_type;
	long allocs = 0;
	long deallocs = 0;
  

	mex_allocator() {}
	mex_allocator(const mex_allocator&) {}


	/* allocate n instances of size T
	 * second argument is a hint for where we should allocate
	 * and is not implemented
	 */
	pointer   allocate(size_type n, const void * = 0) {
		T* t = (T*) mxMalloc(n * sizeof(T));
		allocs++;
		return t;
	}
	/* deallocate memory block */
	void      deallocate(void* p, size_type) {
		if (p) {
			mxFree(p);
			deallocs++;
		}
	}
	/* get address of argument */
	pointer           address(reference x) const { return &x; }
	/* get address of argument & promise not to modify */
	const_pointer     address(const_reference x) const { return &x; }
	/* assignment - copy address of the allocator */
	mex_allocator<T>&  operator=(const mex_allocator&) { return *this; }
	/* constructor */
	void              construct(pointer p, const T& val)
	{
		new ((T*)p) T(val);
	}
	/* deconstructor */
	void              destroy(pointer p) { p->~T(); }

	size_type         max_size() const { return size_t(-1); }

	template <class U>
	struct rebind { typedef mex_allocator<U> other; };

	template <class U>
	mex_allocator(const mex_allocator<U>&) {}

	template <class U>
	mex_allocator& operator=(const mex_allocator<U>&) { return *this; }
};
