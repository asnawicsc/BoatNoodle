defmodule BoatNoodle.Repo.Migrations.CreateTagCatalog do
  use Ecto.Migration

  def change do
    create table(:tag_catalog) do
      add :name, :string
      add :description, :string
      add :tag_category, :string
      add :tag_items, :string

      timestamps()
    end

  end
end
