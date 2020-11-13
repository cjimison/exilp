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
defmodule Gateway.Application do
  @moduledoc false

  # ----------------------------------------------------------------------------
  # Module Require, Import and Uses
  # ----------------------------------------------------------------------------

  use Application

  # ----------------------------------------------------------------------------
  # Module Types
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # Module Contants
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # Public Api
  # ----------------------------------------------------------------------------

  @impl true
  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = buildChildren([])

    opts = [strategy: :one_for_one, name: Gateway.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # ----------------------------------------------------------------------------
  # Private API
  # ----------------------------------------------------------------------------
  defp buildChildren(children) do
    children = enableRouter(children, Gateway.Router.Metric, :metric_enable_tls, :metric_port)

    # Return the children
    children
  end

  # Common template of code for setting up a child service as a child node
  defp enableRouter(children, plugName, tlsEnableName, portName) do
    httpType =
      if "false" == Application.get_env(:gateway, tlsEnableName, "false") do
        :http
      else
        :https
      end

    :ok = plugName.setup()

    [
      Plug.Cowboy.child_spec(
        scheme: httpType,
        plug: plugName,
        port:
          Application.get_env(:gateway, portName)
          |> String.to_integer()
      )
      | children
    ]
  end
end
