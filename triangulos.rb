class Triangulos
  def initialize(a,b,c)
    @a = a
    @b = b
    @c = c
    angulosTriangulos(a,b,c)
  end


  def angulosTriangulos(a,b,c)
    angulo = 180/Math::PI
    bCuadrado= b*b
    cCuadrado = c*c
    aCuadrado = a*a
    @alfa = Math.acos((bCuadrado+cCuadrado- aCuadrado)/(2*b*c))* angulo
    @beta = Math.acos((aCuadrado+cCuadrado- bCuadrado )/(2*a*c))*angulo
    @gama = Math.acos((aCuadrado+bCuadrado-cCuadrado)/(2*a*b))*angulo
  end

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

  def perimetro
    @perimetro = a+b+c
  end



end
