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
end
