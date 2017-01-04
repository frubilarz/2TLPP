class Node
  
  def initialize(node,mesh)
    lista = []
    File.open(node+'.node','r') do |f| #en espiral.lista estan las coordenadas de los puntos
      while linea = f.gets
        lista << linea.chop! #chop elimina el ultimo caracter en este caso el salto de linea
      end
    end
    for i in 0..lista.length-1
      lista[i]= lista[i].split(" ")
      for j in 0..lista[i].length-1
        if j == 0
          lista[i][j]= lista[i][j].to_i
        else
          lista[i][j]= lista[i][j].to_f
        end
      end
    end
    leerTriangulos(mesh)
    @node = lista 
  end
  

  
  def leerTriangulos(mesh)
    triangulos = []
    File.open(mesh+'.mesh','r') do |f| # en espiral.lista estan definidos los triangulos con sus puntos
      while linea = f.gets
        triangulos << linea.chop!
      end
    end
    for i in 0..triangulos.length-1
      triangulos[i]= triangulos[i].split(" ")
      for j in 0..triangulos[i].length-1
        triangulos[i][j]= triangulos[i][j].to_i
      end
    end
    @mesh = triangulos
  end


  def node 
     @node
  end

  def mesh
    @mesh
  end
  

end