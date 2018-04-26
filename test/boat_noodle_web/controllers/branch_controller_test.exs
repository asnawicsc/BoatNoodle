defmodule BoatNoodleWeb.BranchControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{branch_address: "some branch_address", branch_code: "some branch_code", branch_contact: "some branch_contact", branch_manager: "some branch_manager", branch_name: "some branch_name", goverment_tax_percentage: 42, number_of_staff: 42, organization: "some organization", report_class: "some report_class", service_tax_percentage: 42}
  @update_attrs %{branch_address: "some updated branch_address", branch_code: "some updated branch_code", branch_contact: "some updated branch_contact", branch_manager: "some updated branch_manager", branch_name: "some updated branch_name", goverment_tax_percentage: 43, number_of_staff: 43, organization: "some updated organization", report_class: "some updated report_class", service_tax_percentage: 43}
  @invalid_attrs %{branch_address: nil, branch_code: nil, branch_contact: nil, branch_manager: nil, branch_name: nil, goverment_tax_percentage: nil, number_of_staff: nil, organization: nil, report_class: nil, service_tax_percentage: nil}

  def fixture(:branch) do
    {:ok, branch} = BN.create_branch(@create_attrs)
    branch
  end

  describe "index" do
    test "lists all branch", %{conn: conn} do
      conn = get conn, branch_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Branch"
    end
  end

  describe "new branch" do
    test "renders form", %{conn: conn} do
      conn = get conn, branch_path(conn, :new)
      assert html_response(conn, 200) =~ "New Branch"
    end
  end

  describe "create branch" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, branch_path(conn, :create), branch: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == branch_path(conn, :show, id)

      conn = get conn, branch_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Branch"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, branch_path(conn, :create), branch: @invalid_attrs
      assert html_response(conn, 200) =~ "New Branch"
    end
  end

  describe "edit branch" do
    setup [:create_branch]

    test "renders form for editing chosen branch", %{conn: conn, branch: branch} do
      conn = get conn, branch_path(conn, :edit, branch)
      assert html_response(conn, 200) =~ "Edit Branch"
    end
  end

  describe "update branch" do
    setup [:create_branch]

    test "redirects when data is valid", %{conn: conn, branch: branch} do
      conn = put conn, branch_path(conn, :update, branch), branch: @update_attrs
      assert redirected_to(conn) == branch_path(conn, :show, branch)

      conn = get conn, branch_path(conn, :show, branch)
      assert html_response(conn, 200) =~ "some updated branch_address"
    end

    test "renders errors when data is invalid", %{conn: conn, branch: branch} do
      conn = put conn, branch_path(conn, :update, branch), branch: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Branch"
    end
  end

  describe "delete branch" do
    setup [:create_branch]

    test "deletes chosen branch", %{conn: conn, branch: branch} do
      conn = delete conn, branch_path(conn, :delete, branch)
      assert redirected_to(conn) == branch_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, branch_path(conn, :show, branch)
      end
    end
  end

  defp create_branch(_) do
    branch = fixture(:branch)
    {:ok, branch: branch}
  end
end
