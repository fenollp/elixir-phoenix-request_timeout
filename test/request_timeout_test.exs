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
      plug(RequestTimeout, after: 200)
      plug(:index)

      defp index(conn, _opts) do
        Process.sleep(1_000)
        conn |> send_resp(200, "[]")
      end
    end

    conn = conn(:get, "/", %{}) |> TestPlug.Slow.call(%{})
    assert conn.state == :sent
    assert conn.status == 508
    assert get_resp_header(conn, "content-type") == ["text/plain"]
    assert conn.resp_body == "Resource Limit Reached"
  end
end
