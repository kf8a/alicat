defmodule AirflowTest do
  use ExUnit.Case
  doctest Airflow

  test "greets the world" do
    assert Airflow.hello() == :world
  end
end
