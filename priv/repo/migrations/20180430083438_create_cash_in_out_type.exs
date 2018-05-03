defmodule BoatNoodle.Repo.Migrations.CreateCashInOutType do
  use Ecto.Migration

  def change do
    create table(:cash_in_out_type) do
      add :cash_type_id, :integer
      add :name, :string
      add :description, :string

      timestamps()
    end

  end
end
