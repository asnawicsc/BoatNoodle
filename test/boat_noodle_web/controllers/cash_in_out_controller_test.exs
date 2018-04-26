defmodule BoatNoodleWeb.CashInOutControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{branch: "some branch", cash_in: "120.5", cash_out: "120.5", open_drawer: 42}
  @update_attrs %{branch: "some updated branch", cash_in: "456.7", cash_out: "456.7", open_drawer: 43}
  @invalid_attrs %{branch: nil, cash_in: nil, cash_out: nil, open_drawer: nil}

  def fixture(:cash_in_out) do
    {:ok, cash_in_out} = BN.create_cash_in_out(@create_attrs)
    cash_in_out
  end

  describe "index" do
    test "lists all cash_in_out", %{conn: conn} do
      conn = get conn, cash_in_out_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Cash in out"
    end
  end

  describe "new cash_in_out" do
    test "renders form", %{conn: conn} do
      conn = get conn, cash_in_out_path(conn, :new)
      assert html_response(conn, 200) =~ "New Cash in out"
    end
  end

  describe "create cash_in_out" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, cash_in_out_path(conn, :create), cash_in_out: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == cash_in_out_path(conn, :show, id)

      conn = get conn, cash_in_out_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Cash in out"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, cash_in_out_path(conn, :create), cash_in_out: @invalid_attrs
      assert html_response(conn, 200) =~ "New Cash in out"
    end
  end

  describe "edit cash_in_out" do
    setup [:create_cash_in_out]

    test "renders form for editing chosen cash_in_out", %{conn: conn, cash_in_out: cash_in_out} do
      conn = get conn, cash_in_out_path(conn, :edit, cash_in_out)
      assert html_response(conn, 200) =~ "Edit Cash in out"
    end
  end

  describe "update cash_in_out" do
    setup [:create_cash_in_out]

    test "redirects when data is valid", %{conn: conn, cash_in_out: cash_in_out} do
      conn = put conn, cash_in_out_path(conn, :update, cash_in_out), cash_in_out: @update_attrs
      assert redirected_to(conn) == cash_in_out_path(conn, :show, cash_in_out)

      conn = get conn, cash_in_out_path(conn, :show, cash_in_out)
      assert html_response(conn, 200) =~ "some updated branch"
    end

    test "renders errors when data is invalid", %{conn: conn, cash_in_out: cash_in_out} do
      conn = put conn, cash_in_out_path(conn, :update, cash_in_out), cash_in_out: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Cash in out"
    end
  end

  describe "delete cash_in_out" do
    setup [:create_cash_in_out]

    test "deletes chosen cash_in_out", %{conn: conn, cash_in_out: cash_in_out} do
      conn = delete conn, cash_in_out_path(conn, :delete, cash_in_out)
      assert redirected_to(conn) == cash_in_out_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, cash_in_out_path(conn, :show, cash_in_out)
      end
    end
  end

  defp create_cash_in_out(_) do
    cash_in_out = fixture(:cash_in_out)
    {:ok, cash_in_out: cash_in_out}
  end
end
