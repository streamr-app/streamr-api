defmodule Streamr.Repo.Migrations.CreateUserSubscriptions do
  use Ecto.Migration

  def change do
    create table(:user_subscriptions) do
      add :subscriber_id, references(:users), null: false
      add :subscription_id, references(:users), null: false

      timestamps()
    end
  end
end
