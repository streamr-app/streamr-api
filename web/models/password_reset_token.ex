defmodule Streamr.PasswordResetToken do
  import Joken

  alias Streamr.{Repo, User}

  @secret_key_base Application.get_env(:streamr, :secret_key_base)

  def generate(user) do
    %{user_id: user.id, current_pw_hash: user.password_hash}
    |> token()
    |> with_signer(hs256(@secret_key_base))
    |> sign()
    |> get_compact()
  end

  def verify(token_to_verify) do
    case decode_token(token_to_verify) do
      {:ok, %{"user_id" => user_id}} -> {:ok, Repo.get(User, user_id)}
      {:error, error} -> {:error, error}
    end
  end

  defp decode_token(token_to_verify) do
    token_to_verify
    |> token()
    |> with_validation(["user_id", "current_pw_hash"], validate_token_function())
    |> with_signer(hs256(@secret_key_base))
    |> verify!()
  end

  defp validate_token_function do
    fn user_id, current_pw_hash ->
      case Repo.get(User, user_id) do
        nil -> false
        user -> user.password_hash == current_pw_hash
      end
    end
  end
end
