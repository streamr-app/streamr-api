defmodule Streamr.Color do
  use Streamr.Web, :model

  schema "colors" do
    field :normal, :string
    field :deuteranopia, :string
    field :protanopia, :string
    field :tritanopia, :string
    field :order, :integer

    timestamps()
  end

  def ordered(query) do
    from color in query,
    order_by: [asc: color.order]
  end

  def changeset(color, params \\ []) do
    cast(color, params, [:normal, :deuteranopia, :protanopia, :tritanopia, :order])
  end

  def palettes do
    [:normal, :deuteranopia, :protanopia, :tritanopia]
  end
end
