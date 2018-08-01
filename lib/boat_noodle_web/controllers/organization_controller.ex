defmodule BoatNoodleWeb.OrganizationController do
  use BoatNoodleWeb, :controller

  alias BoatNoodle.BN
  alias BoatNoodle.BN.Organization
  require IEx

  def index(conn, _params) do
    organization = Repo.all(Organization)
    render(conn, "index.html", organization: organization)
  end

  def new(conn, _params) do

changeset = Organization.changeset(%BoatNoodle.BN.Organization{},%{},BN.current_user(conn),"new")
    countries = Countries.all() |> Enum.map(fn x -> {x.name, x.name} end)

    render(conn, "new.html", changeset: changeset, countries: countries)
  end

  def create(conn, %{"organization" => organization_params}) do
    latest_organization_id =
      Repo.all(from(s in Organization))
      |> Enum.map(fn x -> x.organisationid end)
      |> Enum.sort()
      |> List.last()

    latest_organization_id = latest_organization_id + 1

    organization_params = Map.put(organization_params, "organisationid", latest_organization_id)

    changeset=BoatNoodle.BN.Organization.changeset(%BoatNoodle.BN.Organization{},organization_params,BN.current_user(conn),"Create")

    case BoatNoodle.Repo.insert(changeset) do
     {:ok, organization} ->
        conn
        |> put_flash(:info, "Organization created successfully.")
        |> redirect(to: branch_path(conn, :index, BN.get_domain(conn)))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end

   
  end

  def show(conn, %{"id" => id}) do
    organization = BN.get_organization!(id)
    render(conn, "show.html", organization: organization)
  end

  def edit(conn, %{"brand" => brand, "id" => id}) do
    organization = BN.get_organization!(id)
     changeset=BoatNoodle.BN.Organization.changeset(organization,%{}, BN.current_user(conn),"edit")
    countries = Countries.all()  |> Enum.map(fn x -> {x.name, x.name} end) |> Enum.sort_by(fn x -> elem(x,0) end )

    render(
      conn,
      "edit.html",
      organization: organization,
      changeset: changeset,
      countries: countries
    )
  end

  def update(conn, %{"brand" => brand, "id" => id, "organization" => organization_params}) do
    organization = BN.get_organization!(id)

    changeset=BoatNoodle.BN.Organization.changeset(organization,organization_params, BN.current_user(conn),"Update")
    case BoatNoodle.Repo.update(changeset) do
      {:ok, organization} ->
        conn
        |> put_flash(:info, "Organization updated successfully.")
        |> redirect(to: branch_path(conn, :index, BN.get_domain(conn)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", organization: organization, changeset: changeset)
    end
   
  end

  def delete(conn, %{"id" => id}) do
    organization = BN.get_organization!(id)
    {:ok, _organization} = BN.delete_organization(organization)

    conn
    |> put_flash(:info, "Organization deleted successfully.")
    |> redirect(to: organization_path(conn, :index, BN.get_domain(conn)))
  end
end
