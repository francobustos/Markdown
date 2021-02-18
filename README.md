# Tutorial de Elixir
### Con markdown
Por Franco Bustos

# Elixir

##  Introducción
Elixir es un lenguaje de programación funcional y dinámico creado por José Valim en 2011. Este lenguaje fue basado y compila en Erlang, por lo que posee todas sus funcionalidades y es excelente como lenguaje para todas las aplicaciones de comunicación gracias a su gran escalabilidad y tolerancia a fallos. A su vez también su sintaxis es muy parecida a Ruby, por lo que su código es muy amigable y fácil de entender y no lleva mucho tiempo llegar a dominarlo y agarrarle el gustito.

## Instalación

### Para windows:
* Instalador: <https://github.com/elixir-lang/elixir-windows-setup/releases/download/v2.1/elixir-websetup.exe>
* Dar en next, next, …, finish

### Para Ubuntu:
A través de consola:
* Agregar el repositorio de Erlang: `wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb && sudo dpkg -i erlang-solutions_2.0_all.deb`
* Actualizar: `sudo apt-get update`
* Instalar Erlang y sus aplicaciones: `sudo apt-get install esl-erlang`
* Instalar Elixir: `sudo apt-get install elixir`

### Para más opciones:
Visitar <https://elixir-lang.org/install.html>

## Consola interactiva
Para saber si se descargó exitosamente, correr en consola `iex`, esto nos ejecutará una consola interactiva de Elixir.


```
$ iex
Erlang/OTP 23 [erts-11.1.5] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Interactive Elixir (1.11.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

Una de las funciones más importantes para todos aquellos que quieren aprender el lenguaje es `i/1` (El “/1” significa que es una función y esta requiere un parámetro, es importante especificar esto puesto que dos funciones con el mismo nombre pero que piden distinto números de parámetros en elixir son consideradas dos funciones totalmente distintas) ya que nos permite ver información del tipo de dato que le hayamos dado de parámetro.
Por ejemplo:

```elixir
iex(1)> i :hola
Term
  :hola
Data type
  Atom
Reference modules
  Atom
Implemented protocols
  IEx.Info, Inspect, List.Chars, String.Chars
iex(2)>
```

Si la función pide solo un parámetro no hace falta ponerle paréntesis y el parámetro se ingresa separado con un espacio.
Podemos ver que el tipo de dato de `:hola` es un Atom (Que se define como una constante en la que su nombre determina su valor, en este caso `:hola`, significa hola) y que tiene como referencia el módulo Atom (Al ser un lenguaje funcional, las funciones se agrupan en módulos, el módulo Atom tiene funciones para trabajar con Atoms, por ejemplo la función `Atom.to_string :hola` nos devuelve “hola”)

## Aplicación
Para ver en más profundidad este lenguaje crearemos una aplicación que utiliza una API web que nos dará información sobre criptomonedas y su valor actualizado a la fecha.

Para ello necesitaremos de dos dependencias, una que nos permita trabajar con el protocolo HTTP y otra que nos parsee Strings a tipos de datos más manejables como tuplas, listas o mapas.

### Preparación del entorno
Lo primero que necesitamos es un entorno para crear la aplicación, no utilizaremos ningún framework ya que Elixir nos provee un entorno con solo ejecutar `mix new nombre_del_proyecto`:

```
$ mix new aplicacion
* creating README.md
* creating .formatter.exs
* creating .gitignore
* creating mix.exs
* creating lib
* creating lib/aplicacion.ex
* creating test
* creating test/test_helper.exs
* creating test/aplicacion_test.exs

Your Mix project was created successfully.
You can use "mix" to compile it, test it, and more:

    cd aplicacion
    mix test

