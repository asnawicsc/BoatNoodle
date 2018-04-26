defmodule BoatNoodleWeb.OrganizationControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{address: "some address", company_registration_number: "some company_registration_number", contact_number: "some contact_number", country: "some country", name: "some name", tax_registration_number: "some tax_registration_number"}
  @update_attrs %{address: "some updated address", company_registration_number: "some updated company_registration_number", contact_number: "some updated contact_number", country: "some updated country", name: "some updated name", tax_registration_number: "some updated tax_registration_number"}
  @invalid_attrs %{address: nil, company_registration_number: nil, contact_number: nil, country: nil, name: nil, tax_registration_number: nil}

  def fixture(:organization) do
    {:ok, organization} = BN.create_organization(@create_attrs)
    organization
  end

  describe "index" do
    test "lists all organization", %{conn: conn} do
      conn = get conn, organization_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Organization"
    end
  end

  describe "new organization" do
    test "renders form", %{conn: conn} do
      conn = get conn, organization_path(conn, :new)
      assert html_response(conn, 200) =~ "New Organization"
    end
  end

  describe "create organization" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, organization_path(conn, :create), organization: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == organization_path(conn, :show, id)

      conn = get conn, organization_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Organization"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, organization_path(conn, :create), organization: @invalid_attrs
      assert html_response(conn, 200) =~ "New Organization"
    end
  end

  describe "edit organization" do
    setup [:create_organization]

    test "renders form for editing chosen organization", %{conn: conn, organization: organization} do
      conn = get conn, organization_path(conn, :edit, organization)
      assert html_response(conn, 200) =~ "Edit Organization"
    end
  end

  describe "update organization" do
    setup [:create_organization]

    test "redirects when data is valid", %{conn: conn, organization: organization} do
      conn = put conn, organization_path(conn, :update, organization), organization: @update_attrs
      assert redirected_to(conn) == organization_path(conn, :show, organization)

      conn = get conn, organization_path(conn, :show, organization)
      assert html_response(conn, 200) =~ "some updated address"
    end

    test "renders errors when data is invalid", %{conn: conn, organization: organization} do
      conn = put conn, organization_path(conn, :update, organization), organization: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Organization"
    end
  end

  describe "delete organization" do
    setup [:create_organization]

    test "deletes chosen organization", %{conn: conn, organization: organization} do
      conn = delete conn, organization_path(conn, :delete, organization)
      assert redirected_to(conn) == organization_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, organization_path(conn, :show, organization)
      end
    end
  end

  defp create_organization(_) do
    organization = fixture(:organization)
    {:ok, organization: organization}
  end
end
