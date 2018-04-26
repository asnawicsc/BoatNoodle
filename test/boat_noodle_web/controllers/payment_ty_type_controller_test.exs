defmodule BoatNoodleWeb.PaymentTyTypeControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{payment_name: "some payment_name"}
  @update_attrs %{payment_name: "some updated payment_name"}
  @invalid_attrs %{payment_name: nil}

  def fixture(:payment_ty_type) do
    {:ok, payment_ty_type} = BN.create_payment_ty_type(@create_attrs)
    payment_ty_type
  end

  describe "index" do
    test "lists all payment_type", %{conn: conn} do
      conn = get conn, payment_ty_type_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Payment type"
    end
  end

  describe "new payment_ty_type" do
    test "renders form", %{conn: conn} do
      conn = get conn, payment_ty_type_path(conn, :new)
      assert html_response(conn, 200) =~ "New Payment ty type"
    end
  end

  describe "create payment_ty_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, payment_ty_type_path(conn, :create), payment_ty_type: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == payment_ty_type_path(conn, :show, id)

      conn = get conn, payment_ty_type_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Payment ty type"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, payment_ty_type_path(conn, :create), payment_ty_type: @invalid_attrs
      assert html_response(conn, 200) =~ "New Payment ty type"
    end
  end

  describe "edit payment_ty_type" do
    setup [:create_payment_ty_type]

    test "renders form for editing chosen payment_ty_type", %{conn: conn, payment_ty_type: payment_ty_type} do
      conn = get conn, payment_ty_type_path(conn, :edit, payment_ty_type)
      assert html_response(conn, 200) =~ "Edit Payment ty type"
    end
  end

  describe "update payment_ty_type" do
    setup [:create_payment_ty_type]

    test "redirects when data is valid", %{conn: conn, payment_ty_type: payment_ty_type} do
      conn = put conn, payment_ty_type_path(conn, :update, payment_ty_type), payment_ty_type: @update_attrs
      assert redirected_to(conn) == payment_ty_type_path(conn, :show, payment_ty_type)

      conn = get conn, payment_ty_type_path(conn, :show, payment_ty_type)
      assert html_response(conn, 200) =~ "some updated payment_name"
    end

    test "renders errors when data is invalid", %{conn: conn, payment_ty_type: payment_ty_type} do
      conn = put conn, payment_ty_type_path(conn, :update, payment_ty_type), payment_ty_type: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Payment ty type"
    end
  end

  describe "delete payment_ty_type" do
    setup [:create_payment_ty_type]

    test "deletes chosen payment_ty_type", %{conn: conn, payment_ty_type: payment_ty_type} do
      conn = delete conn, payment_ty_type_path(conn, :delete, payment_ty_type)
      assert redirected_to(conn) == payment_ty_type_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, payment_ty_type_path(conn, :show, payment_ty_type)
      end
    end
  end

  defp create_payment_ty_type(_) do
    payment_ty_type = fixture(:payment_ty_type)
    {:ok, payment_ty_type: payment_ty_type}
  end
end
