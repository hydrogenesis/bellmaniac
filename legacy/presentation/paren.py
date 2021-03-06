# autogenerated by bellmaniac
import sys
plus = min
zero = sys.maxint
DIM = 128
MIN = 0
MAX = 1000
from numpy import *

def c(T, oi, oj):
  for i0 in xrange(((-1)*n + 1),1):
    for j0 in xrange(((-1)*i0 + 1),n):
      i = (0 - i0)
      j = j0
      assert ((((0 <= i) and (i < n)) and (i < j)) and (j < n))
      T[(i + oi), (j + oj)] = (x[i] if (i == (j - 1)) else reduce(plus, [((T[(i + oi), (k + oj)] + T[(k + oi), (j + oj)]) + w[i, k, j]) for k in xrange((i + 1), j)], zero))
x = random.randint(MIN, MAX, size=(DIM))
w = random.randint(MIN, MAX, size=(DIM, DIM, DIM))
n = 128
def d1(T, oi, oj, n, w, r, s, t, w_0, w_1, w_2, r_0, r_1, s_0, s_1, t_0, t_1):
  if (n < 4):
    d0(T, oi, oj, n, w, r, s, t, w_0, w_1, w_2, r_0, r_1, s_0, s_1, t_0, t_1)
    return
  # partition
  d1(T, oi, oj, n/2, w, r, s, t, w_0, (n/4 + w_1), w_2, r_0, r_1, s_0, (n/4 + s_1), (n/4 + t_0), t_1)
  d1(T, oi, oj, n/2, w, T, s, t, w_0, w_1, w_2, oi, oj, s_0, s_1, t_0, t_1)
  # partition
  d1(T, oi, (oj + n/4), n/2, w, r, s, t, w_0, w_1, (n/4 + w_2), r_0, (n/4 + r_1), s_0, s_1, t_0, (n/4 + t_1))
  d1(T, oi, (oj + n/4), n/2, w, T, s, t, w_0, (n/4 + w_1), (n/4 + w_2), oi, (oj + n/4), s_0, (n/4 + s_1), (n/4 + t_0), (n/4 + t_1))
  # partition
  d1(T, (oi + n/4), oj, n/2, w, r, s, t, (n/4 + w_0), w_1, w_2, (n/4 + r_0), r_1, (n/4 + s_0), s_1, t_0, t_1)
  d1(T, (oi + n/4), oj, n/2, w, T, s, t, (n/4 + w_0), (n/4 + w_1), w_2, (oi + n/4), oj, (n/4 + s_0), (n/4 + s_1), (n/4 + t_0), t_1)
  # partition
  d1(T, (oi + n/4), (oj + n/4), n/2, w, r, s, t, (n/4 + w_0), w_1, (n/4 + w_2), (n/4 + r_0), (n/4 + r_1), (n/4 + s_0), s_1, t_0, (n/4 + t_1))
  d1(T, (oi + n/4), (oj + n/4), n/2, w, T, s, t, (n/4 + w_0), (n/4 + w_1), (n/4 + w_2), (oi + n/4), (oj + n/4), (n/4 + s_0), (n/4 + s_1), (n/4 + t_0), (n/4 + t_1))
def b1(T, oi, oj, n, w, r, s, t, w1, w_0, w_1, w_2, r_0, r_1, s_0, s_1, t_0, t_1, w1_0, w1_1, w1_2):
  if (n < 4):
    b0(T, oi, oj, n, w, r, s, t, w1, w_0, w_1, w_2, r_0, r_1, s_0, s_1, t_0, t_1, w1_0, w1_1, w1_2)
    return
  # partition
  b1(T, (oi + n/4), (oj + n/4), n/2, w, r, s, t, w1, (n/4 + w_0), (n/4 + w_1), (n/4 + w_2), (n/4 + r_0), (n/4 + r_1), (n/4 + s_0), (n/4 + s_1), (n/4 + t_0), (n/4 + t_1), (n/4 + w1_0), (n/4 + w1_1), (n/4 + w1_2))
  # partition
  d1(T, oi, (oj + n/2), n/2, w1, r, s, T, w1_0, (n/4 + w1_1), (n/2 + w1_2), r_0, (n/2 + r_1), s_0, (n/4 + s_1), (oi + n/4), (n/2 + oj))
  b1(T, oi, (oj + n/4), n/2, w, T, s, t, w1, w_0, (n/4 + w_1), (n/4 + w_2), oi, (n/4 + oj), s_0, s_1, (n/4 + t_0), (n/4 + t_1), w1_0, w1_1, (n/4 + w1_2))
  # partition
  d1(T, (oi + n/4), (oj + 3*n/4), n/2, w, r, T, t, (n/4 + w_0), (n/2 + w_1), (3*n/4 + w_2), (n/4 + r_0), (3*n/4 + r_1), (oi + n/4), (n/2 + oj), (n/2 + t_0), (3*n/4 + t_1))
  b1(T, (oi + n/4), (oj + n/2), n/2, w, T, s, t, w1, (n/4 + w_0), (n/2 + w_1), (n/2 + w_2), (oi + n/4), (n/2 + oj), (n/4 + s_0), (n/4 + s_1), (n/2 + t_0), (n/2 + t_1), (n/4 + w1_0), (n/4 + w1_1), (n/2 + w1_2))
  # partition
  d1(T, oi, (oj + 3*n/4), n/2, w, r, T, t, w_0, (n/2 + w_1), (3*n/4 + w_2), r_0, (3*n/4 + r_1), oi, (n/2 + oj), (n/2 + t_0), (3*n/4 + t_1))
  d1(T, oi, (oj + 3*n/4), n/2, w1, T, s, T, w1_0, (n/4 + w1_1), (3*n/4 + w1_2), oi, (oj + 3*n/4), s_0, (n/4 + s_1), (oi + n/4), (3*n/4 + oj))
  b1(T, oi, (oj + n/2), n/2, w, T, s, t, w1, w_0, (n/2 + w_1), (n/2 + w_2), oi, (n/2 + oj), s_0, s_1, (n/2 + t_0), (n/2 + t_1), w1_0, w1_1, (n/2 + w1_2))
