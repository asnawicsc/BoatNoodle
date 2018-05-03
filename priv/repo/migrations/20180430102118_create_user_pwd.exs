defmodule BoatNoodle.Repo.Migrations.CreateUserPwd do
  use Ecto.Migration

  def change do
    create table(:user_pwd) do
      add :name, :string
      add :pass, :string

      timestamps()
    end

  end
end
