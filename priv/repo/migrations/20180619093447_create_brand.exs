defmodule BoatNoodle.Repo.Migrations.CreateBrand do
  use Ecto.Migration

  def change do
    create table(:brand) do
      add :name, :string
      add :",", :string
      add :domain_name, :string
      add :",", :string
      add :bin, :string
      add :"", :binary

      timestamps()
    end

  end
end
