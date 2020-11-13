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
defmodule Interledger.MixProject do
  @moduledoc """
  """

  # ----------------------------------------------------------------------------
  # Module Require, Import and Uses
  # ----------------------------------------------------------------------------

  use Mix.Project

  # ----------------------------------------------------------------------------
  # Module Types
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # Module Contants
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # Public Api
  # ----------------------------------------------------------------------------

  @doc """
  Callback made by the system when compiling the mix project
  """
  def project do
    [
      app: :interledger,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  @doc """
  Run "mix help compile.app" to learn about applications.
  """
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # ----------------------------------------------------------------------------
  # Private Api
  # ----------------------------------------------------------------------------

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:utils, in_umbrella: true}
    ]
  end
end
