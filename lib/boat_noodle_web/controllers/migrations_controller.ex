defmodule BoatNoodleWeb.MigrationsController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Migrations

  def index(conn, _params) do
    migrations = BN.list_migrations()
    render(conn, "index.html", migrations: migrations)
  end

  def new(conn, _params) do
    changeset = BN.change_migrations(%Migrations{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"migrations" => migrations_params}) do
    case BN.create_migrations(migrations_params) do
      {:ok, migrations} ->
        conn
        |> put_flash(:info, "Migrations created successfully.")
        |> redirect(to: migrations_path(conn, :show, migrations))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    migrations = BN.get_migrations!(id)
    render(conn, "show.html", migrations: migrations)
  end

  def edit(conn, %{"id" => id}) do
    migrations = BN.get_migrations!(id)
    changeset = BN.change_migrations(migrations)
    render(conn, "edit.html", migrations: migrations, changeset: changeset)
  end

  def update(conn, %{"id" => id, "migrations" => migrations_params}) do
    migrations = BN.get_migrations!(id)

    case BN.update_migrations(migrations, migrations_params) do
      {:ok, migrations} ->
        conn
        |> put_flash(:info, "Migrations updated successfully.")
        |> redirect(to: migrations_path(conn, :show, migrations))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", migrations: migrations, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    migrations = BN.get_migrations!(id)
    {:ok, _migrations} = BN.delete_migrations(migrations)

    conn
    |> put_flash(:info, "Migrations deleted successfully.")
    |> redirect(to: migrations_path(conn, :index))
  end
end
