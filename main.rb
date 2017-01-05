require 'geometry'
require_relative './triangulos'
require_relative './node'
require 'mpi'
node = ARGV[0] # recive el nombre del fichero .node
mesh = ARGV[1] # recive el nombre del fichero .mesh
grado = ARGV[2]
MPI.Init
world = MPI::Comm::WORLD
#node = 'vertices'
#mesh= 'triangulos'
#grado = 12
preproceso = Node.new(node,mesh) # instancia un objeto con los datos node y mesh 
node = preproceso.node # prepocesamiento node
mesh = preproceso.mesh # prepoceso mesh


def toEdge(nodoPrimero,nodoSegundo) # transforma los nodos en objetos edges para poder calcular sus disntancias
  largo1 =[]
  largo2 =[]
  largo1 << nodoPrimero[1] << nodoPrimero[2]
  largo2 << nodoSegundo[1] << nodoSegundo[2]
  geometria = Geometry::Edge.new(largo1,largo2)
  return geometria
end #complejidad O(1)

def get_dimension a  #calcula la dimension del array
  return 0 if a.class != Array
  result = 1
  a.each do |sub_a|
    if sub_a.class == Array
      dim = get_dimension(sub_a)
      result = dim + 1 if dim + 1 > result
    end
  end
  return result
end #complejidad O(n)

def combinaciones(mesh)
  combinacion = []
  dimension = get_dimension mesh
  if dimension == 1 && mesh.length == 3
    combinacion = mesh.combination(2).to_a
  else
    largo = mesh.length
    if largo > 1
      for i in 0..mesh.length-1
        combinacion << mesh[i].combination(2).to_a
      end
    end
  end
  return combinacion
end # complejidad O(2n)

def dividirTriangulosPorNodo(tamano,cantidad)
  ma=[]
  n=[]
  i = 1
  procesador = 0
  
  loop do
    tamano.times do
      ma << i.to_i<<procesador.to_i
      i+=1
    end
    procesador +=1    
    break if i >= cantidad
  end
  loop do
    ma.delete_at(ma.length-1)
    break if cantidad >= ma.length
  end
  return ma
end

uno = toEdge(node[1],node[2])
dos = toEdge(node[1],node[3])
tres = toEdge(node[2],node[3])
t = Triangulos.new(uno.length, dos.length, tres.length, grado.to_i) 
cantidad = mesh[0][0].to_i/world.size
mesh_nodo = dividirTriangulosPorNodo(cantidad.to_i,mesh[0][0].to_i)

j=0
for i in mesh_nodo.length-1
  if j==mesh_nodo[1]
    puts mesh_nodo[]
  end
end
puts mesh_nodo.last

MPI.Finalize



