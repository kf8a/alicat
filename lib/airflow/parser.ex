defmodule Airflow.Parser do
  use ExUnit.Case
  doctest Airflow

  test "parses string" do
    test_string = "A +13.5424 +24.5782 +16.6670 +15.4443 +15.4443 N2"
    result = Airflow.Parser.parse(test_string)
    assert result.volumetric_flow == 16.6670
  end
end
