x=readdlm("RunStatus1")

iter=0
for i=1:length(x[:,1])
	x[i,6]=="Epw"?iter=iter+1:iter=iter+0
end

count1=0;count2=0;
for i=1:length(x[:,1])
	x[i,1]==1 && x[i,2]==1?count1=count1+1:count1=count1+0
	x[i,1]==1 && x[i,2]==2?count2=count2+1:count2=count2+0
end
println("rate between replicas 1 and 2 ="," ", count1/iter*2)
println("rate between replicas 2 and 3 ="," ", count2/iter*2)
ave=((count1/iter*2)+(count2/iter*2))/2
println("                 average rate ="," ", ave)

