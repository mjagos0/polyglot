select
    p.id,
    v.vendor,
    pt.product_type,
    pc.product_condition,
    p.mpn,
    p.product_warranty,
    p.stock_quantity,
    p.price,
    p.attributes,
    p.created_at,
    p.updated_at
from products p
left join categories c on p.category_id = c.id
left join vendors v on p.vendor_id = v.id
left join product_types pt on p.product_type_id = pt.id
left join product_conditions pc on p.product_condition_id = pc.id