TRUNCATE TABLE RFM;

-- Benzersiz müşteri ID'lerini ekle
INSERT INTO RFM (CustomerID)
SELECT DISTINCT [Customer ID]
FROM ONLINERETAIL_2010
WHERE [Customer ID] IS NOT NULL;


UPDATE RFM
SET LastInvoiceDate = (
    SELECT MAX(InvoiceDate)
    FROM ONLINERETAIL_2010
    WHERE [Customer ID] = RFM.CustomerID
);


UPDATE RFM
SET Recency = DATEDIFF(DAY, LastInvoiceDate, '2011-12-11');


UPDATE RFM
SET Frequency = (
    SELECT COUNT(DISTINCT InvoiceNo)
    FROM ONLINERETAIL_2010
    WHERE [Customer ID] = RFM.CustomerID
);


UPDATE RFM
SET Monetary = (
    SELECT SUM(UnitPrice * Quantity)
    FROM ONLINERETAIL_2010
    WHERE [Customer ID] = RFM.CustomerID
);

-- Recency Score
UPDATE RFM
SET Recency_Score = t.RankVal
FROM (
    SELECT CustomerID, NTILE(5) OVER (ORDER BY Recency ASC) AS RankVal
    FROM RFM
) t
WHERE t.CustomerID = RFM.CustomerID;

-- Frequency Score
UPDATE RFM
SET Frequency_Score = t.RankVal
FROM (
    SELECT CustomerID, NTILE(5) OVER (ORDER BY Frequency ASC) AS RankVal
    FROM RFM
) t
WHERE t.CustomerID = RFM.CustomerID;

-- Monetary Score
UPDATE RFM
SET Monetary_Score = t.RankVal
FROM (
    SELECT CustomerID, NTILE(5) OVER (ORDER BY Monetary ASC) AS RankVal
    FROM RFM
) t
WHERE t.CustomerID = RFM.CustomerID;

-- RFM Segmentasyonu
UPDATE RFM SET Segment = 'Hibernating'
WHERE Recency_Score IN (1,2) AND Frequency_Score IN (1,2);

UPDATE RFM SET Segment = 'At_Risk'
WHERE Recency_Score IN (1,2) AND Frequency_Score IN (3,4);

UPDATE RFM SET Segment = 'Cant_Lose'
WHERE Recency_Score IN (1,2) AND Frequency_Score = 5;

UPDATE RFM SET Segment = 'About_to_Sleep'
WHERE Recency_Score = 3 AND Frequency_Score IN (1,2);

UPDATE RFM SET Segment = 'Need_Attention'
WHERE Recency_Score = 3 AND Frequency_Score = 3;

UPDATE RFM SET Segment = 'Loyal_Customers'
WHERE Recency_Score IN (3,4) AND Frequency_Score IN (4,5);

UPDATE RFM SET Segment = 'Promising'
WHERE Recency_Score = 4 AND Frequency_Score = 1;

UPDATE RFM SET Segment = 'New_Customers'
WHERE Recency_Score = 5 AND Frequency_Score = 1;

UPDATE RFM SET Segment = 'Potential_Loyalists'
WHERE Recency_Score IN (4,5) AND Frequency_Score IN (2,3);

UPDATE RFM SET Segment = 'Champions'
WHERE Recency_Score = 5 AND Frequency_Score IN (4,5);
