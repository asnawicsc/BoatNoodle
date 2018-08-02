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
  def changeset(organization, attrs,user_id, action) do
    organization=organization
    |> cast(attrs, [:created_at,:updated_at,:organisationid, :address, :orgregid, :gst_reg_id, :phone, :country,:organisationname])

        if action == "new" or action =="edit" do

      
     else

           if action == "Update" do
        attrs = Map.put(attrs, "organisationid", organization.data.organisationid)
      end

       BoatNoodle.BN.ModalLog.changeset(%BoatNoodle.BN.ModalLog{},%{name: "organization", user_id: user_id,description: Poison.encode!(attrs),action: action})|>BoatNoodle.Repo.insert()
    end

    

    organization
    end
end
