defmodule Streamr.Color do
  use Streamr.Web, :model

  schema "colors" do
    field :normal, :string
    field :deuteranopia, :string
    field :protanopia, :string
    field :tritanopia, :string
    field :order, :integer

    timestamps
  end

  def ordered(query) do
    from color in query,
    order_by: [asc: color.order]
  end
end
