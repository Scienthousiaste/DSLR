defmodule DslrTest do
  use ExUnit.Case
  doctest Dslr

  test "greets the world" do
    assert Dslr.hello() == :world
  end
end
