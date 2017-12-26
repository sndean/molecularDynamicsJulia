function phi_psi(quad)
	dihedral = calcdihedral(trj,quad)
	phi = dihedral[:,1].*180./pi
	psi = dihedral[:,2].*180./pi
	g=open("phi.dat","w")
	writedlm(g,(phi))
	close(g)
	f=open("psi.dat","w")
	writedlm(f,(psi))
	close(f)
end