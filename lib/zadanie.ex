defmodule ZADANIE do
  @moduledoc """
  Documentation for ZADANIE.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ZADANIE.hello
      :world

  """
  def hello do
    :world
  end
  def callREST do
    spawn(fn ->for _ <- Stream.cycle([:ok]) do
      IO.puts("REST")
      ZADANIE.chapters
      :timer.sleep(3000)
    end
    end)
    #IO.puts("REST nr"<> Integer.to_string(inta))
    #ZADANIE.chapters()
    #:timer.sleep(3000)
    #callREST(inta+1)
  end

  @sleep_time_on_error 100
  defp spawn_recv_loop(socket) do
    #pid = self()
    spawn(fn ->
      for _ <- Stream.cycle([:ok]) do
        socket|> Socket.Web.send({ :text, "test" })
        case Socket.Web.recv(socket) do
          {:ok, message} ->
            IO.puts("Webhook")
            message
            |>elem(1)
            |>IO.puts
          {:error, error} ->
            IO.puts(error)
            :timer.sleep(@sleep_time_on_error)
        end
      end
    end)
  end

  def rec (soc)do
    soc|>Socket.Web.recv!
    |>elem(1)
    |>IO.puts
    soc|>spawn_recv_loop
  end

  def socketaa do
    socket=Socket.Web.connect!("localhost", 8000)
    socket|>Socket.Web.send!({ :text, "test" })
    #rec(socket)# => {:text, "test"}
    rec(socket)
end

  def sub(a,b) do
    a-b|>
    Float.round(2) 
  end

  def get (param)do
    Map.fetch!(param, "main")|>
    Map.fetch!("temp")|>
    sub(273)|>
    IO.puts
  end
  def chapters do
    case HTTPotion.get("api.openweathermap.org/data/2.5/weather?q=London,uk&APPID=c3d658e5f8b13205fc052296190e40b7") do
      %HTTPotion.Response{ body: body, headers: _headers, status_code: 200 } ->
        {:ok, get(Poison.Parser.parse!(body)) }
      _ ->
        {:err, "not found"}
    end
  end
end
