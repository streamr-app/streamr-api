defmodule Streamr.SecureRandom do
  def base64(length) do
    length
    |> random_bytes
    |> :base64.encode_to_string
    |> to_string
  end

  def random_bytes(length) do
    :crypto.strong_rand_bytes(length)
  end
end
