defmodule BoatNoodle.Repo.Migrations.CreateItemCustomized do
  use Ecto.Migration

  def change do
    create table(:item_customized) do
      add :itemcustomid, :integer
      add :subcatid, :string
      add :customize_code, :string
      add :customize_detail, :string
      add :price, :decimal
      add :availability, :string
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime

      timestamps()
    end

  end
end
