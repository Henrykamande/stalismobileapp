var accountsTableSql =
    ''' CREATE TABLE `accounts` (`id` integer PRIMARY KEY,`Name` text, `subscriber_id` integer) ''';

var customerSql = '''CREATE TABLE `customers` ( `id` integer PRIMARY KEY,
    `subscriber_id` integer,
    `Name` VARCHAR(255),
    `PhoneNumber` VARCHAR(20),
    `Email` VARCHAR(255)) ''';

var inventoryTableSql =
    ''' CREATE TABLE `inventories` (`id` integer PRIMARY KEY AUTOINCREMENT,`oitms_id` integer,
      `store_id` integer,`available_qty` real,`uom_entry` integer,CONSTRAINT `fk_products_inventory` FOREIGN KEY (`oitms_id`) REFERENCES `products`(`id`)) ''';

var invoiceTableSql = '''
      CREATE TABLE `invoices` (`id` integer PRIMARY KEY AUTOINCREMENT,`created_at` datetime,`updated_at` datetime,
      `deleted_at` datetime,`local_id` text,`store_id` integer,`sold_by` integer,`card_code` integer,`obj_type` integer,`doc_total` real,
      `total_paid` real,`cash_given` real,`balance` real,`change` real,`sale_status` integer,`receipt_no`
       integer,`cancelled` integer,CONSTRAINT `fk_invoices_seller` FOREIGN KEY (`sold_by`) REFERENCES `users`(`id`),
       CONSTRAINT `fk_invoices_customer` FOREIGN KEY (`card_code`) REFERENCES `customers`(`id`))''';

var paymentTableSql = '''CREATE TABLE `payments` (
    "id" INTEGER,
    "created_at" DATETIME,
    "updated_at" DATETIME,
    "deleted_at" DATETIME,
    "store_id" INTEGER,
    "invoice_id" INTEGER,
    "card_code" INTEGER,
    "account_id" INTEGER,
    "sum_applied" REAL,
    "payment_remarks" TEXT,
    "sold_by" INTEGER,
    "receipt_no" INTEGER,
    "cancelled" INTEGER,
    FOREIGN KEY ("invoice_id") REFERENCES "invoices"("id"),
    FOREIGN KEY ("card_code") REFERENCES "customers"("id"),
    FOREIGN KEY ("account_id") REFERENCES "accounts"("id"),
    FOREIGN KEY ("sold_by") REFERENCES "users"("id")
)''';
var printerSetup =
    ''' CREATE TABLE `printer_setups` (`id` integer PRIMARY KEY AUTOINCREMENT,`row_text` text,`row_location` text,`store_id` integer)''';

var productsTableSql = ''' CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    Name TEXT,
    BarCode TEXT,
    ItemType TEXT,
    BuyingPrice REAL,
    SellingPrice REAL,
    LeastPrice REAL,
    AvailableQty REAL,
    HasUom INTEGER,
    subscriber_id INTEGER)''';

var saleRowTableSql =
    '''CREATE TABLE `sale_rows` (`id` integer PRIMARY KEY AUTOINCREMENT,`created_at` datetime,`updated_at` datetime,`deleted_at` 
      datetime,`store_id` integer,`invoice_id` integer,`card_code` integer,`row_id` text,`product_id` integer,`name` text,`uom_entry` integer,`quantity` real,`price` real,`line_total` real,`sold_by` integer,`receipt_no` integer,`cancelled` integer,CONSTRAINT `fk_sale_rows_seller` 
      FOREIGN KEY (`sold_by`) REFERENCES `users`(`id`),CONSTRAINT `fk_invoices_sales` FOREIGN KEY (`invoice_id`) REFERENCES `invoices`(`id`),CONSTRAINT `fk_sale_rows_customer` 
      FOREIGN KEY (`card_code`) REFERENCES `customers`(`id`),CONSTRAINT `fk_sale_rows_uom` FOREIGN KEY (`uom_entry`) REFERENCES `uoms`(`id`))''';
var uomGroups =
    ''' CREATE TABLE `uom_groups` (`id` integer PRIMARY KEY AUTOINCREMENT,`ugp_name` text,`base_uom` integer,`is_manual` text)''';
var uomsTableSql =
    ''' CREATE TABLE `uoms` (`id` integer PRIMARY KEY AUTOINCREMENT,`uom_name` text) ''';
var ugp1TableSql =
    ''' CREATE TABLE "ugp1"  (`id` integer PRIMARY KEY AUTOINCREMENT,`ugp_entry` integer,`uom_entry` integer,`alt_qty` integer,`base_qty` real,
      `buying_price` real,`retail_price` real,`selling_price` real,
      `wholesale_price` real,CONSTRAINT `fk_ugp1_uom` FOREIGN KEY (`uom_entry`) REFERENCES `uoms`(`id`),
      CONSTRAINT `fk_uom_groups_ugp1` FOREIGN KEY (`ugp_entry`) REFERENCES `uom_groups`(`id`)) ''';
var usersTableSql =
    ''' CREATE TABLE `users` (`id` integer PRIMARY KEY AUTOINCREMENT,`name` text,`phone_number` text,`user_pin` text,`user_name` text,`store_id` integer,`shop_name` text) ''';

var versionTableSql = '''CREATE TABLE version (
    id INTEGER PRIMARY KEY,
    products_inserted INTEGER DEFAULT 0
);''';
// create table outsourceds (id integer primary key, created_at datetime, updated_at datetime, deleted_at datetime, store_id integer, invoice_id integer, card_code integer, row_id text, name text, uom_name text, quantity real, buying_price real, price real, line_total real, sold_by integer, receipt_no integer, cancelled integer, constraint fk_outsourceds_seller foreign key (sold_by) references users(id), constraint fk_outsourceds_customer foreign key (card_code) references customers(id), constraint fk_outsourceds_invoices foreign key (invoice_id) references invoices(id));

var outsourcedsTableSql = ''' CREATE TABLE oursourced (
    `id` INTEGER,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    `deleted_at` DATETIME,
    `store_id` INTEGER,
    `invoice_id` INTEGER,
    CONSTRAINT `fk_invoice_id` FOREIGN KEY (`invoice_id`) REFERENCES `invoices`(`id`),
    `card_code` INTEGER,
    CONSTRAINT `fk_card_code` FOREIGN KEY (`card_code`) REFERENCES `customers`(`id`),
    `row_id` TEXT,
    `name` TEXT,
    `uom_name` TEXT,
    `quantity` REAL,
    `buying_price` REAL,
    `price` REAL,
    `line_total` REAL,
    `sold_by` INTEGER,
    CONSTRAINT `fk_sold_by` FOREIGN KEY (`sold_by`) REFERENCES `users`(`id`),
    `receipt_no` INTEGER,
    `cancelled` INTEGER''';

var saletypes = '''CREATE TABLE saletypes (
    `id` INTEGER,
    `created_at` DATETIME,
    `updated_at` DATETIME,
    `deleted_at` DATETIME,
    `store_id` INTEGER,
    `name` TEXT,
    `description` TEXT,
    `status` INTEGER
''';
