defmodule Streamr.Repo.Migrations.AddColorPreferenceToUsers do
  use Ecto.Migration

  def up do
    Streamr.ColorPreferenceEnum.create_type

    alter table(:users) do
      add :color_preference, :color_preference, null: false, default: "normal"
    end
  end

  def down do
    alter table(:users) do
      remove :color_preference
    end

    Streamr.ColorPreferenceEnum.drop_type
  end
end
