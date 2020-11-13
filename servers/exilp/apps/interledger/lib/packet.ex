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
defmodule Interledger.Packet do
  @moduledoc """
  Manages the Base layer of interledger packet types.
  """

  # ----------------------------------------------------------------------------
  # Module  Requires, Uses and Imports
  # ----------------------------------------------------------------------------
  require Logger

  # ----------------------------------------------------------------------------
  # Module Types
  # ----------------------------------------------------------------------------
  @type ilp_packet_type ::
          :ilp_packet_prepare
          | :ilp_packet_fulfill
          | :ilp_packet_reject
          | :ilp_packet_unknown

  @type ilp_prepare :: {integer, DateTime.t(), non_neg_integer, String.t(), binary}
  @type ilp_fulfill :: {integer, non_neg_integer}
  @type ilp_reject :: {ilp_packet_error, String.t(), String.t(), binary}
  @type ilp_packet_error ::
          :f00_bad_request
          | :f01_invalid_packet
          | :f02_unreachable
          | :f03_invalid_amount
          | :f04_insufficient_destination_amount
          | :f05_wrong_condition
          | :f06_unexpected_payment
          | :f07_cannot_receive
          | :f08_amount_too_large
          | :f09_invalid_peer_response
          | :f99_application_error
          | :t00_internal_error
          | :t01_peer_unreachable
          | :t02_peer_busy
          | :t03_connector_busy
          | :t04_insufficient_liquidity
          | :t05_rate_limited
          | :t99_application_error
          | :r00_transfer_timed_out
          | :r01_insufficient_source_amount
          | :r02_insufficient_timeout
          | :r99_application_error

  # ----------------------------------------------------------------------------
  # Module Contants
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # Public API
  # ----------------------------------------------------------------------------

  @doc """
  Parse out packet types from the binary envelope.  ILP uses this to define
  the message type and then based on this value decode the rest
  """
  @spec parse(binary()) ::
          {:ok, {ilp_packet_type, ilp_prepare | ilp_fulfill | ilp_reject}}
          | {:error, term}
  def parse(data) do
    # Read the packet type
    {type, data} = Utils.OER.decodeFixedUint(8, data)
    {data, _rest} = Utils.OER.decodeVariableBinary(data)

    toIlpPacketType(type)
    |> toIlpPacket(data)
  end

  # ----------------------------------------------------------------------------
  # Private API
  # ----------------------------------------------------------------------------

  # Parse out the prepare packet
  defp toIlpPacket(:ilp_packet_prepare, data) do
    # Read out the amount
    {amount, data} = Utils.OER.decodeFixedUint(64, data)

    # Read out the Timestamp
    {strTime, data} = Utils.OER.decodeFixedTimestamp(data)

    # Read out the condition field
    {con, data} = Utils.OER.decodeFixedUint(256, data)

    # Read out the Destination
    {dest, data} = Utils.OER.decodeVariableBinary(data)

    # And the rest of the packet payload that shouldn't be touched
    {data, _} = Utils.OER.decodeVariableBinary(data)

    {:ok, expiresAt, 0} = DateTime.from_iso8601(strTime)
    {:ok, {:ilp_packet_prepare, {amount, expiresAt, con, dest, data}}}
  end

  # Parse out the fulfill packet
  defp toIlpPacket(:ilp_packet_fulfill, data) do
    # Read out the condition field
    {fulfillment, data} = Utils.OER.decodeFixedUint(256, data)

    # And the rest of the packet payload that shouldn't be touched
    {data, _} = Utils.OER.decodeVariableBinary(data)

    {:ok, {:ilp_packet_fulfill, {fulfillment, data}}}
  end

  # Parse a reject packet.
  defp toIlpPacket(:ilp_packet_reject, data) do
    <<
      # Read out the condition field
      code::size(24)-bitstring,
      data::binary
    >> = data

    # Read out who triggered this
    {dest, data} = Utils.OER.decodeVariableBinary(data)

    # Read out the message
    {msg, data} = Utils.OER.decodeVariableBinary(data)

    # And the rest of the packet payload that shouldn't be touched
    {data, _} = Utils.OER.decodeVariableBinary(data)

    {:ok, {:ilp_packet_reject, {toError(code), dest, msg, data}}}
  end

  # I don't know what the packet type is so just error out
  defp toIlpPacket(:ilp_packet_unknown, _), do: {:error, :ilp_packet_unknown}

  # Get the atom value of the type based on the value read in.
  defp toIlpPacketType(12), do: :ilp_packet_prepare
  defp toIlpPacketType(13), do: :ilp_packet_fulfill
  defp toIlpPacketType(14), do: :ilp_packet_reject
  defp toIlpPacketType(_), do: :ilp_packet_unknown

  # Convert the string error to an atom.  This is mostly to make
  # life easier for me when tracking error types, etc.
  defp toError("F00"), do: :f00_bad_request
  defp toError("F01"), do: :f01_invalid_packet
  defp toError("F02"), do: :f02_unreachable
  defp toError("F03"), do: :f03_invalid_amount
  defp toError("F04"), do: :f04_insufficient_destination_amount
  defp toError("F05"), do: :f05_wrong_condition
  defp toError("F06"), do: :f06_unexpected_payment
  defp toError("F07"), do: :f07_cannot_receive
  defp toError("F08"), do: :f08_amount_too_large
  defp toError("F09"), do: :f09_invalid_peer_response
  defp toError("F99"), do: :f99_application_error
  defp toError("T00"), do: :t00_internal_error
  defp toError("T01"), do: :t01_peer_unreachable
  defp toError("T02"), do: :t02_peer_busy
  defp toError("T03"), do: :t03_connector_busy
  defp toError("T04"), do: :t04_insufficient_liquidity
  defp toError("T05"), do: :t05_rate_limited
  defp toError("T99"), do: :t99_application_error
  defp toError("R00"), do: :r00_transfer_timed_out
  defp toError("R01"), do: :r01_insufficient_source_amount
  defp toError("R02"), do: :r02_insufficient_timeout
  defp toError("R99"), do: :r99_application_error

  defp toError(e) do
    Logger.error("[Interledger.toError/1] Unknown error code: #{inspect(e)}")
    :t00_internal_error
  end
end
