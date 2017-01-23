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
        if mesh[i].size == 3
          combinacion << mesh[i].combination(2).to_a
        end
      end
    end
  end
  return combinacion
end # complejidad O(2n)
def triangulos_por_nodo(np,largo_mesh,triangulos_a_refinar)
  lista = []
  mesh_nodo =[]
  np_aux = 0
  for i in 1..largo_mesh
    lista << i
  end
  
  for i in 0..triangulos_a_refinar.length-1
    lista_ayuda= []
    lista_ayuda << triangulos_a_refinar[i] << np_aux
    mesh_nodo << lista_ayuda
    np_aux+=1
    if  np_aux >= np
      np_aux = 0
    end
    lista.delete(triangulos_a_refinar[i])
  end
  np_aux = 1
  for i in 0..lista.size-1
    lista_ayuda=[]
    lista_ayuda<< lista[i] << np_aux
    mesh_nodo<< lista_ayuda
    np_aux+=1
    if  np_aux >= np
      np_aux = 0
    end
  end
  
  return mesh_nodo
end
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

def generarPart(mesh,tamano)
  File.open('archivo.part','w') do |f|
    f.puts mesh.length.to_s+' '+tamano.to_s
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


def candidatos_a_refinar(mesh,node,grado) # genera una lista con los triangulos a refinar
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


def crearTriangulo(mesh,node,listaDeTriangulosArefinar,mesh_nodo,rank)

  combinacion = combinaciones(listaDeTriangulosArefinar)
  dimension = get_dimension combinacion
  if dimension ==2
    triangulo = combinacion
    lado = buscarNodo(triangulo,node)
    punto = buscarPunto(node,triangulo[lado.to_i])
    edge = toEdge(punto[0],punto[1])
    puntoMedio = puntoMedio(edge,node)
    nuevoTriangulo = []
    for k in 0..triangulo.length-1
      if(k!=lado)
        triangulo[k]<<puntoMedio[0]
        nuevoTriangulo << triangulo[k]
      end
    end
    for j in 0..mesh.length-1
      if(mesh[j]==listaDeTriangulosArefinar)
        mesh[j]= nuevoTriangulo[0]
      end
    end
    mesh<< nuevoTriangulo[1]
    lista =[]
    lista << mesh.size-1 << rank
    mesh_nodo<< lista
    igual = iguales(mesh,triangulo,lado)


    if igual != []
      crearTriangulo(mesh,node,igual,mesh_nodo,rank)
    end
    mesh[0][0]= mesh.length-1
  end
  if dimension!=2
    for i in 0..combinacion.length-1
      triangulo = combinacion[i]
      lado = buscarNodo(triangulo,node)
      punto = buscarPunto(node,triangulo[lado.to_i])
      edge = toEdge(punto[0],punto[1])
      puntoMedio = puntoMedio(edge,node)
      nuevoTriangulo = []
      for k in 0..triangulo.length-1
        if(k!=lado)
          triangulo[k]<<puntoMedio[0]
          nuevoTriangulo << triangulo[k]
        end
      end
      for j in 0..mesh.length-1
        if(mesh[j]==listaDeTriangulosArefinar[i])
          mesh[j]= nuevoTriangulo[0]
        end
      end
      mesh<< nuevoTriangulo[1]

      igual = iguales(mesh,triangulo,lado)


      if igual != []
        crearTriangulo(mesh,node,igual,mesh_nodo,rank)
      end
    end
    mesh[0][0]= mesh.length-1
  end
end #complejidad O(2n+n((n+1)+(n^2)+(1)+(n+1)+n+n)) --> O(2n+n(n^2+4n+3))--> O(2n+n^3+4n^2+3n)->O(n^3+4n^2+5)



def mesh_del_rank(mesh_nodo, rank)
  lista = []
  for i in 0..mesh_nodo.size-1
    if mesh_nodo[i][1]== rank
      lista << mesh_nodo[i][0]
    end
  end
  return lista
end
def puntoMedio(lado,lista) #calcula el punto medio de una distancia
  x = ((lado.first.x + lado.last.x)/2).to_f
  y= ((lado.first.y + lado.last.y)/2).to_f
  auxiliar = 1
  for i in 0..lista.length-1
    if(lista[i][1] ==x && lista[i][2] == y )
      auxiliar = 0
      indice = i
    end
  end
  if auxiliar == 1
    numero  = lista.length+1
    puntoMed = [numero,x,y]
    lista<< puntoMed
  else
    puntoMed = [lista[indice][0],x,y]
  end
  return puntoMed
