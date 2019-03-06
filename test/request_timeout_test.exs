defmodule RequestTimeout.Test do
  use ExUnit.Case, async: true
  use Plug.Test


  defmodule TestPlug do
    use Plug.Builder
    import Plug.Conn

    plug(Pandapi.Authentication, [])
    plug(:index)

    defp index(conn, _opts), do: conn |> send_resp(200, "[]")
  end

  @opts TestPlug.init([])
  @invalid_creds %{"error" => "Invalid credentials"}
  @missing_token %{"error" => "Token is missing"}

  test "A query without token returns an error" do
    conn =
      conn(:get, "/leagues", %{})
      |> put_req_header("content-type", "application/json")
      |> TestPlug.call(@opts)

    assert conn.state == :sent
    assert conn.status == 403
    assert conn.resp_body |> Jason.decode!() == @missing_token
  end
end
