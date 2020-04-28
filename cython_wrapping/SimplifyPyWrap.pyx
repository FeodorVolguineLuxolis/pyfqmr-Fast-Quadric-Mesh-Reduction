distutils: language = "c++"

##from SimplifyPy cimport SimplifyMeshReduction

import  cython
from    copy          import  deepcopy
cimport SimplifyPy
from    libcpp.vector cimport vector
from    cpython       cimport Py_buffer
import  numpy
cimport numpy
import  trimesh


#@cython.boundscheck(False)
#@cython.wraparound(False)
cdef class SimplifyPy:
    cdef SimplifyPy obj
    cdef numpy.ndarray[double, mode="c"]  vertsVectNp  # C style array
    cdef numpy.ndarray[int, mode="c"]     facesVectNp  # C style array
    cdef int len_verts
    cdef int len_faces

    def __cinit__(self, triMesh):
        self.vertsVectNp = deepcopy(triMesh.vertices).flatten().dtype(float)
        self.facesVectNp = deepcopy(triMesh.faces).flatten().dtype(int)
        self.len_verts   = len(self.vertsVectNp)
        self.len_faces   = len(self.facesVectNp)

        self._simplifyCpp = new SimplifyMeshReduction()
        #if self._simplifyCpp == NULL :
        #    raise MemoryError('Not Enough Memory')
        # set parameters for reduction
        self._simplifyCpp.set_values_from_CArray(self.vertsVectNp, self.len_verts,
                                                self.facesVectNp, self.len_faces)

    def __del__(self):
        del self._simplifyCpp

    property verts_C :
        # only to get the reduced mesh parameters
        def __get__(self):
            return self._simplifyCpp.getVertsCContiguous()

    property faces_C :
        # only to get the reduced mesh parameters
        def __get__(self):
            return self._simplifyCpp.getFacesCContiguous()








'''cdef class Matrix2D:
    ## class taken from "http://docs.cython.org/en/latest/src/userguide/buffer.html"
    cdef Py_ssize_t ncols
    cdef Py_ssize_t shape[2]
    cdef Py_ssize_t strides[2]
    cdef vector[float] v

    def __cinit__(self, Py_ssize_t ncols):
        self.ncols = ncols
        self.view_count = 0

    def add_row(self):
        self.v.resize(self.v.size() + self.ncols)

    def __getbuffer__(self, Py_buffer *buffer, int flags):
        cdef Py_ssize_t itemsize = sizeof(self.v[0])

        self.shape[0] = self.v.size() / self.ncols
        self.shape[1] = self.ncols

        # Stride 1 is the distance, in bytes, between two items in a row;
        # this is the distance between two adjacent items in the vector.
        # Stride 0 is the distance between the first elements of adjacent rows.
        self.strides[1] = <Py_ssize_t>(  <char *>&(self.v[1])
                                       - <char *>&(self.v[0]))
        self.strides[0] = self.ncols * self.strides[1]

        buffer.buf = <char *>&(self.v[0])
        buffer.format = 'f'                     # float
        buffer.internal = NULL                  # see References
        buffer.itemsize = itemsize
        buffer.len = self.v.size() * itemsize   # product(shape) * itemsize
        buffer.ndim = 2
        buffer.obj = self
        buffer.readonly = 0
        buffer.shape = self.shape
        buffer.strides = self.strides
        buffer.suboffsets = NULL                # for pointer arrays only

        self.view_count += 1

    def __releasebuffer__(self, Py_buffer *buffer):
        self.view_count -= 1

'''
