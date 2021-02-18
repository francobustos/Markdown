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
