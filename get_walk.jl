x=readdlm("RunStatus1")
iter=0
for i=1:length(x[:,1])
	x[i,6]=="Epw"?iter=iter+1:iter=iter+0
end

temp=cell(1,3)
walk=cell(iter,3)
walk[1,:]=[1 2 3]

i=2;j=1
while j<=length(x[:,1])
	j=j+9
	if x[j,1]=="Replica"
		walk[i,:]=walk[i-1,:]
	elseif x[j,2]==1	
		temp[3]=walk[i-1,3];temp[1]=walk[i-1,2];temp[2]=walk[i-1,1]
		walk[i,:]=temp
		j=j+1
	elseif x[j,2]==2
		temp[1]=walk[i-1,1];temp[2]=walk[i-1,3];temp[3]=walk[i-1,2]
		walk[i,:]=temp
		j=j+1
	end
	i=i+1
end