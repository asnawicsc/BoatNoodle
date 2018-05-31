defmodule BoatNoodle.Images.Picture do
  use Ecto.Schema
  import Ecto.Changeset

  schema "picture" do
    field(:bin, :binary)
    field(:file_type, :string)
    field(:filename, :string)
    field(:gallery_id, :integer)
    field(:url, :string)
  end

  @doc false
  def changeset(picture, attrs) do
    picture
    |> cast(attrs, [:filename, :file_type, :bin, :url, :gallery_id])
  end
end
