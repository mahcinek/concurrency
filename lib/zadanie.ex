defmodule WEBHOOK do
  @sleep_time_on_error 100
  defp spawn_recv_loop(socket, pidAdress) do
    pid =spawn(fn ->
      for _ <- Stream.cycle([:ok]) do
        socket|> Socket.Web.send({ :text, "test" })
        case Socket.Web.recv(socket) do
          {:ok, message} ->
            mes=elem(message,1)
            mes=Float.parse(mes)
            mes=mes|>elem(0)
            last=STORE.get(:storage,:websocket)
            lastR=STORE.get(:storage,:lastRest)
            currentR=STORE.get(:storage,:rest)
            STORE.delete(:storage,:lastWebsocket)
            STORE.put(:storage,:lastWebsocket,last)
            if(last != mes or lastR != currentR)do
              STORE.delete(:storage,:websocket)
              STORE.put(:storage,:websocket,mes)
            rest=STORE.get(:storage,:rest)
            if(mes<rest and last != mes)do
              IO.inspect "WEBSOCKET mowi: W WEBSOCKET temperatura jest nizsza niz w REST"
              IO.inspect "WEBSOCKET "<> Float.to_string(mes)<>" REST "<> Float.to_string(rest)
              IO.inspect "*******************************************************************************"
            end
          end
            send pidAdress,{:websocket,mes}
          {:error, error} ->
            IO.puts(error)
            :timer.sleep(@sleep_time_on_error)
        end
      end
    end)
    pid
  end

  def socketaa (pidAdress) do
    socket=Socket.Web.connect!("localhost", 8000)
    spawn_recv_loop(socket, pidAdress)
end
end

defmodule REST do

  def call_rest (pidAdress)do
    spawn(fn ->for _ <- Stream.cycle([:ok]) do
      REST.chapters(pidAdress)
      :timer.sleep(5000)
    end
    end)
  end

  def sub(a,b) do
    a-b|>
    Float.round
  end

  def get(param, pidAdress)do
    mess=Map.fetch!(param, "main")
    mess=mess|>Map.fetch!("temp")
    mess=mess|>sub(273)
    last=STORE.get(:storage,:rest)
    lastWS=STORE.get(:storage,:lastWebsocket)
    currentWS=STORE.get(:storage,:websocket)
    STORE.delete(:storage,:lastRest)
    STORE.put(:storage,:lastRest,last)
    if(last != mess or lastWS != currentWS)do
    STORE.delete(:storage,:rest)
    STORE.put(:storage,:rest,mess)
    websocket=STORE.get(:storage,:websocket)
    tmp=STORE.get(:storage,:tmp)
    STORE.delete(:storage,:tmp)
    STORE.put(:storage,:tmp,websocket)
    if(mess<websocket and (last != mess or tmp != currentWS))do
      IO.inspect "REST mowi: W REST temperatura jest nizsza niz w WEBSOCKET"
      IO.inspect "WEBSOCKET "<> Float.to_string(websocket)<>" REST "<> Float.to_string(mess)
      IO.inspect "*******************************************************************************"
    end
  end
    send pidAdress, {:REST, mess}
  end
  def chapters(pidAdress) do
    case HTTPotion.get("api.openweathermap.org/data/2.5/weather?q=London,uk&APPID=c3d658e5f8b13205fc052296190e40b7") do
      %HTTPotion.Response{ body: body, headers: _headers, status_code: 200 } ->
        {:ok, get(Poison.Parser.parse!(body),pidAdress) }
      _ ->
        {:err, "not found"}
    end
  end
end

defmodule ZADANIE do
  def start do
    pid=spawn(LISTENER,:listen,[])
    Process.register(pid, :addmsg)

    STORE.start_link(:storage)
    STORE.put(:storage,:rest,-300.0)
    STORE.put(:storage,:websocket,-300)
    STORE.put(:storage,:lastRest,-300)
    STORE.put(:storage,:lastWebsocket,-300)
    STORE.put(:storage,:tmp,-300)
    ZADANIE.loop(pid)
  end

  def loop (pidAdress) do
      REST.call_rest(pidAdress)
      WEBHOOK.socketaa(pidAdress)
  end

  def hello do
    :world
  end

end

defmodule LISTENER do
  def listen do
    receive do
      {:REST,text} ->
        text
      {:websocket, test}->
        test

    end
    listen()
end
end


defmodule STORE do
  @doc """
  Starts a new bucket.
  """
  def start_link(name) do
    Agent.start_link(fn -> %{} end,name: name)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(storage, key) do
    Agent.get(storage, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(storage, key, value) do
    Agent.update(storage, &Map.put(&1, key, value))
  end
  def delete(storage, key) do
    Agent.update(storage, &Map.delete(&1, key))
end
 def tolist(storage) do
   Agent.get(storage, &Map.to_list(&1))
 end
end

defmodule Util do
    def typeof(self) do
        cond do
            is_float(self)    -> "float"
            is_number(self)   -> "number"
            is_atom(self)     -> "atom"
            is_boolean(self)  -> "boolean"
            is_binary(self)   -> "binary"
            is_function(self) -> "function"
            is_list(self)     -> "list"
            is_tuple(self)    -> "tuple"
            true                -> "idunno"
        end
    end
end
