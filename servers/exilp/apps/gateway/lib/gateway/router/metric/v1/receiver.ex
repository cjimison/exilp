# MIT License
#
# Copyright (c) 2020 Chris Jimison
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
defmodule Gateway.Router.Metric.V1.Receiver do
  @moduledoc """
  """

  # ----------------------------------------------------------------------------
  # Module Require, Import and Uses
  # ----------------------------------------------------------------------------

  require Logger
  use Plug.Router

  # ----------------------------------------------------------------------------
  # Module Types
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # Module Contants
  # ----------------------------------------------------------------------------

  @mod __MODULE__

  # ----------------------------------------------------------------------------
  # Plug options
  # ----------------------------------------------------------------------------
  #plug(Plug.Logger, log: :debug)

  plug(Corsica, origins: "*", allow_methods: :all, allow_headers: :all)

  plug(:match)

  plug(:dispatch)

  # ----------------------------------------------------------------------------
  # Public Node APIs
  # ----------------------------------------------------------------------------
  get "/" do
    put_resp_content_type(conn, "text/plain")
    |> send_resp(200, Gateway.Router.Metric.Handler.metrics())
  end

  get "/ping" do
    send_resp(conn, 200, Gateway.Router.Metric.Handler.ping())
  end

  match _ do
    Logger.error("[#{@mod}.match] Unknown path #{inspect(conn)}")
    send_resp(conn, 404, "Invalid Metric Route")
  end

  # ----------------------------------------------------------------------------
  # Private API
  # ----------------------------------------------------------------------------
  # defp getHeaderValue(conn, val) do
  #  case conn |> get_req_header(val) do
  #    [val] -> val
  #    _ -> nil
  #  end
  # end
  # defp jsonRsp(conn, status, obj) do
  #   put_resp_content_type(conn, "application/json")
  #   |> send_resp(status, Jason.encode!(obj))
  #   |> halt()
  # end
end
