defmodule BoatNoodle.Repo.Migrations.CreateItemcat do
  use Ecto.Migration

  def change do
    create table(:itemcat) do
      add :itemcatid, :integer
      add :itemcatcode, :string
      add :itemcatname, :string
      add :itemcatdesc, :string
      add :is_default, :integer
      add :category_type, :string
      add :is_delete, :integer
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime

      timestamps()
    end

  end
end
