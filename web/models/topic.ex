defmodule Streamr.Topic do
  use Streamr.Web, :model

  schema "topics" do
    field :name, :string

    timestamps
  end
end
