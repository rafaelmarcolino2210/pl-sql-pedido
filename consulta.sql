select * from ORDERS

select * from ORDERITEMS

SELECT
    o.OrderId,
    o.CustomerName,
    o.OrderDate,
    LISTAGG(
        i.ProductName || ' (Quantidade: ' || i.Quantity || ', Valor: ' || i.Price || ')',
        ', '
    ) WITHIN GROUP (ORDER BY i.ProductName) AS Items
FROM Orders o
JOIN OrderItems i ON o.OrderId = i.OrderId
GROUP BY o.OrderId, o.CustomerName, o.OrderDate
ORDER BY o.OrderId;
