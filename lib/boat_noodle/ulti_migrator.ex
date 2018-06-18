defmodule BoatNoodle.UltiMigrator do
  use Task

  @migration_modules [
    {0, AddBrand},
    {1, AddBrand2},
    {2, AddBrand3},
    {3, AddBrand4}
  ]

  require IEx

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(arg) do
    versions = Ecto.Migrator.migrated_versions(BoatNoodle.Repo)
    # IEx.pry()
    Ecto.Migrator.run(BoatNoodle.Repo, @migration_modules, :up, all: true)
  end
end

# migrate the new items

defmodule AddBrand4 do
  use Ecto.Migration

  def change do
    # execute("ALTER TABLE `branch` DROP PRIMARY KEY, ADD PRIMARY KEY (`branchid`, `brand_id`);")

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

    alter table(:branch) do
      # remove(:brand_id)

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
  end
end

defmodule AddBrand2 do
  use Ecto.Migration

  def change do
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
