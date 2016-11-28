defmodule Streamr.Repo.Migrations.CreateRefreshToken do
  use Ecto.Migration

  def change do
    create table(:refresh_tokens) do
      add :user_id, references(:users), null: false
      add :token, :text, null: false

      timestamps
    end

    create unique_index(:refresh_tokens, [:token])
  end
end
