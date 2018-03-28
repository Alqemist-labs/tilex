defmodule Release.Tasks do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:tilex)

    path = Application.app_dir(:tilex, "priv/repo/migrations")

    Ecto.Migrator.run(Tilex.Repo, path, :up, all: true)
  end
end
