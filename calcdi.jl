# this is the triple function in julia
# index=[1 3]
# index3=[1 2 3 7 8 9]

#index0 = cell(1, size(index,2)*3)
#index0[1:3:end] = 3.*(index-1) + 1
#index0[2:3:end] = 3.*(index-1) + 2
#index0[3:3:end] = 3.*(index-1) + 3

###############################################

#quad = [5 6 7 8; 6 7 8 9]

function calcdihedral(x,y)
nstep = size(x, 1)
nquad = size(y, 1)
dihedral = cell(nstep, nquad)

for iquad = 1:nquad
  index1 = triple(quad[iquad, 1])
  index2 = triple(quad[iquad, 2])
  index3 = triple(quad[iquad, 3])
  index4 = triple(quad[iquad, 4])
  for istep = 1:nstep
    d1 = trj[istep, vec(int64(index1))] - trj[istep, vec(int64(index2))]
    d2 = trj[istep, vec(int64(index3))] - trj[istep, vec(int64(index2))]
    d3 = trj[istep, vec(int64(index3))] - trj[istep, vec(int64(index4))]
    m1 = cross(vec(d1), vec(d2))
    m2 = cross(vec(d2), vec(d3))
    dihedral[istep, iquad] = float64(acos(dot(m1, m2)./(norm(m1).*norm(m2))))
    rotdirection = float64(dot(vec(d2),cross(m1, m2)))
    if rotdirection < 0
      dihedral[istep, iquad] = - dihedral[istep, iquad]
    end
  end
end
return dihedral
end

