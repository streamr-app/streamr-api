# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Streamr.Repo.insert!(%Streamr.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Streamr.{Repo, Topic, Color}

Repo.delete_all Topic
Repo.insert! %Topic{name: "Art History"}
Repo.insert! %Topic{name: "Biology"}
Repo.insert! %Topic{name: "Chemistry"}
Repo.insert! %Topic{name: "Computer Science"}
Repo.insert! %Topic{name: "Cosmology & Astronomy"}
Repo.insert! %Topic{name: "Electrical Engineering"}
Repo.insert! %Topic{name: "Entrepreneurship"}
Repo.insert! %Topic{name: "Grammar"}
Repo.insert! %Topic{name: "Health & Medicine"}
Repo.insert! %Topic{name: "Macroeconomics"}
Repo.insert! %Topic{name: "Microeconomics"}
Repo.insert! %Topic{name: "Music"}
Repo.insert! %Topic{name: "Organic Chemistry"}
Repo.insert! %Topic{name: "Physics"}
Repo.insert! %Topic{name: "US History"}
Repo.insert! %Topic{name: "World History"}

normal_colors = %{
  white: "#d4d8e0",
  red: "#e06c75",
  orange: "#d19a66",
  green: "#98c379",
  blue: "#61afef",
  purple: "#c678dd",
}

deuteranopia_colors = %{
  white: "#ffffff",
  red: "#adedbd",
  orange: "#d19a66",
  green: "#9b9fa2",
  blue: "#61afef",
  purple: "#b940dd",
}

protanopia_colors = %{
  white: "#ffffff",
  red: "#adedbd",
  orange: "#d19a66",
  green: "#9b9fa2",
  blue: "#61afef",
  purple: "#b940dd",
}

tritanopia_colors = %{
  white: "#ffffff",
  red: "#adedbd",
  orange: "#d19a66",
  green: "#9b9fa2",
  blue: "#61afef",
  purple: "#c500ff",
}

color_orders = [
  {:white, 1},
  {:red, 2},
  {:orange, 3},
  {:green, 4},
  {:blue, 5},
  {:purple, 6}
]

Enum.each color_orders, fn {color_atom, order} ->
  changes = %{
    normal: normal_colors[color_atom],
    protanopia: protanopia_colors[color_atom],
    deuteranopia: deuteranopia_colors[color_atom],
    tritanopia: tritanopia_colors[color_atom],
    order: order
  }

  if color = Repo.get_by(Color, order: order) do
    color
    |> Color.changeset(changes)
    |> Repo.update!()
  else
    %Color{}
    |> Color.changeset(changes)
    |> Repo.insert!()
  end
end
