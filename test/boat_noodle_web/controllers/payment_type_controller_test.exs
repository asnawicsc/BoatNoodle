defmodule BoatNoodleWeb.PaymentTypeControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{payment_name: "some payment_name"}
  @update_attrs %{payment_name: "some updated payment_name"}
  @invalid_attrs %{payment_name: nil}

  def fixture(:payment_type) do
    {:ok, payment_type} = BN.create_payment_type(@create_attrs)
    payment_type
  end

  describe "index" do
    test "lists all payment_type", %{conn: conn} do
      conn = get conn, payment_type_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Payment type"
    end
  end

  describe "new payment_type" do
    test "renders form", %{conn: conn} do
      conn = get conn, payment_type_path(conn, :new)
      assert html_response(conn, 200) =~ "New Payment type"
    end
  end

  describe "create payment_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, payment_type_path(conn, :create), payment_type: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == payment_type_path(conn, :show, id)

      conn = get conn, payment_type_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Payment type"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, payment_type_path(conn, :create), payment_type: @invalid_attrs
      assert html_response(conn, 200) =~ "New Payment type"
    end
  end

  describe "edit payment_type" do
    setup [:create_payment_type]

    test "renders form for editing chosen payment_type", %{conn: conn, payment_type: payment_type} do
      conn = get conn, payment_type_path(conn, :edit, payment_type)
      assert html_response(conn, 200) =~ "Edit Payment type"
    end
  end

  describe "update payment_type" do
    setup [:create_payment_type]

    test "redirects when data is valid", %{conn: conn, payment_type: payment_type} do
      conn = put conn, payment_type_path(conn, :update, payment_type), payment_type: @update_attrs
      assert redirected_to(conn) == payment_type_path(conn, :show, payment_type)

      conn = get conn, payment_type_path(conn, :show, payment_type)
      assert html_response(conn, 200) =~ "some updated payment_name"
    end

    test "renders errors when data is invalid", %{conn: conn, payment_type: payment_type} do
      conn = put conn, payment_type_path(conn, :update, payment_type), payment_type: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Payment type"
    end
  end

  describe "delete payment_type" do
    setup [:create_payment_type]

    test "deletes chosen payment_type", %{conn: conn, payment_type: payment_type} do
      conn = delete conn, payment_type_path(conn, :delete, payment_type)
      assert redirected_to(conn) == payment_type_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, payment_type_path(conn, :show, payment_type)
      end
    end
  end

  defp create_payment_type(_) do
    payment_type = fixture(:payment_type)
    {:ok, payment_type: payment_type}
  end
end
