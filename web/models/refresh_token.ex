defmodule Streamr.RefreshToken do
  use Streamr.Web, :model

  alias Streamr.{RefreshToken, Repo}
  import Ecto.Query

  schema "refresh_tokens" do
    field :token, :string, null: false
    belongs_to :user, Streamr.User

    timestamps
  end

  def create_for_user(user) do
    if user_token_count(user) >= 20, do: remove_oldeset_token(user)

    Repo.insert(new_token_changeset(user))
  end

  def user_token_count(user) do
    Repo.aggregate(tokens_for_user(user), :count, :id)
  end

  def tokens_for_user(user) do
    from token in RefreshToken,
    where: token.user_id == ^user.id
  end

  def find_associated_user(token) do
    refresh_token = Repo.get_by(RefreshToken, token: token)

    if refresh_token do
      Repo.preload(refresh_token, :user).user
    end
  end

  defp new_token_changeset(user) do
    params = %{user_id: user.id, token: Streamr.SecureRandom.base64(256)}

    %RefreshToken{}
    |> cast(params, [:token, :user_id])
    |> validate_required([:token, :user_id])
  end

  defp remove_oldeset_token(user) do
    oldest_token = Repo.one(
      from token in tokens_for_user(user),
      order_by: [asc: token.inserted_at],
      limit: 1
    )

    Repo.delete(oldest_token)
  end
end
