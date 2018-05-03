defmodule BoatNoodle.Repo.Migrations.CreateUserBranchAccess do
  use Ecto.Migration

  def change do
    create table(:user_branch_access) do
      add :userbranchid, :integer
      add :userid, :integer
      add :branchid, :integer

      timestamps()
    end

  end
end
