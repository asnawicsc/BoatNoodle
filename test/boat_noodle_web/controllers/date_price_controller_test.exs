defmodule BoatNoodleWeb.DatePriceControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{brand_id: 42, end_date: ~D[2010-04-17], item_subcat_id: 42, start_date: ~D[2010-04-17], unit_price: "120.5"}
  @update_attrs %{brand_id: 43, end_date: ~D[2011-05-18], item_subcat_id: 43, start_date: ~D[2011-05-18], unit_price: "456.7"}
  @invalid_attrs %{brand_id: nil, end_date: nil, item_subcat_id: nil, start_date: nil, unit_price: nil}

  def fixture(:date_price) do
    {:ok, date_price} = BN.create_date_price(@create_attrs)
    date_price
  end

  describe "index" do
    test "lists all item_subcat_date_price", %{conn: conn} do
      conn = get conn, date_price_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Item subcat date price"
    end
  end

  describe "new date_price" do
    test "renders form", %{conn: conn} do
      conn = get conn, date_price_path(conn, :new)
      assert html_response(conn, 200) =~ "New Date price"
    end
  end

  describe "create date_price" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, date_price_path(conn, :create), date_price: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == date_price_path(conn, :show, id)

      conn = get conn, date_price_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Date price"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, date_price_path(conn, :create), date_price: @invalid_attrs
      assert html_response(conn, 200) =~ "New Date price"
    end
  end

  describe "edit date_price" do
    setup [:create_date_price]

    test "renders form for editing chosen date_price", %{conn: conn, date_price: date_price} do
      conn = get conn, date_price_path(conn, :edit, date_price)
      assert html_response(conn, 200) =~ "Edit Date price"
    end
  end

  describe "update date_price" do
    setup [:create_date_price]

    test "redirects when data is valid", %{conn: conn, date_price: date_price} do
      conn = put conn, date_price_path(conn, :update, date_price), date_price: @update_attrs
      assert redirected_to(conn) == date_price_path(conn, :show, date_price)

      conn = get conn, date_price_path(conn, :show, date_price)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, date_price: date_price} do
      conn = put conn, date_price_path(conn, :update, date_price), date_price: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Date price"
    end
  end

  describe "delete date_price" do
    setup [:create_date_price]

    test "deletes chosen date_price", %{conn: conn, date_price: date_price} do
      conn = delete conn, date_price_path(conn, :delete, date_price)
      assert redirected_to(conn) == date_price_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, date_price_path(conn, :show, date_price)
      end
    end
  end

  defp create_date_price(_) do
    date_price = fixture(:date_price)
    {:ok, date_price: date_price}
  end
end
