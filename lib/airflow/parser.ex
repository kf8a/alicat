defmodule Airflow.Parser do

  def process_data(string, pid) when is_binary(string) do
    result = parse(string)
    Process.send(pid, {:parser, result}, [])
  end

  def process_data(_x, _pid) do
  end

  def parse(string) do
    [_address, pressure, temperature, volumetric_flow, mass_flow, setpoint, gas] = String.split(string)
    %Airflow{pressure: String.to_float(pressure),
      temperature: String.to_float(temperature),
      volumetric_flow: String.to_float(volumetric_flow),
      mass_flow: String.to_float(mass_flow),
      setpoint: String.to_float(setpoint),
      gas: gas}
  end
end
