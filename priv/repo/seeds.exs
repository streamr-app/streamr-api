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

alias Streamr.{Repo, Topic}

Repo.delete_all Topic
Repo.insert! %Topic{name: "Art History"}
Repo.insert! %Topic{name: "Biology"}
Repo.insert! %Topic{name: "Chemistry"}
Repo.insert! %Topic{name: "Computer Science"}
Repo.insert! %Topic{name: "Cosmology & Astronomy"}
Repo.insert! %Topic{name: "Electrical Engineering"}
Repo.insert! %Topic{name: "Entrepreneurship"}
Repo.insert! %Topic{name: "Finance & capital Markets"}
Repo.insert! %Topic{name: "Grammar"}
Repo.insert! %Topic{name: "Health & Medicine"}
Repo.insert! %Topic{name: "Macroeconomics"}
Repo.insert! %Topic{name: "Microeconomics"}
Repo.insert! %Topic{name: "Music"}
Repo.insert! %Topic{name: "Organic Chemistry"}
Repo.insert! %Topic{name: "Physics"}
Repo.insert! %Topic{name: "US History"}
Repo.insert! %Topic{name: "World History"}
