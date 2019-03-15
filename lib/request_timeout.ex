defmodule RequestTimeout do
  require Logger
  import Plug.Conn
  alias Plug.Conn

  @default_timeout_ms 30_000
  @default_kill_msg :kill
  @default_http_ct "text/plain"
  @default_http_msg "Resource Limit Reached"
  @default_http_code 508
  @default_sup nil

  defstruct after: @default_timeout_ms,
            code: @default_http_code,
            ct: @default_http_ct,
            err: @default_kill_msg,
            msg: @default_http_msg,
            sup: @default_sup

  @doc false
  def init(options) do
    %__MODULE__{}
    |> case do
      s -> %{s | after: options |> Keyword.get(:after, s.after)}
    end
    |> case do
      s -> %{s | code: options |> Keyword.get(:code, s.code)}
    end
    |> case do
      s -> %{s | ct: options |> Keyword.get(:content_type, s.ct)}
    end
    |> case do
      s -> %{s | err: options |> Keyword.get(:error, s.err)}
    end
    |> case do
      s -> %{s | msg: options |> Keyword.get(:msg, s.msg)}
    end
    |> case do
      s -> %{s | sup: options |> Keyword.get(:sup, s.sup)}
    end
  end

  @doc false
  def call(conn = %Conn{}, opts = %__MODULE__{sup: sup}) do
    parent = self()

    if is_nil(sup) do
      _child = spawn(fn -> circuit_breaker(conn, parent, opts) end)
    else
      # TODO: spawn under sup
    end

    conn
  end

  defp circuit_breaker(conn, parent, %__MODULE__{
         after: ms,
         code: code,
         ct: ct,
         err: err,
         msg: msg
       }) do
    ref = Process.monitor(parent)

    receive do
      {:DOWN, ^ref, :process, ^parent, reason} ->
        Logger.debug("parent=#{inspect(parent)} died with #{reason}")
        true = Process.demonitor(ref)
    after
      ms ->
        Logger.warn(
          "parent=#{inspect(parent)} took longer than #{ms}ms, " <>
            "sending #{code} and exiting with #{err}"
        )

        true = Process.demonitor(ref)

        conn
        |> put_resp_content_type(ct)
        |> send_resp(code, msg)
        |> halt()

        Process.exit(parent, err)
    end
  end
end
