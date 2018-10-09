defmodule BoatNoodle.Repo.Migrations.CreateReports do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :filename, :string
      add :url_path, :string
      add :bin, :binary

      timestamps()
    end

  end
end
