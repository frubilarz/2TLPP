require 'geometry'
require_relative './triangulos'
require_relative './node'
require 'mpi'
if defined?(NumRu::NArray)
  include NumRu
end
#node = ARGV[0] # recive el nombre del fichero .node
#mesh = ARGV[1] # recive el nombre del fichero .mesh
grado = ARGV[0]
MPI.Init
world = MPI::Comm::WORLD
node = 'vertices'
mesh= 'triangulos'
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
  resto = -1*(cantidad%tamano)
  i = 1
  procesador = 0
  loop do
    tamano.times do
      n=[]
      n << i.to_i<<procesador.to_i
      ma << n
      i+=1
    end
    procesador +=1    
    break if i >= cantidad
  end
  for i in ma.length..cantidad
    n=[]
    n << i.to_i<<procesador.to_i
    ma << n
  end
  loop do
    ma.delete_at(ma.length-1)
    break if cantidad >= ma.length
  end
  for i in resto..1 # corrije que no este fuera del rango de procesador
    if i == 0
      break
    end
    ma[i][1]= ((cantidad/tamano).to_i)-1
  end
  return ma
end

def generarPart(mesh)
  File.open('archivo.part','w') do |f|
    f.puts mesh.length.to_s+' '+(mesh[-1][1]+1).to_s
    for i in 0..mesh.length-1
      f.puts mesh[i][0].to_s+' '+(mesh[i][1]+1).to_s
    end
  end
end

def generarEle(mesh)
  File.open('archivo.ele','w') do |f|
    f.puts (mesh.length-1).to_s+' 3'
    for i in 1..mesh.length-1
      f.puts i.to_s+' '+mesh[i][0].to_s+' '+mesh[i][1].to_s+' '+mesh[i][2].to_s
    end
  end
end

def generarNode(node)
  File.open('archivo.node','w') do |f|
    f.puts (node.length-1).to_s+' 2'
    for i in 1..node.length-1
      f.puts i.to_s+' '+node[i][1].to_s+' '+node[i][2].to_s
    end
  end
end

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


def candidatos_a_refinar(mesh,node,grado)
  lista = []
  combinacion = combinaciones(mesh)
  for i in 1..combinacion.length-1
    listaAyuda =[]
    listaAyuda = combinacion[i]
    uno = toEdge(node[listaAyuda[0][0]],node[listaAyuda[0][1]])
    dos = toEdge(node[listaAyuda[1][0]],node[listaAyuda[1][1]])
    tres = toEdge(node[listaAyuda[2][0]],node[listaAyuda[2][1]])
    triangulo = Triangulos.new(uno.length, dos.length, tres.length, grado.to_i)
    lista << triangulo.refinamiento
  end
  return lista
end
def triangulosArefinar(refinar) #indice del triangulo en el vector
  lista=[]
  for i in 0..refinar.length-1
    if refinar[i]==1
      lista<<i+1
    end
  end
  return lista
end #complejidad O(n)

uno = toEdge(node[1],node[2])
dos = toEdge(node[1],node[3])
tres = toEdge(node[2],node[3])
t = Triangulos.new(uno.length, dos.length, tres.length, grado.to_i) 
cantidad = mesh[0][0].to_i/world.size
resto = mesh[0][0].to_i%world.size
mesh_nodo = dividirTriangulosPorNodo(cantidad.to_i,mesh[0][0].to_i)
candidato = candidatos_a_refinar(mesh,node,grado)
triangulos_a_ref = triangulosArefinar(candidato)
generarPart(mesh_nodo)
generarNode(node)
generarEle(mesh)
def pertenezco_al_nodo(tr_a_refinar,mesh_nodo,rank)
  for i in 0..mesh_nodo.size-1
    if tr_a_refinar == mesh_nodo[i][0]
      if rank== mesh_nodo[i][1]
        return 1
      end
    end
  end
  return 0
end

rank = world.rank

for i in 0..rank
  if i == rank
    sum = 0
    a = NArray.int(cantidad.to_i+resto)
    k=0
    for j in 0..mesh_nodo.size-1
      if mesh_nodo[j][1]==rank
        a[k]=mesh_nodo[j][0]
        k+=1
      end
    end
    ref = 0
    for j in 0..(triangulos_a_ref.length)-1
      ref = ref+pertenezco_al_nodo(triangulos_a_ref[j],mesh_nodo,rank)
    end
    puts ref
    world.Send(a, 0, 1)
  end
end
if rank == 0
  (world.size).times do |i|
    a = NArray.int(cantidad.to_i+resto)
    world.Recv(a, i, 1)
    
    p a
  end
end




MPI.Finalize



