defmodule RequestTimeout.Test do
  use ExUnit.Case, async: true
  use Plug.Test

  test "A fast response is not killed" do
    defmodule TestPlug.Fast do
      use Plug.Builder
      import Plug.Conn
      plug(RequestTimeout, [])
      plug(:index)
      defp index(conn, _opts), do: conn |> send_resp(200, "[]")
    end

    conn = conn(:get, "/", %{}) |> TestPlug.Fast.call(%{})
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "[]"
  end

  test "A slow response is killed" do
    defmodule TestPlug.Slow do
      use Plug.Builder
      import Plug.Conn
      plug(RequestTimeout, after: 100, error: :die!)
      plug(:index)

      defp index(conn, _opts) do
        Process.sleep(300)
        conn |> send_resp(201, "")
      end
    end

    trap = Process.flag(:trap_exit, true)
    conn = conn(:get, "/", %{}) |> TestPlug.Slow.call(%{})
    assert_receive {:EXIT, _, :die!}, 500
    # NOTE: this is a lie. It seems the Plug.Test conn map is unhindered by halt/1
    assert conn.state == :sent
    Process.flag(:trap_exit, trap)
  end
end
