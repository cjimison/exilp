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
defmodule Gateway.Router.Metric do
  @moduledoc ~S"""
  """

  # ----------------------------------------------------------------------------
  # Module Require, Import and Uses
  # ----------------------------------------------------------------------------
  require Logger
  use Plug.Router

  # ----------------------------------------------------------------------------
  # Plug options
  # ----------------------------------------------------------------------------
  # plug(Plug.Logger, log: :debug)
  plug(Plug.Telemetry, event_prefix: [:gateway, :metric])
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  # ----------------------------------------------------------------------------
  # Forward routes
  # ----------------------------------------------------------------------------
  forward("/metric/v1", to: Gateway.Router.Metric.V1.Receiver)
  forward("/metric", to: Gateway.Router.Metric.V1.Receiver)

  forward("/metrics/v1", to: Gateway.Router.Metric.V1.Receiver)
  forward("/metrics", to: Gateway.Router.Metric.V1.Receiver)

  match _ do
    case conn.request_path do
      "/" ->
        # Some Ingress controllers check this path to make sure
        # it is alive.  As such we will just return 200
        send_resp(conn, 200, "ok")

      path ->
        Logger.error("[Gateway.Router.Metric.match] Invalid Path #{inspect(path)}")

        send_resp(conn, 200, "Invalid Node Route #{inspect(path)}")
    end
  end

  @doc """
  Nothing to really do here.  But this is a hook callback so if I need to setup
  something specific around the metrics I can
  """
  @spec setup() :: :ok
  def setup(), do: Gateway.Router.Metric.Handler.setup()
end
