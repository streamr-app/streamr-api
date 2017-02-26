defmodule Streamr.Repo.Migrations.CreateColors do
  use Ecto.Migration

  def change do
    create table(:colors) do
      add :normal, :string
      add :deuteranopia, :string
      add :protanopia, :string
      add :tritanopia, :string
      add :order, :integer

      timestamps
    end
  end
end
