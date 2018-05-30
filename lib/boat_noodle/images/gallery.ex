defmodule BoatNoodle.Images.Gallery do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gallery" do
  end

  @doc false
  def changeset(gallery, attrs) do
    gallery
    |> cast(attrs, [])
  end
end
