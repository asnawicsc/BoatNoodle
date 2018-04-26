defmodule BoatNoodle.Repo.Migrations.CreatePaymentType do
  use Ecto.Migration

  def change do
    create table(:payment_type) do
      add :payment_name, :string

      timestamps()
    end

  end
end
