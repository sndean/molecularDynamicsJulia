const R=0.001986;const temp=310;p=0.0000146;repmax=3;
list=readdlm("RepTemp.dat");b1=cell(repmax);scale=cell(repmax)

for rep=1:repmax
	b1[rep]=(1/(R*(list[rep])))
	scale[rep]=(sqrt(b1[rep]/b1[1])/2)
	EPP=readdlm("Epp$rep.dat")
	epw=readdlm("Epw$rep.dat")
	xsc=readdlm("xsc$rep.dat")
	x=xsc[:,2]+xsc[:,14];y=xsc[:,6]+xsc[:,15];z=xsc[:,10]+xsc[:,16];
	XSC=cell(length(x));EPW=cell(length(x));total=cell(length(250));vol=cell(length(x))
	for i=1:length(x)
		XSC[i]=x[i]*y[i]*z[i]
		EPW[i]=epw[i]*scale[rep]
	end
	vol=XSC*p
	total=EPP+EPW+vol
	writedlm("total_hist$rep.dat",total)
end

#x=readdlm("total_hist1.dat")
#plot(x)


#...Epp + 1/2(Beta0/Betam)^(1/2)*Epw + pV..//////////////////////////////////////////////