using Gadfly

phi=(readdlm("phi.dat"))[:,1]
psi=(readdlm("psi.dat"))[:,1]

g=plot(layer(x=phi, y=psi),
	Guide.ylabel("psi"), 
    Guide.xlabel("phi"),  
    Guide.title("Test"),  
	Theme(
     default_point_size=14pt,
     major_label_font_size=14pt,
     minor_label_font_size=14pt,
     default_color=color("orange")),
	Geom.histogram2d(xbincount=30, ybincount=30))
draw(SVGJS("myplot.svg", 6inch, 6inch), g)