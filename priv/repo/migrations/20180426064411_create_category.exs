defmodule BoatNoodle.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table(:category) do
      add :category_name, :string
      add :category_description, :string
      add :is_default_menu, :boolean, default: false, null: false

      timestamps()
    end

  end
end
