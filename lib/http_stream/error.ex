defmodule HTTPStream.Error do
  @moduledoc """
  Container for HTTPStream errors.
  """

  defexception reason: nil, status: nil

  @type t :: %__MODULE__{reason: any, status: any}

  def message(%__MODULE__{reason: reason, status: nil}), do: inspect(reason)

  def message(%__MODULE__{reason: reason, status: status}) do
    "status: #{status} - #{inspect(reason)}"
  end
end
