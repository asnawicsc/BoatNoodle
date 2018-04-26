defmodule BoatNoodle.Repo.Migrations.CreateTag do
  use Ecto.Migration

  def change do
    create table(:tag) do
      add :tag_name, :string
      add :description, :string
      add :printer_name, :string

      timestamps()
    end

  end
end
