# Airflow

Connects to and reads data from an Alicat Gas flow controller
(https://documents.alicat.com/manuals/DOC-MANUAL-MC.pdf)

The application needs either a serial port or serial port seria number (useful for USB serial adapters) passed in. It assumes that the communication settings for the Alicat controller are set to 9600, 8,1,N.

## Usage

Start a reader instance

```elixir
{:ok, pid} = Airflow.Reader.start_link(”FS1243”)
```

Then retrieve the current value

```elixir
value = Airflow.Reader.current_value
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `airflow` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:airflow, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/airflow](https://hexdocs.pm/airflow).

