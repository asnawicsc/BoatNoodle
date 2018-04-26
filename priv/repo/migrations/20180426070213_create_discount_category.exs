defmodule BoatNoodle.Repo.Migrations.CreateDiscountCategory do
  use Ecto.Migration

  def change do
    create table(:discount_category) do
      add :name, :string
      add :description, :string
      add :discount_type, :string
      add :amount_percentage, :integer
      add :status, :boolean, default: false, null: false
      add :discount_catalog, :string

      timestamps()
    end

  end
end
