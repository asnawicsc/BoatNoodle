defmodule BoatNoodle.BN.Tag do
  use Ecto.Schema
  import Ecto.Changeset

@primary_key false
  schema "tag_tbl" do
    field :tagid, :integer, primary_key: true
    field :tagdesc, :string
    field :printer, :string
    field :tagname, :string
    field :updated_at, :utc_datetime
    field :created_at, :utc_datetime

  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:created_at,:updated_at,:tagid,:tagname, :tagdesc, :printer])
   
  end
end
