defmodule BoatNoodle.Repo.Migrations.CreateComboMap do
  use Ecto.Migration

  def change do
    create table(:combo_map) do
      add :subcatid, :integer
      add :linkid, :integer

      timestamps()
    end

  end
end
