defmodule Streamr.Repo.Migrations.AddStreamFulltextSearch do
  use Ecto.Migration

  def up do
    execute "CREATE extension if not exists pg_trgm;"
    execute "CREATE INDEX streams_title_trgm_index ON streams USING gin (title gin_trgm_ops);"
    execute(
      "CREATE INDEX streams_description_trgm_index ON streams USING gin (description gin_trgm_ops);"
    )
  end

  def down do
    execute "DROP INDEX streams_title_trgm_index;"
    execute "DROP INDEX streams_description_trgm_index;"
  end
end
