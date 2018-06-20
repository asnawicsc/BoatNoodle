defmodule BoatNoodleWeb.BrandControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.Bn

  @create_attrs %{bin: "some bin", domain_name: "some domain_name", name: "some name"}
  @update_attrs %{bin: "some updated bin", domain_name: "some updated domain_name", name: "some updated name"}
  @invalid_attrs %{bin: nil, domain_name: nil, name: nil}

  def fixture(:brand) do
    {:ok, brand} = Bn.create_brand(@create_attrs)
    brand
  end

  describe "index" do
    test "lists all brand", %{conn: conn} do
      conn = get conn, brand_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Brand"
    end
  end

  describe "new brand" do
    test "renders form", %{conn: conn} do
      conn = get conn, brand_path(conn, :new)
      assert html_response(conn, 200) =~ "New Brand"
    end
  end

  describe "create brand" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, brand_path(conn, :create), brand: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == brand_path(conn, :show, id)

      conn = get conn, brand_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Brand"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, brand_path(conn, :create), brand: @invalid_attrs
      assert html_response(conn, 200) =~ "New Brand"
    end
  end

  describe "edit brand" do
    setup [:create_brand]

    test "renders form for editing chosen brand", %{conn: conn, brand: brand} do
      conn = get conn, brand_path(conn, :edit, brand)
      assert html_response(conn, 200) =~ "Edit Brand"
    end
  end

  describe "update brand" do
    setup [:create_brand]

    test "redirects when data is valid", %{conn: conn, brand: brand} do
      conn = put conn, brand_path(conn, :update, brand), brand: @update_attrs
      assert redirected_to(conn) == brand_path(conn, :show, brand)

      conn = get conn, brand_path(conn, :show, brand)
      assert html_response(conn, 200) =~ "some updated domain_name"
    end

    test "renders errors when data is invalid", %{conn: conn, brand: brand} do
      conn = put conn, brand_path(conn, :update, brand), brand: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Brand"
    end
  end

  describe "delete brand" do
    setup [:create_brand]

    test "deletes chosen brand", %{conn: conn, brand: brand} do
      conn = delete conn, brand_path(conn, :delete, brand)
      assert redirected_to(conn) == brand_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, brand_path(conn, :show, brand)
      end
    end
  end

  defp create_brand(_) do
    brand = fixture(:brand)
    {:ok, brand: brand}
  end
end
