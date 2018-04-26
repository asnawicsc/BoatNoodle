defmodule BoatNoodle.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :username, :string
      add :password, :string
      add :email, :string
      add :user_role, :string
      add :branch_access, :string

      timestamps()
    end

  end
end
