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

alias Streamr.{Repo, Topic, Stream}

defmodule SeedHelpers do
  def aws_url(path) do
    "https://s3-us-west-2.amazonaws.com/streamr-staging/Seeds/" <> path
  end
end

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

Repo.delete_all Stream
Repo.insert! %Stream{
  title: "Electic Charge, Fields, and Potential pt. 1",
  image: SeedHelpers.aws_url("Screen+Shot+2017-01-29+at+6.25.36+PM.png"),
  user_id: 1
}

Repo.insert! %Stream{
  title: "Electic Charge, Fields, and Potential pt. 2",
  image: SeedHelpers.aws_url("Screen+Shot+2017-01-29+at+6.26.01+PM.png"),
  user_id: 1
}

Repo.insert! %Stream{
  title: "Half Life Into",
  image: SeedHelpers.aws_url("Screen+Shot+2017-01-29+at+6.27.00+PM.png"),
  user_id: 1
}

Repo.insert! %Stream{
  title: "Linear Equations",
  image: SeedHelpers.aws_url("Screen+Shot+2017-01-29+at+6.29.31+PM.png"),
  user_id: 1
}

Repo.insert! %Stream{
  title: "Riemann Sum Proof",
  image: SeedHelpers.aws_url("Screen+Shot+2017-01-29+at+6.30.04+PM.png"),
  user_id: 1
}

Repo.insert! %Stream{
  title: "Squeeze Theorem Explained",
  image: SeedHelpers.aws_url("Screen+Shot+2017-01-29+at+6.34.46+PM.png"),
  user_id: 1
}

Repo.insert! %Stream{
  title: "Intro to Differential Equations",
  image: SeedHelpers.aws_url("Screen+Shot+2017-01-29+at+6.36.42+PM.png"),
  user_id: 1
}

Repo.insert! %Stream{
  title: "R-squared Coefficient",
  image: SeedHelpers.aws_url("Screen+Shot+2017-01-29+at+6.38.11+PM.png"),
  user_id: 1
}
