part of garesco.email;

class Email extends Ref {
  @Field() String urlBanner;
  @Field() String headingTop;
  @Field() String descripcionTop;

  @Field() List<Categoria> categorias;
  @Field() List<FilaCategoria> get filasCategoria {
    if (categorias == null) return null;

    return qi
        .partition(categorias, 3)
        .map((l) => new FilaCategoria.desdeIterable(l))
        .toList();
  }

  @Field() List<Maquina> maquinas;
  @Field() List<FilaMaquina> get filas {
    if (maquinas == null) return null;

    return qi
        .partition(maquinas, 2)
        .map((l) => new FilaMaquina.desdeIterable(l))
        .toList();
  }

  @Field() String headingBottom;
  @Field() String descripcionBottom;
  @Field() String mensajeFinal;
  @Field() String urlImagenFinal;
}

class FilaMaquina {
  @Field() Maquina izq;
  @Field() Maquina der;

  FilaMaquina();
  FilaMaquina.desdeIterable(Iterable<Maquina> maquinas) {
    var iter = maquinas.iterator;
    izq = (iter..moveNext()).current;
    der = (iter..moveNext()).current;
  }
}

class FilaCategoria {
  @Field() Categoria uno;
  @Field() Categoria dos;
  @Field() Categoria tres;

  FilaCategoria();
  FilaCategoria.desdeIterable(Iterable<Categoria> categorias) {
    var iter = categorias.iterator;
    uno = (iter..moveNext()).current;
    dos = (iter..moveNext()).current;
    tres = (iter..moveNext()).current;
  }
}

class Maquina extends Ref {
  @Field() String venta;
  @Field() String pais;
  @Field() String precio;
  @Field() String modelo;
  @Field() String aNo;
  @Field() String descripcion;
  @Field() String imagenUrl;
  @Field() String link;
  @Field() bool linkVideo;

  String _verMas;
  @Field() set verMas(String s) => _verMas = s;
  @Field() String get verMas =>
      _verMas != null ? _verMas : linkVideo == true ? "Ver Video" : "Ver Mas";
}

class Categoria extends Ref {
  @Field() String urlIcono;
  @Field() String heading;
  @Field() String descripcion;
  @Field() Link link;
}

class Link {
  @Field() String href;
}