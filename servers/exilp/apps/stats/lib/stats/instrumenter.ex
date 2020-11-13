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
defmodule Stats.Instrumenter do
  @moduledoc """
  """

  # ----------------------------------------------------------------------------
  # Module Require, Import and Uses
  # ----------------------------------------------------------------------------
  require Logger
  use Prometheus.Metric

  # ----------------------------------------------------------------------------
  # Module Types
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # Module Contants
  # ----------------------------------------------------------------------------
  # @mod __MODULE__

  # ----------------------------------------------------------------------------
  # Public API
  # ----------------------------------------------------------------------------

  def setup do
    Gauge.declare(
      name: :exilp_gateway_response_size,
      help: "The size of the response body sent in a message",
      labels: [:gauge]
    )

    Gauge.declare(
      name: :exilp_gateway_response_codes,
      help: "The response codes sent in a message",
      labels: [:gauge]
    )

    Gauge.declare(
      name: :exilp_gateway_response_time,
      help: "The response codes sent in a message",
      labels: [:gauge]
    )

    events = [
      [:gateway, :metric, :start],
      [:gateway, :metric, :stop]
    ]

    :telemetry.attach_many("stats-instrumenter", events, &handle_event/4, nil)
    :ok
  end

  def handle_event([:gateway, :metric, :start], _systemTime, %{conn: _conn}, _config) do
    :ok
  end

  def handle_event([:gateway, :metric, :stop], %{duration: time}, %{conn: conn}, _config) do
    # Critical Info we should know
    path = conn.request_path
    Gauge.set([name: :exilp_gateway_response_size, labels: [path]], byte_size(conn.resp_body))
    Gauge.set([name: :exilp_gateway_response_codes, labels: [path]], conn.status)

    Gauge.set(
      [name: :exilp_gateway_response_time, labels: [path]],
      System.convert_time_unit(time, :native, :millisecond)
    )
  end

  @doc """
  """
  def execute(event, measurement \\ %{}, metadata \\ %{}),
    do: :telemetry.execute(event, measurement, metadata)

  # ----------------------------------------------------------------------------
  # Private API
  # ----------------------------------------------------------------------------
end
