defmodule BoatNoodle.Repo.Migrations.CreateStaffType do
  use Ecto.Migration

  def change do
    create table(:staff_type) do
      add :id, :integer
      add :name, :string
      add :description, :string

      timestamps()
    end

  end
end