end #complejidad O(n+1)
def iguales(mesh,triangulo,lado)
  combinacion = combinaciones(mesh)
  iguales = []
  for i in 0..combinacion.length-1
    for j in 0..combinacion[i].length-1
      if triangulo[lado] == combinacion[i][j] || triangulo[lado].reverse == combinacion[i][j]
        iguales = mesh[i]
      end
    end
  end
  return iguales
end #complejidad O(2n+n^2)


def buscarPunto(node,arreglo) # busca los nodos
  nodo = []
  for i in 0..node.length-1
    for j in 0..arreglo.length-1
      if(arreglo[j] == node[i][0]) # compara el numero del nodo para retornar su nodo completo
        nodo << node[i]
      end
    end
  end
  return nodo
end #complejidad O(n^2)

def verticeMasLargo(a,b,c)
  if a > b && a > c
    lado = 0
  end
  if b >a && b > c
    lado = 1
  end
  if c > a && c > b
    lado = 2
  end
  return lado
end # complejidad O(1)


  
def buscarNodo(matriz,node)
  uno = matriz[0]
  dos = matriz[1]
  tres = matriz[2]
  for i in 0..node.size-1
    if(uno[0]==node[i][0])
      primerlargo = node[i]
    end
    if(uno[1]==node[i][0])
      segundolargo = node[i]
    end

    if(dos[0]==node[i][0])
      tercerolargo = node[i]
    end
    if(dos[1]==node[i][0])
      cuartolargo = node[i]
    end

    if(tres[0]==node[i][0])
      quintolargo = node[i]
    end
    if(tres[1]==node[i][0])
      sextolargo = node[i]
    end
  end
  a =  toEdge(primerlargo,segundolargo)
  b =  toEdge(tercerolargo,cuartolargo)
  c =  toEdge(quintolargo,sextolargo)
  s = verticeMasLargo(a.length,b.length,c.length)
  return s
end #complejidad O(n+1)

def calculateTriangle(mesh, triangulosArefinar)
  #refinacion del triangulo y calculo de los triangulos nuevos
  nuevo =[]
  for i in 0..triangulosArefinar.length-1
    nuevo<<mesh[triangulosArefinar[i]]
  end
  return nuevo
end #complejidad O(n)

def puntoMedioContenido(lado,node) #calcula el punto medio de una distancia
  x = ((lado.first.x + lado.last.x)/2).to_f
  y= ((lado.first.y + lado.last.y)/2).to_f

  contador = 0
  for i in 0..node.length-1
    if(node[i][1]==x && node[i][2])
      contador+=1
    end
  end
  return contador
end

def revisar(mesh,node,mesh_nodo,rank)
  combinacion = combinaciones(mesh)
  contador = []
  lista = []
  for i in 1..combinacion.length-1
    for j in 0..combinacion[i].length-1
      punto = combinacion[i][j]
      lado = buscarPunto(node,punto)
      edge = toEdge(lado[0],lado[1])
      contador << puntoMedioContenido(edge,node)
      if contador.reduce(:+)== 1
        puntoMedio(edge,node)
        crearTriangulo(mesh,node,mesh[i],mesh_nodo,rank)
        break
      end
    end
    lista << contador.reduce(:+)
    contador = []
  end
  return lista
end

cantidad = mesh[0][0].to_i/world.size
resto = mesh[0][0].to_i%world.size
candidato = candidatos_a_refinar(mesh,node,grado)
triangulos_a_ref = triangulosArefinar(candidato)
mesh_nodo = triangulos_por_nodo(world.size,mesh[0][0],triangulos_a_ref)

generarPart(mesh_nodo,world.size)
generarNode(node)
generarEle(mesh)


rank = world.rank
if rank== 0
  p 'cantidad de tr a refinar '+candidato.reduce(:+).to_s
end

if rank 
  lista = mesh_del_rank(mesh_nodo,rank)
  a = NArray.int(cantidad.to_i+resto)
  for i in 0..a.length-1
    a[i]=lista[i].to_i
  end
  
  triangulos_total_del_nodo = calculateTriangle(mesh,lista)
  
  nova =[]
  for i in 0..mesh_nodo.size-1
    for j in 0..triangulos_a_ref.size-1
      if mesh_nodo[i][1] == rank
        if mesh_nodo[i][0] == triangulos_a_ref[j]
          nova << triangulos_a_ref[j]
        end
      end
    end
  end
  
  triangulos_por_lado = calculateTriangle(mesh,nova)
  crearTriangulo(triangulos_total_del_nodo,node,triangulos_por_lado,mesh_nodo,rank)
  
  world.Send(a, 0, 1)
end


if rank == 0
  (world.size).times do |i|
    a = NArray.int(cantidad.to_i+resto)
    world.Recv(a, i, 1)
    p a
    
  end

end
p mesh.size
p mesh_nodo.size
  

generarNode(node)
generarEle(mesh)


MPI.Finalize



