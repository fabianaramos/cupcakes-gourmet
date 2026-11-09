-- Projeto físico do banco (DDL extraído do SQLite de desenvolvimento).
-- Em produção as mesmas migrations (db/migrate) geram o equivalente em PostgreSQL.

CREATE TABLE IF NOT EXISTS "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(120) NOT NULL, "email" varchar(160) NOT NULL, "password_digest" varchar NOT NULL, "cpf" varchar(11), "phone" varchar(20), "role" varchar(20) DEFAULT 'cliente' NOT NULL, "approved" boolean DEFAULT TRUE NOT NULL, "failed_attempts" integer DEFAULT 0 NOT NULL, "locked_until" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT users_role_check CHECK (role IN ('cliente','admin','superadmin')));
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email");
CREATE UNIQUE INDEX "index_users_on_cpf" ON "users" ("cpf");
CREATE TABLE IF NOT EXISTS "addresses" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "cep" varchar(8) NOT NULL, "street" varchar(150) NOT NULL, "number" varchar(10) NOT NULL, "complement" varchar(60), "neighborhood" varchar(80) NOT NULL, "city" varchar(80) NOT NULL, "state" varchar(2) NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_48c9e0c5a2"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
 ON DELETE CASCADE);
CREATE INDEX "index_addresses_on_user_id" ON "addresses" ("user_id");
CREATE TABLE IF NOT EXISTS "categories" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(60) NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_categories_on_name" ON "categories" ("name");
CREATE TABLE IF NOT EXISTS "products" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "category_id" integer NOT NULL, "name" varchar(100) NOT NULL, "description" text NOT NULL, "ingredients" text NOT NULL, "allergens" varchar(200), "price" decimal(8,2) NOT NULL, "stock" integer DEFAULT 0 NOT NULL, "min_stock" integer DEFAULT 10 NOT NULL, "active" boolean DEFAULT FALSE NOT NULL, "image_url" varchar(500), "sold_count" integer DEFAULT 0 NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_fb915499a4"
FOREIGN KEY ("category_id")
  REFERENCES "categories" ("id")
, CONSTRAINT products_price_positive CHECK (price > 0), CONSTRAINT products_stock_non_negative CHECK (stock >= 0));
CREATE INDEX "index_products_on_category_id" ON "products" ("category_id");
CREATE UNIQUE INDEX "index_products_on_name" ON "products" ("name");
CREATE TABLE IF NOT EXISTS "coupons" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "code" varchar(30) NOT NULL, "kind" varchar(12) NOT NULL, "value" decimal(8,2) NOT NULL, "valid_until" date NOT NULL, "usage_limit" integer DEFAULT 100 NOT NULL, "used_count" integer DEFAULT 0 NOT NULL, "active" boolean DEFAULT TRUE NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT coupons_kind_check CHECK (kind IN ('percentual','fixo')), CONSTRAINT coupons_value_positive CHECK (value > 0));
CREATE UNIQUE INDEX "index_coupons_on_code" ON "coupons" ("code");
CREATE TABLE IF NOT EXISTS "orders" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "address_id" integer NOT NULL, "coupon_id" integer, "number" varchar(20) NOT NULL, "status" varchar(20) DEFAULT 'recebido' NOT NULL, "subtotal" decimal(10,2) NOT NULL, "discount" decimal(10,2) DEFAULT 0.0 NOT NULL, "shipping" decimal(10,2) NOT NULL, "total" decimal(10,2) NOT NULL, "payment_method" varchar(10) NOT NULL, "installments" integer DEFAULT 1 NOT NULL, "payment_code" varchar(120), "paid_at" datetime(6), "delivery_date" date NOT NULL, "delivery_period" varchar(10) NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_f868b47f6a"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_774ef80392"
FOREIGN KEY ("address_id")
  REFERENCES "addresses" ("id")
, CONSTRAINT "fk_rails_907a5e9f62"
FOREIGN KEY ("coupon_id")
  REFERENCES "coupons" ("id")
, CONSTRAINT orders_status_check CHECK (status IN ('recebido','confirmado','em_preparo','saiu_para_entrega','entregue','cancelado')), CONSTRAINT orders_payment_check CHECK (payment_method IN ('cartao','pix','boleto')));
CREATE INDEX "index_orders_on_user_id" ON "orders" ("user_id");
CREATE INDEX "index_orders_on_address_id" ON "orders" ("address_id");
CREATE INDEX "index_orders_on_coupon_id" ON "orders" ("coupon_id");
CREATE UNIQUE INDEX "index_orders_on_number" ON "orders" ("number");
CREATE TABLE IF NOT EXISTS "order_items" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "order_id" integer NOT NULL, "product_id" integer NOT NULL, "quantity" integer NOT NULL, "unit_price" decimal(8,2) NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_f1a29ddd47"
FOREIGN KEY ("product_id")
  REFERENCES "products" ("id")
, CONSTRAINT "fk_rails_e3cb28f071"
FOREIGN KEY ("order_id")
  REFERENCES "orders" ("id")
 ON DELETE CASCADE, CONSTRAINT order_items_quantity_range CHECK (quantity BETWEEN 1 AND 50));
CREATE INDEX "index_order_items_on_order_id" ON "order_items" ("order_id");
CREATE INDEX "index_order_items_on_product_id" ON "order_items" ("product_id");
CREATE UNIQUE INDEX "index_order_items_on_order_id_and_product_id" ON "order_items" ("order_id", "product_id");
CREATE TABLE IF NOT EXISTS "order_status_changes" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "order_id" integer NOT NULL, "user_id" integer, "from_status" varchar(20), "to_status" varchar(20) NOT NULL, "created_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_fba94f0c84"
FOREIGN KEY ("order_id")
  REFERENCES "orders" ("id")
 ON DELETE CASCADE, CONSTRAINT "fk_rails_2034632817"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_order_status_changes_on_order_id" ON "order_status_changes" ("order_id");
CREATE INDEX "index_order_status_changes_on_user_id" ON "order_status_changes" ("user_id");
CREATE TABLE IF NOT EXISTS "reviews" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "product_id" integer NOT NULL, "order_id" integer NOT NULL, "rating" integer NOT NULL, "comment" text, "approved" boolean DEFAULT FALSE NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_eadb6874f1"
FOREIGN KEY ("order_id")
  REFERENCES "orders" ("id")
, CONSTRAINT "fk_rails_bedd9094d4"
FOREIGN KEY ("product_id")
  REFERENCES "products" ("id")
, CONSTRAINT "fk_rails_74a66bd6c5"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT reviews_rating_range CHECK (rating BETWEEN 1 AND 5));
CREATE INDEX "index_reviews_on_user_id" ON "reviews" ("user_id");
CREATE INDEX "index_reviews_on_product_id" ON "reviews" ("product_id");
CREATE INDEX "index_reviews_on_order_id" ON "reviews" ("order_id");
CREATE UNIQUE INDEX "index_reviews_on_order_id_and_product_id" ON "reviews" ("order_id", "product_id");
