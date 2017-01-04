class Triangulos
  
  def initialize(a,b,c,grado)
    @a = a
    @b = b
    @c = c
    angulosTriangulos(a,b,c)
    refinar(grado)
    verticeMasLargo(a,b,c)
  end
  def refinar(grado) #ingresa un grado y verifica si es o no refinable
    refinar = 0
    if(alfa().to_f <= grado.to_f || beta().to_f <= grado.to_f || gama().to_f <= grado.to_f)
      refinar = 1
    end
    @refinamiento = refinar
  end 

  def angulosTriangulos(a,b,c)  # calcula los angulos del triangulo
    angulo = 180/Math::PI
    bCuadrado= b*b
    cCuadrado = c*c
    aCuadrado = a*a
    @alfa = Math.acos((bCuadrado+cCuadrado- aCuadrado)/(2*b*c))* angulo
    @beta = Math.acos((aCuadrado+cCuadrado- bCuadrado )/(2*a*c))*angulo
    @gama = Math.acos((aCuadrado+bCuadrado-cCuadrado)/(2*a*b))*angulo
  end
  
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
    @largo= lado
  end # complejidad O(1)

  def a
    return @a
  end

  def b
    return @b
  end

  def c
    return @c
  end

  def alfa
    return @alfa
  end

  def beta
    return @beta
  end

  def gama
    return @gama
  end
  
  def refinamiento
    return @refinamiento
  end
  
  def largo
    return @largo
  end
  
end
