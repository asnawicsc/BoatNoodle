defmodule BoatNoodle.Repo.Migrations.CreateDiscountItem do
  use Ecto.Migration

  def change do
    create table(:discount_item) do
      add :discount_name, :string
      add :description, :string
      add :discount_type, :string
      add :discount_category, :string
      add :discount_percentage, :string
      add :status, :boolean, default: false, null: false
      add :minimum_spend, :integer
      add :discount_catalog, :string

      timestamps()
    end

  end
end
