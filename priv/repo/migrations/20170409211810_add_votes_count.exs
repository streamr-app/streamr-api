defmodule Streamr.Repo.Migrations.AddVotesCount do
  use Ecto.Migration

  def change do
    alter table(:streams) do
      add :votes_count, :integer, default: 0, null: false
    end

    alter table(:comments) do
      add :votes_count, :integer, default: 0, null: false
    end
  end
end
