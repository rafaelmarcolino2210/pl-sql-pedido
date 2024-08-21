SET SERVEROUTPUT ON;

DECLARE v_order_xml CLOB := '<Order>
        <CustomerName>Ariane Martins</CustomerName>
        <OrderDate>2024-08-20</OrderDate>
        <Items>
            <Item>
                <ProductName>Produto A</ProductName>
                <Quantity>3</Quantity>
                <Price>15.99</Price>
            </Item>
            <Item>
                <ProductName>Produto B</ProductName>
                <Quantity>1</Quantity>
                <Price>45.50</Price>
            </Item>
            <Item>
                <ProductName>Produto C</ProductName>
                <Quantity>2</Quantity>
                <Price>22.75</Price>
            </Item>
        </Items>
    </Order>';
BEGIN
    OrderProcessing.ProcessOrder(v_order_xml);
END;

