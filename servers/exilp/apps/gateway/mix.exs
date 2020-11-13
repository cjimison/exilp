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
defmodule Gateway.MixProject do
  @moduledoc """
  """

  # ----------------------------------------------------------------------------
  # Module Requires, Import and Uses
  # ----------------------------------------------------------------------------
  use Mix.Project

  # ----------------------------------------------------------------------------
  # Module Types
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # Module Contants
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # Public API
  # ----------------------------------------------------------------------------

  def project do
    [
      app: :gateway,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      elixirc_options: elixirc_options(Mix.env()),
      erlc_options: erlc_options(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Gateway.Application, []}
    ]
  end

  # ----------------------------------------------------------------------------
  # Private Api
  # ----------------------------------------------------------------------------
  defp deps do
    [
      # Umbrella Apps
      {:stats, in_umbrella: true},

      # External Libs
      {:cowlib, "~> 2.10", override: true},
      {:cowboy, "~> 2.8", override: true},
      {:plug_cowboy, "~> 2.4"},
      {:elixir_uuid,
       git: "https://github.com/cjimison/elixir-uuid.git", branch: "master", override: true},
      {:jason, "~> 1.2"},
      {:plug, git: "https://github.com/fortelabsinc/plug.git", branch: "master", override: true},
      {:corsica, "~> 1.1"},
      {:ex_json_schema, "~> 0.7.4"},

      # Unit testing libs
      {:excoveralls, "~> 0.13", only: :test}
    ]
  end

  defp elixirc_options(:prod) do
    [all_warnings: true, warnings_as_errors: true, debug_info: false]
  end

  defp elixirc_options(_) do
    [all_warnings: true, warnings_as_errors: true, debug_info: true]
  end

  defp erlc_options(:prod) do
    [:warnings_as_errors]
  end

  defp erlc_options(_) do
    [:warnings_as_errors, :debug_info]
  end
end
