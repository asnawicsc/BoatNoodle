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

  describe "branch_item_deactivate" do
    alias BoatNoodle.BN.BranchItemDeactivate

    @valid_attrs %{branchid: 42, id: 42, is_activate: 42, itemid: 42}
    @update_attrs %{branchid: 43, id: 43, is_activate: 43, itemid: 43}
    @invalid_attrs %{branchid: nil, id: nil, is_activate: nil, itemid: nil}

    def branch_item_deactivate_fixture(attrs \\ %{}) do
      {:ok, branch_item_deactivate} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_branch_item_deactivate()

      branch_item_deactivate
    end

    test "list_branch_item_deactivate/0 returns all branch_item_deactivate" do
      branch_item_deactivate = branch_item_deactivate_fixture()
      assert BN.list_branch_item_deactivate() == [branch_item_deactivate]
    end

    test "get_branch_item_deactivate!/1 returns the branch_item_deactivate with given id" do
      branch_item_deactivate = branch_item_deactivate_fixture()
      assert BN.get_branch_item_deactivate!(branch_item_deactivate.id) == branch_item_deactivate
    end

    test "create_branch_item_deactivate/1 with valid data creates a branch_item_deactivate" do
      assert {:ok, %BranchItemDeactivate{} = branch_item_deactivate} = BN.create_branch_item_deactivate(@valid_attrs)
      assert branch_item_deactivate.branchid == 42
      assert branch_item_deactivate.id == 42
      assert branch_item_deactivate.is_activate == 42
      assert branch_item_deactivate.itemid == 42
    end

    test "create_branch_item_deactivate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_branch_item_deactivate(@invalid_attrs)
    end

    test "update_branch_item_deactivate/2 with valid data updates the branch_item_deactivate" do
      branch_item_deactivate = branch_item_deactivate_fixture()
      assert {:ok, branch_item_deactivate} = BN.update_branch_item_deactivate(branch_item_deactivate, @update_attrs)
      assert %BranchItemDeactivate{} = branch_item_deactivate
      assert branch_item_deactivate.branchid == 43
      assert branch_item_deactivate.id == 43
      assert branch_item_deactivate.is_activate == 43
      assert branch_item_deactivate.itemid == 43
    end

    test "update_branch_item_deactivate/2 with invalid data returns error changeset" do
      branch_item_deactivate = branch_item_deactivate_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_branch_item_deactivate(branch_item_deactivate, @invalid_attrs)
      assert branch_item_deactivate == BN.get_branch_item_deactivate!(branch_item_deactivate.id)
    end

    test "delete_branch_item_deactivate/1 deletes the branch_item_deactivate" do
      branch_item_deactivate = branch_item_deactivate_fixture()
      assert {:ok, %BranchItemDeactivate{}} = BN.delete_branch_item_deactivate(branch_item_deactivate)
      assert_raise Ecto.NoResultsError, fn -> BN.get_branch_item_deactivate!(branch_item_deactivate.id) end
    end

    test "change_branch_item_deactivate/1 returns a branch_item_deactivate changeset" do
      branch_item_deactivate = branch_item_deactivate_fixture()
      assert %Ecto.Changeset{} = BN.change_branch_item_deactivate(branch_item_deactivate)
    end
  end

  describe "cashier_session" do
    alias BoatNoodle.BN.CashierSession

    @valid_attrs %{branchid: "some branchid", cash_in: "120.5", cash_out: "120.5", close_amt: "120.5", csid: 42, deposits: "120.5", duration: 42, floatamt: "120.5", open_amt: "120.5", paidout: "120.5", staffid: "some staffid", time_end: "2010-04-17 14:00:00.000000Z", time_start: "2010-04-17 14:00:00.000000Z"}
    @update_attrs %{branchid: "some updated branchid", cash_in: "456.7", cash_out: "456.7", close_amt: "456.7", csid: 43, deposits: "456.7", duration: 43, floatamt: "456.7", open_amt: "456.7", paidout: "456.7", staffid: "some updated staffid", time_end: "2011-05-18 15:01:01.000000Z", time_start: "2011-05-18 15:01:01.000000Z"}
    @invalid_attrs %{branchid: nil, cash_in: nil, cash_out: nil, close_amt: nil, csid: nil, deposits: nil, duration: nil, floatamt: nil, open_amt: nil, paidout: nil, staffid: nil, time_end: nil, time_start: nil}

    def cashier_session_fixture(attrs \\ %{}) do
      {:ok, cashier_session} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_cashier_session()

      cashier_session
    end

    test "list_cashier_session/0 returns all cashier_session" do
      cashier_session = cashier_session_fixture()
      assert BN.list_cashier_session() == [cashier_session]
    end

    test "get_cashier_session!/1 returns the cashier_session with given id" do
      cashier_session = cashier_session_fixture()
      assert BN.get_cashier_session!(cashier_session.id) == cashier_session
    end

    test "create_cashier_session/1 with valid data creates a cashier_session" do
      assert {:ok, %CashierSession{} = cashier_session} = BN.create_cashier_session(@valid_attrs)
      assert cashier_session.branchid == "some branchid"
      assert cashier_session.cash_in == Decimal.new("120.5")
      assert cashier_session.cash_out == Decimal.new("120.5")
      assert cashier_session.close_amt == Decimal.new("120.5")
      assert cashier_session.csid == 42
      assert cashier_session.deposits == Decimal.new("120.5")
      assert cashier_session.duration == 42
      assert cashier_session.floatamt == Decimal.new("120.5")
      assert cashier_session.open_amt == Decimal.new("120.5")
      assert cashier_session.paidout == Decimal.new("120.5")
      assert cashier_session.staffid == "some staffid"
      assert cashier_session.time_end == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert cashier_session.time_start == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
    end

    test "create_cashier_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_cashier_session(@invalid_attrs)
    end

    test "update_cashier_session/2 with valid data updates the cashier_session" do
      cashier_session = cashier_session_fixture()
      assert {:ok, cashier_session} = BN.update_cashier_session(cashier_session, @update_attrs)
      assert %CashierSession{} = cashier_session
      assert cashier_session.branchid == "some updated branchid"
      assert cashier_session.cash_in == Decimal.new("456.7")
      assert cashier_session.cash_out == Decimal.new("456.7")
      assert cashier_session.close_amt == Decimal.new("456.7")
      assert cashier_session.csid == 43
      assert cashier_session.deposits == Decimal.new("456.7")
      assert cashier_session.duration == 43
      assert cashier_session.floatamt == Decimal.new("456.7")
      assert cashier_session.open_amt == Decimal.new("456.7")
      assert cashier_session.paidout == Decimal.new("456.7")
      assert cashier_session.staffid == "some updated staffid"
      assert cashier_session.time_end == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert cashier_session.time_start == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
    end

    test "update_cashier_session/2 with invalid data returns error changeset" do
      cashier_session = cashier_session_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_cashier_session(cashier_session, @invalid_attrs)
      assert cashier_session == BN.get_cashier_session!(cashier_session.id)
    end

    test "delete_cashier_session/1 deletes the cashier_session" do
      cashier_session = cashier_session_fixture()
      assert {:ok, %CashierSession{}} = BN.delete_cashier_session(cashier_session)
      assert_raise Ecto.NoResultsError, fn -> BN.get_cashier_session!(cashier_session.id) end
    end

    test "change_cashier_session/1 returns a cashier_session changeset" do
      cashier_session = cashier_session_fixture()
      assert %Ecto.Changeset{} = BN.change_cashier_session(cashier_session)
    end
  end

  describe "cash_in_out_type" do
    alias BoatNoodle.BN.CashInOutType

    @valid_attrs %{cash_type_id: 42, description: "some description", name: "some name"}
    @update_attrs %{cash_type_id: 43, description: "some updated description", name: "some updated name"}
    @invalid_attrs %{cash_type_id: nil, description: nil, name: nil}

    def cash_in_out_type_fixture(attrs \\ %{}) do
      {:ok, cash_in_out_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_cash_in_out_type()

      cash_in_out_type
    end

    test "list_cash_in_out_type/0 returns all cash_in_out_type" do
      cash_in_out_type = cash_in_out_type_fixture()
      assert BN.list_cash_in_out_type() == [cash_in_out_type]
    end

    test "get_cash_in_out_type!/1 returns the cash_in_out_type with given id" do
      cash_in_out_type = cash_in_out_type_fixture()
      assert BN.get_cash_in_out_type!(cash_in_out_type.id) == cash_in_out_type
    end

    test "create_cash_in_out_type/1 with valid data creates a cash_in_out_type" do
      assert {:ok, %CashInOutType{} = cash_in_out_type} = BN.create_cash_in_out_type(@valid_attrs)
      assert cash_in_out_type.cash_type_id == 42
      assert cash_in_out_type.description == "some description"
      assert cash_in_out_type.name == "some name"
    end

    test "create_cash_in_out_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_cash_in_out_type(@invalid_attrs)
    end

    test "update_cash_in_out_type/2 with valid data updates the cash_in_out_type" do
      cash_in_out_type = cash_in_out_type_fixture()
      assert {:ok, cash_in_out_type} = BN.update_cash_in_out_type(cash_in_out_type, @update_attrs)
      assert %CashInOutType{} = cash_in_out_type
      assert cash_in_out_type.cash_type_id == 43
      assert cash_in_out_type.description == "some updated description"
      assert cash_in_out_type.name == "some updated name"
    end

    test "update_cash_in_out_type/2 with invalid data returns error changeset" do
      cash_in_out_type = cash_in_out_type_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_cash_in_out_type(cash_in_out_type, @invalid_attrs)
      assert cash_in_out_type == BN.get_cash_in_out_type!(cash_in_out_type.id)
    end

    test "delete_cash_in_out_type/1 deletes the cash_in_out_type" do
      cash_in_out_type = cash_in_out_type_fixture()
      assert {:ok, %CashInOutType{}} = BN.delete_cash_in_out_type(cash_in_out_type)
      assert_raise Ecto.NoResultsError, fn -> BN.get_cash_in_out_type!(cash_in_out_type.id) end
    end

    test "change_cash_in_out_type/1 returns a cash_in_out_type changeset" do
      cash_in_out_type = cash_in_out_type_fixture()
      assert %Ecto.Changeset{} = BN.change_cash_in_out_type(cash_in_out_type)
    end
  end

  describe "combo_details" do
    alias BoatNoodle.BN.ComboDetails

    @valid_attrs %{combo_id: 42, combo_item_code: "some combo_item_code", combo_item_id: 42, combo_item_name: "some combo_item_name", combo_item_qty: 42, combo_qty: 42, id: 42, menu_cat_id: 42, top_up: "120.5", unit_price: "120.5", update_qty: 42}
    @update_attrs %{combo_id: 43, combo_item_code: "some updated combo_item_code", combo_item_id: 43, combo_item_name: "some updated combo_item_name", combo_item_qty: 43, combo_qty: 43, id: 43, menu_cat_id: 43, top_up: "456.7", unit_price: "456.7", update_qty: 43}
    @invalid_attrs %{combo_id: nil, combo_item_code: nil, combo_item_id: nil, combo_item_name: nil, combo_item_qty: nil, combo_qty: nil, id: nil, menu_cat_id: nil, top_up: nil, unit_price: nil, update_qty: nil}

    def combo_details_fixture(attrs \\ %{}) do
      {:ok, combo_details} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_combo_details()

      combo_details
    end

    test "list_combo_details/0 returns all combo_details" do
      combo_details = combo_details_fixture()
      assert BN.list_combo_details() == [combo_details]
    end

    test "get_combo_details!/1 returns the combo_details with given id" do
      combo_details = combo_details_fixture()
      assert BN.get_combo_details!(combo_details.id) == combo_details
    end

    test "create_combo_details/1 with valid data creates a combo_details" do
      assert {:ok, %ComboDetails{} = combo_details} = BN.create_combo_details(@valid_attrs)
      assert combo_details.combo_id == 42
      assert combo_details.combo_item_code == "some combo_item_code"
      assert combo_details.combo_item_id == 42
      assert combo_details.combo_item_name == "some combo_item_name"
      assert combo_details.combo_item_qty == 42
      assert combo_details.combo_qty == 42
      assert combo_details.id == 42
      assert combo_details.menu_cat_id == 42
      assert combo_details.top_up == Decimal.new("120.5")
      assert combo_details.unit_price == Decimal.new("120.5")
      assert combo_details.update_qty == 42
    end

    test "create_combo_details/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_combo_details(@invalid_attrs)
    end

    test "update_combo_details/2 with valid data updates the combo_details" do
      combo_details = combo_details_fixture()
      assert {:ok, combo_details} = BN.update_combo_details(combo_details, @update_attrs)
      assert %ComboDetails{} = combo_details
      assert combo_details.combo_id == 43
      assert combo_details.combo_item_code == "some updated combo_item_code"
      assert combo_details.combo_item_id == 43
      assert combo_details.combo_item_name == "some updated combo_item_name"
      assert combo_details.combo_item_qty == 43
      assert combo_details.combo_qty == 43
      assert combo_details.id == 43
      assert combo_details.menu_cat_id == 43
      assert combo_details.top_up == Decimal.new("456.7")
      assert combo_details.unit_price == Decimal.new("456.7")
      assert combo_details.update_qty == 43
    end

    test "update_combo_details/2 with invalid data returns error changeset" do
      combo_details = combo_details_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_combo_details(combo_details, @invalid_attrs)
      assert combo_details == BN.get_combo_details!(combo_details.id)
    end

    test "delete_combo_details/1 deletes the combo_details" do
      combo_details = combo_details_fixture()
      assert {:ok, %ComboDetails{}} = BN.delete_combo_details(combo_details)
      assert_raise Ecto.NoResultsError, fn -> BN.get_combo_details!(combo_details.id) end
    end

    test "change_combo_details/1 returns a combo_details changeset" do
      combo_details = combo_details_fixture()
      assert %Ecto.Changeset{} = BN.change_combo_details(combo_details)
    end
  end

  describe "combo_map" do
    alias BoatNoodle.BN.ComboMap

    @valid_attrs %{linkid: 42, subcatid: 42}
    @update_attrs %{linkid: 43, subcatid: 43}
    @invalid_attrs %{linkid: nil, subcatid: nil}

    def combo_map_fixture(attrs \\ %{}) do
      {:ok, combo_map} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_combo_map()

      combo_map
    end

    test "list_combo_map/0 returns all combo_map" do
      combo_map = combo_map_fixture()
      assert BN.list_combo_map() == [combo_map]
    end

    test "get_combo_map!/1 returns the combo_map with given id" do
      combo_map = combo_map_fixture()
      assert BN.get_combo_map!(combo_map.id) == combo_map
    end

    test "create_combo_map/1 with valid data creates a combo_map" do
      assert {:ok, %ComboMap{} = combo_map} = BN.create_combo_map(@valid_attrs)
      assert combo_map.linkid == 42
      assert combo_map.subcatid == 42
    end

    test "create_combo_map/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_combo_map(@invalid_attrs)
    end

    test "update_combo_map/2 with valid data updates the combo_map" do
      combo_map = combo_map_fixture()
      assert {:ok, combo_map} = BN.update_combo_map(combo_map, @update_attrs)
      assert %ComboMap{} = combo_map
      assert combo_map.linkid == 43
      assert combo_map.subcatid == 43
    end

    test "update_combo_map/2 with invalid data returns error changeset" do
      combo_map = combo_map_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_combo_map(combo_map, @invalid_attrs)
      assert combo_map == BN.get_combo_map!(combo_map.id)
    end

    test "delete_combo_map/1 deletes the combo_map" do
      combo_map = combo_map_fixture()
      assert {:ok, %ComboMap{}} = BN.delete_combo_map(combo_map)
      assert_raise Ecto.NoResultsError, fn -> BN.get_combo_map!(combo_map.id) end
    end

    test "change_combo_map/1 returns a combo_map changeset" do
      combo_map = combo_map_fixture()
      assert %Ecto.Changeset{} = BN.change_combo_map(combo_map)
    end
  end

  describe "discount_type" do
    alias BoatNoodle.BN.DiscountType

    @valid_attrs %{disctypeid: 42, disctypename: "some disctypename"}
    @update_attrs %{disctypeid: 43, disctypename: "some updated disctypename"}
    @invalid_attrs %{disctypeid: nil, disctypename: nil}

    def discount_type_fixture(attrs \\ %{}) do
      {:ok, discount_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_discount_type()

      discount_type
    end

    test "list_discount_type/0 returns all discount_type" do
      discount_type = discount_type_fixture()
      assert BN.list_discount_type() == [discount_type]
    end

    test "get_discount_type!/1 returns the discount_type with given id" do
      discount_type = discount_type_fixture()
      assert BN.get_discount_type!(discount_type.id) == discount_type
    end

    test "create_discount_type/1 with valid data creates a discount_type" do
      assert {:ok, %DiscountType{} = discount_type} = BN.create_discount_type(@valid_attrs)
      assert discount_type.disctypeid == 42
      assert discount_type.disctypename == "some disctypename"
    end

    test "create_discount_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_discount_type(@invalid_attrs)
    end

    test "update_discount_type/2 with valid data updates the discount_type" do
      discount_type = discount_type_fixture()
      assert {:ok, discount_type} = BN.update_discount_type(discount_type, @update_attrs)
      assert %DiscountType{} = discount_type
      assert discount_type.disctypeid == 43
      assert discount_type.disctypename == "some updated disctypename"
    end

    test "update_discount_type/2 with invalid data returns error changeset" do
      discount_type = discount_type_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_discount_type(discount_type, @invalid_attrs)
      assert discount_type == BN.get_discount_type!(discount_type.id)
    end

    test "delete_discount_type/1 deletes the discount_type" do
      discount_type = discount_type_fixture()
      assert {:ok, %DiscountType{}} = BN.delete_discount_type(discount_type)
      assert_raise Ecto.NoResultsError, fn -> BN.get_discount_type!(discount_type.id) end
    end

    test "change_discount_type/1 returns a discount_type changeset" do
      discount_type = discount_type_fixture()
      assert %Ecto.Changeset{} = BN.change_discount_type(discount_type)
    end
  end

  describe "item_customized" do
    alias BoatNoodle.BN.ItemCustomized

    @valid_attrs %{availability: "some availability", created_at: "2010-04-17 14:00:00.000000Z", customize_code: "some customize_code", customize_detail: "some customize_detail", itemcustomid: 42, price: "120.5", subcatid: "some subcatid", updated_at: "2010-04-17 14:00:00.000000Z"}
    @update_attrs %{availability: "some updated availability", created_at: "2011-05-18 15:01:01.000000Z", customize_code: "some updated customize_code", customize_detail: "some updated customize_detail", itemcustomid: 43, price: "456.7", subcatid: "some updated subcatid", updated_at: "2011-05-18 15:01:01.000000Z"}
    @invalid_attrs %{availability: nil, created_at: nil, customize_code: nil, customize_detail: nil, itemcustomid: nil, price: nil, subcatid: nil, updated_at: nil}

    def item_customized_fixture(attrs \\ %{}) do
      {:ok, item_customized} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_item_customized()

      item_customized
    end

    test "list_item_customized/0 returns all item_customized" do
      item_customized = item_customized_fixture()
      assert BN.list_item_customized() == [item_customized]
    end

    test "get_item_customized!/1 returns the item_customized with given id" do
      item_customized = item_customized_fixture()
      assert BN.get_item_customized!(item_customized.id) == item_customized
    end

    test "create_item_customized/1 with valid data creates a item_customized" do
      assert {:ok, %ItemCustomized{} = item_customized} = BN.create_item_customized(@valid_attrs)
      assert item_customized.availability == "some availability"
      assert item_customized.created_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert item_customized.customize_code == "some customize_code"
      assert item_customized.customize_detail == "some customize_detail"
      assert item_customized.itemcustomid == 42
      assert item_customized.price == Decimal.new("120.5")
      assert item_customized.subcatid == "some subcatid"
      assert item_customized.updated_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
    end

    test "create_item_customized/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_item_customized(@invalid_attrs)
    end

    test "update_item_customized/2 with valid data updates the item_customized" do
      item_customized = item_customized_fixture()
      assert {:ok, item_customized} = BN.update_item_customized(item_customized, @update_attrs)
      assert %ItemCustomized{} = item_customized
      assert item_customized.availability == "some updated availability"
      assert item_customized.created_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert item_customized.customize_code == "some updated customize_code"
      assert item_customized.customize_detail == "some updated customize_detail"
      assert item_customized.itemcustomid == 43
      assert item_customized.price == Decimal.new("456.7")
      assert item_customized.subcatid == "some updated subcatid"
      assert item_customized.updated_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
    end

    test "update_item_customized/2 with invalid data returns error changeset" do
      item_customized = item_customized_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_item_customized(item_customized, @invalid_attrs)
      assert item_customized == BN.get_item_customized!(item_customized.id)
    end

    test "delete_item_customized/1 deletes the item_customized" do
      item_customized = item_customized_fixture()
      assert {:ok, %ItemCustomized{}} = BN.delete_item_customized(item_customized)
      assert_raise Ecto.NoResultsError, fn -> BN.get_item_customized!(item_customized.id) end
    end

    test "change_item_customized/1 returns a item_customized changeset" do
      item_customized = item_customized_fixture()
      assert %Ecto.Changeset{} = BN.change_item_customized(item_customized)
    end
  end

  describe "migrations" do
    alias BoatNoodle.BN.Migrations

    @valid_attrs %{batch: 42, migration: "some migration"}
    @update_attrs %{batch: 43, migration: "some updated migration"}
    @invalid_attrs %{batch: nil, migration: nil}

    def migrations_fixture(attrs \\ %{}) do
      {:ok, migrations} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_migrations()

      migrations
    end

    test "list_migrations/0 returns all migrations" do
      migrations = migrations_fixture()
      assert BN.list_migrations() == [migrations]
    end

    test "get_migrations!/1 returns the migrations with given id" do
      migrations = migrations_fixture()
      assert BN.get_migrations!(migrations.id) == migrations
    end

    test "create_migrations/1 with valid data creates a migrations" do
      assert {:ok, %Migrations{} = migrations} = BN.create_migrations(@valid_attrs)
      assert migrations.batch == 42
      assert migrations.migration == "some migration"
    end

    test "create_migrations/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_migrations(@invalid_attrs)
    end

    test "update_migrations/2 with valid data updates the migrations" do
      migrations = migrations_fixture()
      assert {:ok, migrations} = BN.update_migrations(migrations, @update_attrs)
      assert %Migrations{} = migrations
      assert migrations.batch == 43
      assert migrations.migration == "some updated migration"
    end

    test "update_migrations/2 with invalid data returns error changeset" do
      migrations = migrations_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_migrations(migrations, @invalid_attrs)
      assert migrations == BN.get_migrations!(migrations.id)
    end

    test "delete_migrations/1 deletes the migrations" do
      migrations = migrations_fixture()
      assert {:ok, %Migrations{}} = BN.delete_migrations(migrations)
      assert_raise Ecto.NoResultsError, fn -> BN.get_migrations!(migrations.id) end
    end

    test "change_migrations/1 returns a migrations changeset" do
      migrations = migrations_fixture()
      assert %Ecto.Changeset{} = BN.change_migrations(migrations)
    end
  end

  describe "password_resets" do
    alias BoatNoodle.BN.PasswordResets

    @valid_attrs %{created_at: "2010-04-17 14:00:00.000000Z", email: "some email", token: "some token"}
    @update_attrs %{created_at: "2011-05-18 15:01:01.000000Z", email: "some updated email", token: "some updated token"}
    @invalid_attrs %{created_at: nil, email: nil, token: nil}

    def password_resets_fixture(attrs \\ %{}) do
      {:ok, password_resets} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_password_resets()

      password_resets
    end

    test "list_password_resets/0 returns all password_resets" do
      password_resets = password_resets_fixture()
      assert BN.list_password_resets() == [password_resets]
    end

    test "get_password_resets!/1 returns the password_resets with given id" do
      password_resets = password_resets_fixture()
      assert BN.get_password_resets!(password_resets.id) == password_resets
    end

    test "create_password_resets/1 with valid data creates a password_resets" do
      assert {:ok, %PasswordResets{} = password_resets} = BN.create_password_resets(@valid_attrs)
      assert password_resets.created_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert password_resets.email == "some email"
      assert password_resets.token == "some token"
    end

    test "create_password_resets/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_password_resets(@invalid_attrs)
    end

    test "update_password_resets/2 with valid data updates the password_resets" do
      password_resets = password_resets_fixture()
      assert {:ok, password_resets} = BN.update_password_resets(password_resets, @update_attrs)
      assert %PasswordResets{} = password_resets
      assert password_resets.created_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert password_resets.email == "some updated email"
      assert password_resets.token == "some updated token"
    end

    test "update_password_resets/2 with invalid data returns error changeset" do
      password_resets = password_resets_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_password_resets(password_resets, @invalid_attrs)
      assert password_resets == BN.get_password_resets!(password_resets.id)
    end

    test "delete_password_resets/1 deletes the password_resets" do
      password_resets = password_resets_fixture()
      assert {:ok, %PasswordResets{}} = BN.delete_password_resets(password_resets)
      assert_raise Ecto.NoResultsError, fn -> BN.get_password_resets!(password_resets.id) end
    end

    test "change_password_resets/1 returns a password_resets changeset" do
      password_resets = password_resets_fixture()
      assert %Ecto.Changeset{} = BN.change_password_resets(password_resets)
    end
  end

  describe "rpt_cashier_eod" do
    alias BoatNoodle.BN.RPTCASHIEREOD

    @valid_attrs %{branch_id: 42, branchcode: "some branchcode", cash: "120.5", cash_in: "120.5", close_amt: "120.5", deposit: "120.5", dinein: "120.5", drawamt: "120.5", duration: "some duration", exp_drw_amt: "120.5", extra: "120.5", floats: "120.5", open_amt: "120.5", paidout: "120.5", rptid: 42, staff_name: "some staff_name", takeaway: "120.5", time_end: "2010-04-17 14:00:00.000000Z", time_start: "2010-04-17 14:00:00.000000Z", total_cash: "120.5", total_changes: "120.5", total_disc: "120.5", total_pymt: "120.5", total_round: "120.5", total_sr: "120.5", totalpax: 42, totalsales: "120.5", totalsvc: "120.5", totaltax: "120.5", voiditem: 120.5, voidsales: 120.5}
    @update_attrs %{branch_id: 43, branchcode: "some updated branchcode", cash: "456.7", cash_in: "456.7", close_amt: "456.7", deposit: "456.7", dinein: "456.7", drawamt: "456.7", duration: "some updated duration", exp_drw_amt: "456.7", extra: "456.7", floats: "456.7", open_amt: "456.7", paidout: "456.7", rptid: 43, staff_name: "some updated staff_name", takeaway: "456.7", time_end: "2011-05-18 15:01:01.000000Z", time_start: "2011-05-18 15:01:01.000000Z", total_cash: "456.7", total_changes: "456.7", total_disc: "456.7", total_pymt: "456.7", total_round: "456.7", total_sr: "456.7", totalpax: 43, totalsales: "456.7", totalsvc: "456.7", totaltax: "456.7", voiditem: 456.7, voidsales: 456.7}
    @invalid_attrs %{branch_id: nil, branchcode: nil, cash: nil, cash_in: nil, close_amt: nil, deposit: nil, dinein: nil, drawamt: nil, duration: nil, exp_drw_amt: nil, extra: nil, floats: nil, open_amt: nil, paidout: nil, rptid: nil, staff_name: nil, takeaway: nil, time_end: nil, time_start: nil, total_cash: nil, total_changes: nil, total_disc: nil, total_pymt: nil, total_round: nil, total_sr: nil, totalpax: nil, totalsales: nil, totalsvc: nil, totaltax: nil, voiditem: nil, voidsales: nil}

    def rptcashiereod_fixture(attrs \\ %{}) do
      {:ok, rptcashiereod} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_rptcashiereod()

      rptcashiereod
    end

    test "list_rpt_cashier_eod/0 returns all rpt_cashier_eod" do
      rptcashiereod = rptcashiereod_fixture()
      assert BN.list_rpt_cashier_eod() == [rptcashiereod]
    end

    test "get_rptcashiereod!/1 returns the rptcashiereod with given id" do
      rptcashiereod = rptcashiereod_fixture()
      assert BN.get_rptcashiereod!(rptcashiereod.id) == rptcashiereod
    end

    test "create_rptcashiereod/1 with valid data creates a rptcashiereod" do
      assert {:ok, %RPTCASHIEREOD{} = rptcashiereod} = BN.create_rptcashiereod(@valid_attrs)
      assert rptcashiereod.branch_id == 42
      assert rptcashiereod.branchcode == "some branchcode"
      assert rptcashiereod.cash == Decimal.new("120.5")
      assert rptcashiereod.cash_in == Decimal.new("120.5")
      assert rptcashiereod.close_amt == Decimal.new("120.5")
      assert rptcashiereod.deposit == Decimal.new("120.5")
      assert rptcashiereod.dinein == Decimal.new("120.5")
      assert rptcashiereod.drawamt == Decimal.new("120.5")
      assert rptcashiereod.duration == "some duration"
      assert rptcashiereod.exp_drw_amt == Decimal.new("120.5")
      assert rptcashiereod.extra == Decimal.new("120.5")
      assert rptcashiereod.floats == Decimal.new("120.5")
      assert rptcashiereod.open_amt == Decimal.new("120.5")
      assert rptcashiereod.paidout == Decimal.new("120.5")
      assert rptcashiereod.rptid == 42
      assert rptcashiereod.staff_name == "some staff_name"
      assert rptcashiereod.takeaway == Decimal.new("120.5")
      assert rptcashiereod.time_end == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert rptcashiereod.time_start == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert rptcashiereod.total_cash == Decimal.new("120.5")
      assert rptcashiereod.total_changes == Decimal.new("120.5")
      assert rptcashiereod.total_disc == Decimal.new("120.5")
      assert rptcashiereod.total_pymt == Decimal.new("120.5")
      assert rptcashiereod.total_round == Decimal.new("120.5")
      assert rptcashiereod.total_sr == Decimal.new("120.5")
      assert rptcashiereod.totalpax == 42
      assert rptcashiereod.totalsales == Decimal.new("120.5")
      assert rptcashiereod.totalsvc == Decimal.new("120.5")
      assert rptcashiereod.totaltax == Decimal.new("120.5")
      assert rptcashiereod.voiditem == 120.5
      assert rptcashiereod.voidsales == 120.5
    end

    test "create_rptcashiereod/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_rptcashiereod(@invalid_attrs)
    end

    test "update_rptcashiereod/2 with valid data updates the rptcashiereod" do
      rptcashiereod = rptcashiereod_fixture()
      assert {:ok, rptcashiereod} = BN.update_rptcashiereod(rptcashiereod, @update_attrs)
      assert %RPTCASHIEREOD{} = rptcashiereod
      assert rptcashiereod.branch_id == 43
      assert rptcashiereod.branchcode == "some updated branchcode"
      assert rptcashiereod.cash == Decimal.new("456.7")
      assert rptcashiereod.cash_in == Decimal.new("456.7")
      assert rptcashiereod.close_amt == Decimal.new("456.7")
      assert rptcashiereod.deposit == Decimal.new("456.7")
      assert rptcashiereod.dinein == Decimal.new("456.7")
      assert rptcashiereod.drawamt == Decimal.new("456.7")
      assert rptcashiereod.duration == "some updated duration"
      assert rptcashiereod.exp_drw_amt == Decimal.new("456.7")
      assert rptcashiereod.extra == Decimal.new("456.7")
      assert rptcashiereod.floats == Decimal.new("456.7")
      assert rptcashiereod.open_amt == Decimal.new("456.7")
      assert rptcashiereod.paidout == Decimal.new("456.7")
      assert rptcashiereod.rptid == 43
      assert rptcashiereod.staff_name == "some updated staff_name"
      assert rptcashiereod.takeaway == Decimal.new("456.7")
      assert rptcashiereod.time_end == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert rptcashiereod.time_start == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert rptcashiereod.total_cash == Decimal.new("456.7")
      assert rptcashiereod.total_changes == Decimal.new("456.7")
      assert rptcashiereod.total_disc == Decimal.new("456.7")
      assert rptcashiereod.total_pymt == Decimal.new("456.7")
      assert rptcashiereod.total_round == Decimal.new("456.7")
      assert rptcashiereod.total_sr == Decimal.new("456.7")
      assert rptcashiereod.totalpax == 43
      assert rptcashiereod.totalsales == Decimal.new("456.7")
      assert rptcashiereod.totalsvc == Decimal.new("456.7")
      assert rptcashiereod.totaltax == Decimal.new("456.7")
      assert rptcashiereod.voiditem == 456.7
      assert rptcashiereod.voidsales == 456.7
    end

    test "update_rptcashiereod/2 with invalid data returns error changeset" do
      rptcashiereod = rptcashiereod_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_rptcashiereod(rptcashiereod, @invalid_attrs)
      assert rptcashiereod == BN.get_rptcashiereod!(rptcashiereod.id)
    end

    test "delete_rptcashiereod/1 deletes the rptcashiereod" do
      rptcashiereod = rptcashiereod_fixture()
      assert {:ok, %RPTCASHIEREOD{}} = BN.delete_rptcashiereod(rptcashiereod)
      assert_raise Ecto.NoResultsError, fn -> BN.get_rptcashiereod!(rptcashiereod.id) end
    end

    test "change_rptcashiereod/1 returns a rptcashiereod changeset" do
      rptcashiereod = rptcashiereod_fixture()
      assert %Ecto.Changeset{} = BN.change_rptcashiereod(rptcashiereod)
    end
  end

  describe "rpt_hourly_outlet" do
    alias BoatNoodle.BN.RPTHOURLYOUTLET

    @valid_attrs %{brachcode: "some brachcode", branchid: 42, branchname: "some branchname", integer: "some integer", pax: 42, sales: "120.5", salesdate: ~N[2010-04-17 14:00:00.000000], saleshour: 42, salesmonth: 42, salesquarter: 42, salesyear: 42, transaction: "some transaction"}
    @update_attrs %{brachcode: "some updated brachcode", branchid: 43, branchname: "some updated branchname", integer: "some updated integer", pax: 43, sales: "456.7", salesdate: ~N[2011-05-18 15:01:01.000000], saleshour: 43, salesmonth: 43, salesquarter: 43, salesyear: 43, transaction: "some updated transaction"}
    @invalid_attrs %{brachcode: nil, branchid: nil, branchname: nil, integer: nil, pax: nil, sales: nil, salesdate: nil, saleshour: nil, salesmonth: nil, salesquarter: nil, salesyear: nil, transaction: nil}

    def rpthourlyoutlet_fixture(attrs \\ %{}) do
      {:ok, rpthourlyoutlet} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_rpthourlyoutlet()

      rpthourlyoutlet
    end

    test "list_rpt_hourly_outlet/0 returns all rpt_hourly_outlet" do
      rpthourlyoutlet = rpthourlyoutlet_fixture()
      assert BN.list_rpt_hourly_outlet() == [rpthourlyoutlet]
    end

    test "get_rpthourlyoutlet!/1 returns the rpthourlyoutlet with given id" do
      rpthourlyoutlet = rpthourlyoutlet_fixture()
      assert BN.get_rpthourlyoutlet!(rpthourlyoutlet.id) == rpthourlyoutlet
    end

    test "create_rpthourlyoutlet/1 with valid data creates a rpthourlyoutlet" do
      assert {:ok, %RPTHOURLYOUTLET{} = rpthourlyoutlet} = BN.create_rpthourlyoutlet(@valid_attrs)
      assert rpthourlyoutlet.brachcode == "some brachcode"
      assert rpthourlyoutlet.branchid == 42
      assert rpthourlyoutlet.branchname == "some branchname"
      assert rpthourlyoutlet.integer == "some integer"
      assert rpthourlyoutlet.pax == 42
      assert rpthourlyoutlet.sales == Decimal.new("120.5")
      assert rpthourlyoutlet.salesdate == ~N[2010-04-17 14:00:00.000000]
      assert rpthourlyoutlet.saleshour == 42
      assert rpthourlyoutlet.salesmonth == 42
      assert rpthourlyoutlet.salesquarter == 42
      assert rpthourlyoutlet.salesyear == 42
      assert rpthourlyoutlet.transaction == "some transaction"
    end

    test "create_rpthourlyoutlet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_rpthourlyoutlet(@invalid_attrs)
    end

    test "update_rpthourlyoutlet/2 with valid data updates the rpthourlyoutlet" do
      rpthourlyoutlet = rpthourlyoutlet_fixture()
      assert {:ok, rpthourlyoutlet} = BN.update_rpthourlyoutlet(rpthourlyoutlet, @update_attrs)
      assert %RPTHOURLYOUTLET{} = rpthourlyoutlet
      assert rpthourlyoutlet.brachcode == "some updated brachcode"
      assert rpthourlyoutlet.branchid == 43
      assert rpthourlyoutlet.branchname == "some updated branchname"
      assert rpthourlyoutlet.integer == "some updated integer"
      assert rpthourlyoutlet.pax == 43
      assert rpthourlyoutlet.sales == Decimal.new("456.7")
      assert rpthourlyoutlet.salesdate == ~N[2011-05-18 15:01:01.000000]
      assert rpthourlyoutlet.saleshour == 43
      assert rpthourlyoutlet.salesmonth == 43
      assert rpthourlyoutlet.salesquarter == 43
      assert rpthourlyoutlet.salesyear == 43
      assert rpthourlyoutlet.transaction == "some updated transaction"
    end

    test "update_rpthourlyoutlet/2 with invalid data returns error changeset" do
      rpthourlyoutlet = rpthourlyoutlet_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_rpthourlyoutlet(rpthourlyoutlet, @invalid_attrs)
      assert rpthourlyoutlet == BN.get_rpthourlyoutlet!(rpthourlyoutlet.id)
    end

    test "delete_rpthourlyoutlet/1 deletes the rpthourlyoutlet" do
      rpthourlyoutlet = rpthourlyoutlet_fixture()
      assert {:ok, %RPTHOURLYOUTLET{}} = BN.delete_rpthourlyoutlet(rpthourlyoutlet)
      assert_raise Ecto.NoResultsError, fn -> BN.get_rpthourlyoutlet!(rpthourlyoutlet.id) end
    end

    test "change_rpthourlyoutlet/1 returns a rpthourlyoutlet changeset" do
      rpthourlyoutlet = rpthourlyoutlet_fixture()
      assert %Ecto.Changeset{} = BN.change_rpthourlyoutlet(rpthourlyoutlet)
    end
  end

  describe "rpt_transaction" do
    alias BoatNoodle.BN.RPTTRANSACTION

    @valid_attrs %{after_disc: "some after_disc", branchcode: "some branchcode", branchid: 42, cash: "120.5", changes: "120.5", decimal: "some decimal", grand_total: "120.5", gst_charge: "some gst_charge", invoiceno: "some invoiceno", is_void: 42, pax: 42, payment_type: "some payment_type", quarter: 42, remark: "some remark", rounding: "120.5", salesdate: "2010-04-17 14:00:00.000000Z", saleshour: 42, salesid: "some salesid", salesmonth: 42, salestime: "2010-04-17 14:00:00.000000Z", salesyear: 42, service_charge: "120.5", staffid: 42, staffname: "some staffname", sub_total: "120.5", tbl_no: 42, type: "some type", void_by: "some void_by", voidreason: "some voidreason"}
    @update_attrs %{after_disc: "some updated after_disc", branchcode: "some updated branchcode", branchid: 43, cash: "456.7", changes: "456.7", decimal: "some updated decimal", grand_total: "456.7", gst_charge: "some updated gst_charge", invoiceno: "some updated invoiceno", is_void: 43, pax: 43, payment_type: "some updated payment_type", quarter: 43, remark: "some updated remark", rounding: "456.7", salesdate: "2011-05-18 15:01:01.000000Z", saleshour: 43, salesid: "some updated salesid", salesmonth: 43, salestime: "2011-05-18 15:01:01.000000Z", salesyear: 43, service_charge: "456.7", staffid: 43, staffname: "some updated staffname", sub_total: "456.7", tbl_no: 43, type: "some updated type", void_by: "some updated void_by", voidreason: "some updated voidreason"}
    @invalid_attrs %{after_disc: nil, branchcode: nil, branchid: nil, cash: nil, changes: nil, decimal: nil, grand_total: nil, gst_charge: nil, invoiceno: nil, is_void: nil, pax: nil, payment_type: nil, quarter: nil, remark: nil, rounding: nil, salesdate: nil, saleshour: nil, salesid: nil, salesmonth: nil, salestime: nil, salesyear: nil, service_charge: nil, staffid: nil, staffname: nil, sub_total: nil, tbl_no: nil, type: nil, void_by: nil, voidreason: nil}

    def rpttransaction_fixture(attrs \\ %{}) do
      {:ok, rpttransaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_rpttransaction()

      rpttransaction
    end

    test "list_rpt_transaction/0 returns all rpt_transaction" do
      rpttransaction = rpttransaction_fixture()
      assert BN.list_rpt_transaction() == [rpttransaction]
    end

    test "get_rpttransaction!/1 returns the rpttransaction with given id" do
      rpttransaction = rpttransaction_fixture()
      assert BN.get_rpttransaction!(rpttransaction.id) == rpttransaction
    end

    test "create_rpttransaction/1 with valid data creates a rpttransaction" do
      assert {:ok, %RPTTRANSACTION{} = rpttransaction} = BN.create_rpttransaction(@valid_attrs)
      assert rpttransaction.after_disc == "some after_disc"
      assert rpttransaction.branchcode == "some branchcode"
      assert rpttransaction.branchid == 42
      assert rpttransaction.cash == Decimal.new("120.5")
      assert rpttransaction.changes == Decimal.new("120.5")
      assert rpttransaction.decimal == "some decimal"
      assert rpttransaction.grand_total == Decimal.new("120.5")
      assert rpttransaction.gst_charge == "some gst_charge"
      assert rpttransaction.invoiceno == "some invoiceno"
      assert rpttransaction.is_void == 42
      assert rpttransaction.pax == 42
      assert rpttransaction.payment_type == "some payment_type"
      assert rpttransaction.quarter == 42
      assert rpttransaction.remark == "some remark"
      assert rpttransaction.rounding == Decimal.new("120.5")
      assert rpttransaction.salesdate == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert rpttransaction.saleshour == 42
      assert rpttransaction.salesid == "some salesid"
      assert rpttransaction.salesmonth == 42
      assert rpttransaction.salestime == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert rpttransaction.salesyear == 42
      assert rpttransaction.service_charge == Decimal.new("120.5")
      assert rpttransaction.staffid == 42
      assert rpttransaction.staffname == "some staffname"
      assert rpttransaction.sub_total == Decimal.new("120.5")
      assert rpttransaction.tbl_no == 42
      assert rpttransaction.type == "some type"
      assert rpttransaction.void_by == "some void_by"
      assert rpttransaction.voidreason == "some voidreason"
    end

    test "create_rpttransaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_rpttransaction(@invalid_attrs)
    end

    test "update_rpttransaction/2 with valid data updates the rpttransaction" do
      rpttransaction = rpttransaction_fixture()
      assert {:ok, rpttransaction} = BN.update_rpttransaction(rpttransaction, @update_attrs)
      assert %RPTTRANSACTION{} = rpttransaction
      assert rpttransaction.after_disc == "some updated after_disc"
      assert rpttransaction.branchcode == "some updated branchcode"
      assert rpttransaction.branchid == 43
      assert rpttransaction.cash == Decimal.new("456.7")
      assert rpttransaction.changes == Decimal.new("456.7")
      assert rpttransaction.decimal == "some updated decimal"
      assert rpttransaction.grand_total == Decimal.new("456.7")
      assert rpttransaction.gst_charge == "some updated gst_charge"
      assert rpttransaction.invoiceno == "some updated invoiceno"
      assert rpttransaction.is_void == 43
      assert rpttransaction.pax == 43
      assert rpttransaction.payment_type == "some updated payment_type"
      assert rpttransaction.quarter == 43
      assert rpttransaction.remark == "some updated remark"
      assert rpttransaction.rounding == Decimal.new("456.7")
      assert rpttransaction.salesdate == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert rpttransaction.saleshour == 43
      assert rpttransaction.salesid == "some updated salesid"
      assert rpttransaction.salesmonth == 43
      assert rpttransaction.salestime == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert rpttransaction.salesyear == 43
      assert rpttransaction.service_charge == Decimal.new("456.7")
      assert rpttransaction.staffid == 43
      assert rpttransaction.staffname == "some updated staffname"
      assert rpttransaction.sub_total == Decimal.new("456.7")
      assert rpttransaction.tbl_no == 43
      assert rpttransaction.type == "some updated type"
      assert rpttransaction.void_by == "some updated void_by"
      assert rpttransaction.voidreason == "some updated voidreason"
    end

    test "update_rpttransaction/2 with invalid data returns error changeset" do
      rpttransaction = rpttransaction_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_rpttransaction(rpttransaction, @invalid_attrs)
      assert rpttransaction == BN.get_rpttransaction!(rpttransaction.id)
    end

    test "delete_rpttransaction/1 deletes the rpttransaction" do
      rpttransaction = rpttransaction_fixture()
      assert {:ok, %RPTTRANSACTION{}} = BN.delete_rpttransaction(rpttransaction)
      assert_raise Ecto.NoResultsError, fn -> BN.get_rpttransaction!(rpttransaction.id) end
    end

    test "change_rpttransaction/1 returns a rpttransaction changeset" do
      rpttransaction = rpttransaction_fixture()
      assert %Ecto.Changeset{} = BN.change_rpttransaction(rpttransaction)
    end
  end

  describe "salesdetailcust" do
    alias BoatNoodle.BN.SalesDetailCust

    @valid_attrs %{created_at: "2010-04-17 14:00:00.000000Z", custom_name: "some custom_name", customer_price: "120.5", orderid: "some orderid", salescustid: 42, updated_at: "2010-04-17 14:00:00.000000Z"}
    @update_attrs %{created_at: "2011-05-18 15:01:01.000000Z", custom_name: "some updated custom_name", customer_price: "456.7", orderid: "some updated orderid", salescustid: 43, updated_at: "2011-05-18 15:01:01.000000Z"}
    @invalid_attrs %{created_at: nil, custom_name: nil, customer_price: nil, orderid: nil, salescustid: nil, updated_at: nil}

    def sales_detail_cust_fixture(attrs \\ %{}) do
      {:ok, sales_detail_cust} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_sales_detail_cust()

      sales_detail_cust
    end

    test "list_salesdetailcust/0 returns all salesdetailcust" do
      sales_detail_cust = sales_detail_cust_fixture()
      assert BN.list_salesdetailcust() == [sales_detail_cust]
    end

    test "get_sales_detail_cust!/1 returns the sales_detail_cust with given id" do
      sales_detail_cust = sales_detail_cust_fixture()
      assert BN.get_sales_detail_cust!(sales_detail_cust.id) == sales_detail_cust
    end

    test "create_sales_detail_cust/1 with valid data creates a sales_detail_cust" do
      assert {:ok, %SalesDetailCust{} = sales_detail_cust} = BN.create_sales_detail_cust(@valid_attrs)
      assert sales_detail_cust.created_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert sales_detail_cust.custom_name == "some custom_name"
      assert sales_detail_cust.customer_price == Decimal.new("120.5")
      assert sales_detail_cust.orderid == "some orderid"
      assert sales_detail_cust.salescustid == 42
      assert sales_detail_cust.updated_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
    end

    test "create_sales_detail_cust/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_sales_detail_cust(@invalid_attrs)
    end

    test "update_sales_detail_cust/2 with valid data updates the sales_detail_cust" do
      sales_detail_cust = sales_detail_cust_fixture()
      assert {:ok, sales_detail_cust} = BN.update_sales_detail_cust(sales_detail_cust, @update_attrs)
      assert %SalesDetailCust{} = sales_detail_cust
      assert sales_detail_cust.created_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert sales_detail_cust.custom_name == "some updated custom_name"
      assert sales_detail_cust.customer_price == Decimal.new("456.7")
      assert sales_detail_cust.orderid == "some updated orderid"
      assert sales_detail_cust.salescustid == 43
      assert sales_detail_cust.updated_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
    end

    test "update_sales_detail_cust/2 with invalid data returns error changeset" do
      sales_detail_cust = sales_detail_cust_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_sales_detail_cust(sales_detail_cust, @invalid_attrs)
      assert sales_detail_cust == BN.get_sales_detail_cust!(sales_detail_cust.id)
    end

    test "delete_sales_detail_cust/1 deletes the sales_detail_cust" do
      sales_detail_cust = sales_detail_cust_fixture()
      assert {:ok, %SalesDetailCust{}} = BN.delete_sales_detail_cust(sales_detail_cust)
      assert_raise Ecto.NoResultsError, fn -> BN.get_sales_detail_cust!(sales_detail_cust.id) end
    end

    test "change_sales_detail_cust/1 returns a sales_detail_cust changeset" do
      sales_detail_cust = sales_detail_cust_fixture()
      assert %Ecto.Changeset{} = BN.change_sales_detail_cust(sales_detail_cust)
    end
  end

  describe "staff_log_session" do
    alias BoatNoodle.BN.StaffLogSession

    @valid_attrs %{branch_id: 42, id: 42, log_id: 42, log_in: "2010-04-17 14:00:00.000000Z", log_out: "2010-04-17 14:00:00.000000Z", staff_id: 42}
    @update_attrs %{branch_id: 43, id: 43, log_id: 43, log_in: "2011-05-18 15:01:01.000000Z", log_out: "2011-05-18 15:01:01.000000Z", staff_id: 43}
    @invalid_attrs %{branch_id: nil, id: nil, log_id: nil, log_in: nil, log_out: nil, staff_id: nil}

    def staff_log_session_fixture(attrs \\ %{}) do
      {:ok, staff_log_session} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_staff_log_session()

      staff_log_session
    end

    test "list_staff_log_session/0 returns all staff_log_session" do
      staff_log_session = staff_log_session_fixture()
      assert BN.list_staff_log_session() == [staff_log_session]
    end

    test "get_staff_log_session!/1 returns the staff_log_session with given id" do
      staff_log_session = staff_log_session_fixture()
      assert BN.get_staff_log_session!(staff_log_session.id) == staff_log_session
    end

    test "create_staff_log_session/1 with valid data creates a staff_log_session" do
      assert {:ok, %StaffLogSession{} = staff_log_session} = BN.create_staff_log_session(@valid_attrs)
      assert staff_log_session.branch_id == 42
      assert staff_log_session.id == 42
      assert staff_log_session.log_id == 42
      assert staff_log_session.log_in == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert staff_log_session.log_out == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert staff_log_session.staff_id == 42
    end

    test "create_staff_log_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_staff_log_session(@invalid_attrs)
    end

    test "update_staff_log_session/2 with valid data updates the staff_log_session" do
      staff_log_session = staff_log_session_fixture()
      assert {:ok, staff_log_session} = BN.update_staff_log_session(staff_log_session, @update_attrs)
      assert %StaffLogSession{} = staff_log_session
      assert staff_log_session.branch_id == 43
      assert staff_log_session.id == 43
      assert staff_log_session.log_id == 43
      assert staff_log_session.log_in == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert staff_log_session.log_out == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert staff_log_session.staff_id == 43
    end

    test "update_staff_log_session/2 with invalid data returns error changeset" do
      staff_log_session = staff_log_session_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_staff_log_session(staff_log_session, @invalid_attrs)
      assert staff_log_session == BN.get_staff_log_session!(staff_log_session.id)
    end

    test "delete_staff_log_session/1 deletes the staff_log_session" do
      staff_log_session = staff_log_session_fixture()
      assert {:ok, %StaffLogSession{}} = BN.delete_staff_log_session(staff_log_session)
      assert_raise Ecto.NoResultsError, fn -> BN.get_staff_log_session!(staff_log_session.id) end
    end

    test "change_staff_log_session/1 returns a staff_log_session changeset" do
      staff_log_session = staff_log_session_fixture()
      assert %Ecto.Changeset{} = BN.change_staff_log_session(staff_log_session)
    end
  end

  describe "staff_type" do
    alias BoatNoodle.BN.StaffType

    @valid_attrs %{description: "some description", id: 42, name: "some name"}
    @update_attrs %{description: "some updated description", id: 43, name: "some updated name"}
    @invalid_attrs %{description: nil, id: nil, name: nil}

    def staff_type_fixture(attrs \\ %{}) do
      {:ok, staff_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_staff_type()

      staff_type
    end

    test "list_staff_type/0 returns all staff_type" do
      staff_type = staff_type_fixture()
      assert BN.list_staff_type() == [staff_type]
    end

    test "get_staff_type!/1 returns the staff_type with given id" do
      staff_type = staff_type_fixture()
      assert BN.get_staff_type!(staff_type.id) == staff_type
    end

    test "create_staff_type/1 with valid data creates a staff_type" do
      assert {:ok, %StaffType{} = staff_type} = BN.create_staff_type(@valid_attrs)
      assert staff_type.description == "some description"
      assert staff_type.id == 42
      assert staff_type.name == "some name"
    end

    test "create_staff_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_staff_type(@invalid_attrs)
    end

    test "update_staff_type/2 with valid data updates the staff_type" do
      staff_type = staff_type_fixture()
      assert {:ok, staff_type} = BN.update_staff_type(staff_type, @update_attrs)
      assert %StaffType{} = staff_type
      assert staff_type.description == "some updated description"
      assert staff_type.id == 43
      assert staff_type.name == "some updated name"
    end

    test "update_staff_type/2 with invalid data returns error changeset" do
      staff_type = staff_type_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_staff_type(staff_type, @invalid_attrs)
      assert staff_type == BN.get_staff_type!(staff_type.id)
    end

    test "delete_staff_type/1 deletes the staff_type" do
      staff_type = staff_type_fixture()
      assert {:ok, %StaffType{}} = BN.delete_staff_type(staff_type)
      assert_raise Ecto.NoResultsError, fn -> BN.get_staff_type!(staff_type.id) end
    end

    test "change_staff_type/1 returns a staff_type changeset" do
      staff_type = staff_type_fixture()
      assert %Ecto.Changeset{} = BN.change_staff_type(staff_type)
    end
  end

  describe "user_branch_access" do
    alias BoatNoodle.BN.UserBranchAccess

    @valid_attrs %{branchid: 42, userbranchid: 42, userid: 42}
    @update_attrs %{branchid: 43, userbranchid: 43, userid: 43}
    @invalid_attrs %{branchid: nil, userbranchid: nil, userid: nil}

    def user_branch_access_fixture(attrs \\ %{}) do
      {:ok, user_branch_access} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_user_branch_access()

      user_branch_access
    end

    test "list_user_branch_access/0 returns all user_branch_access" do
      user_branch_access = user_branch_access_fixture()
      assert BN.list_user_branch_access() == [user_branch_access]
    end

    test "get_user_branch_access!/1 returns the user_branch_access with given id" do
      user_branch_access = user_branch_access_fixture()
      assert BN.get_user_branch_access!(user_branch_access.id) == user_branch_access
    end

    test "create_user_branch_access/1 with valid data creates a user_branch_access" do
      assert {:ok, %UserBranchAccess{} = user_branch_access} = BN.create_user_branch_access(@valid_attrs)
      assert user_branch_access.branchid == 42
      assert user_branch_access.userbranchid == 42
      assert user_branch_access.userid == 42
    end

    test "create_user_branch_access/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_user_branch_access(@invalid_attrs)
    end

    test "update_user_branch_access/2 with valid data updates the user_branch_access" do
      user_branch_access = user_branch_access_fixture()
      assert {:ok, user_branch_access} = BN.update_user_branch_access(user_branch_access, @update_attrs)
      assert %UserBranchAccess{} = user_branch_access
      assert user_branch_access.branchid == 43
      assert user_branch_access.userbranchid == 43
      assert user_branch_access.userid == 43
    end

    test "update_user_branch_access/2 with invalid data returns error changeset" do
      user_branch_access = user_branch_access_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_user_branch_access(user_branch_access, @invalid_attrs)
      assert user_branch_access == BN.get_user_branch_access!(user_branch_access.id)
    end

    test "delete_user_branch_access/1 deletes the user_branch_access" do
      user_branch_access = user_branch_access_fixture()
      assert {:ok, %UserBranchAccess{}} = BN.delete_user_branch_access(user_branch_access)
      assert_raise Ecto.NoResultsError, fn -> BN.get_user_branch_access!(user_branch_access.id) end
    end

    test "change_user_branch_access/1 returns a user_branch_access changeset" do
      user_branch_access = user_branch_access_fixture()
      assert %Ecto.Changeset{} = BN.change_user_branch_access(user_branch_access)
    end
  end

  describe "user_pwd" do
    alias BoatNoodle.BN.UserPwd

    @valid_attrs %{name: "some name", pass: "some pass"}
    @update_attrs %{name: "some updated name", pass: "some updated pass"}
    @invalid_attrs %{name: nil, pass: nil}

    def user_pwd_fixture(attrs \\ %{}) do
      {:ok, user_pwd} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_user_pwd()

      user_pwd
    end

    test "list_user_pwd/0 returns all user_pwd" do
      user_pwd = user_pwd_fixture()
      assert BN.list_user_pwd() == [user_pwd]
    end

    test "get_user_pwd!/1 returns the user_pwd with given id" do
      user_pwd = user_pwd_fixture()
      assert BN.get_user_pwd!(user_pwd.id) == user_pwd
    end

    test "create_user_pwd/1 with valid data creates a user_pwd" do
      assert {:ok, %UserPwd{} = user_pwd} = BN.create_user_pwd(@valid_attrs)
      assert user_pwd.name == "some name"
      assert user_pwd.pass == "some pass"
    end

    test "create_user_pwd/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_user_pwd(@invalid_attrs)
    end

    test "update_user_pwd/2 with valid data updates the user_pwd" do
      user_pwd = user_pwd_fixture()
      assert {:ok, user_pwd} = BN.update_user_pwd(user_pwd, @update_attrs)
      assert %UserPwd{} = user_pwd
      assert user_pwd.name == "some updated name"
      assert user_pwd.pass == "some updated pass"
    end

    test "update_user_pwd/2 with invalid data returns error changeset" do
      user_pwd = user_pwd_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_user_pwd(user_pwd, @invalid_attrs)
      assert user_pwd == BN.get_user_pwd!(user_pwd.id)
    end

    test "delete_user_pwd/1 deletes the user_pwd" do
      user_pwd = user_pwd_fixture()
      assert {:ok, %UserPwd{}} = BN.delete_user_pwd(user_pwd)
      assert_raise Ecto.NoResultsError, fn -> BN.get_user_pwd!(user_pwd.id) end
    end

    test "change_user_pwd/1 returns a user_pwd changeset" do
      user_pwd = user_pwd_fixture()
      assert %Ecto.Changeset{} = BN.change_user_pwd(user_pwd)
    end
  end

  describe "user_role" do
    alias BoatNoodle.BN.UserRole

    @valid_attrs %{role_desc: "some role_desc", role_name: "some role_name", roleid: 42}
    @update_attrs %{role_desc: "some updated role_desc", role_name: "some updated role_name", roleid: 43}
    @invalid_attrs %{role_desc: nil, role_name: nil, roleid: nil}

    def user_role_fixture(attrs \\ %{}) do
      {:ok, user_role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_user_role()

      user_role
    end

    test "list_user_role/0 returns all user_role" do
      user_role = user_role_fixture()
      assert BN.list_user_role() == [user_role]
    end

    test "get_user_role!/1 returns the user_role with given id" do
      user_role = user_role_fixture()
      assert BN.get_user_role!(user_role.id) == user_role
    end

    test "create_user_role/1 with valid data creates a user_role" do
      assert {:ok, %UserRole{} = user_role} = BN.create_user_role(@valid_attrs)
      assert user_role.role_desc == "some role_desc"
      assert user_role.role_name == "some role_name"
      assert user_role.roleid == 42
    end

    test "create_user_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_user_role(@invalid_attrs)
    end

    test "update_user_role/2 with valid data updates the user_role" do
      user_role = user_role_fixture()
      assert {:ok, user_role} = BN.update_user_role(user_role, @update_attrs)
      assert %UserRole{} = user_role
      assert user_role.role_desc == "some updated role_desc"
      assert user_role.role_name == "some updated role_name"
      assert user_role.roleid == 43
    end

    test "update_user_role/2 with invalid data returns error changeset" do
      user_role = user_role_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_user_role(user_role, @invalid_attrs)
      assert user_role == BN.get_user_role!(user_role.id)
    end

    test "delete_user_role/1 deletes the user_role" do
      user_role = user_role_fixture()
      assert {:ok, %UserRole{}} = BN.delete_user_role(user_role)
      assert_raise Ecto.NoResultsError, fn -> BN.get_user_role!(user_role.id) end
    end

    test "change_user_role/1 returns a user_role changeset" do
      user_role = user_role_fixture()
      assert %Ecto.Changeset{} = BN.change_user_role(user_role)
    end
  end

  describe "voiditems" do
    alias BoatNoodle.BN.VoidItems

    @valid_attrs %{discount: 120.5, discountitemsid: 42, displayprice: "some displayprice", is_print: 42, is_void: 42, itemcode: "some itemcode", itemid: 42, itemname: "some itemname", itempriceperqty: "120.5", orderid: "some orderid", price: "120.5", priceafterdiscount: "120.5", qtyafterdisc: 42, quantity: 42, remark: "some remark", tableid: 42, takeawayid: "some takeawayid", void_by: 42, voidreason: "some voidreason"}
    @update_attrs %{discount: 456.7, discountitemsid: 43, displayprice: "some updated displayprice", is_print: 43, is_void: 43, itemcode: "some updated itemcode", itemid: 43, itemname: "some updated itemname", itempriceperqty: "456.7", orderid: "some updated orderid", price: "456.7", priceafterdiscount: "456.7", qtyafterdisc: 43, quantity: 43, remark: "some updated remark", tableid: 43, takeawayid: "some updated takeawayid", void_by: 43, voidreason: "some updated voidreason"}
    @invalid_attrs %{discount: nil, discountitemsid: nil, displayprice: nil, is_print: nil, is_void: nil, itemcode: nil, itemid: nil, itemname: nil, itempriceperqty: nil, orderid: nil, price: nil, priceafterdiscount: nil, qtyafterdisc: nil, quantity: nil, remark: nil, tableid: nil, takeawayid: nil, void_by: nil, voidreason: nil}

    def void_items_fixture(attrs \\ %{}) do
      {:ok, void_items} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_void_items()

      void_items
    end

    test "list_voiditems/0 returns all voiditems" do
      void_items = void_items_fixture()
      assert BN.list_voiditems() == [void_items]
    end

    test "get_void_items!/1 returns the void_items with given id" do
      void_items = void_items_fixture()
      assert BN.get_void_items!(void_items.id) == void_items
    end

    test "create_void_items/1 with valid data creates a void_items" do
      assert {:ok, %VoidItems{} = void_items} = BN.create_void_items(@valid_attrs)
      assert void_items.discount == 120.5
      assert void_items.discountitemsid == 42
      assert void_items.displayprice == "some displayprice"
      assert void_items.is_print == 42
      assert void_items.is_void == 42
      assert void_items.itemcode == "some itemcode"
      assert void_items.itemid == 42
      assert void_items.itemname == "some itemname"
      assert void_items.itempriceperqty == Decimal.new("120.5")
      assert void_items.orderid == "some orderid"
      assert void_items.price == Decimal.new("120.5")
      assert void_items.priceafterdiscount == Decimal.new("120.5")
      assert void_items.qtyafterdisc == 42
      assert void_items.quantity == 42
      assert void_items.remark == "some remark"
      assert void_items.tableid == 42
      assert void_items.takeawayid == "some takeawayid"
      assert void_items.void_by == 42
      assert void_items.voidreason == "some voidreason"
    end

    test "create_void_items/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_void_items(@invalid_attrs)
    end

    test "update_void_items/2 with valid data updates the void_items" do
      void_items = void_items_fixture()
      assert {:ok, void_items} = BN.update_void_items(void_items, @update_attrs)
      assert %VoidItems{} = void_items
      assert void_items.discount == 456.7
      assert void_items.discountitemsid == 43
      assert void_items.displayprice == "some updated displayprice"
      assert void_items.is_print == 43
      assert void_items.is_void == 43
      assert void_items.itemcode == "some updated itemcode"
      assert void_items.itemid == 43
      assert void_items.itemname == "some updated itemname"
      assert void_items.itempriceperqty == Decimal.new("456.7")
      assert void_items.orderid == "some updated orderid"
      assert void_items.price == Decimal.new("456.7")
      assert void_items.priceafterdiscount == Decimal.new("456.7")
      assert void_items.qtyafterdisc == 43
      assert void_items.quantity == 43
      assert void_items.remark == "some updated remark"
      assert void_items.tableid == 43
      assert void_items.takeawayid == "some updated takeawayid"
      assert void_items.void_by == 43
      assert void_items.voidreason == "some updated voidreason"
    end

    test "update_void_items/2 with invalid data returns error changeset" do
      void_items = void_items_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_void_items(void_items, @invalid_attrs)
      assert void_items == BN.get_void_items!(void_items.id)
    end

    test "delete_void_items/1 deletes the void_items" do
      void_items = void_items_fixture()
      assert {:ok, %VoidItems{}} = BN.delete_void_items(void_items)
      assert_raise Ecto.NoResultsError, fn -> BN.get_void_items!(void_items.id) end
    end

    test "change_void_items/1 returns a void_items changeset" do
      void_items = void_items_fixture()
      assert %Ecto.Changeset{} = BN.change_void_items(void_items)
    end
  end

  describe "salespayment" do
    alias BoatNoodle.BN.SalesPayment

    @valid_attrs %{after_disc: "120.5", card_no: 42, cash: "120.5", changes: "120.5", created_at: "2010-04-17 14:00:00.000000Z", disc_amt: "120.5", discountid: "some discountid", grand_total: "120.5", gst_charge: "120.5", payment_code1: "some payment_code1", payment_code2: "some payment_code2", payment_type: "some payment_type", payment_type_am1: "120.5", payment_type_am2: "120.5", payment_type_id1: 42, payment_type_id2: 42, rounding: "120.5", salesid: "some salesid", salespay_id: 42, service_charge: "120.5", sub_total: "120.5", taxcode: "some taxcode", updated_at: "2010-04-17 14:00:00.000000Z", voucher_code: "some voucher_code"}
    @update_attrs %{after_disc: "456.7", card_no: 43, cash: "456.7", changes: "456.7", created_at: "2011-05-18 15:01:01.000000Z", disc_amt: "456.7", discountid: "some updated discountid", grand_total: "456.7", gst_charge: "456.7", payment_code1: "some updated payment_code1", payment_code2: "some updated payment_code2", payment_type: "some updated payment_type", payment_type_am1: "456.7", payment_type_am2: "456.7", payment_type_id1: 43, payment_type_id2: 43, rounding: "456.7", salesid: "some updated salesid", salespay_id: 43, service_charge: "456.7", sub_total: "456.7", taxcode: "some updated taxcode", updated_at: "2011-05-18 15:01:01.000000Z", voucher_code: "some updated voucher_code"}
    @invalid_attrs %{after_disc: nil, card_no: nil, cash: nil, changes: nil, created_at: nil, disc_amt: nil, discountid: nil, grand_total: nil, gst_charge: nil, payment_code1: nil, payment_code2: nil, payment_type: nil, payment_type_am1: nil, payment_type_am2: nil, payment_type_id1: nil, payment_type_id2: nil, rounding: nil, salesid: nil, salespay_id: nil, service_charge: nil, sub_total: nil, taxcode: nil, updated_at: nil, voucher_code: nil}

    def sales_payment_fixture(attrs \\ %{}) do
      {:ok, sales_payment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_sales_payment()

      sales_payment
    end

    test "list_salespayment/0 returns all salespayment" do
      sales_payment = sales_payment_fixture()
      assert BN.list_salespayment() == [sales_payment]
    end

    test "get_sales_payment!/1 returns the sales_payment with given id" do
      sales_payment = sales_payment_fixture()
      assert BN.get_sales_payment!(sales_payment.id) == sales_payment
    end

    test "create_sales_payment/1 with valid data creates a sales_payment" do
      assert {:ok, %SalesPayment{} = sales_payment} = BN.create_sales_payment(@valid_attrs)
      assert sales_payment.after_disc == Decimal.new("120.5")
      assert sales_payment.card_no == 42
      assert sales_payment.cash == Decimal.new("120.5")
      assert sales_payment.changes == Decimal.new("120.5")
      assert sales_payment.created_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert sales_payment.disc_amt == Decimal.new("120.5")
      assert sales_payment.discountid == "some discountid"
      assert sales_payment.grand_total == Decimal.new("120.5")
      assert sales_payment.gst_charge == Decimal.new("120.5")
      assert sales_payment.payment_code1 == "some payment_code1"
      assert sales_payment.payment_code2 == "some payment_code2"
      assert sales_payment.payment_type == "some payment_type"
      assert sales_payment.payment_type_am1 == Decimal.new("120.5")
      assert sales_payment.payment_type_am2 == Decimal.new("120.5")
      assert sales_payment.payment_type_id1 == 42
      assert sales_payment.payment_type_id2 == 42
      assert sales_payment.rounding == Decimal.new("120.5")
      assert sales_payment.salesid == "some salesid"
      assert sales_payment.salespay_id == 42
      assert sales_payment.service_charge == Decimal.new("120.5")
      assert sales_payment.sub_total == Decimal.new("120.5")
      assert sales_payment.taxcode == "some taxcode"
      assert sales_payment.updated_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert sales_payment.voucher_code == "some voucher_code"
    end

    test "create_sales_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_sales_payment(@invalid_attrs)
    end

    test "update_sales_payment/2 with valid data updates the sales_payment" do
      sales_payment = sales_payment_fixture()
      assert {:ok, sales_payment} = BN.update_sales_payment(sales_payment, @update_attrs)
      assert %SalesPayment{} = sales_payment
      assert sales_payment.after_disc == Decimal.new("456.7")
      assert sales_payment.card_no == 43
      assert sales_payment.cash == Decimal.new("456.7")
      assert sales_payment.changes == Decimal.new("456.7")
      assert sales_payment.created_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert sales_payment.disc_amt == Decimal.new("456.7")
      assert sales_payment.discountid == "some updated discountid"
      assert sales_payment.grand_total == Decimal.new("456.7")
      assert sales_payment.gst_charge == Decimal.new("456.7")
      assert sales_payment.payment_code1 == "some updated payment_code1"
      assert sales_payment.payment_code2 == "some updated payment_code2"
      assert sales_payment.payment_type == "some updated payment_type"
      assert sales_payment.payment_type_am1 == Decimal.new("456.7")
      assert sales_payment.payment_type_am2 == Decimal.new("456.7")
      assert sales_payment.payment_type_id1 == 43
      assert sales_payment.payment_type_id2 == 43
      assert sales_payment.rounding == Decimal.new("456.7")
      assert sales_payment.salesid == "some updated salesid"
      assert sales_payment.salespay_id == 43
      assert sales_payment.service_charge == Decimal.new("456.7")
      assert sales_payment.sub_total == Decimal.new("456.7")
      assert sales_payment.taxcode == "some updated taxcode"
      assert sales_payment.updated_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert sales_payment.voucher_code == "some updated voucher_code"
    end

    test "update_sales_payment/2 with invalid data returns error changeset" do
      sales_payment = sales_payment_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_sales_payment(sales_payment, @invalid_attrs)
      assert sales_payment == BN.get_sales_payment!(sales_payment.id)
    end

    test "delete_sales_payment/1 deletes the sales_payment" do
      sales_payment = sales_payment_fixture()
      assert {:ok, %SalesPayment{}} = BN.delete_sales_payment(sales_payment)
      assert_raise Ecto.NoResultsError, fn -> BN.get_sales_payment!(sales_payment.id) end
    end

    test "change_sales_payment/1 returns a sales_payment changeset" do
      sales_payment = sales_payment_fixture()
      assert %Ecto.Changeset{} = BN.change_sales_payment(sales_payment)
    end
  end

  describe "item_subcat" do
    alias BoatNoodle.BN.ItemSubcat

    @valid_attrs %{created_at: "2010-04-17 14:00:00.000000Z", enable_disc: 42, include_spend: 42, integer: "some integer", is_active: 42, is_categorize: 42, is_combo: 42, is_default_combo: 42, is_delete: 42, is_print: 42, itemcatid: "some itemcatid", itemcode: "some itemcode", itemdesc: "some itemdesc", itemimage: "some itemimage", itemname: "some itemname", itemprice: "120.5", part_code: "some part_code", price_code: "some price_code", product_code: "some product_code", subcatid: "some subcatid", updated_at: "2010-04-17 14:00:00.000000Z"}
    @update_attrs %{created_at: "2011-05-18 15:01:01.000000Z", enable_disc: 43, include_spend: 43, integer: "some updated integer", is_active: 43, is_categorize: 43, is_combo: 43, is_default_combo: 43, is_delete: 43, is_print: 43, itemcatid: "some updated itemcatid", itemcode: "some updated itemcode", itemdesc: "some updated itemdesc", itemimage: "some updated itemimage", itemname: "some updated itemname", itemprice: "456.7", part_code: "some updated part_code", price_code: "some updated price_code", product_code: "some updated product_code", subcatid: "some updated subcatid", updated_at: "2011-05-18 15:01:01.000000Z"}
    @invalid_attrs %{created_at: nil, enable_disc: nil, include_spend: nil, integer: nil, is_active: nil, is_categorize: nil, is_combo: nil, is_default_combo: nil, is_delete: nil, is_print: nil, itemcatid: nil, itemcode: nil, itemdesc: nil, itemimage: nil, itemname: nil, itemprice: nil, part_code: nil, price_code: nil, product_code: nil, subcatid: nil, updated_at: nil}

    def item_subcat_fixture(attrs \\ %{}) do
      {:ok, item_subcat} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_item_subcat()

      item_subcat
    end

    test "list_item_subcat/0 returns all item_subcat" do
      item_subcat = item_subcat_fixture()
      assert BN.list_item_subcat() == [item_subcat]
    end

    test "get_item_subcat!/1 returns the item_subcat with given id" do
      item_subcat = item_subcat_fixture()
      assert BN.get_item_subcat!(item_subcat.id) == item_subcat
    end

    test "create_item_subcat/1 with valid data creates a item_subcat" do
      assert {:ok, %ItemSubcat{} = item_subcat} = BN.create_item_subcat(@valid_attrs)
      assert item_subcat.created_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert item_subcat.enable_disc == 42
      assert item_subcat.include_spend == 42
      assert item_subcat.integer == "some integer"
      assert item_subcat.is_active == 42
      assert item_subcat.is_categorize == 42
      assert item_subcat.is_combo == 42
      assert item_subcat.is_default_combo == 42
      assert item_subcat.is_delete == 42
      assert item_subcat.is_print == 42
      assert item_subcat.itemcatid == "some itemcatid"
      assert item_subcat.itemcode == "some itemcode"
      assert item_subcat.itemdesc == "some itemdesc"
      assert item_subcat.itemimage == "some itemimage"
      assert item_subcat.itemname == "some itemname"
      assert item_subcat.itemprice == Decimal.new("120.5")
      assert item_subcat.part_code == "some part_code"
      assert item_subcat.price_code == "some price_code"
      assert item_subcat.product_code == "some product_code"
      assert item_subcat.subcatid == "some subcatid"
      assert item_subcat.updated_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
    end

    test "create_item_subcat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_item_subcat(@invalid_attrs)
    end

    test "update_item_subcat/2 with valid data updates the item_subcat" do
      item_subcat = item_subcat_fixture()
      assert {:ok, item_subcat} = BN.update_item_subcat(item_subcat, @update_attrs)
      assert %ItemSubcat{} = item_subcat
      assert item_subcat.created_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert item_subcat.enable_disc == 43
      assert item_subcat.include_spend == 43
      assert item_subcat.integer == "some updated integer"
      assert item_subcat.is_active == 43
      assert item_subcat.is_categorize == 43
      assert item_subcat.is_combo == 43
      assert item_subcat.is_default_combo == 43
      assert item_subcat.is_delete == 43
      assert item_subcat.is_print == 43
      assert item_subcat.itemcatid == "some updated itemcatid"
      assert item_subcat.itemcode == "some updated itemcode"
      assert item_subcat.itemdesc == "some updated itemdesc"
      assert item_subcat.itemimage == "some updated itemimage"
      assert item_subcat.itemname == "some updated itemname"
      assert item_subcat.itemprice == Decimal.new("456.7")
      assert item_subcat.part_code == "some updated part_code"
      assert item_subcat.price_code == "some updated price_code"
      assert item_subcat.product_code == "some updated product_code"
      assert item_subcat.subcatid == "some updated subcatid"
      assert item_subcat.updated_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
    end

    test "update_item_subcat/2 with invalid data returns error changeset" do
      item_subcat = item_subcat_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_item_subcat(item_subcat, @invalid_attrs)
      assert item_subcat == BN.get_item_subcat!(item_subcat.id)
    end

    test "delete_item_subcat/1 deletes the item_subcat" do
      item_subcat = item_subcat_fixture()
      assert {:ok, %ItemSubcat{}} = BN.delete_item_subcat(item_subcat)
      assert_raise Ecto.NoResultsError, fn -> BN.get_item_subcat!(item_subcat.id) end
    end

    test "change_item_subcat/1 returns a item_subcat changeset" do
      item_subcat = item_subcat_fixture()
      assert %Ecto.Changeset{} = BN.change_item_subcat(item_subcat)
    end
  end

  describe "itemcat" do
    alias BoatNoodle.BN.ItemCat

    @valid_attrs %{category_type: "some category_type", created_at: "2010-04-17 14:00:00.000000Z", is_default: 42, is_delete: 42, itemcatcode: "some itemcatcode", itemcatdesc: "some itemcatdesc", itemcatid: 42, itemcatname: "some itemcatname", updated_at: "2010-04-17 14:00:00.000000Z"}
    @update_attrs %{category_type: "some updated category_type", created_at: "2011-05-18 15:01:01.000000Z", is_default: 43, is_delete: 43, itemcatcode: "some updated itemcatcode", itemcatdesc: "some updated itemcatdesc", itemcatid: 43, itemcatname: "some updated itemcatname", updated_at: "2011-05-18 15:01:01.000000Z"}
    @invalid_attrs %{category_type: nil, created_at: nil, is_default: nil, is_delete: nil, itemcatcode: nil, itemcatdesc: nil, itemcatid: nil, itemcatname: nil, updated_at: nil}

    def item_cat_fixture(attrs \\ %{}) do
      {:ok, item_cat} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_item_cat()

      item_cat
    end

    test "list_itemcat/0 returns all itemcat" do
      item_cat = item_cat_fixture()
      assert BN.list_itemcat() == [item_cat]
    end

    test "get_item_cat!/1 returns the item_cat with given id" do
      item_cat = item_cat_fixture()
      assert BN.get_item_cat!(item_cat.id) == item_cat
    end

    test "create_item_cat/1 with valid data creates a item_cat" do
      assert {:ok, %ItemCat{} = item_cat} = BN.create_item_cat(@valid_attrs)
      assert item_cat.category_type == "some category_type"
      assert item_cat.created_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert item_cat.is_default == 42
      assert item_cat.is_delete == 42
      assert item_cat.itemcatcode == "some itemcatcode"
      assert item_cat.itemcatdesc == "some itemcatdesc"
      assert item_cat.itemcatid == 42
      assert item_cat.itemcatname == "some itemcatname"
      assert item_cat.updated_at == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
    end

    test "create_item_cat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_item_cat(@invalid_attrs)
    end

    test "update_item_cat/2 with valid data updates the item_cat" do
      item_cat = item_cat_fixture()
      assert {:ok, item_cat} = BN.update_item_cat(item_cat, @update_attrs)
      assert %ItemCat{} = item_cat
      assert item_cat.category_type == "some updated category_type"
      assert item_cat.created_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert item_cat.is_default == 43
      assert item_cat.is_delete == 43
      assert item_cat.itemcatcode == "some updated itemcatcode"
      assert item_cat.itemcatdesc == "some updated itemcatdesc"
      assert item_cat.itemcatid == 43
      assert item_cat.itemcatname == "some updated itemcatname"
      assert item_cat.updated_at == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
    end

    test "update_item_cat/2 with invalid data returns error changeset" do
      item_cat = item_cat_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_item_cat(item_cat, @invalid_attrs)
      assert item_cat == BN.get_item_cat!(item_cat.id)
    end

    test "delete_item_cat/1 deletes the item_cat" do
      item_cat = item_cat_fixture()
      assert {:ok, %ItemCat{}} = BN.delete_item_cat(item_cat)
      assert_raise Ecto.NoResultsError, fn -> BN.get_item_cat!(item_cat.id) end
    end

    test "change_item_cat/1 returns a item_cat changeset" do
      item_cat = item_cat_fixture()
      assert %Ecto.Changeset{} = BN.change_item_cat(item_cat)
    end
  end

  describe "discount" do
    alias BoatNoodle.BN.Discount

    @valid_attrs %{descriptions: "some descriptions", disc_qty: 42, discamtpercentage: "120.5", discname: "some discname", discount_id: 42, disctype: "some disctype", is_categorize: 42, is_delete: 42, is_used: 42, is_visible: 42, targer_itemcode: "some targer_itemcode", target_cat: 42}
    @update_attrs %{descriptions: "some updated descriptions", disc_qty: 43, discamtpercentage: "456.7", discname: "some updated discname", discount_id: 43, disctype: "some updated disctype", is_categorize: 43, is_delete: 43, is_used: 43, is_visible: 43, targer_itemcode: "some updated targer_itemcode", target_cat: 43}
    @invalid_attrs %{descriptions: nil, disc_qty: nil, discamtpercentage: nil, discname: nil, discount_id: nil, disctype: nil, is_categorize: nil, is_delete: nil, is_used: nil, is_visible: nil, targer_itemcode: nil, target_cat: nil}

    def discount_fixture(attrs \\ %{}) do
      {:ok, discount} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_discount()

      discount
    end

    test "list_discount/0 returns all discount" do
      discount = discount_fixture()
      assert BN.list_discount() == [discount]
    end

    test "get_discount!/1 returns the discount with given id" do
      discount = discount_fixture()
      assert BN.get_discount!(discount.id) == discount
    end

    test "create_discount/1 with valid data creates a discount" do
      assert {:ok, %Discount{} = discount} = BN.create_discount(@valid_attrs)
      assert discount.descriptions == "some descriptions"
      assert discount.disc_qty == 42
      assert discount.discamtpercentage == Decimal.new("120.5")
      assert discount.discname == "some discname"
      assert discount.discount_id == 42
      assert discount.disctype == "some disctype"
      assert discount.is_categorize == 42
      assert discount.is_delete == 42
      assert discount.is_used == 42
      assert discount.is_visible == 42
      assert discount.targer_itemcode == "some targer_itemcode"
      assert discount.target_cat == 42
    end

    test "create_discount/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_discount(@invalid_attrs)
    end

    test "update_discount/2 with valid data updates the discount" do
      discount = discount_fixture()
      assert {:ok, discount} = BN.update_discount(discount, @update_attrs)
      assert %Discount{} = discount
      assert discount.descriptions == "some updated descriptions"
      assert discount.disc_qty == 43
      assert discount.discamtpercentage == Decimal.new("456.7")
      assert discount.discname == "some updated discname"
      assert discount.discount_id == 43
      assert discount.disctype == "some updated disctype"
      assert discount.is_categorize == 43
      assert discount.is_delete == 43
      assert discount.is_used == 43
      assert discount.is_visible == 43
      assert discount.targer_itemcode == "some updated targer_itemcode"
      assert discount.target_cat == 43
    end

    test "update_discount/2 with invalid data returns error changeset" do
      discount = discount_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_discount(discount, @invalid_attrs)
      assert discount == BN.get_discount!(discount.id)
    end

    test "delete_discount/1 deletes the discount" do
      discount = discount_fixture()
      assert {:ok, %Discount{}} = BN.delete_discount(discount)
      assert_raise Ecto.NoResultsError, fn -> BN.get_discount!(discount.id) end
    end

    test "change_discount/1 returns a discount changeset" do
      discount = discount_fixture()
      assert %Ecto.Changeset{} = BN.change_discount(discount)
    end
  end

  describe "brand" do
    alias BoatNoodle.Bn.Brand

    @valid_attrs %{"": "some ", ",": "some ,", bin: "some bin", domain_name: "some domain_name", name: "some name"}
    @update_attrs %{"": "some updated ", ",": "some updated ,", bin: "some updated bin", domain_name: "some updated domain_name", name: "some updated name"}
    @invalid_attrs %{"": nil, ",": nil, bin: nil, domain_name: nil, name: nil}

    def brand_fixture(attrs \\ %{}) do
      {:ok, brand} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bn.create_brand()

      brand
    end

    test "list_brand/0 returns all brand" do
      brand = brand_fixture()
      assert Bn.list_brand() == [brand]
    end

    test "get_brand!/1 returns the brand with given id" do
      brand = brand_fixture()
      assert Bn.get_brand!(brand.id) == brand
    end

    test "create_brand/1 with valid data creates a brand" do
      assert {:ok, %Brand{} = brand} = Bn.create_brand(@valid_attrs)
      assert brand. == "some "
      assert brand., == "some ,"
      assert brand.bin == "some bin"
      assert brand.domain_name == "some domain_name"
      assert brand.name == "some name"
    end

    test "create_brand/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bn.create_brand(@invalid_attrs)
    end

    test "update_brand/2 with valid data updates the brand" do
      brand = brand_fixture()
      assert {:ok, brand} = Bn.update_brand(brand, @update_attrs)
      assert %Brand{} = brand
      assert brand. == "some updated "
      assert brand., == "some updated ,"
      assert brand.bin == "some updated bin"
      assert brand.domain_name == "some updated domain_name"
      assert brand.name == "some updated name"
    end

    test "update_brand/2 with invalid data returns error changeset" do
      brand = brand_fixture()
      assert {:error, %Ecto.Changeset{}} = Bn.update_brand(brand, @invalid_attrs)
      assert brand == Bn.get_brand!(brand.id)
    end

    test "delete_brand/1 deletes the brand" do
      brand = brand_fixture()
      assert {:ok, %Brand{}} = Bn.delete_brand(brand)
      assert_raise Ecto.NoResultsError, fn -> Bn.get_brand!(brand.id) end
    end

    test "change_brand/1 returns a brand changeset" do
      brand = brand_fixture()
      assert %Ecto.Changeset{} = Bn.change_brand(brand)
    end
  end

  describe "brand" do
    alias BoatNoodle.Bn.Brand

    @valid_attrs %{bin: "some bin", domain_name: "some domain_name", name: "some name"}
    @update_attrs %{bin: "some updated bin", domain_name: "some updated domain_name", name: "some updated name"}
    @invalid_attrs %{bin: nil, domain_name: nil, name: nil}

    def brand_fixture(attrs \\ %{}) do
      {:ok, brand} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Bn.create_brand()

      brand
    end

    test "list_brand/0 returns all brand" do
      brand = brand_fixture()
      assert Bn.list_brand() == [brand]
    end

    test "get_brand!/1 returns the brand with given id" do
      brand = brand_fixture()
      assert Bn.get_brand!(brand.id) == brand
    end

    test "create_brand/1 with valid data creates a brand" do
      assert {:ok, %Brand{} = brand} = Bn.create_brand(@valid_attrs)
      assert brand.bin == "some bin"
      assert brand.domain_name == "some domain_name"
      assert brand.name == "some name"
    end

    test "create_brand/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bn.create_brand(@invalid_attrs)
    end

    test "update_brand/2 with valid data updates the brand" do
      brand = brand_fixture()
      assert {:ok, brand} = Bn.update_brand(brand, @update_attrs)
      assert %Brand{} = brand
      assert brand.bin == "some updated bin"
      assert brand.domain_name == "some updated domain_name"
      assert brand.name == "some updated name"
    end

    test "update_brand/2 with invalid data returns error changeset" do
      brand = brand_fixture()
      assert {:error, %Ecto.Changeset{}} = Bn.update_brand(brand, @invalid_attrs)
      assert brand == Bn.get_brand!(brand.id)
    end

    test "delete_brand/1 deletes the brand" do
      brand = brand_fixture()
      assert {:ok, %Brand{}} = Bn.delete_brand(brand)
      assert_raise Ecto.NoResultsError, fn -> Bn.get_brand!(brand.id) end
    end

    test "change_brand/1 returns a brand changeset" do
      brand = brand_fixture()
      assert %Ecto.Changeset{} = Bn.change_brand(brand)
    end
  end

  describe "api_log" do
    alias BoatNoodle.BN.ApiLog

    @valid_attrs %{message: "some message"}
    @update_attrs %{message: "some updated message"}
    @invalid_attrs %{message: nil}

    def api_log_fixture(attrs \\ %{}) do
      {:ok, api_log} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_api_log()

      api_log
    end

    test "list_api_log/0 returns all api_log" do
      api_log = api_log_fixture()
      assert BN.list_api_log() == [api_log]
    end

    test "get_api_log!/1 returns the api_log with given id" do
      api_log = api_log_fixture()
      assert BN.get_api_log!(api_log.id) == api_log
    end

    test "create_api_log/1 with valid data creates a api_log" do
      assert {:ok, %ApiLog{} = api_log} = BN.create_api_log(@valid_attrs)
      assert api_log.message == "some message"
    end

    test "create_api_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_api_log(@invalid_attrs)
    end

    test "update_api_log/2 with valid data updates the api_log" do
      api_log = api_log_fixture()
      assert {:ok, api_log} = BN.update_api_log(api_log, @update_attrs)
      assert %ApiLog{} = api_log
      assert api_log.message == "some updated message"
    end

    test "update_api_log/2 with invalid data returns error changeset" do
      api_log = api_log_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_api_log(api_log, @invalid_attrs)
      assert api_log == BN.get_api_log!(api_log.id)
    end

    test "delete_api_log/1 deletes the api_log" do
      api_log = api_log_fixture()
      assert {:ok, %ApiLog{}} = BN.delete_api_log(api_log)
      assert_raise Ecto.NoResultsError, fn -> BN.get_api_log!(api_log.id) end
    end

    test "change_api_log/1 returns a api_log changeset" do
      api_log = api_log_fixture()
      assert %Ecto.Changeset{} = BN.change_api_log(api_log)
    end
  end

  describe "vouchers" do
    alias BoatNoodle.BN.Voucher

    @valid_attrs %{branchid: 42, code_number: "some code_number", discount_name: "some discount_name", is_used: true}
    @update_attrs %{branchid: 43, code_number: "some updated code_number", discount_name: "some updated discount_name", is_used: false}
    @invalid_attrs %{branchid: nil, code_number: nil, discount_name: nil, is_used: nil}

    def voucher_fixture(attrs \\ %{}) do
      {:ok, voucher} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BN.create_voucher()

      voucher
    end

    test "list_vouchers/0 returns all vouchers" do
      voucher = voucher_fixture()
      assert BN.list_vouchers() == [voucher]
    end

    test "get_voucher!/1 returns the voucher with given id" do
      voucher = voucher_fixture()
      assert BN.get_voucher!(voucher.id) == voucher
    end

    test "create_voucher/1 with valid data creates a voucher" do
      assert {:ok, %Voucher{} = voucher} = BN.create_voucher(@valid_attrs)
      assert voucher.branchid == 42
      assert voucher.code_number == "some code_number"
      assert voucher.discount_name == "some discount_name"
      assert voucher.is_used == true
    end

    test "create_voucher/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BN.create_voucher(@invalid_attrs)
    end

    test "update_voucher/2 with valid data updates the voucher" do
      voucher = voucher_fixture()
      assert {:ok, voucher} = BN.update_voucher(voucher, @update_attrs)
      assert %Voucher{} = voucher
      assert voucher.branchid == 43
      assert voucher.code_number == "some updated code_number"
      assert voucher.discount_name == "some updated discount_name"
      assert voucher.is_used == false
    end

    test "update_voucher/2 with invalid data returns error changeset" do
      voucher = voucher_fixture()
      assert {:error, %Ecto.Changeset{}} = BN.update_voucher(voucher, @invalid_attrs)
      assert voucher == BN.get_voucher!(voucher.id)
    end

    test "delete_voucher/1 deletes the voucher" do
      voucher = voucher_fixture()
      assert {:ok, %Voucher{}} = BN.delete_voucher(voucher)
      assert_raise Ecto.NoResultsError, fn -> BN.get_voucher!(voucher.id) end
    end

    test "change_voucher/1 returns a voucher changeset" do
      voucher = voucher_fixture()
      assert %Ecto.Changeset{} = BN.change_voucher(voucher)
    end
  end
end
