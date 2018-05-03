defmodule BoatNoodleWeb.MigrationsControllerTest do
  use BoatNoodleWeb.ConnCase

  alias BoatNoodle.BN

  @create_attrs %{batch: 42, migration: "some migration"}
  @update_attrs %{batch: 43, migration: "some updated migration"}
  @invalid_attrs %{batch: nil, migration: nil}

  def fixture(:migrations) do
    {:ok, migrations} = BN.create_migrations(@create_attrs)
    migrations
  end

  describe "index" do
    test "lists all migrations", %{conn: conn} do
      conn = get conn, migrations_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Migrations"
    end
  end

  describe "new migrations" do
    test "renders form", %{conn: conn} do
      conn = get conn, migrations_path(conn, :new)
      assert html_response(conn, 200) =~ "New Migrations"
    end
  end

  describe "create migrations" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, migrations_path(conn, :create), migrations: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == migrations_path(conn, :show, id)

      conn = get conn, migrations_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Migrations"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, migrations_path(conn, :create), migrations: @invalid_attrs
      assert html_response(conn, 200) =~ "New Migrations"
    end
  end

  describe "edit migrations" do
    setup [:create_migrations]

    test "renders form for editing chosen migrations", %{conn: conn, migrations: migrations} do
      conn = get conn, migrations_path(conn, :edit, migrations)
      assert html_response(conn, 200) =~ "Edit Migrations"
    end
  end

  describe "update migrations" do
    setup [:create_migrations]

    test "redirects when data is valid", %{conn: conn, migrations: migrations} do
      conn = put conn, migrations_path(conn, :update, migrations), migrations: @update_attrs
      assert redirected_to(conn) == migrations_path(conn, :show, migrations)

      conn = get conn, migrations_path(conn, :show, migrations)
      assert html_response(conn, 200) =~ "some updated migration"
    end

    test "renders errors when data is invalid", %{conn: conn, migrations: migrations} do
      conn = put conn, migrations_path(conn, :update, migrations), migrations: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Migrations"
    end
  end

  describe "delete migrations" do
    setup [:create_migrations]

    test "deletes chosen migrations", %{conn: conn, migrations: migrations} do
      conn = delete conn, migrations_path(conn, :delete, migrations)
      assert redirected_to(conn) == migrations_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, migrations_path(conn, :show, migrations)
      end
    end
  end

  defp create_migrations(_) do
    migrations = fixture(:migrations)
    {:ok, migrations: migrations}
  end
end
