defmodule BoatNoodle.BN do
  @moduledoc """
  The BN context.
  """

  import Ecto.Query, warn: false
  alias BoatNoodle.Repo

  alias BoatNoodle.BN.MenuItem

  @doc """
  Returns the list of menu_item.

  ## Examples

      iex> list_menu_item()
      [%MenuItem{}, ...]

  """
  def list_menu_item do
    Repo.all(MenuItem)
  end

  @doc """
  Gets a single menu_item.

  Raises `Ecto.NoResultsError` if the Menu item does not exist.

  ## Examples

      iex> get_menu_item!(123)
      %MenuItem{}

      iex> get_menu_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_menu_item!(id), do: Repo.get!(MenuItem, id)

  @doc """
  Creates a menu_item.

  ## Examples

      iex> create_menu_item(%{field: value})
      {:ok, %MenuItem{}}

      iex> create_menu_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_menu_item(attrs \\ %{}) do
    %MenuItem{}
    |> MenuItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a menu_item.

  ## Examples

      iex> update_menu_item(menu_item, %{field: new_value})
      {:ok, %MenuItem{}}

      iex> update_menu_item(menu_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_menu_item(%MenuItem{} = menu_item, attrs) do
    menu_item
    |> MenuItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a MenuItem.

  ## Examples

      iex> delete_menu_item(menu_item)
      {:ok, %MenuItem{}}

      iex> delete_menu_item(menu_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_menu_item(%MenuItem{} = menu_item) do
    Repo.delete(menu_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking menu_item changes.

  ## Examples

      iex> change_menu_item(menu_item)
      %Ecto.Changeset{source: %MenuItem{}}

  """
  def change_menu_item(%MenuItem{} = menu_item) do
    MenuItem.changeset(menu_item, %{})
  end

  alias BoatNoodle.BN.Category

  @doc """
  Returns the list of category.

  ## Examples

      iex> list_category()
      [%Category{}, ...]

  """
  def list_category do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Category{}}

  """
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end

  alias BoatNoodle.BN.Remark

  @doc """
  Returns the list of remark.

  ## Examples

      iex> list_remark()
      [%Remark{}, ...]

  """
  def list_remark do
    Repo.all(Remark)
  end

  @doc """
  Gets a single remark.

  Raises `Ecto.NoResultsError` if the Remark does not exist.

  ## Examples

      iex> get_remark!(123)
      %Remark{}

      iex> get_remark!(456)
      ** (Ecto.NoResultsError)

  """
  def get_remark!(id), do: Repo.get!(Remark, id)

  @doc """
  Creates a remark.

  ## Examples

      iex> create_remark(%{field: value})
      {:ok, %Remark{}}

      iex> create_remark(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_remark(attrs \\ %{}) do
    %Remark{}
    |> Remark.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a remark.

  ## Examples

      iex> update_remark(remark, %{field: new_value})
      {:ok, %Remark{}}

      iex> update_remark(remark, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_remark(%Remark{} = remark, attrs) do
    remark
    |> Remark.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Remark.

  ## Examples

      iex> delete_remark(remark)
      {:ok, %Remark{}}

      iex> delete_remark(remark)
      {:error, %Ecto.Changeset{}}

  """
  def delete_remark(%Remark{} = remark) do
    Repo.delete(remark)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking remark changes.

  ## Examples

      iex> change_remark(remark)
      %Ecto.Changeset{source: %Remark{}}

  """
  def change_remark(%Remark{} = remark) do
    Remark.changeset(remark, %{})
  end

  alias BoatNoodle.BN.MenuCatalog

  @doc """
  Returns the list of menu_catalog.

  ## Examples

      iex> list_menu_catalog()
      [%MenuCatalog{}, ...]

  """
  def list_menu_catalog do
    Repo.all(MenuCatalog)
  end

  @doc """
  Gets a single menu_catalog.

  Raises `Ecto.NoResultsError` if the Menu catalog does not exist.

  ## Examples

      iex> get_menu_catalog!(123)
      %MenuCatalog{}

      iex> get_menu_catalog!(456)
      ** (Ecto.NoResultsError)

  """
  def get_menu_catalog!(id), do: Repo.get!(MenuCatalog, id)

  @doc """
  Creates a menu_catalog.

  ## Examples

      iex> create_menu_catalog(%{field: value})
      {:ok, %MenuCatalog{}}

      iex> create_menu_catalog(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_menu_catalog(attrs \\ %{}) do
    %MenuCatalog{}
    |> MenuCatalog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a menu_catalog.

  ## Examples

      iex> update_menu_catalog(menu_catalog, %{field: new_value})
      {:ok, %MenuCatalog{}}

      iex> update_menu_catalog(menu_catalog, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_menu_catalog(%MenuCatalog{} = menu_catalog, attrs) do
    menu_catalog
    |> MenuCatalog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a MenuCatalog.

  ## Examples

      iex> delete_menu_catalog(menu_catalog)
      {:ok, %MenuCatalog{}}

      iex> delete_menu_catalog(menu_catalog)
      {:error, %Ecto.Changeset{}}

  """
  def delete_menu_catalog(%MenuCatalog{} = menu_catalog) do
    Repo.delete(menu_catalog)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking menu_catalog changes.

  ## Examples

      iex> change_menu_catalog(menu_catalog)
      %Ecto.Changeset{source: %MenuCatalog{}}

  """
  def change_menu_catalog(%MenuCatalog{} = menu_catalog) do
    MenuCatalog.changeset(menu_catalog, %{})
  end

  alias BoatNoodle.BN.MenuCatalogMaster

  @doc """
  Returns the list of menu_catalog_master.

  ## Examples

      iex> list_menu_catalog_master()
      [%MenuCatalogMaster{}, ...]

  """
  def list_menu_catalog_master do
    Repo.all(MenuCatalogMaster)
  end

  @doc """
  Gets a single menu_catalog_master.

  Raises `Ecto.NoResultsError` if the Menu catalog master does not exist.

  ## Examples

      iex> get_menu_catalog_master!(123)
      %MenuCatalogMaster{}

      iex> get_menu_catalog_master!(456)
      ** (Ecto.NoResultsError)

  """
  def get_menu_catalog_master!(id), do: Repo.get!(MenuCatalogMaster, id)

  @doc """
  Creates a menu_catalog_master.

  ## Examples

      iex> create_menu_catalog_master(%{field: value})
      {:ok, %MenuCatalogMaster{}}

      iex> create_menu_catalog_master(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_menu_catalog_master(attrs \\ %{}) do
    %MenuCatalogMaster{}
    |> MenuCatalogMaster.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a menu_catalog_master.

  ## Examples

      iex> update_menu_catalog_master(menu_catalog_master, %{field: new_value})
      {:ok, %MenuCatalogMaster{}}

      iex> update_menu_catalog_master(menu_catalog_master, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_menu_catalog_master(%MenuCatalogMaster{} = menu_catalog_master, attrs) do
    menu_catalog_master
    |> MenuCatalogMaster.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a MenuCatalogMaster.

  ## Examples

      iex> delete_menu_catalog_master(menu_catalog_master)
      {:ok, %MenuCatalogMaster{}}

      iex> delete_menu_catalog_master(menu_catalog_master)
      {:error, %Ecto.Changeset{}}

  """
  def delete_menu_catalog_master(%MenuCatalogMaster{} = menu_catalog_master) do
    Repo.delete(menu_catalog_master)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking menu_catalog_master changes.

  ## Examples

      iex> change_menu_catalog_master(menu_catalog_master)
      %Ecto.Changeset{source: %MenuCatalogMaster{}}

  """
  def change_menu_catalog_master(%MenuCatalogMaster{} = menu_catalog_master) do
    MenuCatalogMaster.changeset(menu_catalog_master, %{})
  end

  alias BoatNoodle.BN.DiscountCategory

  @doc """
  Returns the list of discount_category.

  ## Examples

      iex> list_discount_category()
      [%DiscountCategory{}, ...]

  """
  def list_discount_category do
    Repo.all(DiscountCategory)
  end

  @doc """
  Gets a single discount_category.

  Raises `Ecto.NoResultsError` if the Discount category does not exist.

  ## Examples

      iex> get_discount_category!(123)
      %DiscountCategory{}

      iex> get_discount_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_discount_category!(id), do: Repo.get!(DiscountCategory, id)

  @doc """
  Creates a discount_category.

  ## Examples

      iex> create_discount_category(%{field: value})
      {:ok, %DiscountCategory{}}

      iex> create_discount_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_discount_category(attrs \\ %{}) do
    %DiscountCategory{}
    |> DiscountCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a discount_category.

  ## Examples

      iex> update_discount_category(discount_category, %{field: new_value})
      {:ok, %DiscountCategory{}}

      iex> update_discount_category(discount_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_discount_category(%DiscountCategory{} = discount_category, attrs) do
    discount_category
    |> DiscountCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DiscountCategory.

  ## Examples

      iex> delete_discount_category(discount_category)
      {:ok, %DiscountCategory{}}

      iex> delete_discount_category(discount_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_discount_category(%DiscountCategory{} = discount_category) do
    Repo.delete(discount_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking discount_category changes.

  ## Examples

      iex> change_discount_category(discount_category)
      %Ecto.Changeset{source: %DiscountCategory{}}

  """
  def change_discount_category(%DiscountCategory{} = discount_category) do
    DiscountCategory.changeset(discount_category, %{})
  end

  alias BoatNoodle.BN.DiscountItem

  @doc """
  Returns the list of discount_item.

  ## Examples

      iex> list_discount_item()
      [%DiscountItem{}, ...]

  """
  def list_discount_item do
    Repo.all(DiscountItem)
  end

  @doc """
  Gets a single discount_item.

  Raises `Ecto.NoResultsError` if the Discount item does not exist.

  ## Examples

      iex> get_discount_item!(123)
      %DiscountItem{}

      iex> get_discount_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_discount_item!(id), do: Repo.get!(DiscountItem, id)

  @doc """
  Creates a discount_item.

  ## Examples

      iex> create_discount_item(%{field: value})
      {:ok, %DiscountItem{}}

      iex> create_discount_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_discount_item(attrs \\ %{}) do
    %DiscountItem{}
    |> DiscountItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a discount_item.

  ## Examples

      iex> update_discount_item(discount_item, %{field: new_value})
      {:ok, %DiscountItem{}}

      iex> update_discount_item(discount_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_discount_item(%DiscountItem{} = discount_item, attrs) do
    discount_item
    |> DiscountItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DiscountItem.

  ## Examples

      iex> delete_discount_item(discount_item)
      {:ok, %DiscountItem{}}

      iex> delete_discount_item(discount_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_discount_item(%DiscountItem{} = discount_item) do
    Repo.delete(discount_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking discount_item changes.

  ## Examples

      iex> change_discount_item(discount_item)
      %Ecto.Changeset{source: %DiscountItem{}}

  """
  def change_discount_item(%DiscountItem{} = discount_item) do
    DiscountItem.changeset(discount_item, %{})
  end

  alias BoatNoodle.BN.DiscountCatalogMaster

  @doc """
  Returns the list of discount_catalog_master.

  ## Examples

      iex> list_discount_catalog_master()
      [%DiscountCatalogMaster{}, ...]

  """
  def list_discount_catalog_master do
    Repo.all(DiscountCatalogMaster)
  end

  @doc """
  Gets a single discount_catalog_master.

  Raises `Ecto.NoResultsError` if the Discount catalog master does not exist.

  ## Examples

      iex> get_discount_catalog_master!(123)
      %DiscountCatalogMaster{}

      iex> get_discount_catalog_master!(456)
      ** (Ecto.NoResultsError)

  """
  def get_discount_catalog_master!(id), do: Repo.get!(DiscountCatalogMaster, id)

  @doc """
  Creates a discount_catalog_master.

  ## Examples

      iex> create_discount_catalog_master(%{field: value})
      {:ok, %DiscountCatalogMaster{}}

      iex> create_discount_catalog_master(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_discount_catalog_master(attrs \\ %{}) do
    %DiscountCatalogMaster{}
    |> DiscountCatalogMaster.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a discount_catalog_master.

  ## Examples

      iex> update_discount_catalog_master(discount_catalog_master, %{field: new_value})
      {:ok, %DiscountCatalogMaster{}}

      iex> update_discount_catalog_master(discount_catalog_master, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_discount_catalog_master(%DiscountCatalogMaster{} = discount_catalog_master, attrs) do
    discount_catalog_master
    |> DiscountCatalogMaster.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DiscountCatalogMaster.

  ## Examples

      iex> delete_discount_catalog_master(discount_catalog_master)
      {:ok, %DiscountCatalogMaster{}}

      iex> delete_discount_catalog_master(discount_catalog_master)
      {:error, %Ecto.Changeset{}}

  """
  def delete_discount_catalog_master(%DiscountCatalogMaster{} = discount_catalog_master) do
    Repo.delete(discount_catalog_master)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking discount_catalog_master changes.

  ## Examples

      iex> change_discount_catalog_master(discount_catalog_master)
      %Ecto.Changeset{source: %DiscountCatalogMaster{}}

  """
  def change_discount_catalog_master(%DiscountCatalogMaster{} = discount_catalog_master) do
    DiscountCatalogMaster.changeset(discount_catalog_master, %{})
  end

  alias BoatNoodle.BN.DiscountCatalog

  @doc """
  Returns the list of discount_catalog.

  ## Examples

      iex> list_discount_catalog()
      [%DiscountCatalog{}, ...]

  """
  def list_discount_catalog do
    Repo.all(DiscountCatalog)
  end

  @doc """
  Gets a single discount_catalog.

  Raises `Ecto.NoResultsError` if the Discount catalog does not exist.

  ## Examples

      iex> get_discount_catalog!(123)
      %DiscountCatalog{}

      iex> get_discount_catalog!(456)
      ** (Ecto.NoResultsError)

  """
  def get_discount_catalog!(id), do: Repo.get!(DiscountCatalog, id)

  @doc """
  Creates a discount_catalog.

  ## Examples

      iex> create_discount_catalog(%{field: value})
      {:ok, %DiscountCatalog{}}

      iex> create_discount_catalog(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_discount_catalog(attrs \\ %{}) do
    %DiscountCatalog{}
    |> DiscountCatalog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a discount_catalog.

  ## Examples

      iex> update_discount_catalog(discount_catalog, %{field: new_value})
      {:ok, %DiscountCatalog{}}

      iex> update_discount_catalog(discount_catalog, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_discount_catalog(%DiscountCatalog{} = discount_catalog, attrs) do
    discount_catalog
    |> DiscountCatalog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DiscountCatalog.

  ## Examples

      iex> delete_discount_catalog(discount_catalog)
      {:ok, %DiscountCatalog{}}

      iex> delete_discount_catalog(discount_catalog)
      {:error, %Ecto.Changeset{}}

  """
  def delete_discount_catalog(%DiscountCatalog{} = discount_catalog) do
    Repo.delete(discount_catalog)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking discount_catalog changes.

  ## Examples

      iex> change_discount_catalog(discount_catalog)
      %Ecto.Changeset{source: %DiscountCatalog{}}

  """
  def change_discount_catalog(%DiscountCatalog{} = discount_catalog) do
    DiscountCatalog.changeset(discount_catalog, %{})
  end

  alias BoatNoodle.BN.TagCatalog

  @doc """
  Returns the list of tag_catalog.

  ## Examples

      iex> list_tag_catalog()
      [%TagCatalog{}, ...]

  """
  def list_tag_catalog do
    Repo.all(TagCatalog)
  end

  @doc """
  Gets a single tag_catalog.

  Raises `Ecto.NoResultsError` if the Tag catalog does not exist.

  ## Examples

      iex> get_tag_catalog!(123)
      %TagCatalog{}

      iex> get_tag_catalog!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag_catalog!(id), do: Repo.get!(TagCatalog, id)

  @doc """
  Creates a tag_catalog.

  ## Examples

      iex> create_tag_catalog(%{field: value})
      {:ok, %TagCatalog{}}

      iex> create_tag_catalog(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag_catalog(attrs \\ %{}) do
    %TagCatalog{}
    |> TagCatalog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag_catalog.

  ## Examples

      iex> update_tag_catalog(tag_catalog, %{field: new_value})
      {:ok, %TagCatalog{}}

      iex> update_tag_catalog(tag_catalog, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag_catalog(%TagCatalog{} = tag_catalog, attrs) do
    tag_catalog
    |> TagCatalog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TagCatalog.

  ## Examples

      iex> delete_tag_catalog(tag_catalog)
      {:ok, %TagCatalog{}}

      iex> delete_tag_catalog(tag_catalog)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag_catalog(%TagCatalog{} = tag_catalog) do
    Repo.delete(tag_catalog)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag_catalog changes.

  ## Examples

      iex> change_tag_catalog(tag_catalog)
      %Ecto.Changeset{source: %TagCatalog{}}

  """
  def change_tag_catalog(%TagCatalog{} = tag_catalog) do
    TagCatalog.changeset(tag_catalog, %{})
  end

  alias BoatNoodle.BN.TagItems

  @doc """
  Returns the list of tag_items.

  ## Examples

      iex> list_tag_items()
      [%TagItems{}, ...]

  """
  def list_tag_items do
    Repo.all(TagItems)
  end

  @doc """
  Gets a single tag_items.

  Raises `Ecto.NoResultsError` if the Tag items does not exist.

  ## Examples

      iex> get_tag_items!(123)
      %TagItems{}

      iex> get_tag_items!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag_items!(id), do: Repo.get!(TagItems, id)

  @doc """
  Creates a tag_items.

  ## Examples

      iex> create_tag_items(%{field: value})
      {:ok, %TagItems{}}

      iex> create_tag_items(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag_items(attrs \\ %{}) do
    %TagItems{}
    |> TagItems.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag_items.

  ## Examples

      iex> update_tag_items(tag_items, %{field: new_value})
      {:ok, %TagItems{}}

      iex> update_tag_items(tag_items, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag_items(%TagItems{} = tag_items, attrs) do
    tag_items
    |> TagItems.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TagItems.

  ## Examples

      iex> delete_tag_items(tag_items)
      {:ok, %TagItems{}}

      iex> delete_tag_items(tag_items)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag_items(%TagItems{} = tag_items) do
    Repo.delete(tag_items)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag_items changes.

  ## Examples

      iex> change_tag_items(tag_items)
      %Ecto.Changeset{source: %TagItems{}}

  """
  def change_tag_items(%TagItems{} = tag_items) do
    TagItems.changeset(tag_items, %{})
  end

  alias BoatNoodle.BN.Staff

  @doc """
  Returns the list of staff.

  ## Examples

      iex> list_staff()
      [%Staff{}, ...]

  """
  def list_staff do
    Repo.all(Staff)
  end

  @doc """
  Gets a single staff.

  Raises `Ecto.NoResultsError` if the Staff does not exist.

  ## Examples

      iex> get_staff!(123)
      %Staff{}

      iex> get_staff!(456)
      ** (Ecto.NoResultsError)

  """
  def get_staff!(id), do: Repo.get!(Staff, id)

  @doc """
  Creates a staff.

  ## Examples

      iex> create_staff(%{field: value})
      {:ok, %Staff{}}

      iex> create_staff(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_staff(attrs \\ %{}) do
    %Staff{}
    |> Staff.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a staff.

  ## Examples

      iex> update_staff(staff, %{field: new_value})
      {:ok, %Staff{}}

      iex> update_staff(staff, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_staff(%Staff{} = staff, attrs) do
    staff
    |> Staff.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Staff.

  ## Examples

      iex> delete_staff(staff)
      {:ok, %Staff{}}

      iex> delete_staff(staff)
      {:error, %Ecto.Changeset{}}

  """
  def delete_staff(%Staff{} = staff) do
    Repo.delete(staff)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking staff changes.

  ## Examples

      iex> change_staff(staff)
      %Ecto.Changeset{source: %Staff{}}

  """
  def change_staff(%Staff{} = staff) do
    Staff.changeset(staff, %{})
  end

  alias BoatNoodle.BN.User

  @doc """
  Returns the list of user.

  ## Examples

      iex> list_user()
      [%User{}, ...]

  """
  def list_user do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias BoatNoodle.BN.Organization

  @doc """
  Returns the list of organization.

  ## Examples

      iex> list_organization()
      [%Organization{}, ...]

  """
  def list_organization do
    Repo.all(Organization)
  end

  @doc """
  Gets a single organization.

  Raises `Ecto.NoResultsError` if the Organization does not exist.

  ## Examples

      iex> get_organization!(123)
      %Organization{}

      iex> get_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organization!(id), do: Repo.get!(Organization, id)

  @doc """
  Creates a organization.

  ## Examples

      iex> create_organization(%{field: value})
      {:ok, %Organization{}}

      iex> create_organization(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a organization.

  ## Examples

      iex> update_organization(organization, %{field: new_value})
      {:ok, %Organization{}}

      iex> update_organization(organization, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Organization.

  ## Examples

      iex> delete_organization(organization)
      {:ok, %Organization{}}

      iex> delete_organization(organization)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organization changes.

  ## Examples

      iex> change_organization(organization)
      %Ecto.Changeset{source: %Organization{}}

  """
  def change_organization(%Organization{} = organization) do
    Organization.changeset(organization, %{})
  end

  alias BoatNoodle.BN.Branch

  @doc """
  Returns the list of branch.

  ## Examples

      iex> list_branch()
      [%Branch{}, ...]

  """
  def list_branch do
    Repo.all(Branch)
  end

  @doc """
  Gets a single branch.

  Raises `Ecto.NoResultsError` if the Branch does not exist.

  ## Examples

      iex> get_branch!(123)
      %Branch{}

      iex> get_branch!(456)
      ** (Ecto.NoResultsError)

  """
  def get_branch!(id), do: Repo.get!(Branch, id)

  @doc """
  Creates a branch.

  ## Examples

      iex> create_branch(%{field: value})
      {:ok, %Branch{}}

      iex> create_branch(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_branch(attrs \\ %{}) do
    %Branch{}
    |> Branch.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a branch.

  ## Examples

      iex> update_branch(branch, %{field: new_value})
      {:ok, %Branch{}}

      iex> update_branch(branch, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_branch(%Branch{} = branch, attrs) do
    branch
    |> Branch.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Branch.

  ## Examples

      iex> delete_branch(branch)
      {:ok, %Branch{}}

      iex> delete_branch(branch)
      {:error, %Ecto.Changeset{}}

  """
  def delete_branch(%Branch{} = branch) do
    Repo.delete(branch)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking branch changes.

  ## Examples

      iex> change_branch(branch)
      %Ecto.Changeset{source: %Branch{}}

  """
  def change_branch(%Branch{} = branch) do
    Branch.changeset(branch, %{})
  end

  alias BoatNoodle.BN.Tag

  @doc """
  Returns the list of tag.

  ## Examples

      iex> list_tag()
      [%Tag{}, ...]

  """
  def list_tag do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{source: %Tag{}}

  """
  def change_tag(%Tag{} = tag) do
    Tag.changeset(tag, %{})
  end

  alias BoatNoodle.BN.PaymentType

  @doc """
  Returns the list of payment_type.

  ## Examples

      iex> list_payment_type()
      [%PaymentType{}, ...]

  """
  def list_payment_type do
    Repo.all(PaymentType)
  end

  @doc """
  Gets a single payment_type.

  Raises `Ecto.NoResultsError` if the Payment type does not exist.

  ## Examples

      iex> get_payment_type!(123)
      %PaymentType{}

      iex> get_payment_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_payment_type!(id), do: Repo.get!(PaymentType, id)

  @doc """
  Creates a payment_type.

  ## Examples

      iex> create_payment_type(%{field: value})
      {:ok, %PaymentType{}}

      iex> create_payment_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment_type(attrs \\ %{}) do
    %PaymentType{}
    |> PaymentType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a payment_type.

  ## Examples

      iex> update_payment_type(payment_type, %{field: new_value})
      {:ok, %PaymentType{}}

      iex> update_payment_type(payment_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_payment_type(%PaymentType{} = payment_type, attrs) do
    payment_type
    |> PaymentType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PaymentType.

  ## Examples

      iex> delete_payment_type(payment_type)
      {:ok, %PaymentType{}}

      iex> delete_payment_type(payment_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_payment_type(%PaymentType{} = payment_type) do
    Repo.delete(payment_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking payment_type changes.

  ## Examples

      iex> change_payment_type(payment_type)
      %Ecto.Changeset{source: %PaymentType{}}

  """
  def change_payment_type(%PaymentType{} = payment_type) do
    PaymentType.changeset(payment_type, %{})
  end

  alias BoatNoodle.BN.SalesMaster

  @doc """
  Returns the list of sales_master.

  ## Examples

      iex> list_sales_master()
      [%SalesMaster{}, ...]

  """
  def list_sales_master do
    Repo.all(SalesMaster)
  end

  @doc """
  Gets a single sales_master.

  Raises `Ecto.NoResultsError` if the Sales master does not exist.

  ## Examples

      iex> get_sales_master!(123)
      %SalesMaster{}

      iex> get_sales_master!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sales_master!(id), do: Repo.get!(SalesMaster, id)

  @doc """
  Creates a sales_master.

  ## Examples

      iex> create_sales_master(%{field: value})
      {:ok, %SalesMaster{}}

      iex> create_sales_master(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sales_master(attrs \\ %{}) do
    %SalesMaster{}
    |> SalesMaster.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sales_master.

  ## Examples

      iex> update_sales_master(sales_master, %{field: new_value})
      {:ok, %SalesMaster{}}

      iex> update_sales_master(sales_master, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sales_master(%SalesMaster{} = sales_master, attrs) do
    sales_master
    |> SalesMaster.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SalesMaster.

  ## Examples

      iex> delete_sales_master(sales_master)
      {:ok, %SalesMaster{}}

      iex> delete_sales_master(sales_master)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sales_master(%SalesMaster{} = sales_master) do
    Repo.delete(sales_master)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sales_master changes.

  ## Examples

      iex> change_sales_master(sales_master)
      %Ecto.Changeset{source: %SalesMaster{}}

  """
  def change_sales_master(%SalesMaster{} = sales_master) do
    SalesMaster.changeset(sales_master, %{})
  end

  alias BoatNoodle.BN.Sales

  @doc """
  Returns the list of sales.

  ## Examples

      iex> list_sales()
      [%Sales{}, ...]

  """
  def list_sales do
    Repo.all(Sales)
  end

  @doc """
  Gets a single sales.

  Raises `Ecto.NoResultsError` if the Sales does not exist.

  ## Examples

      iex> get_sales!(123)
      %Sales{}

      iex> get_sales!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sales!(id), do: Repo.get!(Sales, id)

  @doc """
  Creates a sales.

  ## Examples

      iex> create_sales(%{field: value})
      {:ok, %Sales{}}

      iex> create_sales(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sales(attrs \\ %{}) do
    %Sales{}
    |> Sales.changeset(attrs)
    |> Repo.insert()
  end


  @doc """
  Updates a sales.

  ## Examples

      iex> update_sales(sales, %{field: new_value})
      {:ok, %Sales{}}

      iex> update_sales(sales, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sales(%Sales{} = sales, attrs) do
    sales
    |> Sales.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Sales.

  ## Examples

      iex> delete_sales(sales)
      {:ok, %Sales{}}

      iex> delete_sales(sales)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sales(%Sales{} = sales) do
    Repo.delete(sales)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sales changes.

  ## Examples

      iex> change_sales(sales)
      %Ecto.Changeset{source: %Sales{}}

  """
  def change_sales(%Sales{} = sales) do
    Sales.changeset(sales, %{})
  end

  alias BoatNoodle.BN.Tax

  @doc """
  Returns the list of tax.

  ## Examples

      iex> list_tax()
      [%Tax{}, ...]

  """
  def list_tax do
    Repo.all(Tax)
  end

  @doc """
  Gets a single tax.

  Raises `Ecto.NoResultsError` if the Tax does not exist.

  ## Examples

      iex> get_tax!(123)
      %Tax{}

      iex> get_tax!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tax!(id), do: Repo.get!(Tax, id)

  @doc """
  Creates a tax.

  ## Examples

      iex> create_tax(%{field: value})
      {:ok, %Tax{}}

      iex> create_tax(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tax(attrs \\ %{}) do
    %Tax{}
    |> Tax.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tax.

  ## Examples

      iex> update_tax(tax, %{field: new_value})
      {:ok, %Tax{}}

      iex> update_tax(tax, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tax(%Tax{} = tax, attrs) do
    tax
    |> Tax.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tax.

  ## Examples

      iex> delete_tax(tax)
      {:ok, %Tax{}}

      iex> delete_tax(tax)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tax(%Tax{} = tax) do
    Repo.delete(tax)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tax changes.

  ## Examples

      iex> change_tax(tax)
      %Ecto.Changeset{source: %Tax{}}

  """
  def change_tax(%Tax{} = tax) do
    Tax.changeset(tax, %{})
  end

  alias BoatNoodle.BN.CashInOut

  @doc """
  Returns the list of cash_in_out.

  ## Examples

      iex> list_cash_in_out()
      [%CashInOut{}, ...]

  """
  def list_cash_in_out do
    Repo.all(CashInOut)
  end

  @doc """
  Gets a single cash_in_out.

  Raises `Ecto.NoResultsError` if the Cash in out does not exist.

  ## Examples

      iex> get_cash_in_out!(123)
      %CashInOut{}

      iex> get_cash_in_out!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cash_in_out!(id), do: Repo.get!(CashInOut, id)

  @doc """
  Creates a cash_in_out.

  ## Examples

      iex> create_cash_in_out(%{field: value})
      {:ok, %CashInOut{}}

      iex> create_cash_in_out(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cash_in_out(attrs \\ %{}) do
    %CashInOut{}
    |> CashInOut.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cash_in_out.

  ## Examples

      iex> update_cash_in_out(cash_in_out, %{field: new_value})
      {:ok, %CashInOut{}}

      iex> update_cash_in_out(cash_in_out, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cash_in_out(%CashInOut{} = cash_in_out, attrs) do
    cash_in_out
    |> CashInOut.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CashInOut.

  ## Examples

      iex> delete_cash_in_out(cash_in_out)
      {:ok, %CashInOut{}}

      iex> delete_cash_in_out(cash_in_out)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cash_in_out(%CashInOut{} = cash_in_out) do
    Repo.delete(cash_in_out)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cash_in_out changes.

  ## Examples

      iex> change_cash_in_out(cash_in_out)
      %Ecto.Changeset{source: %CashInOut{}}

  """
  def change_cash_in_out(%CashInOut{} = cash_in_out) do
    CashInOut.changeset(cash_in_out, %{})
  end

  alias BoatNoodle.BN.BranchItemDeactivate

  @doc """
  Returns the list of branch_item_deactivate.

  ## Examples

      iex> list_branch_item_deactivate()
      [%BranchItemDeactivate{}, ...]

  """
  def list_branch_item_deactivate do
    Repo.all(BranchItemDeactivate)
  end

  @doc """
  Gets a single branch_item_deactivate.

  Raises `Ecto.NoResultsError` if the Branch item deactivate does not exist.

  ## Examples

      iex> get_branch_item_deactivate!(123)
      %BranchItemDeactivate{}

      iex> get_branch_item_deactivate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_branch_item_deactivate!(id), do: Repo.get!(BranchItemDeactivate, id)

  @doc """
  Creates a branch_item_deactivate.

  ## Examples

      iex> create_branch_item_deactivate(%{field: value})
      {:ok, %BranchItemDeactivate{}}

      iex> create_branch_item_deactivate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_branch_item_deactivate(attrs \\ %{}) do
    %BranchItemDeactivate{}
    |> BranchItemDeactivate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a branch_item_deactivate.

  ## Examples

      iex> update_branch_item_deactivate(branch_item_deactivate, %{field: new_value})
      {:ok, %BranchItemDeactivate{}}

      iex> update_branch_item_deactivate(branch_item_deactivate, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_branch_item_deactivate(%BranchItemDeactivate{} = branch_item_deactivate, attrs) do
    branch_item_deactivate
    |> BranchItemDeactivate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BranchItemDeactivate.

  ## Examples

      iex> delete_branch_item_deactivate(branch_item_deactivate)
      {:ok, %BranchItemDeactivate{}}

      iex> delete_branch_item_deactivate(branch_item_deactivate)
      {:error, %Ecto.Changeset{}}

  """
  def delete_branch_item_deactivate(%BranchItemDeactivate{} = branch_item_deactivate) do
    Repo.delete(branch_item_deactivate)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking branch_item_deactivate changes.

  ## Examples

      iex> change_branch_item_deactivate(branch_item_deactivate)
      %Ecto.Changeset{source: %BranchItemDeactivate{}}

  """
  def change_branch_item_deactivate(%BranchItemDeactivate{} = branch_item_deactivate) do
    BranchItemDeactivate.changeset(branch_item_deactivate, %{})
  end

  alias BoatNoodle.BN.CashierSession

  @doc """
  Returns the list of cashier_session.

  ## Examples

      iex> list_cashier_session()
      [%CashierSession{}, ...]

  """
  def list_cashier_session do
    Repo.all(CashierSession)
  end

  @doc """
  Gets a single cashier_session.

  Raises `Ecto.NoResultsError` if the Cashier session does not exist.

  ## Examples

      iex> get_cashier_session!(123)
      %CashierSession{}

      iex> get_cashier_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cashier_session!(id), do: Repo.get!(CashierSession, id)

  @doc """
  Creates a cashier_session.

  ## Examples

      iex> create_cashier_session(%{field: value})
      {:ok, %CashierSession{}}

      iex> create_cashier_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cashier_session(attrs \\ %{}) do
    %CashierSession{}
    |> CashierSession.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cashier_session.

  ## Examples

      iex> update_cashier_session(cashier_session, %{field: new_value})
      {:ok, %CashierSession{}}

      iex> update_cashier_session(cashier_session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cashier_session(%CashierSession{} = cashier_session, attrs) do
    cashier_session
    |> CashierSession.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CashierSession.

  ## Examples

      iex> delete_cashier_session(cashier_session)
      {:ok, %CashierSession{}}

      iex> delete_cashier_session(cashier_session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cashier_session(%CashierSession{} = cashier_session) do
    Repo.delete(cashier_session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cashier_session changes.

  ## Examples

      iex> change_cashier_session(cashier_session)
      %Ecto.Changeset{source: %CashierSession{}}

  """
  def change_cashier_session(%CashierSession{} = cashier_session) do
    CashierSession.changeset(cashier_session, %{})
  end

  alias BoatNoodle.BN.CashInOutType

  @doc """
  Returns the list of cash_in_out_type.

  ## Examples

      iex> list_cash_in_out_type()
      [%CashInOutType{}, ...]

  """
  def list_cash_in_out_type do
    Repo.all(CashInOutType)
  end

  @doc """
  Gets a single cash_in_out_type.

  Raises `Ecto.NoResultsError` if the Cash in out type does not exist.

  ## Examples

      iex> get_cash_in_out_type!(123)
      %CashInOutType{}

      iex> get_cash_in_out_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cash_in_out_type!(id), do: Repo.get!(CashInOutType, id)

  @doc """
  Creates a cash_in_out_type.

  ## Examples

      iex> create_cash_in_out_type(%{field: value})
      {:ok, %CashInOutType{}}

      iex> create_cash_in_out_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cash_in_out_type(attrs \\ %{}) do
    %CashInOutType{}
    |> CashInOutType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cash_in_out_type.

  ## Examples

      iex> update_cash_in_out_type(cash_in_out_type, %{field: new_value})
      {:ok, %CashInOutType{}}

      iex> update_cash_in_out_type(cash_in_out_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cash_in_out_type(%CashInOutType{} = cash_in_out_type, attrs) do
    cash_in_out_type
    |> CashInOutType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CashInOutType.

  ## Examples

      iex> delete_cash_in_out_type(cash_in_out_type)
      {:ok, %CashInOutType{}}

      iex> delete_cash_in_out_type(cash_in_out_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cash_in_out_type(%CashInOutType{} = cash_in_out_type) do
    Repo.delete(cash_in_out_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cash_in_out_type changes.

  ## Examples

      iex> change_cash_in_out_type(cash_in_out_type)
      %Ecto.Changeset{source: %CashInOutType{}}

  """
  def change_cash_in_out_type(%CashInOutType{} = cash_in_out_type) do
    CashInOutType.changeset(cash_in_out_type, %{})
  end

  alias BoatNoodle.BN.ComboDetails

  @doc """
  Returns the list of combo_details.

  ## Examples

      iex> list_combo_details()
      [%ComboDetails{}, ...]

  """
  def list_combo_details do
    Repo.all(ComboDetails)
  end

  @doc """
  Gets a single combo_details.

  Raises `Ecto.NoResultsError` if the Combo details does not exist.

  ## Examples

      iex> get_combo_details!(123)
      %ComboDetails{}

      iex> get_combo_details!(456)
      ** (Ecto.NoResultsError)

  """
  def get_combo_details!(id), do: Repo.get!(ComboDetails, id)

  @doc """
  Creates a combo_details.

  ## Examples

      iex> create_combo_details(%{field: value})
      {:ok, %ComboDetails{}}

      iex> create_combo_details(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_combo_details(attrs \\ %{}) do
    %ComboDetails{}
    |> ComboDetails.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a combo_details.

  ## Examples

      iex> update_combo_details(combo_details, %{field: new_value})
      {:ok, %ComboDetails{}}

      iex> update_combo_details(combo_details, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_combo_details(%ComboDetails{} = combo_details, attrs) do
    combo_details
    |> ComboDetails.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ComboDetails.

  ## Examples

      iex> delete_combo_details(combo_details)
      {:ok, %ComboDetails{}}

      iex> delete_combo_details(combo_details)
      {:error, %Ecto.Changeset{}}

  """
  def delete_combo_details(%ComboDetails{} = combo_details) do
    Repo.delete(combo_details)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking combo_details changes.

  ## Examples

      iex> change_combo_details(combo_details)
      %Ecto.Changeset{source: %ComboDetails{}}

  """
  def change_combo_details(%ComboDetails{} = combo_details) do
    ComboDetails.changeset(combo_details, %{})
  end

  alias BoatNoodle.BN.ComboMap

  @doc """
  Returns the list of combo_map.

  ## Examples

      iex> list_combo_map()
      [%ComboMap{}, ...]

  """
  def list_combo_map do
    Repo.all(ComboMap)
  end

  @doc """
  Gets a single combo_map.

  Raises `Ecto.NoResultsError` if the Combo map does not exist.

  ## Examples

      iex> get_combo_map!(123)
      %ComboMap{}

      iex> get_combo_map!(456)
      ** (Ecto.NoResultsError)

  """
  def get_combo_map!(id), do: Repo.get!(ComboMap, id)

  @doc """
  Creates a combo_map.

  ## Examples

      iex> create_combo_map(%{field: value})
      {:ok, %ComboMap{}}

      iex> create_combo_map(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_combo_map(attrs \\ %{}) do
    %ComboMap{}
    |> ComboMap.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a combo_map.

  ## Examples

      iex> update_combo_map(combo_map, %{field: new_value})
      {:ok, %ComboMap{}}

      iex> update_combo_map(combo_map, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_combo_map(%ComboMap{} = combo_map, attrs) do
    combo_map
    |> ComboMap.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ComboMap.

  ## Examples

      iex> delete_combo_map(combo_map)
      {:ok, %ComboMap{}}

      iex> delete_combo_map(combo_map)
      {:error, %Ecto.Changeset{}}

  """
  def delete_combo_map(%ComboMap{} = combo_map) do
    Repo.delete(combo_map)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking combo_map changes.

  ## Examples

      iex> change_combo_map(combo_map)
      %Ecto.Changeset{source: %ComboMap{}}

  """
  def change_combo_map(%ComboMap{} = combo_map) do
    ComboMap.changeset(combo_map, %{})
  end

  alias BoatNoodle.BN.DiscountType

  @doc """
  Returns the list of discount_type.

  ## Examples

      iex> list_discount_type()
      [%DiscountType{}, ...]

  """
  def list_discount_type do
    Repo.all(DiscountType)
  end

  @doc """
  Gets a single discount_type.

  Raises `Ecto.NoResultsError` if the Discount type does not exist.

  ## Examples

      iex> get_discount_type!(123)
      %DiscountType{}

      iex> get_discount_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_discount_type!(id), do: Repo.get!(DiscountType, id)

  @doc """
  Creates a discount_type.

  ## Examples

      iex> create_discount_type(%{field: value})
      {:ok, %DiscountType{}}

      iex> create_discount_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_discount_type(attrs \\ %{}) do
    %DiscountType{}
    |> DiscountType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a discount_type.

  ## Examples

      iex> update_discount_type(discount_type, %{field: new_value})
      {:ok, %DiscountType{}}

      iex> update_discount_type(discount_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_discount_type(%DiscountType{} = discount_type, attrs) do
    discount_type
    |> DiscountType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a DiscountType.

  ## Examples

      iex> delete_discount_type(discount_type)
      {:ok, %DiscountType{}}

      iex> delete_discount_type(discount_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_discount_type(%DiscountType{} = discount_type) do
    Repo.delete(discount_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking discount_type changes.

  ## Examples

      iex> change_discount_type(discount_type)
      %Ecto.Changeset{source: %DiscountType{}}

  """
  def change_discount_type(%DiscountType{} = discount_type) do
    DiscountType.changeset(discount_type, %{})
  end

  alias BoatNoodle.BN.ItemCustomized

  @doc """
  Returns the list of item_customized.

  ## Examples

      iex> list_item_customized()
      [%ItemCustomized{}, ...]

  """
  def list_item_customized do
    Repo.all(ItemCustomized)
  end

  @doc """
  Gets a single item_customized.

  Raises `Ecto.NoResultsError` if the Item customized does not exist.

  ## Examples

      iex> get_item_customized!(123)
      %ItemCustomized{}

      iex> get_item_customized!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item_customized!(id), do: Repo.get!(ItemCustomized, id)

  @doc """
  Creates a item_customized.

  ## Examples

      iex> create_item_customized(%{field: value})
      {:ok, %ItemCustomized{}}

      iex> create_item_customized(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item_customized(attrs \\ %{}) do
    %ItemCustomized{}
    |> ItemCustomized.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item_customized.

  ## Examples

      iex> update_item_customized(item_customized, %{field: new_value})
      {:ok, %ItemCustomized{}}

      iex> update_item_customized(item_customized, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item_customized(%ItemCustomized{} = item_customized, attrs) do
    item_customized
    |> ItemCustomized.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ItemCustomized.

  ## Examples

      iex> delete_item_customized(item_customized)
      {:ok, %ItemCustomized{}}

      iex> delete_item_customized(item_customized)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item_customized(%ItemCustomized{} = item_customized) do
    Repo.delete(item_customized)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item_customized changes.

  ## Examples

      iex> change_item_customized(item_customized)
      %Ecto.Changeset{source: %ItemCustomized{}}

  """
  def change_item_customized(%ItemCustomized{} = item_customized) do
    ItemCustomized.changeset(item_customized, %{})
  end

  alias BoatNoodle.BN.Migrations

  @doc """
  Returns the list of migrations.

  ## Examples

      iex> list_migrations()
      [%Migrations{}, ...]

  """
  def list_migrations do
    Repo.all(Migrations)
  end

  @doc """
  Gets a single migrations.

  Raises `Ecto.NoResultsError` if the Migrations does not exist.

  ## Examples

      iex> get_migrations!(123)
      %Migrations{}

      iex> get_migrations!(456)
      ** (Ecto.NoResultsError)

  """
  def get_migrations!(id), do: Repo.get!(Migrations, id)

  @doc """
  Creates a migrations.

  ## Examples

      iex> create_migrations(%{field: value})
      {:ok, %Migrations{}}

      iex> create_migrations(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_migrations(attrs \\ %{}) do
    %Migrations{}
    |> Migrations.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a migrations.

  ## Examples

      iex> update_migrations(migrations, %{field: new_value})
      {:ok, %Migrations{}}

      iex> update_migrations(migrations, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_migrations(%Migrations{} = migrations, attrs) do
    migrations
    |> Migrations.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Migrations.

  ## Examples

      iex> delete_migrations(migrations)
      {:ok, %Migrations{}}

      iex> delete_migrations(migrations)
      {:error, %Ecto.Changeset{}}

  """
  def delete_migrations(%Migrations{} = migrations) do
    Repo.delete(migrations)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking migrations changes.

  ## Examples

      iex> change_migrations(migrations)
      %Ecto.Changeset{source: %Migrations{}}

  """
  def change_migrations(%Migrations{} = migrations) do
    Migrations.changeset(migrations, %{})
  end

  alias BoatNoodle.BN.PasswordResets

  @doc """
  Returns the list of password_resets.

  ## Examples

      iex> list_password_resets()
      [%PasswordResets{}, ...]

  """
  def list_password_resets do
    Repo.all(PasswordResets)
  end

  @doc """
  Gets a single password_resets.

  Raises `Ecto.NoResultsError` if the Password resets does not exist.

  ## Examples

      iex> get_password_resets!(123)
      %PasswordResets{}

      iex> get_password_resets!(456)
      ** (Ecto.NoResultsError)

  """
  def get_password_resets!(id), do: Repo.get!(PasswordResets, id)

  @doc """
  Creates a password_resets.

  ## Examples

      iex> create_password_resets(%{field: value})
      {:ok, %PasswordResets{}}

      iex> create_password_resets(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_password_resets(attrs \\ %{}) do
    %PasswordResets{}
    |> PasswordResets.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a password_resets.

  ## Examples

      iex> update_password_resets(password_resets, %{field: new_value})
      {:ok, %PasswordResets{}}

      iex> update_password_resets(password_resets, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_password_resets(%PasswordResets{} = password_resets, attrs) do
    password_resets
    |> PasswordResets.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PasswordResets.

  ## Examples

      iex> delete_password_resets(password_resets)
      {:ok, %PasswordResets{}}

      iex> delete_password_resets(password_resets)
      {:error, %Ecto.Changeset{}}

  """
  def delete_password_resets(%PasswordResets{} = password_resets) do
    Repo.delete(password_resets)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking password_resets changes.

  ## Examples

      iex> change_password_resets(password_resets)
      %Ecto.Changeset{source: %PasswordResets{}}

  """
  def change_password_resets(%PasswordResets{} = password_resets) do
    PasswordResets.changeset(password_resets, %{})
  end

  alias BoatNoodle.BN.RPTCASHIEREOD

  @doc """
  Returns the list of rpt_cashier_eod.

  ## Examples

      iex> list_rpt_cashier_eod()
      [%RPTCASHIEREOD{}, ...]

  """
  def list_rpt_cashier_eod do
    Repo.all(RPTCASHIEREOD)
  end

  @doc """
  Gets a single rptcashiereod.

  Raises `Ecto.NoResultsError` if the Rptcashiereod does not exist.

  ## Examples

      iex> get_rptcashiereod!(123)
      %RPTCASHIEREOD{}

      iex> get_rptcashiereod!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rptcashiereod!(id), do: Repo.get!(RPTCASHIEREOD, id)

  @doc """
  Creates a rptcashiereod.

  ## Examples

      iex> create_rptcashiereod(%{field: value})
      {:ok, %RPTCASHIEREOD{}}

      iex> create_rptcashiereod(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rptcashiereod(attrs \\ %{}) do
    %RPTCASHIEREOD{}
    |> RPTCASHIEREOD.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rptcashiereod.

  ## Examples

      iex> update_rptcashiereod(rptcashiereod, %{field: new_value})
      {:ok, %RPTCASHIEREOD{}}

      iex> update_rptcashiereod(rptcashiereod, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rptcashiereod(%RPTCASHIEREOD{} = rptcashiereod, attrs) do
    rptcashiereod
    |> RPTCASHIEREOD.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a RPTCASHIEREOD.

  ## Examples

      iex> delete_rptcashiereod(rptcashiereod)
      {:ok, %RPTCASHIEREOD{}}

      iex> delete_rptcashiereod(rptcashiereod)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rptcashiereod(%RPTCASHIEREOD{} = rptcashiereod) do
    Repo.delete(rptcashiereod)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rptcashiereod changes.

  ## Examples

      iex> change_rptcashiereod(rptcashiereod)
      %Ecto.Changeset{source: %RPTCASHIEREOD{}}

  """
  def change_rptcashiereod(%RPTCASHIEREOD{} = rptcashiereod) do
    RPTCASHIEREOD.changeset(rptcashiereod, %{})
  end

  alias BoatNoodle.BN.RPTHOURLYOUTLET

  @doc """
  Returns the list of rpt_hourly_outlet.

  ## Examples

      iex> list_rpt_hourly_outlet()
      [%RPTHOURLYOUTLET{}, ...]

  """
  def list_rpt_hourly_outlet do
    Repo.all(RPTHOURLYOUTLET)
  end

  @doc """
  Gets a single rpthourlyoutlet.

  Raises `Ecto.NoResultsError` if the Rpthourlyoutlet does not exist.

  ## Examples

      iex> get_rpthourlyoutlet!(123)
      %RPTHOURLYOUTLET{}

      iex> get_rpthourlyoutlet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rpthourlyoutlet!(id), do: Repo.get!(RPTHOURLYOUTLET, id)

  @doc """
  Creates a rpthourlyoutlet.

  ## Examples

      iex> create_rpthourlyoutlet(%{field: value})
      {:ok, %RPTHOURLYOUTLET{}}

      iex> create_rpthourlyoutlet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rpthourlyoutlet(attrs \\ %{}) do
    %RPTHOURLYOUTLET{}
    |> RPTHOURLYOUTLET.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rpthourlyoutlet.

  ## Examples

      iex> update_rpthourlyoutlet(rpthourlyoutlet, %{field: new_value})
      {:ok, %RPTHOURLYOUTLET{}}

      iex> update_rpthourlyoutlet(rpthourlyoutlet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rpthourlyoutlet(%RPTHOURLYOUTLET{} = rpthourlyoutlet, attrs) do
    rpthourlyoutlet
    |> RPTHOURLYOUTLET.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a RPTHOURLYOUTLET.

  ## Examples

      iex> delete_rpthourlyoutlet(rpthourlyoutlet)
      {:ok, %RPTHOURLYOUTLET{}}

      iex> delete_rpthourlyoutlet(rpthourlyoutlet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rpthourlyoutlet(%RPTHOURLYOUTLET{} = rpthourlyoutlet) do
    Repo.delete(rpthourlyoutlet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rpthourlyoutlet changes.

  ## Examples

      iex> change_rpthourlyoutlet(rpthourlyoutlet)
      %Ecto.Changeset{source: %RPTHOURLYOUTLET{}}

  """
  def change_rpthourlyoutlet(%RPTHOURLYOUTLET{} = rpthourlyoutlet) do
    RPTHOURLYOUTLET.changeset(rpthourlyoutlet, %{})
  end

  alias BoatNoodle.BN.RPTTRANSACTION

  @doc """
  Returns the list of rpt_transaction.

  ## Examples

      iex> list_rpt_transaction()
      [%RPTTRANSACTION{}, ...]

  """
  def list_rpt_transaction do
    Repo.all(RPTTRANSACTION)
  end

  @doc """
  Gets a single rpttransaction.

  Raises `Ecto.NoResultsError` if the Rpttransaction does not exist.

  ## Examples

      iex> get_rpttransaction!(123)
      %RPTTRANSACTION{}

      iex> get_rpttransaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rpttransaction!(id), do: Repo.get!(RPTTRANSACTION, id)

  @doc """
  Creates a rpttransaction.

  ## Examples

      iex> create_rpttransaction(%{field: value})
      {:ok, %RPTTRANSACTION{}}

      iex> create_rpttransaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rpttransaction(attrs \\ %{}) do
    %RPTTRANSACTION{}
    |> RPTTRANSACTION.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rpttransaction.

  ## Examples

      iex> update_rpttransaction(rpttransaction, %{field: new_value})
      {:ok, %RPTTRANSACTION{}}

      iex> update_rpttransaction(rpttransaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rpttransaction(%RPTTRANSACTION{} = rpttransaction, attrs) do
    rpttransaction
    |> RPTTRANSACTION.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a RPTTRANSACTION.

  ## Examples

      iex> delete_rpttransaction(rpttransaction)
      {:ok, %RPTTRANSACTION{}}

      iex> delete_rpttransaction(rpttransaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rpttransaction(%RPTTRANSACTION{} = rpttransaction) do
    Repo.delete(rpttransaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rpttransaction changes.

  ## Examples

      iex> change_rpttransaction(rpttransaction)
      %Ecto.Changeset{source: %RPTTRANSACTION{}}

  """
  def change_rpttransaction(%RPTTRANSACTION{} = rpttransaction) do
    RPTTRANSACTION.changeset(rpttransaction, %{})
  end

  alias BoatNoodle.BN.SalesDetailCust

  @doc """
  Returns the list of salesdetailcust.

  ## Examples

      iex> list_salesdetailcust()
      [%SalesDetailCust{}, ...]

  """
  def list_salesdetailcust do
    Repo.all(SalesDetailCust)
  end

  @doc """
  Gets a single sales_detail_cust.

  Raises `Ecto.NoResultsError` if the Sales detail cust does not exist.

  ## Examples

      iex> get_sales_detail_cust!(123)
      %SalesDetailCust{}

      iex> get_sales_detail_cust!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sales_detail_cust!(id), do: Repo.get!(SalesDetailCust, id)

  @doc """
  Creates a sales_detail_cust.

  ## Examples

      iex> create_sales_detail_cust(%{field: value})
      {:ok, %SalesDetailCust{}}

      iex> create_sales_detail_cust(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sales_detail_cust(attrs \\ %{}) do
    %SalesDetailCust{}
    |> SalesDetailCust.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sales_detail_cust.

  ## Examples

      iex> update_sales_detail_cust(sales_detail_cust, %{field: new_value})
      {:ok, %SalesDetailCust{}}

      iex> update_sales_detail_cust(sales_detail_cust, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sales_detail_cust(%SalesDetailCust{} = sales_detail_cust, attrs) do
    sales_detail_cust
    |> SalesDetailCust.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SalesDetailCust.

  ## Examples

      iex> delete_sales_detail_cust(sales_detail_cust)
      {:ok, %SalesDetailCust{}}

      iex> delete_sales_detail_cust(sales_detail_cust)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sales_detail_cust(%SalesDetailCust{} = sales_detail_cust) do
    Repo.delete(sales_detail_cust)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sales_detail_cust changes.

  ## Examples

      iex> change_sales_detail_cust(sales_detail_cust)
      %Ecto.Changeset{source: %SalesDetailCust{}}

  """
  def change_sales_detail_cust(%SalesDetailCust{} = sales_detail_cust) do
    SalesDetailCust.changeset(sales_detail_cust, %{})
  end

  alias BoatNoodle.BN.StaffLogSession

  @doc """
  Returns the list of staff_log_session.

  ## Examples

      iex> list_staff_log_session()
      [%StaffLogSession{}, ...]

  """
  def list_staff_log_session do
    Repo.all(StaffLogSession)
  end

  @doc """
  Gets a single staff_log_session.

  Raises `Ecto.NoResultsError` if the Staff log session does not exist.

  ## Examples

      iex> get_staff_log_session!(123)
      %StaffLogSession{}

      iex> get_staff_log_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_staff_log_session!(id), do: Repo.get!(StaffLogSession, id)

  @doc """
  Creates a staff_log_session.

  ## Examples

      iex> create_staff_log_session(%{field: value})
      {:ok, %StaffLogSession{}}

      iex> create_staff_log_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_staff_log_session(attrs \\ %{}) do
    %StaffLogSession{}
    |> StaffLogSession.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a staff_log_session.

  ## Examples

      iex> update_staff_log_session(staff_log_session, %{field: new_value})
      {:ok, %StaffLogSession{}}

      iex> update_staff_log_session(staff_log_session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_staff_log_session(%StaffLogSession{} = staff_log_session, attrs) do
    staff_log_session
    |> StaffLogSession.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a StaffLogSession.

  ## Examples

      iex> delete_staff_log_session(staff_log_session)
      {:ok, %StaffLogSession{}}

      iex> delete_staff_log_session(staff_log_session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_staff_log_session(%StaffLogSession{} = staff_log_session) do
    Repo.delete(staff_log_session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking staff_log_session changes.

  ## Examples

      iex> change_staff_log_session(staff_log_session)
      %Ecto.Changeset{source: %StaffLogSession{}}

  """
  def change_staff_log_session(%StaffLogSession{} = staff_log_session) do
    StaffLogSession.changeset(staff_log_session, %{})
  end

  alias BoatNoodle.BN.StaffType

  @doc """
  Returns the list of staff_type.

  ## Examples

      iex> list_staff_type()
      [%StaffType{}, ...]

  """
  def list_staff_type do
    Repo.all(StaffType)
  end

  @doc """
  Gets a single staff_type.

  Raises `Ecto.NoResultsError` if the Staff type does not exist.

  ## Examples

      iex> get_staff_type!(123)
      %StaffType{}

      iex> get_staff_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_staff_type!(id), do: Repo.get!(StaffType, id)

  @doc """
  Creates a staff_type.

  ## Examples

      iex> create_staff_type(%{field: value})
      {:ok, %StaffType{}}

      iex> create_staff_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_staff_type(attrs \\ %{}) do
    %StaffType{}
    |> StaffType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a staff_type.

  ## Examples

      iex> update_staff_type(staff_type, %{field: new_value})
      {:ok, %StaffType{}}

      iex> update_staff_type(staff_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_staff_type(%StaffType{} = staff_type, attrs) do
    staff_type
    |> StaffType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a StaffType.

  ## Examples

      iex> delete_staff_type(staff_type)
      {:ok, %StaffType{}}

      iex> delete_staff_type(staff_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_staff_type(%StaffType{} = staff_type) do
    Repo.delete(staff_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking staff_type changes.

  ## Examples

      iex> change_staff_type(staff_type)
      %Ecto.Changeset{source: %StaffType{}}

  """
  def change_staff_type(%StaffType{} = staff_type) do
    StaffType.changeset(staff_type, %{})
  end

  alias BoatNoodle.BN.UserBranchAccess

  @doc """
  Returns the list of user_branch_access.

  ## Examples

      iex> list_user_branch_access()
      [%UserBranchAccess{}, ...]

  """
  def list_user_branch_access do
    Repo.all(UserBranchAccess)
  end

  @doc """
  Gets a single user_branch_access.

  Raises `Ecto.NoResultsError` if the User branch access does not exist.

  ## Examples

      iex> get_user_branch_access!(123)
      %UserBranchAccess{}

      iex> get_user_branch_access!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_branch_access!(id), do: Repo.get!(UserBranchAccess, id)

  @doc """
  Creates a user_branch_access.

  ## Examples

      iex> create_user_branch_access(%{field: value})
      {:ok, %UserBranchAccess{}}

      iex> create_user_branch_access(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_branch_access(attrs \\ %{}) do
    %UserBranchAccess{}
    |> UserBranchAccess.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_branch_access.

  ## Examples

      iex> update_user_branch_access(user_branch_access, %{field: new_value})
      {:ok, %UserBranchAccess{}}

      iex> update_user_branch_access(user_branch_access, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_branch_access(%UserBranchAccess{} = user_branch_access, attrs) do
    user_branch_access
    |> UserBranchAccess.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserBranchAccess.

  ## Examples

      iex> delete_user_branch_access(user_branch_access)
      {:ok, %UserBranchAccess{}}

      iex> delete_user_branch_access(user_branch_access)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_branch_access(%UserBranchAccess{} = user_branch_access) do
    Repo.delete(user_branch_access)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_branch_access changes.

  ## Examples

      iex> change_user_branch_access(user_branch_access)
      %Ecto.Changeset{source: %UserBranchAccess{}}

  """
  def change_user_branch_access(%UserBranchAccess{} = user_branch_access) do
    UserBranchAccess.changeset(user_branch_access, %{})
  end

  alias BoatNoodle.BN.UserPwd

  @doc """
  Returns the list of user_pwd.

  ## Examples

      iex> list_user_pwd()
      [%UserPwd{}, ...]

  """
  def list_user_pwd do
    Repo.all(UserPwd)
  end

  @doc """
  Gets a single user_pwd.

  Raises `Ecto.NoResultsError` if the User pwd does not exist.

  ## Examples

      iex> get_user_pwd!(123)
      %UserPwd{}

      iex> get_user_pwd!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_pwd!(id), do: Repo.get!(UserPwd, id)

  @doc """
  Creates a user_pwd.

  ## Examples

      iex> create_user_pwd(%{field: value})
      {:ok, %UserPwd{}}

      iex> create_user_pwd(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_pwd(attrs \\ %{}) do
    %UserPwd{}
    |> UserPwd.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_pwd.

  ## Examples

      iex> update_user_pwd(user_pwd, %{field: new_value})
      {:ok, %UserPwd{}}

      iex> update_user_pwd(user_pwd, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_pwd(%UserPwd{} = user_pwd, attrs) do
    user_pwd
    |> UserPwd.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserPwd.

  ## Examples

      iex> delete_user_pwd(user_pwd)
      {:ok, %UserPwd{}}

      iex> delete_user_pwd(user_pwd)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_pwd(%UserPwd{} = user_pwd) do
    Repo.delete(user_pwd)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_pwd changes.

  ## Examples

      iex> change_user_pwd(user_pwd)
      %Ecto.Changeset{source: %UserPwd{}}

  """
  def change_user_pwd(%UserPwd{} = user_pwd) do
    UserPwd.changeset(user_pwd, %{})
  end

  alias BoatNoodle.BN.UserRole

  @doc """
  Returns the list of user_role.

  ## Examples

      iex> list_user_role()
      [%UserRole{}, ...]

  """
  def list_user_role do
    Repo.all(UserRole)
  end

  @doc """
  Gets a single user_role.

  Raises `Ecto.NoResultsError` if the User role does not exist.

  ## Examples

      iex> get_user_role!(123)
      %UserRole{}

      iex> get_user_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_role!(id), do: Repo.get!(UserRole, id)

  @doc """
  Creates a user_role.

  ## Examples

      iex> create_user_role(%{field: value})
      {:ok, %UserRole{}}

      iex> create_user_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_role(attrs \\ %{}) do
    %UserRole{}
    |> UserRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_role.

  ## Examples

      iex> update_user_role(user_role, %{field: new_value})
      {:ok, %UserRole{}}

      iex> update_user_role(user_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_role(%UserRole{} = user_role, attrs) do
    user_role
    |> UserRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a UserRole.

  ## Examples

      iex> delete_user_role(user_role)
      {:ok, %UserRole{}}

      iex> delete_user_role(user_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_role(%UserRole{} = user_role) do
    Repo.delete(user_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_role changes.

  ## Examples

      iex> change_user_role(user_role)
      %Ecto.Changeset{source: %UserRole{}}

  """
  def change_user_role(%UserRole{} = user_role) do
    UserRole.changeset(user_role, %{})
  end

  alias BoatNoodle.BN.VoidItems

  @doc """
  Returns the list of voiditems.

  ## Examples

      iex> list_voiditems()
      [%VoidItems{}, ...]

  """
  def list_voiditems do
    Repo.all(VoidItems)
  end

  @doc """
  Gets a single void_items.

  Raises `Ecto.NoResultsError` if the Void items does not exist.

  ## Examples

      iex> get_void_items!(123)
      %VoidItems{}

      iex> get_void_items!(456)
      ** (Ecto.NoResultsError)

  """
  def get_void_items!(id), do: Repo.get!(VoidItems, id)

  @doc """
  Creates a void_items.

  ## Examples

      iex> create_void_items(%{field: value})
      {:ok, %VoidItems{}}

      iex> create_void_items(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_void_items(attrs \\ %{}) do
    %VoidItems{}
    |> VoidItems.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a void_items.

  ## Examples

      iex> update_void_items(void_items, %{field: new_value})
      {:ok, %VoidItems{}}

      iex> update_void_items(void_items, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_void_items(%VoidItems{} = void_items, attrs) do
    void_items
    |> VoidItems.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a VoidItems.

  ## Examples

      iex> delete_void_items(void_items)
      {:ok, %VoidItems{}}

      iex> delete_void_items(void_items)
      {:error, %Ecto.Changeset{}}

  """
  def delete_void_items(%VoidItems{} = void_items) do
    Repo.delete(void_items)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking void_items changes.

  ## Examples

      iex> change_void_items(void_items)
      %Ecto.Changeset{source: %VoidItems{}}

  """
  def change_void_items(%VoidItems{} = void_items) do
    VoidItems.changeset(void_items, %{})
  end

  alias BoatNoodle.BN.SalesPayment

  @doc """
  Returns the list of salespayment.

  ## Examples

      iex> list_salespayment()
      [%SalesPayment{}, ...]

  """
  def list_salespayment do
    Repo.all(SalesPayment)
  end

  @doc """
  Gets a single sales_payment.

  Raises `Ecto.NoResultsError` if the Sales payment does not exist.

  ## Examples

      iex> get_sales_payment!(123)
      %SalesPayment{}

      iex> get_sales_payment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sales_payment!(id), do: Repo.get!(SalesPayment, id)

  @doc """
  Creates a sales_payment.

  ## Examples

      iex> create_sales_payment(%{field: value})
      {:ok, %SalesPayment{}}

      iex> create_sales_payment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sales_payment(attrs \\ %{}) do
    %SalesPayment{}
    |> SalesPayment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sales_payment.

  ## Examples

      iex> update_sales_payment(sales_payment, %{field: new_value})
      {:ok, %SalesPayment{}}

      iex> update_sales_payment(sales_payment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sales_payment(%SalesPayment{} = sales_payment, attrs) do
    sales_payment
    |> SalesPayment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SalesPayment.

  ## Examples

      iex> delete_sales_payment(sales_payment)
      {:ok, %SalesPayment{}}

      iex> delete_sales_payment(sales_payment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sales_payment(%SalesPayment{} = sales_payment) do
    Repo.delete(sales_payment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sales_payment changes.

  ## Examples

      iex> change_sales_payment(sales_payment)
      %Ecto.Changeset{source: %SalesPayment{}}

  """
  def change_sales_payment(%SalesPayment{} = sales_payment) do
    SalesPayment.changeset(sales_payment, %{})
  end

  alias BoatNoodle.BN.ItemSubcat

  @doc """
  Returns the list of item_subcat.

  ## Examples

      iex> list_item_subcat()
      [%ItemSubcat{}, ...]

  """
  def list_item_subcat do
    Repo.all(ItemSubcat)
  end

  @doc """
  Gets a single item_subcat.

  Raises `Ecto.NoResultsError` if the Item subcat does not exist.

  ## Examples

      iex> get_item_subcat!(123)
      %ItemSubcat{}

      iex> get_item_subcat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item_subcat!(id), do: Repo.get!(ItemSubcat, id)

  @doc """
  Creates a item_subcat.

  ## Examples

      iex> create_item_subcat(%{field: value})
      {:ok, %ItemSubcat{}}

      iex> create_item_subcat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item_subcat(attrs \\ %{}) do
    %ItemSubcat{}
    |> ItemSubcat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item_subcat.

  ## Examples

      iex> update_item_subcat(item_subcat, %{field: new_value})
      {:ok, %ItemSubcat{}}

      iex> update_item_subcat(item_subcat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item_subcat(%ItemSubcat{} = item_subcat, attrs) do
    item_subcat
    |> ItemSubcat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ItemSubcat.

  ## Examples

      iex> delete_item_subcat(item_subcat)
      {:ok, %ItemSubcat{}}

      iex> delete_item_subcat(item_subcat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item_subcat(%ItemSubcat{} = item_subcat) do
    Repo.delete(item_subcat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item_subcat changes.

  ## Examples

      iex> change_item_subcat(item_subcat)
      %Ecto.Changeset{source: %ItemSubcat{}}

  """
  def change_item_subcat(%ItemSubcat{} = item_subcat) do
    ItemSubcat.changeset(item_subcat, %{})
  end

  alias BoatNoodle.BN.ItemCat

  @doc """
  Returns the list of itemcat.

  ## Examples

      iex> list_itemcat()
      [%ItemCat{}, ...]

  """
  def list_itemcat do
    Repo.all(ItemCat)
  end

  @doc """
  Gets a single item_cat.

  Raises `Ecto.NoResultsError` if the Item cat does not exist.

  ## Examples

      iex> get_item_cat!(123)
      %ItemCat{}

      iex> get_item_cat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item_cat!(id), do: Repo.get!(ItemCat, id)

  @doc """
  Creates a item_cat.

  ## Examples

      iex> create_item_cat(%{field: value})
      {:ok, %ItemCat{}}

      iex> create_item_cat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item_cat(attrs \\ %{}) do
    %ItemCat{}
    |> ItemCat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item_cat.

  ## Examples

      iex> update_item_cat(item_cat, %{field: new_value})
      {:ok, %ItemCat{}}

      iex> update_item_cat(item_cat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item_cat(%ItemCat{} = item_cat, attrs) do
    item_cat
    |> ItemCat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ItemCat.

  ## Examples

      iex> delete_item_cat(item_cat)
      {:ok, %ItemCat{}}

      iex> delete_item_cat(item_cat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item_cat(%ItemCat{} = item_cat) do
    Repo.delete(item_cat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item_cat changes.

  ## Examples

      iex> change_item_cat(item_cat)
      %Ecto.Changeset{source: %ItemCat{}}

  """
  def change_item_cat(%ItemCat{} = item_cat) do
    ItemCat.changeset(item_cat, %{})
  end

  alias BoatNoodle.BN.Discount

  @doc """
  Returns the list of discount.

  ## Examples

      iex> list_discount()
      [%Discount{}, ...]

  """
  def list_discount do
    Repo.all(Discount)
  end

  @doc """
  Gets a single discount.

  Raises `Ecto.NoResultsError` if the Discount does not exist.

  ## Examples

      iex> get_discount!(123)
      %Discount{}

      iex> get_discount!(456)
      ** (Ecto.NoResultsError)

  """
  def get_discount!(id), do: Repo.get!(Discount, id)

  @doc """
  Creates a discount.

  ## Examples

      iex> create_discount(%{field: value})
      {:ok, %Discount{}}

      iex> create_discount(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_discount(attrs \\ %{}) do
    %Discount{}
    |> Discount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a discount.

  ## Examples

      iex> update_discount(discount, %{field: new_value})
      {:ok, %Discount{}}

      iex> update_discount(discount, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_discount(%Discount{} = discount, attrs) do
    discount
    |> Discount.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Discount.

  ## Examples

      iex> delete_discount(discount)
      {:ok, %Discount{}}

      iex> delete_discount(discount)
      {:error, %Ecto.Changeset{}}

  """
  def delete_discount(%Discount{} = discount) do
    Repo.delete(discount)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking discount changes.

  ## Examples

      iex> change_discount(discount)
      %Ecto.Changeset{source: %Discount{}}

  """
  def change_discount(%Discount{} = discount) do
    Discount.changeset(discount, %{})
  end

  def get_domain(conn) do
    conn.private.plug_session["brand"]
  end

  def get_brand_id(conn) do
    conn.private.plug_session["brand_id"]
  end

  def brand_id(conn) do
    brand = Repo.get_by(BoatNoodle.BN.Brand, domain_name: conn.params["brand"])

    if brand != nil do
      brand.id
    else
      1
    end
  end

  alias BoatNoodle.BN.Brand

  @doc """
  Returns the list of brand.

  ## Examples

      iex> list_brand()
      [%Brand{}, ...]

  """
  def list_brand do
    Repo.all(Brand)
  end

  @doc """
  Gets a single brand.

  Raises `Ecto.NoResultsError` if the Brand does not exist.

  ## Examples

      iex> get_brand!(123)
      %Brand{}

      iex> get_brand!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brand!(id), do: Repo.get!(Brand, id)

  @doc """
  Creates a brand.

  ## Examples

      iex> create_brand(%{field: value})
      {:ok, %Brand{}}

      iex> create_brand(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brand(attrs \\ %{}) do
    %Brand{}
    |> Brand.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brand.

  ## Examples

      iex> update_brand(brand, %{field: new_value})
      {:ok, %Brand{}}

      iex> update_brand(brand, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brand(%Brand{} = brand, attrs) do
    brand
    |> Brand.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Brand.

  ## Examples

      iex> delete_brand(brand)
      {:ok, %Brand{}}

      iex> delete_brand(brand)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brand(%Brand{} = brand) do
    Repo.delete(brand)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brand changes.

  ## Examples

      iex> change_brand(brand)
      %Ecto.Changeset{source: %Brand{}}

  """
  def change_brand(%Brand{} = brand) do
    Brand.changeset(brand, %{})
  end
end
