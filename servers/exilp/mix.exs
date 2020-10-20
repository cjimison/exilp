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
defmodule Exilp.MixProject do
  @moduledoc """
  Root Level Mix File
  """

  # ----------------------------------------------------------------------------
  # Module Uses, Requires and Imports
  # ----------------------------------------------------------------------------

  use Mix.Project

  # ----------------------------------------------------------------------------
  # Public API
  # ----------------------------------------------------------------------------

  @doc """
  Setup the root project spec.  For this project we will be using umbrella
  applications to break up the logic into chunks and enable us to turn on
  and off different parts of the system.
  """
  def project do
    vsn =
      File.read!("../../vsn.txt")
      |> String.trim()

    [
      apps_path: "apps",
      version: vsn,
      elixirc_options: elixirc_options(Mix.env()),
      erlc_options: erlc_options(Mix.env()),
      deps: deps(),
      releases: releases(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [plt_add_apps: [:ex_unit, :mix], ignore_warnings: "config/dialyzer.ignore"],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.13", only: :test},
      {:dialyxir, git: "https://github.com/jeremyjh/dialyxir.git", branch: "master"}
    ]
  end

  # ----------------------------------------------------------------------------
  # Private APIs
  # ----------------------------------------------------------------------------

  defp releases do
    [
      fxchg: mainRelease()
    ]
  end

  defp mainRelease do
    [
      include_executables_for: [:unix],
      strip_beams: true,
      include_erts: true,
      applications: [
        runtime_tools: :permanent,
        utils: :permanent,
        interledger: :permanent,
        service: :permanent
      ]
    ]
  end

  # Manage some of the compile options for the project
  defp elixirc_options(:prod) do
    [debug_info: false, all_warnings: true, warnings_as_errors: true]
  end

  defp elixirc_options(_) do
    [debug_info: true, all_warnings: true, warnings_as_errors: true]
  end

  defp erlc_options(:prod) do
    [:warnings_as_errors]
  end

  defp erlc_options(_) do
    [:warnings_as_errors, :debug_info]
  end
end
