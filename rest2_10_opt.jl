const tmin=310;tmax=600;const n=3;repstep=1;repstepmax=5;analysis_interval=3
batch=1;const R=0.001986;const runlen=20;const runn=1;sf="starting_files";
b1=cell(n);b2=cell(n);b3=cell(n);list=cell(n); iexchange_list=cell(repstepmax); #####
optstepmax=4;optdelta=100;optmin=0.25;optmax=0.30  ######

for optstep=1:optstepmax ######

	for i=1:n; list[i]=tmin*exp((i-1)*log(tmax/tmin)/(n-1)); end;
	writedlm("RepTemp.dat",list)
	for i=1:n; b1[i]=(1/(R*(list[i])));b2[i]=(sqrt(b1[1])/b1[i]);b3[i]=(b1[1]/b1[i]); end
	for s=1:n
		x=readdlm("$sf/body.psf");r = Array(String,0);
		for i in 1:size(x,1)
			x[i,2]=="WT1"?x[i,7]=x[i,7]*b2[s]:x[i,7]=x[i,7]
			push!(r,@sprintf("%8d %-4s %-4d %-s %-4s %-5s %+2.6f %13.4f %11d",
			x[i,1],x[i,2],x[i,3],x[i,4],x[i,5],x[i,6],x[i,7],x[i,8],x[i,9])) 
		end; writedlm("$sf/body$s.psf",r);
		run(pipe(`cat $sf/head.psf $sf/body$s.psf $sf/tail.psf`,"combine$s.psf"))
	end
	for i=1:n
		scaled_OT=b3[i]*-0.1521;scaled_HT=b3[i]*-0.046
		x=readdlm("$sf/OT.prm");x[3]=scaled_OT;y=readdlm("$sf/HT.prm");y[3]=scaled_HT
		writedlm("$sf/OT$i.prm",x);writedlm("$sf/HT$i.prm",y);
		run(pipe(`cat $sf/head.prm $sf/HT$i.prm $sf/OT$i.prm $sf/tail.prm`,"par$i.prm"))
	end
	x=readdlm("$sf/body.pdb");s=Array(String,0);
	for i in 1:size(x,1)
		x[i,12]=="P1"?x[i,11]=1.0:x[i,11]
		push!(s,@sprintf("%s %6s %4s %1s %3s %11s %7.3f %7.3f %5.2f %5.2f %7s %3s",
		x[i,1],x[i,2],x[i,3],x[i,4],x[i,5],x[i,6],x[i,7],x[i,8],x[i,9],x[i,10],x[i,11],x[i,12])) 
	end
	writedlm("$sf/body2.pdb",s);
	run(pipe(`cat $sf/head.pdb $sf/body2.pdb $sf/tail.pdb`,"pair.pdb"))
	for i=1:n
		rm("abf_quench_template$i.namd");rm("abf_quench_templateEpp$i.namd");
		rm("abf_quench_templateEpw$i.namd");
		cp("$sf/abf_quench_template.namd","abf_quench_template$i.namd")
		cp("$sf/abf_quench_templateEpp.namd","abf_quench_templateEpp$i.namd")
		cp("$sf/abf_quench_templateEpw.namd","abf_quench_templateEpw$i.namd")
		x=readall("abf_quench_template$i.namd");y=readall("abf_quench_templateEpp$i.namd")
		z=readall("abf_quench_templateEpw$i.namd")
		st=["FinalFile" "RepTemp" "RunLength" "RestartFile" "OutputFrequency" "Param1" "PSF"]
		en=["abf_quench$i" list[i] "$runlen" "abf_quench$i\_i" "$runlen" "par$i.prm" "combine$i.psf"]
		for j=1:length(en)
			x=replace(x,st[j],en[j]);y=replace(y,st[j],en[j]);z=replace(z,st[j],en[j]);
		end
		t=open("abf_quench_template$i.namd","w");println(t,(x));close(t)
		u=open("abf_quench_templateEpp$i.namd","w");println(u,(y));close(u)
		v=open("abf_quench_templateEpw$i.namd","w");println(v,(z));close(v)
	end
	# Running replica steps /////////////////////////////////////////////////////////////////
	if repstep==1; rm("RunStatus$batch"); end
	for repstep=1:repstepmax
		rs=("Replica step: $repstep");rstat=open("RunStatus$batch","a")
		println(rstat,(rs));close(rstat)
	 	for rep=1:n
	  		reptemp=list[rep]
	  		println("$repstep $rep $reptemp")
	  		s=("$repstep $runn");statu=open("status.dat","w");println(statu,(s));close(statu)
	  		if repstep<10
	    		repstepi="000$repstep"
	  		elseif repstep>=10 
	    		if repstep<100 
	        		repstepi="00$repstep"
				elseif repstep>=100 
	    			if repstep<1000 
	      				repstepi="0$repstep"
	  				elseif repstep>=1000 
	      				repstepi="$repstep"
	      			end
	      		end
	  		end
		x=readall("abf_quench_template$rep.namd");
		y=readall("abf_quench_templateEpp$rep.namd");
		z=readall("abf_quench_templateEpw$rep.namd");
		st=["RandSeed" "DCDFile"];en=["41$runn$repstep$rep" "$runn\_$repstepi\_$rep"]
		for j=1:length(en)
			x=replace(x,st[j],en[j]);y=replace(y,st[j],en[j]);z=replace(z,st[j],en[j]);
		end
		t=open("abf_quench$rep.namd","w");println(t,(x));close(t)
		u=open("abf_quenchEpp$rep.namd","w");println(u,(y));close(u)
		v=open("abf_quenchEpw$rep.namd","w");println(v,(z));close(v)
		# Checking that abf_quench$rep.namd does exist..///////////////////////////////////
	  	ready=0
	  	while ready==0
	      	nlines=readdlm("abf_quench$rep.namd"); nlines[46,1]=="wrapAll"?ready=1:ready=0
	  	end
	  	@async run(pipe(`./namd2 +p1 abf_quench$rep.namd`,"abf_quench$rep.out"))
	  	rs=("sending replica $rep $reptemp");rstat=open("RunStatus$batch","a")
		println(rstat,(rs));close(rstat)
		end
		sleep(1)
		# Checking if all replicas are done..////////////////////////////////////////////////
	 	for rep=1:n; comp=0
	 		while comp<1		
	      		pot=readdlm("abf_quench$rep.out")
	      		pot[end,1]=="Program"?comp=comp+=1:sleep(0.001)
	      	end
	 	end
	  	rs=("Replica step: $repstep completed");rstat=open("RunStatus$batch","a")
		println(rstat,(rs));close(rstat)
		# abf_quench_Epp$rep.namd and abf_quench_Epw$rep.namd..////////////////////////// 
	 	for rep=1:n
	 		run(pipe(`./namd2 +p1 abf_quenchEpp$rep.namd`,"abf_quenchEpp$rep.out"))
			run(pipe(`./namd2 +p1 abf_quenchEpw$rep.namd`,"abf_quenchEpw$rep.out"))
	  		rs=("   sending replica $rep Epp Epw");rstat=open("RunStatus$batch","a")
			println(rstat,(rs));close(rstat)
	 	end
	 	# Checking if quench_Epp and quench_Epw are done..///////////////////////////////////
	 	for rep=1:n; comp=0
	 		while comp<1		
	      		epp=readdlm("abf_quenchEpp$rep.out");epw=readdlm("abf_quenchEpw$rep.out")
	      		epp[1,1]=="Charm++:" && epw[1,1]=="Charm++:"?comp=comp+=1:sleep(0.001)
	      	end
	 	end
	 	rs=("   Replica step: $repstep completed Epp Epw");rstat=open("RunStatus$batch","a")
		println(rstat,(rs));close(rstat)
		#...getting total, Epp, Epw, and box..///////////////////////////////////////////////
		if repstep!=1; rm("RepBox.dat"); rm("RepEnergy.dat"); end
	    for rep=1:n
	    	if repstep==1;rm("Pot$rep.dat");rm("Epw$rep.dat");
	    		rm("Epp$rep.dat");rm("xsc$rep.dat");end
	   		pot=readdlm("abf_quench$rep.out");Pot=cell(1)
	   		for i=1:length(pot[:,1]);
	   			pot[i]=="ENERGY:"&&pot[i,2]==runlen?Pot=(pot[i,14]):print("");end
	   		Potou=open("Pot$rep.dat","a");println(Potou,(Pot));close(Potou)
	   		epw=readdlm("abf_quenchEpw$rep.out");Epw=cell(1)
	   		for i=1:length(epw[:,1]);
	   			epw[i]=="ENERGY:"&&epw[i,2]==runlen?Epw=(epw[i,14]):print("");end
	   		Epwou=open("Epw$rep.dat","a");println(Epwou,(Epw));close(Epwou)
	   		epp=readdlm("abf_quenchEpp$rep.out");Epp=cell(1)
	   		for i=1:length(epp[:,1]);
	   			epp[i]=="ENERGY:"&&epp[i,2]==runlen?Epp=(epp[i,14]):print("");end
	   		Eppou=open("Epp$rep.dat","a");println(Eppou,(Epp));close(Eppou)
	    	xs=readdlm("abf_quench$rep.xsc");xyz=cell(1,3);getxsc=[2 6 10]
	    	for i=1:length(getxsc)
	       		xyz[i]=(xs[getxsc[i]])
	   		end
			Xyz=open("RepBox.dat","a");
			println(Xyz,@sprintf("%3.5f%10.5f%10.5f",xyz[1],xyz[2],xyz[3]));close(Xyz)
			Xsc=open("xsc$rep.dat","a");println(Xsc,xs);close(Xsc)
		end
		Epp=cell(n);Epw=cell(n);
		for rep=1:n
	   		EppStep=readdlm("Epp$rep.dat");Epp[rep]=EppStep[repstep]
	   		EpwStep=readdlm("Epw$rep.dat");Epw[rep]=EpwStep[repstep]
	   		Xx=open("RepEnergy.dat","a");
	   		println(Xx,@sprintf("%2.5f%13.5f%13.5f",b1[rep], Epp[rep], Epw[rep]));close(Xx)
		end
	    #...attempting exchange..////////////////////////////////////////////////////////////
	 	run(pipe("status.dat",`./exchange_rest2_npt.exe`, "exchange_out"))
		for np=1:countlines("exchange_out")
			run(pipe(`head -$np exchange_out`,`tail -1`,"exchange_out_temp"))
		   	exc=round(Int64,readdlm("exchange_out_temp"));
		   	rep1=exc[1];rep2=exc[2];iexchange=exc[3];
		   	iexchange_list[repstep]=iexchange
		   	if iexchange==1
		   		run(`mv abf_quench$rep1.coor restart_coor1`)
		    	run(`mv abf_quench$rep2.coor restart_coor2`)
		    	run(`mv restart_coor1 abf_quench$rep2.coor`)
		    	run(`mv restart_coor2 abf_quench$rep1.coor`)
		    	run(`mv abf_quench$rep1\s.vel abf_quench$rep1.vel`)
		    	run(`mv abf_quench$rep2\s.vel abf_quench$rep2.vel`)
		    	run(`mv abf_quench$rep1.xsc restart_xsc1`)
		    	run(`mv abf_quench$rep2.xsc restart_xsc2`)
		    	run(`mv restart_xsc1 abf_quench$rep2.xsc`)
		    	run(`mv restart_xsc2 abf_quench$rep1.xsc`)
	 			rs=("$np $rep1 $rep2 exchange: $iexchange");
	 			rstat=open("RunStatus$batch","a")
				println(rstat,(rs));close(rstat)
			end
		end
		#####
		if repstep==repstepmax
			iexchange_ave=sum(iexchange_list)/repstepmax
			if iexchange_ave < optmin
				tmax=tmax-optdelta
			elseif iexchange_ave > optmax
				tmax=tmax+optdelta
			end
		end
	end
	println(tmax)
	println(iexchange_list)
end
#####


