defmodule Airflow.Parser do

  require Logger

  def process_data(string, pid) when is_binary(string) do
    result = parse(string)
    Process.send(pid, {:parser, result}, [])
  end

  def process_data(msg, _pid) do
    Logger.error "parse error: #{inspect msg}"
  end

  def parse(string) do
    [_address, pressure, temperature, volumetric_flow, mass_flow, setpoint, gas] = String.split(string)
    %Airflow{pressure: to_float(pressure),
      temperature: to_float(temperature),
      volumetric_flow: to_float(volumetric_flow),
      mass_flow: to_float(mass_flow),
      setpoint: to_float(setpoint),
      gas: gas}
  end

  defp to_float(string) do
    case Float.parse(string) do
      {:ok, value} ->
        value
      {:error, msg} ->
        Logger.info "unable to parse #{inspect msg}"
        0
    end
  end

end
