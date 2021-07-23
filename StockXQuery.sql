-- Review dataset

select *
from Stockx..['StockX-Data-Contest-2019$']


-- Cleanup OrderDate and ReleaseDate column (originally 2017-09-01 00:00:00.000, make to 2017-09-01)

select OrderDate, convert(date, OrderDate)
from Stockx..['StockX-Data-Contest-2019$']

alter table Stockx..['StockX-Data-Contest-2019$'] -- adding new empty column
add OrderDateConverted date;

alter table Stockx..['StockX-Data-Contest-2019$'] -- adding new empty column
add ReleaseDateConverted date;

update Stockx..['StockX-Data-Contest-2019$']
set OrderDateConverted = convert(date, OrderDate)

update Stockx..['StockX-Data-Contest-2019$']
set ReleaseDateConverted = convert(date, ReleaseDate)

-- Review dataset again

select *
from Stockx..['StockX-Data-Contest-2019$']


-- Popularity by Brand

select Brand, count(*) as PairsSold
from Stockx..['StockX-Data-Contest-2019$']
group by Brand


-- Popularity by Sneaker model

select SneakerName, count(*) as PairsSold
from Stockx..['StockX-Data-Contest-2019$']
group by SneakerName
order by PairsSold desc


-- Day with most transactions

select OrderDateConverted, count(*) as NumberOfTransactions
from Stockx..['StockX-Data-Contest-2019$']
group by OrderDateConverted
order by NumberOfTransactions desc


-- Trend of Yeezy/Off-White Transaction over time

select OrderDateConverted,
	count(case when Brand like ' Yeezy'then 1 end) as Yeezy,
	count(case when Brand like 'Off-White'then 1 end) as 'Off-White'
from Stockx..['StockX-Data-Contest-2019$']
group by OrderDateConverted


-- Highest SalePrice and profit margins for each model

select SneakerName, max(SalePrice) as HighestPrice, max(SalePrice - RetailPrice) as MaxProfitMargin, avg(SalePrice) as AvgPrice, round(avg(SalePrice - RetailPrice),2) as AvgProfitMargin
from Stockx..['StockX-Data-Contest-2019$']
group by SneakerName
order by HighestPrice desc


-- Average resale prices of shoes and number of pairs sold per shoes size

select ShoeSize, round(avg(SalePrice),2) as AvgPrice, count(*) as PairsSold
from Stockx..['StockX-Data-Contest-2019$']
group by ShoeSize
order by ShoeSize


-- Sneaker Culture by Region

with nested as (
select BuyerRegion, count(*) as TotalTransactions, round(avg(SalePrice),2) as AmonutSpentPerPair, sum(SalePrice) as TotalSpent,
	case when count(case when Brand like ' Yeezy'then 1 end) > count(case when Brand like 'Off-White' then 1 end) then 'Yeezy'
		 when count(case when Brand like ' Yeezy' then 1 end) < count(case when Brand like 'Off-White'then 1 end) then 'Off-White'
		 else 'Same'
		 end as PopularBrand,
	count(case when Brand like ' Yeezy'then 1 end) as Yeezy,
	count(case when Brand like 'Off-White'then 1 end) as 'Off-White'
from Stockx..['StockX-Data-Contest-2019$']
group by BuyerRegion
)

select BuyerRegion, TotalTransactions, AmonutSpentPerPair, TotalSpent, PopularBrand,
	Yeezy, format(Yeezy * 100.0/TotalTransactions, 'N2') as 'Yeezy%',
	[Off-White] , format([Off-White] * 100.0/TotalTransactions, 'N2') as 'Off-White%'
from nested
order by AmonutSpentPerPair desc