Run "mix help" for more commands.
```
Nos crea una carpeta con el nombre del proyecto, en este caso lo llamé aplicacion (en minúsculas tiene que ser llamado) y dentro hay un archivo README, otro llamado formatter.exs que sirve para el comando `mix format`, un gitignore, un mix.exs en el que se configura la versión de elixir y se instalan las dependencias entre otras cosas y dos carpetas más que una es para test y otra llamada lib en la que dentro van los archivos con los módulos y funciones de nuestra aplicación.

En */aplicacion/lib/aplicacion.ex* se puede ver que tenemos el módulo Aplicacion y contiene la función `hello/0`. Podemos ejecutar todas nuestras funciones en nuestra consola interactiva si compilamos nuestro proyecto, para ello en vez de poner `iex`, ejecutaremos (dentro de la carpeta aplicacion) `iex -S mix`:

```
/aplicacion$ iex -S mix
Erlang/OTP 23 [erts-11.1.5] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Compiling 1 file (.ex)
Generated aplicacion app
Interactive Elixir (1.11.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```
Ya generado, ingresamos el nombre del módulo y de la función, separados por un punto:

```elixir
iex(1)> Aplicacion.hello
:world
```

Nos devuelve el Atom `:world`

### Instalación de dependencias
Nos proveeremos de las dependencias [HTTPotion](https://hexdocs.pm/httpotion/readme.html) y [Poison](https://github.com/devinus/poison).

Se instalan agregándolas al archivo mix.exs en la función `deps/0`:

```elixir
defp deps do
   [
     {:httpotion, "~> 3.1.0"},
     {:poison, "~> 3.1"}
   ]
 end
 ```
y en consola con el comando `mix deps.get`:

```
/aplicacion$ mix deps.get
Resolving Hex dependencies...
Dependency resolution completed:
New:
  httpotion 3.1.3 RETIRED!
    (deprecated) Not really maintained, please check out Tesla
  ibrowse 4.4.0
  poison 3.1.0
* Getting httpotion (Hex package)
* Getting poison (Hex package)
* Getting ibrowse (Hex package)
```
### API Web
Utilizaremos las que nos brinda [CoinMarketCap](https://coinmarketcap.com/). En la sección de [Api Documentation](https://coinmarketcap.com/api/documentation/v1/) que está en Products/Crypto Api sacaremos el URL del servidor al cual nos brindará el JSON con la información que nos interesa y los headers, uno de los cuales es una clave privada que se consigue registrándose en la página.

La URL está en Cryptocurrency/Quotes Latest y le agregaremos al final `?id=1` para indicar que trabajaremos con la moneda de id igual a 1, que es el Bitcoin. Nuestra URL final sería:

    url = https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?id=1

### Aplicación desde la consola
Una vez ya teniendo nuestra URL y clave privada, y las dependencias instaladas en nuestro proyecto, correremos nuestra consola interactiva anexada al proyecto (`iex -S mix`).

En ella le haremos una petición de método GET con sus correspondientes headers a la página de la URL conseguida en el paso anterior para que nos devuelva el JSON con el valor del Bitcoin y lo guardaremos en una variable. Utilizando la dependecia HTTPotion escribiremos en consola lo siguiente:

```elixir
iex(1)> request = HTTPotion.get("https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?id=1", headers: ["Accepts": "application/json","X-CMC_PRO_API_KEY": "TU CLAVE PRIVADA"])
```

Nos devolverá un Struct, que no deja de ser un mapa (Todo tipo de dato que lleva `%{}` se considera Mapa). En la que tendrá tres claves de tipo Atom, body, headers y status_code, es importante recalcar que las claves son de tipo de dato Atoms puesto que esto nos permite interactuar con el mapa de una manera distinta a que si fueran de cualquier otro tipo de dato.

Nuestro mapa es el siguiente:

```elixir
%HTTPotion.Response{
  body: "{\"status\":{\"timestamp\":\"2021-02-12T15:25:24.047Z\",\"error_code\":0,\"error_message\":null,\"elapsed\":25,\"credit_count\":1,\"notice\":null},\"data\":{\"1\":{\"id\":1,\"name\":\"Bitcoin\",\"symbol\":\"BTC\",\"slug\":\"bitcoin\",\"num_market_pairs\":9674,\"date_added\":\"2013-04-28T00:00:00.000Z\",\"tags\":[\"mineable\",\"pow\",\"sha-256\",\"store-of-value\",\"state-channels\",\"coinbase-ventures-portfolio\",\"three-arrows-capital-portfolio\",\"polychain-capital-portfolio\"],\"max_supply\":21000000,\"circulating_supply\":18626737,\"total_supply\":18626737,\"is_active\":1,\"platform\":null,\"cmc_rank\":1,\"is_fiat\":0,\"last_updated\":\"2021-02-12T15:24:02.000Z\",\"quote\":{\"USD\":{\"price\":46889.5970582391,\"volume_24h\":84355360019.83734,\"percent_change_1h\":-2.37960334,\"percent_change_24h\":-1.28057362,\"percent_change_7d\":23.16019562,\"percent_change_30d\":34.15069901,\"market_cap\":873400192439.7935,\"last_updated\":\"2021-02-12T15:24:02.000Z\"}}}}}",
  headers: %HTTPotion.Headers{
    hdrs: %{
      "cache-control" => "no-cache",
      "cf-cache-status" => "DYNAMIC",
      "cf-ray" => "620752708afbf7fa-EZE",
      "cf-request-id" => "083871da570000f7fa1c917000000001",
      "connection" => "keep-alive",
      "content-type" => "application/json; charset=utf-8",
      "date" => "Fri, 12 Feb 2021 15:25:24 GMT",
      "expect-ct" => "max-age=604800, report-uri=\"https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct\"",
      "server" => "cloudflare",
      "set-cookie" => "__cfduid=dd9b5d1e2fd1661667d988ba57d2b7f541613143523; expires=Sun, 14-Mar-21 15:25:23 GMT; path=/; domain=.coinmarketcap.com; HttpOnly; SameSite=Lax; Secure",
      "transfer-encoding" => "chunked",
      "vary" => "origin"
    }
  },
  status_code: 200
}
```

Si el status_code es diferente a 200, puede que estemos haciendo algo mal, el body nos puede llegar a indicar cuál es nuestro error.

Para acceder al body, como es de tipo de dato Atom, con poner la variable y el nombre de la clave separados por punto ya es suficiente, nos conviene a la información guardarla en otra variable

```elixir
iex(2)> body = request.body
"{\"status\":{\"timestamp\":\"2021-02-12T15:25:24.047Z\",\"error_code\":0,\"error_message\":null,\"elapsed\":25,\"credit_count\":1,\"notice\":null},\"data\":{\"1\":{\"id\":1,\"name\":\"Bitcoin\",\"symbol\":\"BTC\",\"slug\":\"bitcoin\",\"num_market_pairs\":9674,\"date_added\":\"2013-04-28T00:00:00.000Z\",\"tags\":[\"mineable\",\"pow\",\"sha-256\",\"store-of-value\",\"state-channels\",\"coinbase-ventures-portfolio\",\"three-arrows-capital-portfolio\",\"polychain-capital-portfolio\"],\"max_supply\":21000000,\"circulating_supply\":18626737,\"total_supply\":18626737,\"is_active\":1,\"platform\":null,\"cmc_rank\":1,\"is_fiat\":0,\"last_updated\":\"2021-02-12T15:24:02.000Z\",\"quote\":{\"USD\":{\"price\":46889.5970582391,\"volume_24h\":84355360019.83734,\"percent_change_1h\":-2.37960334,\"percent_change_24h\":-1.28057362,\"percent_change_7d\":23.16019562,\"percent_change_30d\":34.15069901,\"market_cap\":873400192439.7935,\"last_updated\":\"2021-02-12T15:24:02.000Z\"}}}}}"
```

Nos devuelve un String (Son aquellos que llevan `“”`, no confundir con las comillas simples puesto que se consideran Listas en Elixir) que dentro contiene una tupla (Son aquellas que llevan `{}`). Para acceder a la tupla es necesario utilizar la otra dependencia que instalamos, utilizamos una de sus funciones de la siguiente manera:

```elixir
iex(3)> tuple = Poison.Parser.parse body
{:ok,
 %{
   "data" => %{
     "1" => %{
       "circulating_supply" => 18626737,
       "cmc_rank" => 1,
       "date_added" => "2013-04-28T00:00:00.000Z",
       "id" => 1,
       "is_active" => 1,
       "is_fiat" => 0,
       "last_updated" => "2021-02-12T15:49:02.000Z",
       "max_supply" => 21000000,
       "name" => "Bitcoin",
       "num_market_pairs" => 9674,
       "platform" => nil,
       "quote" => %{
         "USD" => %{
           "last_updated" => "2021-02-12T15:49:02.000Z",
           "market_cap" => 877729917639.1926,
           "percent_change_1h" => -1.60704635,
           "percent_change_24h" => -1.71406628,
           "percent_change_30d" => 35.54059608,
           "percent_change_7d" => 23.49922489,
           "price" => 47122.043846927816,
           "volume_24h" => 84862397577.57399
         }
       },
       "slug" => "bitcoin",
       "symbol" => "BTC",
       "tags" => ["mineable", "pow", "sha-256", "store-of-value",
        "state-channels", "coinbase-ventures-portfolio",
        "three-arrows-capital-portfolio", "polychain-capital-portfolio"],
       "total_supply" => 18626737
     }
   },
   "status" => %{
     "credit_count" => 1,
     "elapsed" => 15,
     "error_code" => 0,
     "error_message" => nil,
     "notice" => nil,
     "timestamp" => "2021-02-12T15:50:21.707Z"
   }
 }}
```

Guardamos el resultado en una variable. Nos devuelve una tupla con dos elementos, un Atom y un Mapa. Para acceder al mapa utilizamos la función que nos trae Elixir `elem/2` que nos pide dos parámetros, una tupla y un Integer que será el índice de la tupla al cual queramos acceder:

    iex(4)> map = elem(tuple,1)

Nos devuelve el mapa. Ahora observamos que las claves de este no son Atoms, para acceder a sus contenidos se pone el mapa y entre corchetes la clave que nos interesa, como a nosotros nos interesa la clave “data” y esta nos devuelve otro mapa que no nos brinda la información de forma directa seguimos adentrándonos, ingresamos a la clave “1”, posteriormente a “quote” y por último a “USD”:

```elixir
iex(5)> values = mapa["data"]["1"]["quote"]["USD"]
%{
  "last_updated" => "2021-02-12T15:49:02.000Z",
  "market_cap" => 877729917639.1926,
  "percent_change_1h" => -1.60704635,
  "percent_change_24h" => -1.71406628,
  "percent_change_30d" => 35.54059608,
  "percent_change_7d" => 23.49922489,
  "price" => 47122.043846927816,
  "volume_24h" => 84862397577.57399
}
```

Si ahora ponemos `values[“price”]` ya nos devuelve el valor del Bitcoin.

### De la consola al proyecto
Nos queda lo más fácil y lo más importante, puesto que si cerramos la consola todo lo que hicimos lo perdemos, para esto es traspasar todo lo que hicimos en funciones, mientras más funciones específicas tengamos mejor es, puesto que también lo podemos hacer todo en una función, pero no es nada recomendable en el paradigma de la programación funcional.

En nuestro archivo */aplicacion/lib/aplicacion.ex* borramos todo el contenido del módulo y creamos la primera función dentro del mismo, que va ser la que le pide con método GET a la API, necesita dos parámetros que son la URL y los headers, nos quedará algo que tal que así:

```elixir
def request(url, headers) do
  HTTPotion.get(url, headers)
end
```

La siguiente es sacar el body de la función anterior:

```elixir
def body(request) do
  request.body
end
```

Parsear el resultado:

```elixir
def parser(body) do
  Poison.Parser.parse body
end
```

Acceder al mapa de la tupla:

```elixir
def tuple_to_map(tuple) do
  elem(tuple, 1)
end
```

Reducir el mapa hasta los valores que nos interesa:

```elixir
def values(map) do
  map["data"]["1"]["quote"]["USD"]
end
```

Y por último queremos que a los valores nos lo imprima en la consola, para ello utilizamos la función `IO.puts/1`:

```elixir
def message(values) do
  IO.puts("El valor del Bitcoin hoy es de: #{values["price"]}")
end
```

Observemos el `#{}`, esto se pone en un string para decir que lo de adentro es una variable.

Solo nos falta una función que nos ejecute en orden todas las demás, para ello utilizaremos `funcion1 |> funcion2` que significa que la función 1 se ejecutará y lo que devuelva será el parámetro de la función dos. Nuestra última función será:

```elixir
def bitcoin do
  request("https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?id=1", [headers: ["Accepts": "application/json","X-CMC_PRO_API_KEY": "TU CLAVE PRIVADA"]])
  |> body
  |> parser
  |> tuple_to_map
  |> values
  |> message
end
```

### Detalles

No importa el orden de las funciones, para ser fácil de leer es recomendable que la función que llame a las demás esté primera y las demás en orden de llamado. En consola solo nos interesa llamar a la primera función, las otras pueden ser privadas poniendo una p después de def, tal que así:

```elixir
defp request(url, headers) do
  HTTPotion.get(url, headers)
end
```

Es recomendable hacer esto con todas las funciones a excepción de la que llama a las demás.
Otra de las características de Elixir es que las funciones que contienen una sola línea se pueden escribir de una manera más corta, se hace separando en coma el nombre de la función y sus parámetros con el *do*, al *do* lo transformamos en Atom agregando dos puntos (pero a la derecha, para indicar lo que contiene) y eliminamos el *end*:

```elixir
defp body(request), do: request.body
```

El resumen llegamos a esto:

```elixir
defmodule Aplicacion do
  def bitcoin do
    request("https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?id=1", [headers: ["Accepts": "application/json","X-CMC_PRO_API_KEY": "TU CLAVE PRIVADA"]])
    |> body
    |> parser
    |> tuple_to_map
    |> values
    |> message
  end

  defp request(url, headers), do: HTTPotion.get(url, headers)

  defp body(request), do: request.body

  defp parser(body), do: Poison.Parser.parse body

  defp tuple_to_map(tuple), do: elem(tuple, 1)

  defp values(map), do: map["data"]["1"]["quote"]["USD"]

  defp message(values), do: IO.puts("El valor del Bitcoin hoy es de: #{values["price"]}")

end
```

Para que la consola actualice nuestros cambios ponemos:

    iex(6)> recompile()

O cerramos la consola interactiva y la volvemos a ejecutar.

¡Ahora si ponemos `Aplicacion.bitcoin` nos retorna el valor del Bitcoin!
