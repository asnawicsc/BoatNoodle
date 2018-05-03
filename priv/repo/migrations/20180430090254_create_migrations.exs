defmodule BoatNoodle.Repo.Migrations.CreateMigrations do
  use Ecto.Migration

  def change do
    create table(:migrations) do
      add :migration, :string
      add :batch, :integer

      timestamps()
    end

  end
end
