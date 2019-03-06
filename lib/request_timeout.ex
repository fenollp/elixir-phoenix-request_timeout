defmodule RequestTimeout do
  import Plug.Conn
  @default_timeout_ms 30_000
  @default_kill_msg :kill
  @default_sup nil

  defstruct :after, :msg, :sup

  @doc false
  def init(options) do
    %__MODULE__{
      after: options |> Keyword.get(:after, @default_timeout_ms),
      msg: options |> Keyword.get(:msg, @default_kill_msg)
    }
  end

  @doc false
  def call(conn, %__MODULE__{after: ms, msg: msg}) do
   #  parent = self()

   #  or exit(Pid,kill).

   #      Process.demonitor(ref, [:flush])

   # handle_info({:DOWN, ref, :process, _pid, _reason}, %{ref: ref} = state) do
   #  conn |> send_resp(204, "") |> halt()
  end
end
