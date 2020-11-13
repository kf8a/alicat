defmodule Airflow.Reader do
  @moduledoc """
  Connect to the alicat airflow sensor via a serial port, and then read the data stream and hold on to the last value
  """
  use GenServer

  require Logger

  alias Airflow.Parser

  @address "a"

  def start_link(serial_number) do
    GenServer.start_link(__MODULE__, %{port_serial: serial_number, result: 0}, name: __MODULE__)
  end

  def init(%{port_serial: serial_number}) do
    {:ok, pid} = Circuits.UART.start_link

    with ports <- Circuits.UART.enumerate,
      {port, _} = find_port(ports, serial_number) do

        case Circuits.UART.open(pid, port, speed: 9600, framing: {Circuits.UART.Framing.Line, separator: "\r"}) do
          :ok ->
        # make sure streaming mode is off
            :ok = Circuits.UART.write(pid, "@@=#{@address}")
            Process.send_after(self(), :read, 1_000)
            {:ok, %{uart: pid, port: port, result: %Airflow{}}}
          _ ->
            Logger.error "Alicat: No valid port found"
            {:ok, %{uart: pid, port: nil, result: %Airflow{}}}
        end
      end
  end

  @doc """
  Helper function to find the right serial port
  given a serial number
  """
  def find_port(ports, serial_number) do
    Enum.find(ports, fn({_port, value}) -> correct_port?(value, serial_number) end)
  end

  defp correct_port?(%{serial_number: number}, serial) do
    number ==  serial
  end

  defp correct_port?(%{}, _serial) do
    false
  end

  def port, do: GenServer.call(__MODULE__, :port)

  def current_value, do: GenServer.call(__MODULE__, :current_value)

  def handle_call(:current_value, _from, %{result: result} = state) do
    {:reply, result, state}
  end

  def handle_call(:port, _from, %{port: port} = state) do
    {:reply, port, state}
  end


  def handle_info(:reconnect, state) do
    :ok = Circuits.UART.close(state[:uart])
    case Circuits.UART.open(state[:uart], state[:port], speed: 9600, framing: {Circuits.UART.Framing.Line, separator: "\r"}) do
      :ok ->
        :ok = Circuits.UART.write(state[:uart], "@@=#{@address}")
      {:error, msg} ->
        Logger.error "reconnect :#{inspect msg}"
        Process.send_after(self(), :reconnect, 500)
    end
    {:noreply, state}
  end

  def handle_info({:circuits_uart, port, {:error, msg}}, state) do
    Logger.error "resetting port: #{inspect msg}"
    if port == state[:port] do
      Process.send_after(self(), :reconnect, 100)
    end
    {:noreply, state}
  end

  def handle_info({:circuits_uart, port, data}, state) do
    if port == state[:port] do
      # spawn(fn -> Parser.process_data(data, self()) end)
      Task.start(Parser, :process_data, [data, self()])
    end
    {:noreply, state}
  end

  def handle_info({:parser, result}, state) do
    {:noreply, Map.put(state, :result, result)}
  end

  def handle_info(:read, state) do
    Circuits.UART.write(state[:uart], @address)
    Process.send_after(self(), :read, 2_000)
    {:noreply, state}
  end
end
