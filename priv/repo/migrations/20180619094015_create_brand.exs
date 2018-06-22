defmodule BoatNoodle.Repo.Migrations.CreateBrand do
  use Ecto.Migration

  def change do
    create table(:brand) do
      add :name, :string
      add :domain_name, :string
      add :bin, :binary

      timestamps()
    end

  end
end
