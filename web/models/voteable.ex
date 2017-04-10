defmodule Streamr.Voteable do
  import Ecto.Changeset
  alias Streamr.Repo

  defmacro __using__(opts \\ []) do
    quote do
      def change_votes_count_changeset(model, :increment) do
        model
        |> update_count(model, 1)
        |> validate_count()
      end

      def change_votes_count_changeset(model, :decrement) do
        model
        |> update_count(model, -1)
        |> validate_count()
      end

      defp update_count(changeset, model, quantity) do
        cast(changeset, %{votes_count: model.votes_count + quantity}, [:votes_count])
      end

      defp validate_count(changeset) do
        validate_number(changeset, :votes_count, greater_than_or_equal_to: 0)
      end
    end
  end
end
