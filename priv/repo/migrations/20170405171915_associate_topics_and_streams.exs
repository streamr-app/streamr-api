defmodule Streamr.Repo.Migrations.AssociateTopicsAndStreams do
  use Ecto.Migration

  def change do
    alter table(:streams) do
      add :topic_id, references(:topics)
    end

    create index(:streams, [:topic_id])
  end
end
