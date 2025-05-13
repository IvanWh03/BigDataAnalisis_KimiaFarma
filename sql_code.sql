CREATE OR REPLACE TABLE `rakamin-kf-analytics-459606.kimia_farma.kimia_farma_analysis` AS
WITH laba_cte AS (
  SELECT
    transaction_id,
    date,
    branch_id,
    customer_name,
    product_id,
    price,
    discount_percentage,
    rating AS rating_transaksi,
    price - (price * discount_percentage / 100) AS nett_sales
  FROM `rakamin-kf-analytics-459606.kimia_farma.kf_final_transaction`
),
laba_dengan_margin AS (
  SELECT *,
    CASE 
      WHEN price <= 50000 THEN 0.10
      WHEN price <= 100000 THEN 0.15
      WHEN price <= 300000 THEN 0.20
      WHEN price <= 500000 THEN 0.25
      ELSE 0.30
    END AS persentase_gross_laba
  FROM laba_cte
),
final_calculation AS (
  SELECT 
    l.transaction_id,
    l.date,
    kc.branch_id,
    kc.branch_name,
    kc.kota,
    kc.provinsi,
    kc.rating AS rating_cabang,
    l.customer_name,
    p.product_id,
    p.product_name,
    l.price AS actual_price,
    l.discount_percentage,
    l.nett_sales,
    l.persentase_gross_laba,
    l.nett_sales * l.persentase_gross_laba AS nett_profit,
    l.rating_transaksi
  FROM laba_dengan_margin l
  JOIN `rakamin-kf-analytics-459606.kimia_farma.kf_kantor_cabang` kc
    ON l.branch_id = kc.branch_id
  JOIN `rakamin-kf-analytics-459606.kimia_farma.kf_product` p
    ON l.product_id = p.product_id
)

SELECT * FROM final_calculation;
