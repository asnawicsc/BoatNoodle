defmodule BoatNoodle.ImagesTest do
  use BoatNoodle.DataCase

  alias BoatNoodle.Images

  describe "gallery" do
    alias BoatNoodle.Images.Gallery

    @valid_attrs %{id: 42}
    @update_attrs %{id: 43}
    @invalid_attrs %{id: nil}

    def gallery_fixture(attrs \\ %{}) do
      {:ok, gallery} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Images.create_gallery()

      gallery
    end

    test "list_gallery/0 returns all gallery" do
      gallery = gallery_fixture()
      assert Images.list_gallery() == [gallery]
    end

    test "get_gallery!/1 returns the gallery with given id" do
      gallery = gallery_fixture()
      assert Images.get_gallery!(gallery.id) == gallery
    end

    test "create_gallery/1 with valid data creates a gallery" do
      assert {:ok, %Gallery{} = gallery} = Images.create_gallery(@valid_attrs)
      assert gallery.id == 42
    end

    test "create_gallery/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Images.create_gallery(@invalid_attrs)
    end

    test "update_gallery/2 with valid data updates the gallery" do
      gallery = gallery_fixture()
      assert {:ok, gallery} = Images.update_gallery(gallery, @update_attrs)
      assert %Gallery{} = gallery
      assert gallery.id == 43
    end

    test "update_gallery/2 with invalid data returns error changeset" do
      gallery = gallery_fixture()
      assert {:error, %Ecto.Changeset{}} = Images.update_gallery(gallery, @invalid_attrs)
      assert gallery == Images.get_gallery!(gallery.id)
    end

    test "delete_gallery/1 deletes the gallery" do
      gallery = gallery_fixture()
      assert {:ok, %Gallery{}} = Images.delete_gallery(gallery)
      assert_raise Ecto.NoResultsError, fn -> Images.get_gallery!(gallery.id) end
    end

    test "change_gallery/1 returns a gallery changeset" do
      gallery = gallery_fixture()
      assert %Ecto.Changeset{} = Images.change_gallery(gallery)
    end
  end

  describe "picture" do
    alias BoatNoodle.Images.Picture

    @valid_attrs %{bin: "some bin", file_type: "some file_type", filename: "some filename", gallery_id: 42, id: 42, url: "some url"}
    @update_attrs %{bin: "some updated bin", file_type: "some updated file_type", filename: "some updated filename", gallery_id: 43, id: 43, url: "some updated url"}
    @invalid_attrs %{bin: nil, file_type: nil, filename: nil, gallery_id: nil, id: nil, url: nil}

    def picture_fixture(attrs \\ %{}) do
      {:ok, picture} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Images.create_picture()

      picture
    end

    test "list_picture/0 returns all picture" do
      picture = picture_fixture()
      assert Images.list_picture() == [picture]
    end

    test "get_picture!/1 returns the picture with given id" do
      picture = picture_fixture()
      assert Images.get_picture!(picture.id) == picture
    end

    test "create_picture/1 with valid data creates a picture" do
      assert {:ok, %Picture{} = picture} = Images.create_picture(@valid_attrs)
      assert picture.bin == "some bin"
      assert picture.file_type == "some file_type"
      assert picture.filename == "some filename"
      assert picture.gallery_id == 42
      assert picture.id == 42
      assert picture.url == "some url"
    end

    test "create_picture/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Images.create_picture(@invalid_attrs)
    end

    test "update_picture/2 with valid data updates the picture" do
      picture = picture_fixture()
      assert {:ok, picture} = Images.update_picture(picture, @update_attrs)
      assert %Picture{} = picture
      assert picture.bin == "some updated bin"
      assert picture.file_type == "some updated file_type"
      assert picture.filename == "some updated filename"
      assert picture.gallery_id == 43
      assert picture.id == 43
      assert picture.url == "some updated url"
    end

    test "update_picture/2 with invalid data returns error changeset" do
      picture = picture_fixture()
      assert {:error, %Ecto.Changeset{}} = Images.update_picture(picture, @invalid_attrs)
      assert picture == Images.get_picture!(picture.id)
    end

    test "delete_picture/1 deletes the picture" do
      picture = picture_fixture()
      assert {:ok, %Picture{}} = Images.delete_picture(picture)
      assert_raise Ecto.NoResultsError, fn -> Images.get_picture!(picture.id) end
    end

    test "change_picture/1 returns a picture changeset" do
      picture = picture_fixture()
      assert %Ecto.Changeset{} = Images.change_picture(picture)
    end
  end
end
