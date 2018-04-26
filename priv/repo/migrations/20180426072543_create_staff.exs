defmodule BoatNoodle.Repo.Migrations.CreateStaff do
  use Ecto.Migration

  def change do
    create table(:staff) do
      add :staff_name, :string
      add :contact_number, :string
      add :email, :string
      add :pin_number, :integer
      add :branch, :string
      add :staff_role, :string
      add :photo, :string

      timestamps()
    end

  end
end
