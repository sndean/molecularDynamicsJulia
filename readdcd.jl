frames=3
fid = open("val_test.dcd")
seekend(fid)
eof = position(fid)
seekstart(fid)
bof = position(fid)

header_blocksize1 = read(fid,Int32,1)[1]
header_hdr = read(fid,Int8,4)

# the total # of frames
header_nset = read(fid,Int32,1)
# starting time-step
header_istrt = read(fid,Int32,1)
# frequency to save trajectory
header_nsavc = read(fid,Int32,1)
# the total # of simulation step
header_nstep = read(fid,Int32,1)[1]
# null4 (int*4)
header_null4 = read(fid,Int32,4)
 # # of degrees of freedom
header_nfreat = read(fid,Int32,1)
# step-size of simulation
header_delta = read(fid,Float32,1)
# null9 (int*9)
header_null9 = read(fid,Int32,9)
# version?
header_version = read(fid,Int32,1)
# mark the current position
marking = position(fid)

# these are true... charmm
header_is_charmm = true
header_is_charmm_extrablock = true
# make "current of file" cof (should return 88)
cof = position(fid)
# go to the beginning, then 48 down from there
seek(fid,bof)
seek(fid,48)
# should return "1"
n = read(fid,Int32,1)
# go back to 88
seek(fid,cof)
# blocksize1
blocksize1 = read(fid,Int32,1)
# blocksize2 
header_blocksize2 = read(fid,Int32,1)
# ntitle
header_ntitle = read(fid,Int32,1)[1]
# long output, moving down the file
header_title = read(fid,Int8,header_ntitle*80)
# blocksize2
blocksize2 = read(fid,Int32,1)
# blocksize3
header_blocksize3 = read(fid,Int32,1)
# number of atoms in the system
header_natom = read(fid,Int32,1)[1]
# blocksize3
blocksize3 = read(fid,Int32,1)
# mark second position
marking2 = position(fid)

# since "header_is_charmm_extrablock" is true
if header_is_charmm_extrablock
  blocksize = read(fid,Int32,1)
  dummy = read(fid,Float64,6)
  blocksize = read(fid,Int32,1)
end

# read x coordinates
blocksize = read(fid,Int32,1)
x = read(fid,Float32,2422)
blocksize = read(fid,Int32,1)

# read y coordinates
blocksize = read(fid,Int32,1)
y = read(fid,Float32,2422)
blocksize = read(fid,Int32,1)

# read z coordinates
blocksize = read(fid,Int32,1)
z = read(fid,Float32,2422)
blocksize = read(fid,Int32,1)

# mark third position
marking3 =position(fid)

# number of atoms
natom = header_natom
index = 1:natom

# buffer size is about 1 gigabyte
nblock = int64(ceil(10^9/(8*natom*3)))
trj = cell(frames,(natom*3))
box_buffer = cell(nblock,3)

# move x y z coordinates to trj_buffer
istep = 1
trj[istep, 1:3:end] = x
trj[istep, 2:3:end] = y
trj[istep, 3:3:end] = z
istep = istep + 1

# read next steps
while true
  cof = position(fid)
  if eof == cof
    break
  end
  
  # read charmm extrablock (unitcell info)
  if header_is_charmm_extrablock
    blocksize = read(fid,Int32,1)
    dummy = read(fid,Float64,6)
    blocksize = read(fid,Int32,1)
  end

  # read x coordinates
  blocksize = read(fid,Int32,1)[1]
  x = read(fid,Float32,natom)
  blocksize = read(fid,Int32,1)[1]

  # read y coordinates 
  blocksize = read(fid,Int32,1)[1]
  y = read(fid,Float32,natom)
  blocksize = read(fid,Int32,1)[1]

  # read z coordinates 
  blocksize = read(fid,Int32,1)[1]
  z = read(fid,Float32,natom)
  blocksize = read(fid,Int32,1)[1]

# add the next frames' coordinates to trj_buffer
trj[istep, 1:3:end] = x
trj[istep, 2:3:end] = y
trj[istep, 3:3:end] = z
istep = istep + 1

end
#trj=cell(header_nstep,(natom*3))
#trj = trj_buffer[1:header_nstep,:]



##################################################








