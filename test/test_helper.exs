# For testing purposes, be sure to have ex_machina started
{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Streamr.Repo, :manual)
