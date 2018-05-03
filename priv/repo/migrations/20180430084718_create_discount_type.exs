defmodule BoatNoodle.Repo.Migrations.CreateDiscountType do
  use Ecto.Migration

  def change do
    create table(:discount_type) do
      add :disctypeid, :integer
      add :disctypename, :string

      timestamps()
    end

  end
end
