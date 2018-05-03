defmodule BoatNoodle.Repo.Migrations.CreateUserRole do
  use Ecto.Migration

  def change do
    create table(:user_role) do
      add :roleid, :integer
      add :role_name, :string
      add :role_desc, :string

      timestamps()
    end

  end
end
