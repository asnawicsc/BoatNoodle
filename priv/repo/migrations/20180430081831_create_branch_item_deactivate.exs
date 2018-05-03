defmodule BoatNoodle.Repo.Migrations.CreateBranchItemDeactivate do
  use Ecto.Migration

  def change do
    create table(:branch_item_deactivate) do
      add :id, :integer
      add :branchid, :integer
      add :itemid, :integer
      add :is_activate, :integer

      timestamps()
    end

  end
end
