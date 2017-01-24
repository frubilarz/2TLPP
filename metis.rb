require_relative('./node')
#node = ARGV[0] # recive el nombre del fichero .node
#mesh = ARGV[1] # recive el nombre del fichero .mesh
node = 'vertices'
mesh= 'triangulos'
tamano = ARGV[0]
preproceso = Node.new(node,mesh) # instancia un objeto con los datos node y mesh 
node = preproceso.node # prepocesamiento node
mesh = preproceso.mesh # prepoceso mesh

def posicionMasAlaDerecha(node)
  menor = 9999999999
  posicion = 0
  for i in 0..node.size-1
    if menor > node[i][1]
      menor = node[i][1]
      posicion = i
    end
  end
  return posicion
end
  
def primerTriangulo(mesh,node)
  posicion = posicionMasAlaDerecha(node)
  for i in 1..mesh.size-1
    if mesh[i][0] == posicion || mesh[i][1]== posicion || mesh[i][2]== posicion
      aux = i
    end
  end
  return aux
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
        if mesh[i].size == 3
          combinacion << mesh[i].combination(2).to_a
        end
      end
    end
  end
  return combinacion
end # complejidad O(2n)
  
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


def estaContenida(triangulo,lista)
  salida = false
  for i in 0..lista.size-1
    if lista[i]== triangulo
      salida = true
    end
  end
  return salida
end

def ordenarMalla(mesh,combinaciones_mesh,vecino,lista)
  for i in 0..combinaciones_mesh.size-1
    temporal = combinaciones_mesh[i]
    if vecino[0]==temporal[0] || vecino[0] == temporal[1] || vecino[0]== temporal[2] ||
        vecino[0]==temporal[0].reverse || vecino[0] == temporal[1].reverse || vecino[0]== temporal[2].reverse ||
        vecino[1]==temporal[0] || vecino[1] == temporal[1] || vecino[1]== temporal[2] ||
        vecino[1]==temporal[0].reverse || vecino[1] == temporal[1].reverse || vecino[1]== temporal[2].reverse ||
        vecino[2]==temporal[0] || vecino[2] == temporal[1] || vecino[2]== temporal[2] ||
        vecino[2]==temporal[0].reverse || vecino[2] == temporal[1].reverse || vecino[2]== temporal[2].reverse
      if(!estaContenida(i+1,lista))
        lista<<i+1
        combinaciones_primero = combinaciones(mesh[lista[-1]])
        ordenarMalla(mesh,combinaciones_mesh,combinaciones_primero,lista)
      end
    end
  end
end


def generarPart(tamano,lista)
  cantidad = lista.size.to_i/tamano.to_i
  rank = 1
  File.open('prueba.part','w') do |f|
    f.puts lista.length.to_s+' '+tamano.to_s
    for i in 0..lista.length-1
      if i == rank*cantidad
        rank+=1
      end
      if rank > tamano.to_i
        rank = tamano.to_i
      end
      f.puts lista[i].to_s+ ' '+rank.to_s
    end
  end
end

lista =[]
primero = primerTriangulo(mesh,node)
lista <<  primero
combinaciones_mesh = combinaciones(mesh)
combinaciones_primero = combinaciones(mesh[primero])
ordenarMalla(mesh,combinaciones_mesh,combinaciones_primero,lista)
generarPart(tamano,lista)


