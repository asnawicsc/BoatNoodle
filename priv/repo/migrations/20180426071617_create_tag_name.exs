defmodule BoatNoodle.Repo.Migrations.CreateTagName do
  use Ecto.Migration

  def change do
    create table(:tag_name) do
      add :description, :string
      add :printer_name, :string

      timestamps()
    end

  end
end
