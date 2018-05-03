defmodule BoatNoodle.BN.Organization do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "organisation" do
    field :organisationid,:integer, primary_key: true
    field :address, :string
    field :orgregid, :string
    field :phone, :string
    field :country, :string
    field :organisationname, :string
    field :gst_reg_id, :string
    field :updated_at, :utc_datetime
    field :created_at, :utc_datetime

  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:created_at,:updated_at,:id, :address, :orgregid, :gst_reg_id, :phone, :country,:organisationname])
    end
end
