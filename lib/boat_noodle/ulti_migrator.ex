defmodule BoatNoodle.UltiMigrator do
  use Task
  require IEx
  import Ecto.Query

  @migration_modules [
    {0, AddBrand},
    {1, AddBrand2},
    {2, AddBrand3},
    {3, AddBrand4}
  ]

  def add_brand(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def migrate(arg) do
    Task.start_link(__MODULE__, :migrate_new, [arg])
  end

  def run(arg) do
    case arg do
      "boat_noodle" ->
        repo = BoatNoodle.Repo

      "chill_chill" ->
        repo = BoatNoodle.RepoChillChill

      _ ->
        repo = nil
    end

    if repo != nil do
      versions = Ecto.Migrator.migrated_versions(repo)

      Ecto.Migrator.run(repo, @migration_modules, :up, all: true)
    else
      IO.puts("unknow database")
    end
  end

  def migrate_new(arg) do
    case arg do
      "boat_noodle" ->
        brand_id = 1

      "chill_chill" ->
        brand_id = 2

      _ ->
        repo = nil
    end

    chill_item_cats =
      BoatNoodle.RepoChillChill.all(from(c in BoatNoodle.BN.ItemCat))
      |> Enum.map(fn x ->
        %{
          brand_id: brand_id,
          itemcatid: x.itemcatid,
          itemcatcode: x.itemcatcode,
          itemcatname: x.itemcatname,
          itemcatdesc: x.itemcatdesc,
          is_default: x.is_default,
          category_type: x.category_type,
          is_delete: x.is_delete
        }
      end)

    batch =
      for chill_item_cat <- chill_item_cats do
        if chill_item_cat.itemcatcode == "" do
          chill_item_cat = Map.put(chill_item_cat, :itemcatcode, "empty")
        end

        cg = BoatNoodle.BN.ItemCat.changeset(%BoatNoodle.BN.ItemCat{}, chill_item_cat)

        case BoatNoodle.Repo.insert(cg) do
          {:ok, item_cat} ->
            item_cat

          {:error, cg} ->
            true
        end
      end

    :ok
  end
end

defmodule AddBrand4 do
  use Ecto.Migration

  def change do
    execute("ALTER TABLE `branch` DROP PRIMARY KEY, ADD PRIMARY KEY (`branchid`, `brand_id`);")

    execute("ALTER TABLE `combo_details` DROP PRIMARY KEY, ADD PRIMARY KEY (`id`, `brand_id`);")

    execute(
      "ALTER TABLE `discount` DROP PRIMARY KEY, ADD PRIMARY KEY (`discountid`, `brand_id`);"
    )

    execute(
      "ALTER TABLE `discount_catalog` DROP PRIMARY KEY, ADD PRIMARY KEY (`id`, `brand_id`);"
    )

    execute(
      "ALTER TABLE `discountitems` DROP PRIMARY KEY, ADD PRIMARY KEY (`discountitemsid`, `brand_id`);"
    )

    execute("ALTER TABLE `item_cat` DROP PRIMARY KEY, ADD PRIMARY KEY (`itemcatid`, `brand_id`);")

    execute(
      "ALTER TABLE `item_subcat` DROP PRIMARY KEY, ADD PRIMARY KEY (`subcatid`, `brand_id`);"
    )

    execute("ALTER TABLE `menu_catalog` DROP PRIMARY KEY, ADD PRIMARY KEY (`id`, `brand_id`);")

    execute("ALTER TABLE `sales` DROP PRIMARY KEY, ADD PRIMARY KEY (`salesid`, `brand_id`);")

    execute(
      "ALTER TABLE `salespayment` DROP PRIMARY KEY, ADD PRIMARY KEY (`salespay_id`, `brand_id`);"
    )

    execute("ALTER TABLE `tag_tbl` DROP PRIMARY KEY, ADD PRIMARY KEY (`tagid`, `brand_id`);")

    # execute("ALTER TABLE `voiditems` DROP PRIMARY KEY, ADD PRIMARY KEY (`branchid`, `brand_id`);")
    execute("ALTER TABLE `staffs` DROP PRIMARY KEY, ADD PRIMARY KEY (`staff_id`, `brand_id`);")

    # execute(
    #   "ALTER TABLE `salesdetail` DROP PRIMARY KEY, ADD PRIMARY KEY (`branchid`, `brand_id`);"
    # )
  end
end

defmodule AddBrand do
  use Ecto.Migration

  def change do
    create table(:brand) do
      add(:name, :string)
      add(:domain_name, :string)

      timestamps()
    end

    create(index(:brand, [:name], unique: true))
    create(index(:brand, [:domain_name], unique: true))
    create(index(:brand, [:name, :domain_name], unique: true))

    execute("ALTER TABLE `brand` CHANGE COLUMN `id` `id` INT NOT NULL AUTO_INCREMENT;")

    execute(
      "INSERT INTO `brand` (`name`, `domain_name`, `inserted_at`, `updated_at`) VALUES ('chill_chill', 'chill_chill', '2018-04-30 21:17:46', '2018-04-30 21:17:46');"
    )
  end
end

defmodule AddBrand2 do
  use Ecto.Migration

  def change do
    alter table(:branch) do
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end

    alter table(:combo_details) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end

    alter table(:discount) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end

    alter table(:discount_catalog) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end

    alter table(:discountitems) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end

    alter table(:item_cat) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end

    alter table(:item_subcat) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end

    alter table(:menu_catalog) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end

    alter table(:sales) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end

    alter table(:salespayment) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end

    alter table(:tag_tbl) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end

    alter table(:voiditems) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end

    alter table(:staffs) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end
  end
end

defmodule AddBrand3 do
  use Ecto.Migration

  def change do
    alter table(:salesdetail) do
      # remove(:brand_id)
      add(:brand_id, references(:brand, on_delete: :nothing, type: :integer), default: 1)
    end
  end
end
