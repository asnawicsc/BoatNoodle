defmodule BoatNoodle.Repo.Migrations.CreateRemark do
  use Ecto.Migration

  def change do
    create table(:remark) do
      add :remark_description, :string
      add :target_category, :string
      add :target_item, :string

      timestamps()
    end

  end
end
