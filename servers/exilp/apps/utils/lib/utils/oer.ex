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
defmodule Utils.OER do
  @moduledoc """
  This style of encode/decoding is pulled from the following documentation:

  https://interledger.org/rfcs/0030-notes-on-oer-encoding/

  Please refere to that doc before changing anything here.
  """

  # ----------------------------------------------------------------------------
  # Module Uses, Requires and Imports
  # ----------------------------------------------------------------------------
  # require Logger

  # ----------------------------------------------------------------------------
  # Module Types
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # Module Conts
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # Public API
  # ----------------------------------------------------------------------------

  @doc """
  Decodes a Variable lenghted binary block.  This does not make any kind of
  assumptions as to what the data is, just that it has a variable length
  encoding.

  # Returns
  {<<binary data read>>, <<rest of the data>>}
  """
  @spec decodeVariableBinary(<<_::8, _::_*8>>) :: {binary, binary}
  def decodeVariableBinary(data) do
    <<topBit::size(1), lowerBits::size(7), rest::binary>> = data
    <<val::size(8)-unsigned-big>> = <<0::size(1), lowerBits::size(7)>>

    if 0 == topBit do
      <<out::binary-size(val), rest::binary>> = rest
      {out, rest}
    else
      <<len::big-unsigned-size(val)-unit(8), out::binary-size(len), rest::binary>> = rest
      {out, rest}
    end
  end

  @doc """
  Decodes a Variable Length Uint based on the size passed in

  # Returns
  {non_net_integer, <<rest of the data>>}
  """
  @spec decodeVariableUint(binary) :: {non_neg_integer, binary}
  def decodeVariableUint(data) do
    <<topBit::size(1), lowerBits::size(7), rest::binary>> = data
    <<val::size(8)-unsigned-big>> = <<0::size(1), lowerBits::size(7)>>

    if 0 == topBit do
      <<out::unsigned-big-size(val), rest::binary>> = rest
      {out, rest}
    else
      <<len::unsigned-big-size(val)-unit(8), out::unsigned-big-size(len), rest::binary>> = rest
      {out, rest}
    end
  end

  @doc """
  Decodes a Variable Length Int based on the size passed in

  # Returns
  {non_net_integer, <<rest of the data>>}
  """
  @spec decodeVariableInt(binary) :: {integer, binary}
  def decodeVariableInt(data) do
    <<topBit::size(1), lowerBits::size(7), rest::binary>> = data
    <<val::size(8)-unsigned-big>> = <<0::size(1), lowerBits::size(7)>>

    if 0 == topBit do
      <<out::signed-big-size(val), rest::binary>> = rest
      {out, rest}
    else
      <<len::unsigned-big-size(val)-unit(8), out::signed-big-size(len), rest::binary>> = rest
      {out, rest}
    end
  end

  @doc """
  Decodes a Fixed Length Uint based on the size passed in

  # Returns
  {non_net_integer, <<rest of the data>>}
  """
  @spec decodeFixedUint(non_neg_integer, binary) :: {non_neg_integer, binary}
  def decodeFixedUint(len, data) do
    <<
      amount::size(len)-unsigned-big,
      data::binary
    >> = data

    {amount, data}
  end

  @doc """
  Decodes a Fixed Length Int based on the size passed in

  # Returns
  {non_net_integer, <<rest of the data>>}
  """
  @spec decodeFixedInt(integer, binary) :: {integer, binary}
  def decodeFixedInt(len, data) do
    <<
      amount::size(len)-signed-big,
      data::binary
    >> = data

    {amount, data}
  end

  @doc """
  Decodes a fixed length timestamp in a format that the ILP system can
  use.

  NOTE: I might want to change this name a bit for future refer as something
        like TimestampILP or some jazz

  # Returns
  {"y-m-dTh:mm:s.msZ", binary}
  """
  @spec decodeFixedTimestamp(<<_::64, _::_*8>>) :: {<<_::56, _::_*8>>, binary}
  def decodeFixedTimestamp(data) do
    <<
      expY::size(32)-bitstring,
      expM::size(16)-bitstring,
      expD::size(16)-bitstring,
      expH::size(16)-bitstring,
      expm::size(16)-bitstring,
      expS::size(16)-bitstring,
      expmm::size(24)-bitstring,
      data::binary
    >> = data

    strTime = "#{expY}-#{expM}-#{expD}T#{expH}:#{expm}:#{expS}.#{expmm}Z"
    {strTime, data}
  end

  # ----------------------------------------------------------------------------
  # Private API
  # ----------------------------------------------------------------------------
end
