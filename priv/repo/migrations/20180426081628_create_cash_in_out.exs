defmodule BoatNoodle.Repo.Migrations.CreateCashInOut do
  use Ecto.Migration

  def change do
    create table(:cash_in_out) do
      add :branch, :string
      add :cash_in, :decimal
      add :cash_out, :decimal
      add :open_drawer, :integer

      timestamps()
    end

  end
end
