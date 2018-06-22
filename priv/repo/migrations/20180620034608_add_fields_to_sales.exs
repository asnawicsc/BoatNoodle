defmodule BoatNoodle.Repo.Migrations.AddFieldsToSales do
  use Ecto.Migration

  def change do
    
    alter table(:sales) do
      add :branch_id, :string
    end

  end
end
