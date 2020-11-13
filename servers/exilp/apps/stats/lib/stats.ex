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
defmodule Stats do
  @moduledoc """
  """

  # ----------------------------------------------------------------------------
  # Module Require, Import and Uses
  # ----------------------------------------------------------------------------
  # require Logger
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

  @doc """
  """
  @spec metrics :: String.t()
  def metrics(), do: Prometheus.Format.Text.format()

  @spec counter(String.t()) :: :ok
  def counter(label) do
    Counter.inc(
      name: :exilp_counter_total,
      labels: [label]
    )
  end

  @spec counterReset(any) :: boolean
  def counterReset(label) do
    Counter.reset(
      name: :exilp_counter_total,
      labels: [label]
    )
  end

  def gauge(label, value) do
    Gauge.set([
        name: :exilp_gauge_total,
        labels: [label]
      ],
      value
    )
  end

  def gaugeInc(label, value) do
    Gauge.inc([
        name: :exilp_gauge_total,
        labels: [label]
      ],
      value
    )
  end

  def gaugeDec(label, value) do
    Gauge.dec([
        name: :exilp_gauge_total,
        labels: [label]
      ],
      value
    )
  end

  # ----------------------------------------------------------------------------
  # Private API
  # ----------------------------------------------------------------------------
end
