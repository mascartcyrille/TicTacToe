from graph_tool.all import *
from queue import *

q = []
dic = dict()

ug = Graph(directed=True)
names = ug.new_vertex_property("string")
shapes = ug.new_vertex_property("string")
colors = ug.new_vertex_property("string")

file = open("example.txt", "r")
data = file.readlines()
k = 1
acc=1
percent=10
for line in data:
	v = line.replace("\t", "").replace("|","").replace("-","").replace(" ","").replace("\n","")
	shap = v[0]
	col = v[0]
	v = v[1:]
	if(len(q)==0):
		vroot = ug.add_vertex()
		q.append(v)
		dic[v] = vroot
		names[vroot] = v
		shapes[vroot] = "octagon"
		colors[vroot] = "green"
	else:
		vparent = q.pop()
		if(not v in dic):
			vchild = ug.add_vertex()
			dic[v] = vchild
			names[vchild] = v
			shapes[vchild] = "circle" if shap == 'O' else "square" if shap == 'X' else "triangle"
			colors[vchild] = "red" if shap == 'O' else "blue" if shap == 'X' else "white"
		else:
			vchild = dic.get(v)
		while(vparent.count('.') <= v.count('.')):
			vparent = q.pop()
		if(not vchild in ug.get_out_neighbors(dic[vparent])):
			ug.add_edge(dic[vparent], vchild)
		q.append(vparent)
		q.append(v)
	if(k/100*len(data)*percent<=acc):
		print("Effectue: ", k*percent, "%")
		k=k+1
	# if(acc>100000):
	# 	break
	acc=acc+1
print("Drawing graph")
pos = radial_tree_layout(ug, ug.vertex(0))
graph_draw(ug, pos=pos, vertex_text=names, vertex_font_size=7, vertex_size=1.5, vertex_shape = shapes, vertex_fill_color = colors, edge_pen_width=2, output_size=(5000, 5000), output="ttt-graph.png")