CREATE OR REPLACE MODEL
  `thelook.users_interrest` 
OPTIONS
  ( MODEL_TYPE='KMEANS',
    NUM_CLUSTERS=4 ) AS
SELECT
  u.country,
  p.brand,
  p.category,
  SUM(i.sale_price*o.num_of_item) AS sales_sum
FROM
  `thelook.order_items` AS i
JOIN
  `thelook.orders` AS o
ON
  i.order_id = o.order_id
JOIN
  `thelook.products` AS p
ON
  i.product_id = p.id
JOIN
  `thelook.users` AS u
ON
  u.id = i.user_id

GROUP BY 1,2,3