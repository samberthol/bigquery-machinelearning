

# Create the model
CREATE OR REPLACE MODEL `thelook.users_recommendation`
OPTIONS
  ( MODEL_TYPE='MATRIX_FACTORIZATION' ) AS
SELECT
  u.email AS user,
  p.brand as item,
  SUM(o.num_of_item) AS rating
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
GROUP BY 1,2



# Use the model
EXECUTE IMMEDIATE
  """
SELECT *
  FROM ML.PREDICT(MODEL `thelook.users_recommendation`,
       (
SELECT
  u.email AS user,
  p.brand as item,
  SUM(o.num_of_item) AS rating
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
GROUP BY 1,2
        )) 
ORDER BY predicted_rating desc;         
""";