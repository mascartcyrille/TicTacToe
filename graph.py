from itertools import zip_longest
from graph_tool.all import *
from queue import *

# Constants
percent=10

# Data structures
q = []
dic = dict()

# Graph and graph properties
ug = Graph(directed=True)
# ug.set_fast_edge_removal(True)
names = ug.new_vertex_property("string")
shapes = ug.new_vertex_property("string")
colors = ug.new_vertex_property("string")

file = open("graph.txt", "r")
data = file.readlines()

k = 1
acc=1
MAX=100
print("Computing the graph")
for line in data:
	v = line.replace("\t", "").replace("|","").replace("-","").replace(" ","").replace("\n","")
	shap = v[0]
	col = v[0]
	v = v[1:]
	if(len(q)==0):																					# If the queue is empty, means if we are at the root of the tree (game = ".........")
		vroot = ug.add_vertex()
		q.append(v)
		dic[v] = vroot
		names[vroot] = v
		shapes[vroot] = "octagon"
		colors[vroot] = "green"
	else:
		if(not v in dic):
			vchild = ug.add_vertex()
			dic[v] = vchild
			names[vchild] = v
			shapes[vchild] = "circle" if shap == 'O' else "square" if shap == 'X' else "octagon" if shap == 'C' else "triangle"
			colors[vchild] = "red" if shap == 'O' else "blue" if shap == 'X' else "white"
		else:
			vchild = dic.get(v)

		vparent = q.pop()
		while(vparent.count('.') <= v.count('.')):
			vparent = q.pop()

		if(not vchild in dic[vparent].out_neighbors()):
			ug.add_edge(dic.get(vparent), vchild)

		q.append(vparent)
		q.append(v)
	if(k/100*MAX*percent<=acc):
		print("Effectue: ", k*percent, "%")
		k=k+1
	if(acc>MAX):
		break
	acc=acc+1

# Saving properties internally
ug.vp.name = names
ug.vertex_properties["shape"] = shapes
ug.vertex_properties["color"] = colors

# Some stats
# print("Some stats")
# print([names[x] for x in ug.get_out_neighbors(dic["xooo.xoxx"])])
# print([names[x] for x in ug.get_in_neighbors(dic["xooo.xoxx"])])

# Drawing the graph into a png file
print("Drawing the graph...")
# print("Shapes: ", shapes)
# names_prop = ug.new_vertex_property("string")
# shapes_prop = ug.new_vertex_property("string")
# colors_prop = ug.new_vertex_property("string")

print("\t-> Reducing the graph to the minimal vertices and edges")
	# tree = random_spanning_tree(ug, root = ug.vertex(0))
	# ug = GraphView(ug, efilt=tree)
	# # ug = GraphView(ug, vfilt=lambda v: v.out_degree()>0)
	# shapes2 = ug.new_vertex_property("string")
	# names2 = ug.new_vertex_property("string")
	# colors2 = ug.new_vertex_property("string")
	# for v in ug.vertices():
	# # # 	print("Vertex: ", v, ", Prop: ", ug.vp.name[v])
	# 	print("Vertex: ", v, "(name: ", names[v], ", ", v.out_degree(), ")")
	# 	names2[v] = names[v]
	# 	shapes2[v] = shapes[v]
	# 	colors2[v] = colors[v]
	# # ug.vertex_properties["names_prop"] = names_prop
	# ug.vp.name = names2
	# ug.vertex_properties["shape"] = shapes
	# ug.vertex_properties["fill_color"] = shapes

print("Num of edges: ", ug.num_edges())
q = []
def span(s):
	"""
	"""
	# print(names[s], names[t])
	q.append(s)
	for t in s.out_neighbors():
		if(t not in q):
			span(t)
		else:
			if(t not in s.in_neighbors()):
				e=ug.edge(s, t)
				ug.remove_edge(e)
span(ug.vertex(0))
print("Num of edges: ", ug.num_edges())

print("\t-> Setting layout: radial tree")
pos = radial_tree_layout(ug, ug.vertex(0))
# print("Vertices: ", ug.get_vertices(),"\nList properties: ", ug.list_properties(),"\nNum vertices: ", ug.num_vertices(False), "/", ug.num_vertices(True))
print("\t-> Print the graph into file")
graph_draw(ug, pos=pos, vertex_text=ug.vp.name, vertex_shape=ug.vp.shape, vertex_fill_color = ug.vp.color, vertex_font_size=7, vertex_size=2.5, edge_pen_width=5, output_size=(5000, 5000), output="ttt-graph.png")

# print("Computing betweenness")
# vp, ep = betweenness(ug, pivots = [ug.vertex(0)], norm = False)
# print("Vertices: ")
# for v in ug.vertices():
# 	print("(", names[v], ", ", vp[v], ")")
# 	print("\tEdges: ")
# 	for e, w in zip_longest(v.out_edges(), v.out_neighbors()):
# 		print("\t(", names[v], ", ", names[w], ", ", ep[e], ")")

# print("\nComputing closeness")
# vp = closeness(ug, norm = False)
# for v in ug.vertices():
# 	print("(", names[v], ", ", vp[v], ")")
