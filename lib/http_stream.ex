defmodule HTTPStream do
  @moduledoc """
  Helper for streaming via an HTTP request.
  """
  alias HTTPStream.Error

  require Logger

  @doc """
  Issues an HTTP get request and returns a stream.

  ## Examples

      iex> get(url)
      [chunk, ...]

  """

  @spec get(String.t()) :: Enumerable.t()
  def get(url) do
    Stream.resource(
      fn ->
        parsed_url = URI.parse(url)

        {:ok, conn} = Mint.HTTP.connect(:https, parsed_url.host, parsed_url.port)

        {:ok, conn, ref} =
          Mint.HTTP.request(conn, "GET", "#{parsed_url.path}?#{parsed_url.query}", [], "")

        {conn, ref}
      end,
      fn
        {conn, ref} ->
          receive do
            message ->
              {:ok, conn, responses} = Mint.HTTP.stream(conn, message)
              Enum.reduce(responses, {[], {conn, ref}}, &handle_response/2)
          end

        {conn, ref, :halt} ->
          {:halt, {conn, ref}}
      end,
      fn {conn, _ref} ->
        Mint.HTTP.close(conn)
      end
    )
  end

  defp handle_response(response, {body, {conn, ref}} = acc) do
    case response do
      {:status, ^ref, 404} -> raise Error, reason: :not_found, status: 404
      {:status, ^ref, _status_code} -> acc
      {:headers, ^ref, _headers} -> acc
      {:data, ^ref, data} -> {body ++ [data], {conn, ref}}
      {:done, ^ref} -> {body, {conn, ref, :halt}}
    end
  end
end
