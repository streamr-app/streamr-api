defmodule Streamr.Sluggifier do
  defmacro __using__(slug_attribute) do
    quote bind_quoted: [attr: slug_attribute] do
      attributes [:slug]

      def slug(object, _conn) do
        [object.id, slug_attribute_for(object)]
        |> Enum.join("-")
        |> Slugger.slugify()
      end

      def slug_attribute_for(object) do
        object
        |> Map.get(unquote(attr))
      end
    end
  end
end
