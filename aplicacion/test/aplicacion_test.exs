defmodule AplicacionTest do
  use ExUnit.Case
  doctest Aplicacion

  test "greets the world" do
    assert Aplicacion.hello() == :world
  end
end
