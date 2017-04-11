defmodule Streamr.Stream.Policy do
  def can?(user, action, stream)
  when action in [:add_line, :update, :delete, :end_stream, :publish] do
    user.id == stream.user_id
  end

  def can?(_, _, _), do: false
end
