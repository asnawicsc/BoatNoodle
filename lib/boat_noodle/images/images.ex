defmodule BoatNoodle.Images do
  @moduledoc """
  The Images context.
  """
  import Mogrify
  import Ecto.Query, warn: false
  alias BoatNoodle.Repo

  alias BoatNoodle.Images.Gallery
  require IEx

  @doc """
  Returns the list of gallery.

  ## Examples

      iex> list_gallery()
      [%Gallery{}, ...]

  """
  def list_gallery do
    Repo.all(Gallery)
  end

  @doc """
  Gets a single gallery.

  Raises `Ecto.NoResultsError` if the Gallery does not exist.

  ## Examples

      iex> get_gallery!(123)
      %Gallery{}

      iex> get_gallery!(456)
      ** (Ecto.NoResultsError)

  """
  def get_gallery!(id), do: Repo.get!(Gallery, id)

  @doc """
  Creates a gallery.

  ## Examples

      iex> create_gallery(%{field: value})
      {:ok, %Gallery{}}

      iex> create_gallery(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_gallery(attrs \\ %{}) do
    %Gallery{}
    |> Gallery.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a gallery.

  ## Examples

      iex> update_gallery(gallery, %{field: new_value})
      {:ok, %Gallery{}}

      iex> update_gallery(gallery, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_gallery(%Gallery{} = gallery, attrs) do
    gallery
    |> Gallery.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Gallery.

  ## Examples

      iex> delete_gallery(gallery)
      {:ok, %Gallery{}}

      iex> delete_gallery(gallery)
      {:error, %Ecto.Changeset{}}

  """
  def delete_gallery(%Gallery{} = gallery) do
    Repo.delete(gallery)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking gallery changes.

  ## Examples

      iex> change_gallery(gallery)
      %Ecto.Changeset{source: %Gallery{}}

  """
  def change_gallery(%Gallery{} = gallery) do
    Gallery.changeset(gallery, %{})
  end

  alias BoatNoodle.Images.Picture

  @doc """
  Returns the list of picture.

  ## Examples

      iex> list_picture()
      [%Picture{}, ...]

  """
  def list_picture do
    Repo.all(Picture)
  end

  @doc """
  Gets a single picture.

  Raises `Ecto.NoResultsError` if the Picture does not exist.

  ## Examples

      iex> get_picture!(123)
      %Picture{}

      iex> get_picture!(456)
      ** (Ecto.NoResultsError)

  """
  def get_picture!(id), do: Repo.get!(Picture, id)

  @doc """
  Creates a picture.

  ## Examples

      iex> create_picture(%{field: value})
      {:ok, %Picture{}}

      iex> create_picture(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_picture(attrs \\ %{}) do
    %Picture{}
    |> Picture.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a picture.

  ## Examples

      iex> update_picture(picture, %{field: new_value})
      {:ok, %Picture{}}

      iex> update_picture(picture, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_picture(%Picture{} = picture, attrs) do
    picture
    |> Picture.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Picture.

  ## Examples

      iex> delete_picture(picture)
      {:ok, %Picture{}}

      iex> delete_picture(picture)
      {:error, %Ecto.Changeset{}}

  """
  def delete_picture(%Picture{} = picture) do
    Repo.delete(picture)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking picture changes.

  ## Examples

      iex> change_picture(picture)
      %Ecto.Changeset{source: %Picture{}}

  """
  def change_picture(%Picture{} = picture) do
    Picture.changeset(picture, %{})
  end

  def upload(param, user_id, gallery_id, filetype) do
    {:ok, seconds} = Timex.format(Timex.now(), "%s", :strftime)

    path = File.cwd!() <> "/media"
    image_path = Application.app_dir(:boat_noodle, "priv/static/images")

    if File.exists?(path) == false do
      File.mkdir(File.cwd!() <> "/media")
    end

    fl = param.filename |> String.replace(" ", "_")
    absolute_path = path <> "/#{seconds <> fl}"
    absolute_path_bin = path <> "/bin_" <> "#{seconds <> fl}"
    File.cp(param.path, absolute_path)
    File.rm(image_path <> "/uploads")
    File.ln_s(path, image_path <> "/uploads")

    resized =
      Mogrify.open(absolute_path)
      |> resize("400x400")
      |> save(path: absolute_path_bin)

    File.cp(resized.path, absolute_path)
    File.rm(image_path <> "/uploads")
    File.ln_s(path, image_path <> "/uploads")

    {:ok, bin} = File.read(resized.path)

    File.rm(resized.path)

    {:ok, picture} =
      BoatNoodle.Images.Picture.changeset(
        %BoatNoodle.Images.Picture{},
        %{
          file_type: filetype,
          filename: seconds <> fl,
          bin: Base.encode64(bin),
          gallery_id: gallery_id
        },
        user_id,
        "Create"
      )
      |> Repo.insert()
  end
end
