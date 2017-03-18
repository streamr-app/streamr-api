defmodule Streamr.Sluggifier do
  defmacro __using__(opts \\ []) do
    quote do
      attributes [:slug]

      def slug(object, _conn) do
        if include_id?() do
          [object.id, slug_attribute_for(object)]
          |> Enum.join("-")
          |> Slugger.slugify()
        else
          object
          |> slug_attribute_for()
          |> Slugger.slugify()
        end
      end

      def slug_attribute_for(object) do
        object
        |> Map.get(slug_attribute())
      end

      def slug_attribute do
        Keyword.get(unquote(opts), :attribute)
      end

      def include_id? do
        Keyword.get(unquote(opts), :include_id, true)
      end
    end
  end
end
