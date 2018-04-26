defmodule BoatNoodle.BNTest do
  use BoatNoodle.DataCase

  alias BoatNoodle.BN

  describe "menu_item" do
    alias BoatNoodle.BN.MenuItem

    @valid_attrs %{active: true, category: "some category", enable_discount: true, is_included_in_minimum_spend: true, item: "some item", item_code: "some item_code", item_description: "some item_description", item_image: "some item_image", item_name: "some item_name", menu_catalogs: "some menu_catalogs", part_code: "some part_code", price: "120.5", price_code: "some price_code", tags: "some tags"}
    @update_attrs %{active: false, category: "some updated category", enable_discount: false, is_included_in_minimum_spend: false, item: "some updated item", item_code: "some updated item_code", item_description: "some updated item_description", item_image: "some updated item_image", item_name: "some updated item_name", menu_catalogs: "some updated menu_catalogs", part_code: "some updated part_code", price: "456.7", price_code: "some updated price_code", tags: "some updated tags"}
    @invalid_attrs %{active: nil, category: nil, enable_discount: nil, is_included_in_minimum_spend: nil, item: nil, item_code: nil, item_description: nil, item_image: nil, item_name: nil, menu_catalogs: nil, part_code: nil, price: nil, price_code: nil, tags: nil}

    def menu_item_fixture(attrs \\ %{}) do
      {:ok, menu_item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_menu_item()

      menu_item
    end

    test "list_menu_item/0 returns all menu_item" do
      menu_item = menu_item_fixture()
      assert BN.list_menu_item() == [menu_item]
    end

    test "get_menu_item!/1 returns the menu_item with given id" do
      menu_item = menu_item_fixture()
      assert BN.get_menu_item!(menu_item.id) == menu_item
    end

    test "create_menu_item/1 with valid data creates a menu_item" do
      assert {:ok, %MenuItem{} = menu_item} = BN.create_menu_item(@valid_attrs)
      assert menu_item.active == true
      assert menu_item.category == "some category"
      assert menu_item.enable_discount == true
      assert menu_item.is_included_in_minimum_spend == true
      assert menu_item.item == "some item"
      assert menu_item.item_code == "some item_code"
      assert menu_item.item_description == "some item_description"
      assert menu_item.item_image == "some item_image"
      assert menu_item.item_name == "some item_name"
      assert menu_item.menu_catalogs == "some menu_catalogs"
      assert menu_item.part_code == "some part_code"
      assert menu_item.price == Decimal.new("120.5")
      assert menu_item.price_code == "some price_code"
      assert menu_item.tags == "some tags"
    end

    test "create_menu_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_menu_item(@invalid_attrs)
    end

    test "update_menu_item/2 with valid data updates the menu_item" do
      menu_item = menu_item_fixture()
      assert {:ok, menu_item} = BN.update_menu_item(menu_item, @update_attrs)
      assert %MenuItem{} = menu_item
      assert menu_item.active == false
      assert menu_item.category == "some updated category"
      assert menu_item.enable_discount == false
      assert menu_item.is_included_in_minimum_spend == false
      assert menu_item.item == "some updated item"
      assert menu_item.item_code == "some updated item_code"
      assert menu_item.item_description == "some updated item_description"
      assert menu_item.item_image == "some updated item_image"
      assert menu_item.item_name == "some updated item_name"
      assert menu_item.menu_catalogs == "some updated menu_catalogs"
      assert menu_item.part_code == "some updated part_code"
      assert menu_item.price == Decimal.new("456.7")
      assert menu_item.price_code == "some updated price_code"
      assert menu_item.tags == "some updated tags"
    end

    test "update_menu_item/2 with invalid data returns error changeset" do
      menu_item = menu_item_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_menu_item(menu_item, @invalid_attrs)
      assert menu_item == BN.get_menu_item!(menu_item.id)
    end

    test "delete_menu_item/1 deletes the menu_item" do
      menu_item = menu_item_fixture()
      assert {:ok, %MenuItem{}} = BN.delete_menu_item(menu_item)
      assert_raise Ecto.NoResultsError, fn -> BN.get_menu_item!(menu_item.id) end
    end

    test "change_menu_item/1 returns a menu_item changeset" do
      menu_item = menu_item_fixture()
      assert %Ecto.Changeset{} = BN.change_menu_item(menu_item)
    end
  end

  describe "category" do
    alias BoatNoodle.BN.Category

    @valid_attrs %{category_description: "some category_description", category_name: "some category_name", is_default_menu: true}
    @update_attrs %{category_description: "some updated category_description", category_name: "some updated category_name", is_default_menu: false}
    @invalid_attrs %{category_description: nil, category_name: nil, is_default_menu: nil}

    def category_fixture(attrs \\ %{}) do
      {:ok, category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_category()

      category
    end

    test "list_category/0 returns all category" do
      category = category_fixture()
      assert BN.list_category() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert BN.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = BN.create_category(@valid_attrs)
      assert category.category_description == "some category_description"
      assert category.category_name == "some category_name"
      assert category.is_default_menu == true
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, category} = BN.update_category(category, @update_attrs)
      assert %Category{} = category
      assert category.category_description == "some updated category_description"
      assert category.category_name == "some updated category_name"
      assert category.is_default_menu == false
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_category(category, @invalid_attrs)
      assert category == BN.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = BN.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> BN.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = BN.change_category(category)
    end
  end

  describe "remark" do
    alias BoatNoodle.BN.Remark

    @valid_attrs %{remark_description: "some remark_description", target_category: "some target_category", target_item: "some target_item"}
    @update_attrs %{remark_description: "some updated remark_description", target_category: "some updated target_category", target_item: "some updated target_item"}
    @invalid_attrs %{remark_description: nil, target_category: nil, target_item: nil}

    def remark_fixture(attrs \\ %{}) do
      {:ok, remark} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_remark()

      remark
    end

    test "list_remark/0 returns all remark" do
      remark = remark_fixture()
      assert BN.list_remark() == [remark]
    end

    test "get_remark!/1 returns the remark with given id" do
      remark = remark_fixture()
      assert BN.get_remark!(remark.id) == remark
    end

    test "create_remark/1 with valid data creates a remark" do
      assert {:ok, %Remark{} = remark} = BN.create_remark(@valid_attrs)
      assert remark.remark_description == "some remark_description"
      assert remark.target_category == "some target_category"
      assert remark.target_item == "some target_item"
    end

    test "create_remark/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_remark(@invalid_attrs)
    end

    test "update_remark/2 with valid data updates the remark" do
      remark = remark_fixture()
      assert {:ok, remark} = BN.update_remark(remark, @update_attrs)
      assert %Remark{} = remark
      assert remark.remark_description == "some updated remark_description"
      assert remark.target_category == "some updated target_category"
      assert remark.target_item == "some updated target_item"
    end

    test "update_remark/2 with invalid data returns error changeset" do
      remark = remark_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_remark(remark, @invalid_attrs)
      assert remark == BN.get_remark!(remark.id)
    end

    test "delete_remark/1 deletes the remark" do
      remark = remark_fixture()
      assert {:ok, %Remark{}} = BN.delete_remark(remark)
      assert_raise Ecto.NoResultsError, fn -> BN.get_remark!(remark.id) end
    end

    test "change_remark/1 returns a remark changeset" do
      remark = remark_fixture()
      assert %Ecto.Changeset{} = BN.change_remark(remark)
    end
  end

  describe "menu_catalog" do
    alias BoatNoodle.BN.MenuCatalog

    @valid_attrs %{catalog_name: "some catalog_name"}
    @update_attrs %{catalog_name: "some updated catalog_name"}
    @invalid_attrs %{catalog_name: nil}

    def menu_catalog_fixture(attrs \\ %{}) do
      {:ok, menu_catalog} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_menu_catalog()

      menu_catalog
    end

    test "list_menu_catalog/0 returns all menu_catalog" do
      menu_catalog = menu_catalog_fixture()
      assert BN.list_menu_catalog() == [menu_catalog]
    end

    test "get_menu_catalog!/1 returns the menu_catalog with given id" do
      menu_catalog = menu_catalog_fixture()
      assert BN.get_menu_catalog!(menu_catalog.id) == menu_catalog
    end

    test "create_menu_catalog/1 with valid data creates a menu_catalog" do
      assert {:ok, %MenuCatalog{} = menu_catalog} = BN.create_menu_catalog(@valid_attrs)
      assert menu_catalog.catalog_name == "some catalog_name"
    end

    test "create_menu_catalog/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_menu_catalog(@invalid_attrs)
    end

    test "update_menu_catalog/2 with valid data updates the menu_catalog" do
      menu_catalog = menu_catalog_fixture()
      assert {:ok, menu_catalog} = BN.update_menu_catalog(menu_catalog, @update_attrs)
      assert %MenuCatalog{} = menu_catalog
      assert menu_catalog.catalog_name == "some updated catalog_name"
    end

    test "update_menu_catalog/2 with invalid data returns error changeset" do
      menu_catalog = menu_catalog_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_menu_catalog(menu_catalog, @invalid_attrs)
      assert menu_catalog == BN.get_menu_catalog!(menu_catalog.id)
    end

    test "delete_menu_catalog/1 deletes the menu_catalog" do
      menu_catalog = menu_catalog_fixture()
      assert {:ok, %MenuCatalog{}} = BN.delete_menu_catalog(menu_catalog)
      assert_raise Ecto.NoResultsError, fn -> BN.get_menu_catalog!(menu_catalog.id) end
    end

    test "change_menu_catalog/1 returns a menu_catalog changeset" do
      menu_catalog = menu_catalog_fixture()
      assert %Ecto.Changeset{} = BN.change_menu_catalog(menu_catalog)
    end
  end

  describe "menu_catalog_master" do
    alias BoatNoodle.BN.MenuCatalogMaster

    @valid_attrs %{catalog_name: "some catalog_name"}
    @update_attrs %{catalog_name: "some updated catalog_name"}
    @invalid_attrs %{catalog_name: nil}

    def menu_catalog_master_fixture(attrs \\ %{}) do
      {:ok, menu_catalog_master} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_menu_catalog_master()

      menu_catalog_master
    end

    test "list_menu_catalog_master/0 returns all menu_catalog_master" do
      menu_catalog_master = menu_catalog_master_fixture()
      assert BN.list_menu_catalog_master() == [menu_catalog_master]
    end

    test "get_menu_catalog_master!/1 returns the menu_catalog_master with given id" do
      menu_catalog_master = menu_catalog_master_fixture()
      assert BN.get_menu_catalog_master!(menu_catalog_master.id) == menu_catalog_master
    end

    test "create_menu_catalog_master/1 with valid data creates a menu_catalog_master" do
      assert {:ok, %MenuCatalogMaster{} = menu_catalog_master} = BN.create_menu_catalog_master(@valid_attrs)
      assert menu_catalog_master.catalog_name == "some catalog_name"
    end

    test "create_menu_catalog_master/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_menu_catalog_master(@invalid_attrs)
    end

    test "update_menu_catalog_master/2 with valid data updates the menu_catalog_master" do
      menu_catalog_master = menu_catalog_master_fixture()
      assert {:ok, menu_catalog_master} = BN.update_menu_catalog_master(menu_catalog_master, @update_attrs)
      assert %MenuCatalogMaster{} = menu_catalog_master
      assert menu_catalog_master.catalog_name == "some updated catalog_name"
    end

    test "update_menu_catalog_master/2 with invalid data returns error changeset" do
      menu_catalog_master = menu_catalog_master_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_menu_catalog_master(menu_catalog_master, @invalid_attrs)
      assert menu_catalog_master == BN.get_menu_catalog_master!(menu_catalog_master.id)
    end

    test "delete_menu_catalog_master/1 deletes the menu_catalog_master" do
      menu_catalog_master = menu_catalog_master_fixture()
      assert {:ok, %MenuCatalogMaster{}} = BN.delete_menu_catalog_master(menu_catalog_master)
      assert_raise Ecto.NoResultsError, fn -> BN.get_menu_catalog_master!(menu_catalog_master.id) end
    end

    test "change_menu_catalog_master/1 returns a menu_catalog_master changeset" do
      menu_catalog_master = menu_catalog_master_fixture()
      assert %Ecto.Changeset{} = BN.change_menu_catalog_master(menu_catalog_master)
    end
  end

  describe "menu_catalog" do
    alias BoatNoodle.BN.MenuCatalog

    @valid_attrs %{active: true, category_item: "some category_item", item_code: "some item_code", item_name: "some item_name", menu_catalog_master_id: 42, price: "120.5", price_code: "some price_code"}
    @update_attrs %{active: false, category_item: "some updated category_item", item_code: "some updated item_code", item_name: "some updated item_name", menu_catalog_master_id: 43, price: "456.7", price_code: "some updated price_code"}
    @invalid_attrs %{active: nil, category_item: nil, item_code: nil, item_name: nil, menu_catalog_master_id: nil, price: nil, price_code: nil}

    def menu_catalog_fixture(attrs \\ %{}) do
      {:ok, menu_catalog} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_menu_catalog()

      menu_catalog
    end

    test "list_menu_catalog/0 returns all menu_catalog" do
      menu_catalog = menu_catalog_fixture()
      assert BN.list_menu_catalog() == [menu_catalog]
    end

    test "get_menu_catalog!/1 returns the menu_catalog with given id" do
      menu_catalog = menu_catalog_fixture()
      assert BN.get_menu_catalog!(menu_catalog.id) == menu_catalog
    end

    test "create_menu_catalog/1 with valid data creates a menu_catalog" do
      assert {:ok, %MenuCatalog{} = menu_catalog} = BN.create_menu_catalog(@valid_attrs)
      assert menu_catalog.active == true
      assert menu_catalog.category_item == "some category_item"
      assert menu_catalog.item_code == "some item_code"
      assert menu_catalog.item_name == "some item_name"
      assert menu_catalog.menu_catalog_master_id == 42
      assert menu_catalog.price == Decimal.new("120.5")
      assert menu_catalog.price_code == "some price_code"
    end

    test "create_menu_catalog/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_menu_catalog(@invalid_attrs)
    end

    test "update_menu_catalog/2 with valid data updates the menu_catalog" do
      menu_catalog = menu_catalog_fixture()
      assert {:ok, menu_catalog} = BN.update_menu_catalog(menu_catalog, @update_attrs)
      assert %MenuCatalog{} = menu_catalog
      assert menu_catalog.active == false
      assert menu_catalog.category_item == "some updated category_item"
      assert menu_catalog.item_code == "some updated item_code"
      assert menu_catalog.item_name == "some updated item_name"
      assert menu_catalog.menu_catalog_master_id == 43
      assert menu_catalog.price == Decimal.new("456.7")
      assert menu_catalog.price_code == "some updated price_code"
    end

    test "update_menu_catalog/2 with invalid data returns error changeset" do
      menu_catalog = menu_catalog_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_menu_catalog(menu_catalog, @invalid_attrs)
      assert menu_catalog == BN.get_menu_catalog!(menu_catalog.id)
    end

    test "delete_menu_catalog/1 deletes the menu_catalog" do
      menu_catalog = menu_catalog_fixture()
      assert {:ok, %MenuCatalog{}} = BN.delete_menu_catalog(menu_catalog)
      assert_raise Ecto.NoResultsError, fn -> BN.get_menu_catalog!(menu_catalog.id) end
    end

    test "change_menu_catalog/1 returns a menu_catalog changeset" do
      menu_catalog = menu_catalog_fixture()
      assert %Ecto.Changeset{} = BN.change_menu_catalog(menu_catalog)
    end
  end

  describe "discount_category" do
    alias BoatNoodle.BN.DiscountCategory

    @valid_attrs %{amount_percentage: 42, description: "some description", discount_catalog: "some discount_catalog", discount_type: "some discount_type", name: "some name", status: true}
    @update_attrs %{amount_percentage: 43, description: "some updated description", discount_catalog: "some updated discount_catalog", discount_type: "some updated discount_type", name: "some updated name", status: false}
    @invalid_attrs %{amount_percentage: nil, description: nil, discount_catalog: nil, discount_type: nil, name: nil, status: nil}

    def discount_category_fixture(attrs \\ %{}) do
      {:ok, discount_category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_discount_category()

      discount_category
    end

    test "list_discount_category/0 returns all discount_category" do
      discount_category = discount_category_fixture()
      assert BN.list_discount_category() == [discount_category]
    end

    test "get_discount_category!/1 returns the discount_category with given id" do
      discount_category = discount_category_fixture()
      assert BN.get_discount_category!(discount_category.id) == discount_category
    end

    test "create_discount_category/1 with valid data creates a discount_category" do
      assert {:ok, %DiscountCategory{} = discount_category} = BN.create_discount_category(@valid_attrs)
      assert discount_category.amount_percentage == 42
      assert discount_category.description == "some description"
      assert discount_category.discount_catalog == "some discount_catalog"
      assert discount_category.discount_type == "some discount_type"
      assert discount_category.name == "some name"
      assert discount_category.status == true
    end

    test "create_discount_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_discount_category(@invalid_attrs)
    end

    test "update_discount_category/2 with valid data updates the discount_category" do
      discount_category = discount_category_fixture()
      assert {:ok, discount_category} = BN.update_discount_category(discount_category, @update_attrs)
      assert %DiscountCategory{} = discount_category
      assert discount_category.amount_percentage == 43
      assert discount_category.description == "some updated description"
      assert discount_category.discount_catalog == "some updated discount_catalog"
      assert discount_category.discount_type == "some updated discount_type"
      assert discount_category.name == "some updated name"
      assert discount_category.status == false
    end

    test "update_discount_category/2 with invalid data returns error changeset" do
      discount_category = discount_category_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_discount_category(discount_category, @invalid_attrs)
      assert discount_category == BN.get_discount_category!(discount_category.id)
    end

    test "delete_discount_category/1 deletes the discount_category" do
      discount_category = discount_category_fixture()
      assert {:ok, %DiscountCategory{}} = BN.delete_discount_category(discount_category)
      assert_raise Ecto.NoResultsError, fn -> BN.get_discount_category!(discount_category.id) end
    end

    test "change_discount_category/1 returns a discount_category changeset" do
      discount_category = discount_category_fixture()
      assert %Ecto.Changeset{} = BN.change_discount_category(discount_category)
    end
  end

  describe "discount_item" do
    alias BoatNoodle.BN.DiscountItem

    @valid_attrs %{description: "some description", discount_catalog: "some discount_catalog", discount_category: "some discount_category", discount_name: "some discount_name", discount_percentage: "some discount_percentage", discount_type: "some discount_type", minimum_spend: 42, status: true}
    @update_attrs %{description: "some updated description", discount_catalog: "some updated discount_catalog", discount_category: "some updated discount_category", discount_name: "some updated discount_name", discount_percentage: "some updated discount_percentage", discount_type: "some updated discount_type", minimum_spend: 43, status: false}
    @invalid_attrs %{description: nil, discount_catalog: nil, discount_category: nil, discount_name: nil, discount_percentage: nil, discount_type: nil, minimum_spend: nil, status: nil}

    def discount_item_fixture(attrs \\ %{}) do
      {:ok, discount_item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_discount_item()

      discount_item
    end

    test "list_discount_item/0 returns all discount_item" do
      discount_item = discount_item_fixture()
      assert BN.list_discount_item() == [discount_item]
    end

    test "get_discount_item!/1 returns the discount_item with given id" do
      discount_item = discount_item_fixture()
      assert BN.get_discount_item!(discount_item.id) == discount_item
    end

    test "create_discount_item/1 with valid data creates a discount_item" do
      assert {:ok, %DiscountItem{} = discount_item} = BN.create_discount_item(@valid_attrs)
      assert discount_item.description == "some description"
      assert discount_item.discount_catalog == "some discount_catalog"
      assert discount_item.discount_category == "some discount_category"
      assert discount_item.discount_name == "some discount_name"
      assert discount_item.discount_percentage == "some discount_percentage"
      assert discount_item.discount_type == "some discount_type"
      assert discount_item.minimum_spend == 42
      assert discount_item.status == true
    end

    test "create_discount_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_discount_item(@invalid_attrs)
    end

    test "update_discount_item/2 with valid data updates the discount_item" do
      discount_item = discount_item_fixture()
      assert {:ok, discount_item} = BN.update_discount_item(discount_item, @update_attrs)
      assert %DiscountItem{} = discount_item
      assert discount_item.description == "some updated description"
      assert discount_item.discount_catalog == "some updated discount_catalog"
      assert discount_item.discount_category == "some updated discount_category"
      assert discount_item.discount_name == "some updated discount_name"
      assert discount_item.discount_percentage == "some updated discount_percentage"
      assert discount_item.discount_type == "some updated discount_type"
      assert discount_item.minimum_spend == 43
      assert discount_item.status == false
    end

    test "update_discount_item/2 with invalid data returns error changeset" do
      discount_item = discount_item_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_discount_item(discount_item, @invalid_attrs)
      assert discount_item == BN.get_discount_item!(discount_item.id)
    end

    test "delete_discount_item/1 deletes the discount_item" do
      discount_item = discount_item_fixture()
      assert {:ok, %DiscountItem{}} = BN.delete_discount_item(discount_item)
      assert_raise Ecto.NoResultsError, fn -> BN.get_discount_item!(discount_item.id) end
    end

    test "change_discount_item/1 returns a discount_item changeset" do
      discount_item = discount_item_fixture()
      assert %Ecto.Changeset{} = BN.change_discount_item(discount_item)
    end
  end

  describe "discount_catalog_master" do
    alias BoatNoodle.BN.DiscountCatalogMaster

    @valid_attrs %{catalog_name: "some catalog_name"}
    @update_attrs %{catalog_name: "some updated catalog_name"}
    @invalid_attrs %{catalog_name: nil}

    def discount_catalog_master_fixture(attrs \\ %{}) do
      {:ok, discount_catalog_master} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_discount_catalog_master()

      discount_catalog_master
    end

    test "list_discount_catalog_master/0 returns all discount_catalog_master" do
      discount_catalog_master = discount_catalog_master_fixture()
      assert BN.list_discount_catalog_master() == [discount_catalog_master]
    end

    test "get_discount_catalog_master!/1 returns the discount_catalog_master with given id" do
      discount_catalog_master = discount_catalog_master_fixture()
      assert BN.get_discount_catalog_master!(discount_catalog_master.id) == discount_catalog_master
    end

    test "create_discount_catalog_master/1 with valid data creates a discount_catalog_master" do
      assert {:ok, %DiscountCatalogMaster{} = discount_catalog_master} = BN.create_discount_catalog_master(@valid_attrs)
      assert discount_catalog_master.catalog_name == "some catalog_name"
    end

    test "create_discount_catalog_master/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_discount_catalog_master(@invalid_attrs)
    end

    test "update_discount_catalog_master/2 with valid data updates the discount_catalog_master" do
      discount_catalog_master = discount_catalog_master_fixture()
      assert {:ok, discount_catalog_master} = BN.update_discount_catalog_master(discount_catalog_master, @update_attrs)
      assert %DiscountCatalogMaster{} = discount_catalog_master
      assert discount_catalog_master.catalog_name == "some updated catalog_name"
    end

    test "update_discount_catalog_master/2 with invalid data returns error changeset" do
      discount_catalog_master = discount_catalog_master_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_discount_catalog_master(discount_catalog_master, @invalid_attrs)
      assert discount_catalog_master == BN.get_discount_catalog_master!(discount_catalog_master.id)
    end

    test "delete_discount_catalog_master/1 deletes the discount_catalog_master" do
      discount_catalog_master = discount_catalog_master_fixture()
      assert {:ok, %DiscountCatalogMaster{}} = BN.delete_discount_catalog_master(discount_catalog_master)
      assert_raise Ecto.NoResultsError, fn -> BN.get_discount_catalog_master!(discount_catalog_master.id) end
    end

    test "change_discount_catalog_master/1 returns a discount_catalog_master changeset" do
      discount_catalog_master = discount_catalog_master_fixture()
      assert %Ecto.Changeset{} = BN.change_discount_catalog_master(discount_catalog_master)
    end
  end

  describe "discount_catalog" do
    alias BoatNoodle.BN.DiscountCatalog

    @valid_attrs %{discount_catalog_master_id: 42, discount_categories: "some discount_categories", discount_category: "some discount_category", discount_name: "some discount_name", name: "some name"}
    @update_attrs %{discount_catalog_master_id: 43, discount_categories: "some updated discount_categories", discount_category: "some updated discount_category", discount_name: "some updated discount_name", name: "some updated name"}
    @invalid_attrs %{discount_catalog_master_id: nil, discount_categories: nil, discount_category: nil, discount_name: nil, name: nil}

    def discount_catalog_fixture(attrs \\ %{}) do
      {:ok, discount_catalog} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_discount_catalog()

      discount_catalog
    end

    test "list_discount_catalog/0 returns all discount_catalog" do
      discount_catalog = discount_catalog_fixture()
      assert BN.list_discount_catalog() == [discount_catalog]
    end

    test "get_discount_catalog!/1 returns the discount_catalog with given id" do
      discount_catalog = discount_catalog_fixture()
      assert BN.get_discount_catalog!(discount_catalog.id) == discount_catalog
    end

    test "create_discount_catalog/1 with valid data creates a discount_catalog" do
      assert {:ok, %DiscountCatalog{} = discount_catalog} = BN.create_discount_catalog(@valid_attrs)
      assert discount_catalog.discount_catalog_master_id == 42
      assert discount_catalog.discount_categories == "some discount_categories"
      assert discount_catalog.discount_category == "some discount_category"
      assert discount_catalog.discount_name == "some discount_name"
      assert discount_catalog.name == "some name"
    end

    test "create_discount_catalog/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_discount_catalog(@invalid_attrs)
    end

    test "update_discount_catalog/2 with valid data updates the discount_catalog" do
      discount_catalog = discount_catalog_fixture()
      assert {:ok, discount_catalog} = BN.update_discount_catalog(discount_catalog, @update_attrs)
      assert %DiscountCatalog{} = discount_catalog
      assert discount_catalog.discount_catalog_master_id == 43
      assert discount_catalog.discount_categories == "some updated discount_categories"
      assert discount_catalog.discount_category == "some updated discount_category"
      assert discount_catalog.discount_name == "some updated discount_name"
      assert discount_catalog.name == "some updated name"
    end

    test "update_discount_catalog/2 with invalid data returns error changeset" do
      discount_catalog = discount_catalog_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_discount_catalog(discount_catalog, @invalid_attrs)
      assert discount_catalog == BN.get_discount_catalog!(discount_catalog.id)
    end

    test "delete_discount_catalog/1 deletes the discount_catalog" do
      discount_catalog = discount_catalog_fixture()
      assert {:ok, %DiscountCatalog{}} = BN.delete_discount_catalog(discount_catalog)
      assert_raise Ecto.NoResultsError, fn -> BN.get_discount_catalog!(discount_catalog.id) end
    end

    test "change_discount_catalog/1 returns a discount_catalog changeset" do
      discount_catalog = discount_catalog_fixture()
      assert %Ecto.Changeset{} = BN.change_discount_catalog(discount_catalog)
    end
  end

  describe "tag_name" do
    alias BoatNoodle.BN.Tag

    @valid_attrs %{description: "some description", printer_name: "some printer_name"}
    @update_attrs %{description: "some updated description", printer_name: "some updated printer_name"}
    @invalid_attrs %{description: nil, printer_name: nil}

    def tag_fixture(attrs \\ %{}) do
      {:ok, tag} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_tag()

      tag
    end

    test "list_tag_name/0 returns all tag_name" do
      tag = tag_fixture()
      assert BN.list_tag_name() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert BN.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      assert {:ok, %Tag{} = tag} = BN.create_tag(@valid_attrs)
      assert tag.description == "some description"
      assert tag.printer_name == "some printer_name"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      assert {:ok, tag} = BN.update_tag(tag, @update_attrs)
      assert %Tag{} = tag
      assert tag.description == "some updated description"
      assert tag.printer_name == "some updated printer_name"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_tag(tag, @invalid_attrs)
      assert tag == BN.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = BN.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> BN.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = BN.change_tag(tag)
    end
  end

  describe "tag_catalog" do
    alias BoatNoodle.BN.TagCatalog

    @valid_attrs %{description: "some description", name: "some name", tag_category: "some tag_category", tag_items: "some tag_items"}
    @update_attrs %{description: "some updated description", name: "some updated name", tag_category: "some updated tag_category", tag_items: "some updated tag_items"}
    @invalid_attrs %{description: nil, name: nil, tag_category: nil, tag_items: nil}

    def tag_catalog_fixture(attrs \\ %{}) do
      {:ok, tag_catalog} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_tag_catalog()

      tag_catalog
    end

    test "list_tag_catalog/0 returns all tag_catalog" do
      tag_catalog = tag_catalog_fixture()
      assert BN.list_tag_catalog() == [tag_catalog]
    end

    test "get_tag_catalog!/1 returns the tag_catalog with given id" do
      tag_catalog = tag_catalog_fixture()
      assert BN.get_tag_catalog!(tag_catalog.id) == tag_catalog
    end

    test "create_tag_catalog/1 with valid data creates a tag_catalog" do
      assert {:ok, %TagCatalog{} = tag_catalog} = BN.create_tag_catalog(@valid_attrs)
      assert tag_catalog.description == "some description"
      assert tag_catalog.name == "some name"
      assert tag_catalog.tag_category == "some tag_category"
      assert tag_catalog.tag_items == "some tag_items"
    end

    test "create_tag_catalog/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_tag_catalog(@invalid_attrs)
    end

    test "update_tag_catalog/2 with valid data updates the tag_catalog" do
      tag_catalog = tag_catalog_fixture()
      assert {:ok, tag_catalog} = BN.update_tag_catalog(tag_catalog, @update_attrs)
      assert %TagCatalog{} = tag_catalog
      assert tag_catalog.description == "some updated description"
      assert tag_catalog.name == "some updated name"
      assert tag_catalog.tag_category == "some updated tag_category"
      assert tag_catalog.tag_items == "some updated tag_items"
    end

    test "update_tag_catalog/2 with invalid data returns error changeset" do
      tag_catalog = tag_catalog_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_tag_catalog(tag_catalog, @invalid_attrs)
      assert tag_catalog == BN.get_tag_catalog!(tag_catalog.id)
    end

    test "delete_tag_catalog/1 deletes the tag_catalog" do
      tag_catalog = tag_catalog_fixture()
      assert {:ok, %TagCatalog{}} = BN.delete_tag_catalog(tag_catalog)
      assert_raise Ecto.NoResultsError, fn -> BN.get_tag_catalog!(tag_catalog.id) end
    end

    test "change_tag_catalog/1 returns a tag_catalog changeset" do
      tag_catalog = tag_catalog_fixture()
      assert %Ecto.Changeset{} = BN.change_tag_catalog(tag_catalog)
    end
  end

  describe "tag_items" do
    alias BoatNoodle.BN.TagItems

    @valid_attrs %{item_name: "some item_name", printer: "some printer", tag_name: "some tag_name"}
    @update_attrs %{item_name: "some updated item_name", printer: "some updated printer", tag_name: "some updated tag_name"}
    @invalid_attrs %{item_name: nil, printer: nil, tag_name: nil}

    def tag_items_fixture(attrs \\ %{}) do
      {:ok, tag_items} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_tag_items()

      tag_items
    end

    test "list_tag_items/0 returns all tag_items" do
      tag_items = tag_items_fixture()
      assert BN.list_tag_items() == [tag_items]
    end

    test "get_tag_items!/1 returns the tag_items with given id" do
      tag_items = tag_items_fixture()
      assert BN.get_tag_items!(tag_items.id) == tag_items
    end

    test "create_tag_items/1 with valid data creates a tag_items" do
      assert {:ok, %TagItems{} = tag_items} = BN.create_tag_items(@valid_attrs)
      assert tag_items.item_name == "some item_name"
      assert tag_items.printer == "some printer"
      assert tag_items.tag_name == "some tag_name"
    end

    test "create_tag_items/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_tag_items(@invalid_attrs)
    end

    test "update_tag_items/2 with valid data updates the tag_items" do
      tag_items = tag_items_fixture()
      assert {:ok, tag_items} = BN.update_tag_items(tag_items, @update_attrs)
      assert %TagItems{} = tag_items
      assert tag_items.item_name == "some updated item_name"
      assert tag_items.printer == "some updated printer"
      assert tag_items.tag_name == "some updated tag_name"
    end

    test "update_tag_items/2 with invalid data returns error changeset" do
      tag_items = tag_items_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_tag_items(tag_items, @invalid_attrs)
      assert tag_items == BN.get_tag_items!(tag_items.id)
    end

    test "delete_tag_items/1 deletes the tag_items" do
      tag_items = tag_items_fixture()
      assert {:ok, %TagItems{}} = BN.delete_tag_items(tag_items)
      assert_raise Ecto.NoResultsError, fn -> BN.get_tag_items!(tag_items.id) end
    end

    test "change_tag_items/1 returns a tag_items changeset" do
      tag_items = tag_items_fixture()
      assert %Ecto.Changeset{} = BN.change_tag_items(tag_items)
    end
  end

  describe "staff" do
    alias BoatNoodle.BN.Staff

    @valid_attrs %{branch: "some branch", contact_number: "some contact_number", email: "some email", photo: "some photo", pin_number: 42, staff_name: "some staff_name", staff_role: "some staff_role"}
    @update_attrs %{branch: "some updated branch", contact_number: "some updated contact_number", email: "some updated email", photo: "some updated photo", pin_number: 43, staff_name: "some updated staff_name", staff_role: "some updated staff_role"}
    @invalid_attrs %{branch: nil, contact_number: nil, email: nil, photo: nil, pin_number: nil, staff_name: nil, staff_role: nil}

    def staff_fixture(attrs \\ %{}) do
      {:ok, staff} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_staff()

      staff
    end

    test "list_staff/0 returns all staff" do
      staff = staff_fixture()
      assert BN.list_staff() == [staff]
    end

    test "get_staff!/1 returns the staff with given id" do
      staff = staff_fixture()
      assert BN.get_staff!(staff.id) == staff
    end

    test "create_staff/1 with valid data creates a staff" do
      assert {:ok, %Staff{} = staff} = BN.create_staff(@valid_attrs)
      assert staff.branch == "some branch"
      assert staff.contact_number == "some contact_number"
      assert staff.email == "some email"
      assert staff.photo == "some photo"
      assert staff.pin_number == 42
      assert staff.staff_name == "some staff_name"
      assert staff.staff_role == "some staff_role"
    end

    test "create_staff/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_staff(@invalid_attrs)
    end

    test "update_staff/2 with valid data updates the staff" do
      staff = staff_fixture()
      assert {:ok, staff} = BN.update_staff(staff, @update_attrs)
      assert %Staff{} = staff
      assert staff.branch == "some updated branch"
      assert staff.contact_number == "some updated contact_number"
      assert staff.email == "some updated email"
      assert staff.photo == "some updated photo"
      assert staff.pin_number == 43
      assert staff.staff_name == "some updated staff_name"
      assert staff.staff_role == "some updated staff_role"
    end

    test "update_staff/2 with invalid data returns error changeset" do
      staff = staff_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_staff(staff, @invalid_attrs)
      assert staff == BN.get_staff!(staff.id)
    end

    test "delete_staff/1 deletes the staff" do
      staff = staff_fixture()
      assert {:ok, %Staff{}} = BN.delete_staff(staff)
      assert_raise Ecto.NoResultsError, fn -> BN.get_staff!(staff.id) end
    end

    test "change_staff/1 returns a staff changeset" do
      staff = staff_fixture()
      assert %Ecto.Changeset{} = BN.change_staff(staff)
    end
  end

  describe "user" do
    alias BoatNoodle.BN.User

    @valid_attrs %{branch_access: "some branch_access", email: "some email", password: "some password", user_role: "some user_role", username: "some username"}
    @update_attrs %{branch_access: "some updated branch_access", email: "some updated email", password: "some updated password", user_role: "some updated user_role", username: "some updated username"}
    @invalid_attrs %{branch_access: nil, email: nil, password: nil, user_role: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_user()

      user
    end

    test "list_user/0 returns all user" do
      user = user_fixture()
      assert BN.list_user() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert BN.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = BN.create_user(@valid_attrs)
      assert user.branch_access == "some branch_access"
      assert user.email == "some email"
      assert user.password == "some password"
      assert user.user_role == "some user_role"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = BN.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.branch_access == "some updated branch_access"
      assert user.email == "some updated email"
      assert user.password == "some updated password"
      assert user.user_role == "some updated user_role"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_user(user, @invalid_attrs)
      assert user == BN.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = BN.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> BN.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = BN.change_user(user)
    end
  end

  describe "organization" do
    alias BoatNoodle.BN.Organization

    @valid_attrs %{address: "some address", company_registration_number: "some company_registration_number", contact_number: "some contact_number", country: "some country", name: "some name", tax_registration_number: "some tax_registration_number"}
    @update_attrs %{address: "some updated address", company_registration_number: "some updated company_registration_number", contact_number: "some updated contact_number", country: "some updated country", name: "some updated name", tax_registration_number: "some updated tax_registration_number"}
    @invalid_attrs %{address: nil, company_registration_number: nil, contact_number: nil, country: nil, name: nil, tax_registration_number: nil}

    def organization_fixture(attrs \\ %{}) do
      {:ok, organization} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_organization()

      organization
    end

    test "list_organization/0 returns all organization" do
      organization = organization_fixture()
      assert BN.list_organization() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert BN.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      assert {:ok, %Organization{} = organization} = BN.create_organization(@valid_attrs)
      assert organization.address == "some address"
      assert organization.company_registration_number == "some company_registration_number"
      assert organization.contact_number == "some contact_number"
      assert organization.country == "some country"
      assert organization.name == "some name"
      assert organization.tax_registration_number == "some tax_registration_number"
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()
      assert {:ok, organization} = BN.update_organization(organization, @update_attrs)
      assert %Organization{} = organization
      assert organization.address == "some updated address"
      assert organization.company_registration_number == "some updated company_registration_number"
      assert organization.contact_number == "some updated contact_number"
      assert organization.country == "some updated country"
      assert organization.name == "some updated name"
      assert organization.tax_registration_number == "some updated tax_registration_number"
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = organization_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_organization(organization, @invalid_attrs)
      assert organization == BN.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = BN.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> BN.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = BN.change_organization(organization)
    end
  end

  describe "branch" do
    alias BoatNoodle.BN.Branch

    @valid_attrs %{branch_address: "some branch_address", branch_code: "some branch_code", branch_contact: "some branch_contact", branch_manager: "some branch_manager", branch_name: "some branch_name", goverment_tax_percentage: 42, number_of_staff: 42, organization: "some organization", report_class: "some report_class", service_tax_percentage: 42}
    @update_attrs %{branch_address: "some updated branch_address", branch_code: "some updated branch_code", branch_contact: "some updated branch_contact", branch_manager: "some updated branch_manager", branch_name: "some updated branch_name", goverment_tax_percentage: 43, number_of_staff: 43, organization: "some updated organization", report_class: "some updated report_class", service_tax_percentage: 43}
    @invalid_attrs %{branch_address: nil, branch_code: nil, branch_contact: nil, branch_manager: nil, branch_name: nil, goverment_tax_percentage: nil, number_of_staff: nil, organization: nil, report_class: nil, service_tax_percentage: nil}

    def branch_fixture(attrs \\ %{}) do
      {:ok, branch} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_branch()

      branch
    end

    test "list_branch/0 returns all branch" do
      branch = branch_fixture()
      assert BN.list_branch() == [branch]
    end

    test "get_branch!/1 returns the branch with given id" do
      branch = branch_fixture()
      assert BN.get_branch!(branch.id) == branch
    end

    test "create_branch/1 with valid data creates a branch" do
      assert {:ok, %Branch{} = branch} = BN.create_branch(@valid_attrs)
      assert branch.branch_address == "some branch_address"
      assert branch.branch_code == "some branch_code"
      assert branch.branch_contact == "some branch_contact"
      assert branch.branch_manager == "some branch_manager"
      assert branch.branch_name == "some branch_name"
      assert branch.goverment_tax_percentage == 42
      assert branch.number_of_staff == 42
      assert branch.organization == "some organization"
      assert branch.report_class == "some report_class"
      assert branch.service_tax_percentage == 42
    end

    test "create_branch/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_branch(@invalid_attrs)
    end

    test "update_branch/2 with valid data updates the branch" do
      branch = branch_fixture()
      assert {:ok, branch} = BN.update_branch(branch, @update_attrs)
      assert %Branch{} = branch
      assert branch.branch_address == "some updated branch_address"
      assert branch.branch_code == "some updated branch_code"
      assert branch.branch_contact == "some updated branch_contact"
      assert branch.branch_manager == "some updated branch_manager"
      assert branch.branch_name == "some updated branch_name"
      assert branch.goverment_tax_percentage == 43
      assert branch.number_of_staff == 43
      assert branch.organization == "some updated organization"
      assert branch.report_class == "some updated report_class"
      assert branch.service_tax_percentage == 43
    end

    test "update_branch/2 with invalid data returns error changeset" do
      branch = branch_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_branch(branch, @invalid_attrs)
      assert branch == BN.get_branch!(branch.id)
    end

    test "delete_branch/1 deletes the branch" do
      branch = branch_fixture()
      assert {:ok, %Branch{}} = BN.delete_branch(branch)
      assert_raise Ecto.NoResultsError, fn -> BN.get_branch!(branch.id) end
    end

    test "change_branch/1 returns a branch changeset" do
      branch = branch_fixture()
      assert %Ecto.Changeset{} = BN.change_branch(branch)
    end
  end

  describe "tag" do
    alias BoatNoodle.BN.Tag

    @valid_attrs %{description: "some description", printer_name: "some printer_name", tag_name: "some tag_name"}
    @update_attrs %{description: "some updated description", printer_name: "some updated printer_name", tag_name: "some updated tag_name"}
    @invalid_attrs %{description: nil, printer_name: nil, tag_name: nil}

    def tag_fixture(attrs \\ %{}) do
      {:ok, tag} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_tag()

      tag
    end

    test "list_tag/0 returns all tag" do
      tag = tag_fixture()
      assert BN.list_tag() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert BN.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      assert {:ok, %Tag{} = tag} = BN.create_tag(@valid_attrs)
      assert tag.description == "some description"
      assert tag.printer_name == "some printer_name"
      assert tag.tag_name == "some tag_name"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      assert {:ok, tag} = BN.update_tag(tag, @update_attrs)
      assert %Tag{} = tag
      assert tag.description == "some updated description"
      assert tag.printer_name == "some updated printer_name"
      assert tag.tag_name == "some updated tag_name"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_tag(tag, @invalid_attrs)
      assert tag == BN.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = BN.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> BN.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = BN.change_tag(tag)
    end
  end

  describe "payment_type" do
    alias BoatNoodle.BN.PaymentTyType

    @valid_attrs %{payment_name: "some payment_name"}
    @update_attrs %{payment_name: "some updated payment_name"}
    @invalid_attrs %{payment_name: nil}

    def payment_ty_type_fixture(attrs \\ %{}) do
      {:ok, payment_ty_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_payment_ty_type()

      payment_ty_type
    end

    test "list_payment_type/0 returns all payment_type" do
      payment_ty_type = payment_ty_type_fixture()
      assert BN.list_payment_type() == [payment_ty_type]
    end

    test "get_payment_ty_type!/1 returns the payment_ty_type with given id" do
      payment_ty_type = payment_ty_type_fixture()
      assert BN.get_payment_ty_type!(payment_ty_type.id) == payment_ty_type
    end

    test "create_payment_ty_type/1 with valid data creates a payment_ty_type" do
      assert {:ok, %PaymentTyType{} = payment_ty_type} = BN.create_payment_ty_type(@valid_attrs)
      assert payment_ty_type.payment_name == "some payment_name"
    end

    test "create_payment_ty_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_payment_ty_type(@invalid_attrs)
    end

    test "update_payment_ty_type/2 with valid data updates the payment_ty_type" do
      payment_ty_type = payment_ty_type_fixture()
      assert {:ok, payment_ty_type} = BN.update_payment_ty_type(payment_ty_type, @update_attrs)
      assert %PaymentTyType{} = payment_ty_type
      assert payment_ty_type.payment_name == "some updated payment_name"
    end

    test "update_payment_ty_type/2 with invalid data returns error changeset" do
      payment_ty_type = payment_ty_type_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_payment_ty_type(payment_ty_type, @invalid_attrs)
      assert payment_ty_type == BN.get_payment_ty_type!(payment_ty_type.id)
    end

    test "delete_payment_ty_type/1 deletes the payment_ty_type" do
      payment_ty_type = payment_ty_type_fixture()
      assert {:ok, %PaymentTyType{}} = BN.delete_payment_ty_type(payment_ty_type)
      assert_raise Ecto.NoResultsError, fn -> BN.get_payment_ty_type!(payment_ty_type.id) end
    end

    test "change_payment_ty_type/1 returns a payment_ty_type changeset" do
      payment_ty_type = payment_ty_type_fixture()
      assert %Ecto.Changeset{} = BN.change_payment_ty_type(payment_ty_type)
    end
  end

  describe "payment_type" do
    alias BoatNoodle.BN.PaymentType

    @valid_attrs %{payment_name: "some payment_name"}
    @update_attrs %{payment_name: "some updated payment_name"}
    @invalid_attrs %{payment_name: nil}

    def payment_type_fixture(attrs \\ %{}) do
      {:ok, payment_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_payment_type()

      payment_type
    end

    test "list_payment_type/0 returns all payment_type" do
      payment_type = payment_type_fixture()
      assert BN.list_payment_type() == [payment_type]
    end

    test "get_payment_type!/1 returns the payment_type with given id" do
      payment_type = payment_type_fixture()
      assert BN.get_payment_type!(payment_type.id) == payment_type
    end

    test "create_payment_type/1 with valid data creates a payment_type" do
      assert {:ok, %PaymentType{} = payment_type} = BN.create_payment_type(@valid_attrs)
      assert payment_type.payment_name == "some payment_name"
    end

    test "create_payment_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_payment_type(@invalid_attrs)
    end

    test "update_payment_type/2 with valid data updates the payment_type" do
      payment_type = payment_type_fixture()
      assert {:ok, payment_type} = BN.update_payment_type(payment_type, @update_attrs)
      assert %PaymentType{} = payment_type
      assert payment_type.payment_name == "some updated payment_name"
    end

    test "update_payment_type/2 with invalid data returns error changeset" do
      payment_type = payment_type_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_payment_type(payment_type, @invalid_attrs)
      assert payment_type == BN.get_payment_type!(payment_type.id)
    end

    test "delete_payment_type/1 deletes the payment_type" do
      payment_type = payment_type_fixture()
      assert {:ok, %PaymentType{}} = BN.delete_payment_type(payment_type)
      assert_raise Ecto.NoResultsError, fn -> BN.get_payment_type!(payment_type.id) end
    end

    test "change_payment_type/1 returns a payment_type changeset" do
      payment_type = payment_type_fixture()
      assert %Ecto.Changeset{} = BN.change_payment_type(payment_type)
    end
  end

  describe "sales_master" do
    alias BoatNoodle.BN.SalesMaster

    @valid_attrs %{casher: "some casher", pax: 42, payment: "some payment", receipt_no: 42, table: 42, total_amount: "120.5"}
    @update_attrs %{casher: "some updated casher", pax: 43, payment: "some updated payment", receipt_no: 43, table: 43, total_amount: "456.7"}
    @invalid_attrs %{casher: nil, pax: nil, payment: nil, receipt_no: nil, table: nil, total_amount: nil}

    def sales_master_fixture(attrs \\ %{}) do
      {:ok, sales_master} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_sales_master()

      sales_master
    end

    test "list_sales_master/0 returns all sales_master" do
      sales_master = sales_master_fixture()
      assert BN.list_sales_master() == [sales_master]
    end

    test "get_sales_master!/1 returns the sales_master with given id" do
      sales_master = sales_master_fixture()
      assert BN.get_sales_master!(sales_master.id) == sales_master
    end

    test "create_sales_master/1 with valid data creates a sales_master" do
      assert {:ok, %SalesMaster{} = sales_master} = BN.create_sales_master(@valid_attrs)
      assert sales_master.casher == "some casher"
      assert sales_master.pax == 42
      assert sales_master.payment == "some payment"
      assert sales_master.receipt_no == 42
      assert sales_master.table == 42
      assert sales_master.total_amount == Decimal.new("120.5")
    end

    test "create_sales_master/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_sales_master(@invalid_attrs)
    end

    test "update_sales_master/2 with valid data updates the sales_master" do
      sales_master = sales_master_fixture()
      assert {:ok, sales_master} = BN.update_sales_master(sales_master, @update_attrs)
      assert %SalesMaster{} = sales_master
      assert sales_master.casher == "some updated casher"
      assert sales_master.pax == 43
      assert sales_master.payment == "some updated payment"
      assert sales_master.receipt_no == 43
      assert sales_master.table == 43
      assert sales_master.total_amount == Decimal.new("456.7")
    end

    test "update_sales_master/2 with invalid data returns error changeset" do
      sales_master = sales_master_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_sales_master(sales_master, @invalid_attrs)
      assert sales_master == BN.get_sales_master!(sales_master.id)
    end

    test "delete_sales_master/1 deletes the sales_master" do
      sales_master = sales_master_fixture()
      assert {:ok, %SalesMaster{}} = BN.delete_sales_master(sales_master)
      assert_raise Ecto.NoResultsError, fn -> BN.get_sales_master!(sales_master.id) end
    end

    test "change_sales_master/1 returns a sales_master changeset" do
      sales_master = sales_master_fixture()
      assert %Ecto.Changeset{} = BN.change_sales_master(sales_master)
    end
  end

  describe "sales" do
    alias BoatNoodle.BN.Sales

    @valid_attrs %{item_id: 42, quantity: 42, sales_master_id: 42}
    @update_attrs %{item_id: 43, quantity: 43, sales_master_id: 43}
    @invalid_attrs %{item_id: nil, quantity: nil, sales_master_id: nil}

    def sales_fixture(attrs \\ %{}) do
      {:ok, sales} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_sales()

      sales
    end

    test "list_sales/0 returns all sales" do
      sales = sales_fixture()
      assert BN.list_sales() == [sales]
    end

    test "get_sales!/1 returns the sales with given id" do
      sales = sales_fixture()
      assert BN.get_sales!(sales.id) == sales
    end

    test "create_sales/1 with valid data creates a sales" do
      assert {:ok, %Sales{} = sales} = BN.create_sales(@valid_attrs)
      assert sales.item_id == 42
      assert sales.quantity == 42
      assert sales.sales_master_id == 42
    end

    test "create_sales/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_sales(@invalid_attrs)
    end

    test "update_sales/2 with valid data updates the sales" do
      sales = sales_fixture()
      assert {:ok, sales} = BN.update_sales(sales, @update_attrs)
      assert %Sales{} = sales
      assert sales.item_id == 43
      assert sales.quantity == 43
      assert sales.sales_master_id == 43
    end

    test "update_sales/2 with invalid data returns error changeset" do
      sales = sales_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_sales(sales, @invalid_attrs)
      assert sales == BN.get_sales!(sales.id)
    end

    test "delete_sales/1 deletes the sales" do
      sales = sales_fixture()
      assert {:ok, %Sales{}} = BN.delete_sales(sales)
      assert_raise Ecto.NoResultsError, fn -> BN.get_sales!(sales.id) end
    end

    test "change_sales/1 returns a sales changeset" do
      sales = sales_fixture()
      assert %Ecto.Changeset{} = BN.change_sales(sales)
    end
  end

  describe "tax" do
    alias BoatNoodle.BN.Tax

    @valid_attrs %{receipt_no: "some receipt_no", sales_time: ~N[2010-04-17 14:00:00.000000], standard_supply_rate: "120.5", tax: "120.5"}
    @update_attrs %{receipt_no: "some updated receipt_no", sales_time: ~N[2011-05-18 15:01:01.000000], standard_supply_rate: "456.7", tax: "456.7"}
    @invalid_attrs %{receipt_no: nil, sales_time: nil, standard_supply_rate: nil, tax: nil}

    def tax_fixture(attrs \\ %{}) do
      {:ok, tax} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_tax()

      tax
    end

    test "list_tax/0 returns all tax" do
      tax = tax_fixture()
      assert BN.list_tax() == [tax]
    end

    test "get_tax!/1 returns the tax with given id" do
      tax = tax_fixture()
      assert BN.get_tax!(tax.id) == tax
    end

    test "create_tax/1 with valid data creates a tax" do
      assert {:ok, %Tax{} = tax} = BN.create_tax(@valid_attrs)
      assert tax.receipt_no == "some receipt_no"
      assert tax.sales_time == ~N[2010-04-17 14:00:00.000000]
      assert tax.standard_supply_rate == Decimal.new("120.5")
      assert tax.tax == Decimal.new("120.5")
    end

    test "create_tax/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_tax(@invalid_attrs)
    end

    test "update_tax/2 with valid data updates the tax" do
      tax = tax_fixture()
      assert {:ok, tax} = BN.update_tax(tax, @update_attrs)
      assert %Tax{} = tax
      assert tax.receipt_no == "some updated receipt_no"
      assert tax.sales_time == ~N[2011-05-18 15:01:01.000000]
      assert tax.standard_supply_rate == Decimal.new("456.7")
      assert tax.tax == Decimal.new("456.7")
    end

    test "update_tax/2 with invalid data returns error changeset" do
      tax = tax_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_tax(tax, @invalid_attrs)
      assert tax == BN.get_tax!(tax.id)
    end

    test "delete_tax/1 deletes the tax" do
      tax = tax_fixture()
      assert {:ok, %Tax{}} = BN.delete_tax(tax)
      assert_raise Ecto.NoResultsError, fn -> BN.get_tax!(tax.id) end
    end

    test "change_tax/1 returns a tax changeset" do
      tax = tax_fixture()
      assert %Ecto.Changeset{} = BN.change_tax(tax)
    end
  end

  describe "cash_in_out" do
    alias BoatNoodle.BN.CashInOut

    @valid_attrs %{branch: "some branch", cash_in: "120.5", cash_out: "120.5", open_drawer: 42}
    @update_attrs %{branch: "some updated branch", cash_in: "456.7", cash_out: "456.7", open_drawer: 43}
    @invalid_attrs %{branch: nil, cash_in: nil, cash_out: nil, open_drawer: nil}

    def cash_in_out_fixture(attrs \\ %{}) do
      {:ok, cash_in_out} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_cash_in_out()

      cash_in_out
    end

    test "list_cash_in_out/0 returns all cash_in_out" do
      cash_in_out = cash_in_out_fixture()
      assert BN.list_cash_in_out() == [cash_in_out]
    end

    test "get_cash_in_out!/1 returns the cash_in_out with given id" do
      cash_in_out = cash_in_out_fixture()
      assert BN.get_cash_in_out!(cash_in_out.id) == cash_in_out
    end

    test "create_cash_in_out/1 with valid data creates a cash_in_out" do
      assert {:ok, %CashInOut{} = cash_in_out} = BN.create_cash_in_out(@valid_attrs)
      assert cash_in_out.branch == "some branch"
      assert cash_in_out.cash_in == Decimal.new("120.5")
      assert cash_in_out.cash_out == Decimal.new("120.5")
      assert cash_in_out.open_drawer == 42
    end

    test "create_cash_in_out/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_cash_in_out(@invalid_attrs)
    end

    test "update_cash_in_out/2 with valid data updates the cash_in_out" do
      cash_in_out = cash_in_out_fixture()
      assert {:ok, cash_in_out} = BN.update_cash_in_out(cash_in_out, @update_attrs)
      assert %CashInOut{} = cash_in_out
      assert cash_in_out.branch == "some updated branch"
      assert cash_in_out.cash_in == Decimal.new("456.7")
      assert cash_in_out.cash_out == Decimal.new("456.7")
      assert cash_in_out.open_drawer == 43
    end

    test "update_cash_in_out/2 with invalid data returns error changeset" do
      cash_in_out = cash_in_out_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_cash_in_out(cash_in_out, @invalid_attrs)
      assert cash_in_out == BN.get_cash_in_out!(cash_in_out.id)
    end

    test "delete_cash_in_out/1 deletes the cash_in_out" do
      cash_in_out = cash_in_out_fixture()
      assert {:ok, %CashInOut{}} = BN.delete_cash_in_out(cash_in_out)
      assert_raise Ecto.NoResultsError, fn -> BN.get_cash_in_out!(cash_in_out.id) end
    end

    test "change_cash_in_out/1 returns a cash_in_out changeset" do
      cash_in_out = cash_in_out_fixture()
      assert %Ecto.Changeset{} = BN.change_cash_in_out(cash_in_out)
    end
  end
end