def c1(T, oi, oj, n, w, r, w_0, w_1, w_2, r_0, r_1):
  if (n < 4):
    c0(T, oi, oj, n, w, r, w_0, w_1, w_2, r_0, r_1)
    return
  # partition
  c1(T, oi, oj, n/2, w, r, w_0, w_1, w_2, r_0, r_1)
  # partition
  c1(T, (oi + n/2), (oj + n/2), n/2, w, r, (n/2 + w_0), (n/2 + w_1), (n/2 + w_2), (n/2 + r_0), (n/2 + r_1))
  # partition
  b1(T, oi, oj, n, w, r, T, T, w, w_0, w_1, w_2, r_0, r_1, oi, oj, oi, oj, w_0, w_1, w_2)
def r(T, oi, oj):
  for i0 in xrange(0,n):
    for j0 in xrange((i0 + 1),n):
      i = i0
      j = j0
      assert ((((0 <= i) and (i < n)) and (i < j)) and (j < n))
      T[(i + oi), (j + oj)] = (x[i] if (i == (j - 1)) else zero)
def c0(T, oi, oj, n, w, r, w_0, w_1, w_2, r_0, r_1):
  for i0 in xrange(((-1)*n + 1),1):
    for j0 in xrange(((-1)*i0 + 1),n):
      i = (0 - i0)
      j = j0
      assert ((((0 <= i) and (i < n)) and (i < j)) and (j < n))
      T[(i + oi), (j + oj)] = plus(reduce(plus, [((T[(i + oi), (k + oj)] + T[(k + oi), (j + oj)]) + w[(i + w_0), (k + w_1), (j + w_2)]) for k in xrange((i + 1), j)], zero), r[(i + r_0), (j + r_1)])
def b0(T, oi, oj, n, w, r, s, t, w1, w_0, w_1, w_2, r_0, r_1, s_0, s_1, t_0, t_1, w1_0, w1_1, w1_2):
  for i0 in xrange(((-1)*n/2 + 1),1):
    for j0 in xrange(n/2,n):
      i = (0 - i0)
      j = j0
      assert (((((0 <= i) and (i < n)) and (i < j)) and (j < n)) and ((i < n/2) and (not (j < n/2))))
      T[(i + oi), (j + oj)] = plus(reduce(plus, [((s[(i + s_0), (k1 + s_1)] + T[(k1 + oi), (j + oj)]) + w1[(i + w1_0), (k1 + w1_1), (j + w1_2)]) for k1 in xrange((i + 1), n/2)] + [((T[(i + oi), (k2 + oj)] + t[(k2 + t_0), (j + t_1)]) + w[(i + w_0), (k2 + w_1), (j + w_2)]) for k2 in xrange(n/2, j)], zero), r[(i + r_0), (j + r_1)])
def d0(T, oi, oj, n, w, r, s, t, w_0, w_1, w_2, r_0, r_1, s_0, s_1, t_0, t_1):
  for i0 in xrange(0,n/2):
    for j0 in xrange(0,n/2):
      i = i0
      j = j0
      assert ((((0 <= i) and (i < n/2)) and (0 <= j)) and (j < n/2))
      T[(i + oi), (j + oj)] = plus(reduce(plus, [((s[(i + s_0), (k + s_1)] + t[(k + t_0), (j + t_1)]) + w[(i + w_0), (k + w_1), (j + w_2)]) for k in xrange(0, n/2)], zero), r[(i + r_0), (j + r_1)])
