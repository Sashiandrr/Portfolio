USE [TertiarySales]
GO

/****** Object:  View [model].[Products]    Script Date: 20.05.2025 15:03:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













ALTER VIEW [model].[Products]
AS
SELECT      
isnull(isnull(p.[ProductCategoriesName], nsicat.nsiname), '�� ����������') [��������� ���], 
tp.ProductID, 
tp.ProductVariantsID, 
tp.SplitDate[���� ���������], 
tp.AddDate[���� ������], 
CAST(pn.[ProductNameSrc] AS NVARCHAR(1024)) AS ProductName,
CAST(tp.ProductCode AS NVARCHAR(1024)) AS ProductCode,
CAST(cp.[ProductCode] AS NVARCHAR(1024)) AS [��� �������� AX],
--pn.[ProductNameSrc] ProductName,
--tp.ProductCode ProductCode,
--cp.[ProductCode] AS [��� �������� AX],

CASE WHEN tp.AxaptaCode IS NULL THEN '�� ����������' ELSE tp.AxaptaCode END AS AxaptaCode, 
m.Manufacturer, 
m.ManufacturerID,
--coalesce (GK.[������ ��������], m.Manufacturer) as [������ ��������], --12.03.2024 GK ���� ������� � ������� �������� ��� ��������� ��� ��, ������������ ��� �������������
tm.TradeMark, 
ISNULL(p.[SAPSKUTrademarkName], tm.TradeMark) AS SAPSKUTrademarkName, 
pc.ProductTypeName Category, 
pc.ProductTypeID, 
pg.ProductGroup, 
pg.[NameGroupForReport], 
isnull(rdn.[ReportName], pg.[NameGroupForReport]) [��������� ������], /*�������� �� ����������� �������� � �����*/ 
f.[Name] [����� ��������], /*pt.PackingTypeName, --�������� �� �����*/ 
isnull(p.[ProductFormatName], pf.nsiname) [������ �������� ���], 
ts.TradeSeria, 
ISNULL(p.[SAPSKUTradeSeriaName], ts.TradeSeria) AS SAPSKUTradeSeriaName, 
sh.ShellName,
tp.ProductWeight as ProductWeightSrc,
REPLACE(CAST(CAST(tp.ProductWeight AS float) AS nvarchar), '.', ',') AS ProductWeight, 
ISNULL(p.SAPSKUCSKUName, N'�� ����������') AS SAPSKUCSKUName, 
ISNULL(isnull(cp.[ProductName], p.SAPSKUName), N'�� ����������') AS SAPSKUName, 
ISNULL(isnull(cp.[ProductShortName], p.SAPSKUShortName), N'�� ����������') AS SAPSKUShortName, 
mn.[ManufacturerSrc] AS ManufacturerSource, 
ISNULL(p.SAPSKUCode , 0) AS SAPSKUCode, 
ISNULL(p.SAPSKUCSKUID ,0) AS SAPSKUCSKUID, 
ISNULL(p.SAPSKUProductionSKUID ,0) AS SAPSKUProductionSKUID, 
ISNULL(p.[SAPSKUAlternativeSKUID],0) AS [SAPSKUAlternativeSKUID], 
ISNULL(p.[SAPSKUAlternativeSKUName], N'�� ����������') [��������������],
ISNULL(p.SAPSKUCSKUNameShort, N'�� ����������') AS SAPSKUCSKUNameShort, 
ISNULL(p.[SAPRecipeSKUID] , 0) AS [SAPRecipeSKUID], 
ISNULL(p.RecipeSKUsName, N'�� ����������') AS RecipeSKUsName, ISNULL(p.RecipeSKUsNameShort, N'�� ����������') AS [RecipeSKUsNameShort], /*	, try_parse(substring(tp.ProductName,CHARINDEX(':',tp.ProductName)+1,100) as decimal)  as kvantIsh*/ ISNULL(mt.ManufacturerType, '��������� ����������') AS [��� �������������], 
h.name AS [������], 
tp.ProductGroupID, 
CASE WHEN tp.[ManufacturerID] = 1357 THEN N'���' ELSE N'���������' END [�������� ������������]

/*�������� ������������ ������ � �����*/ , 
	isnull(rdn.[ReportNameForConstructor] + ' ', 
	/*�������� �������� ������*/ 
	CASE WHEN pg.AddNameGroup = 1 THEN isnull(pg.ProductGroupShort + ' ', pg.ProductGroup + ' ') ELSE '' END) + 
	/*���������*/ 
	CASE WHEN pg.AddNameSubGroup = 1 AND rdn.[ReportNameForConstructor] IS NULL AND spg.SubProductGroupID <> 10 THEN isnull(spg.SubProductGroup + ' ', '') ELSE '' END + 
	/*������������*/ 
	CASE WHEN pg.AddNameConstructor = 1 THEN isnull(tp.[ShortNameForConstructor] + ' ', '') ELSE '' END +  
	/*������*/ 
	isnull(h.[halalForConstructor]+' ','') +

	/*��� �� ���� � �����*/ 
	/*����� �� ������������� ��� 29.08.2024*/
	CASE WHEN m.ManufacturerID NOT IN (7) THEN
		CASE WHEN pg.AddNamePacking = 1 AND ts .TradeSeriaID NOT IN (4, 19)  and ts .TradeSeria<> tm.TradeMark THEN isnull(ts .TradeSeria + ' ', '') ELSE '' END 
		ELSE '' END + 

	/*��� ��������*/ 
	CASE WHEN pg.AddNameShell = 1 THEN isnull(sh.ShellNameShort + ' ', '') 
							 ELSE '' END + 
	/*��� ��������'*/ 
	CASE WHEN pg.AddNameWeight = 1 THEN CASE WHEN tp.PackingTypeID = 4 THEN '��� ' ELSE REPLACE(CAST(CAST(tp.ProductWeight AS float) AS nvarchar), '.', ',') + '�� ' END ELSE '' END + 
	/*�������\�����\����*/ 					 
	CASE WHEN pg.AddNameform = 1 AND f.FormID not IN (19,24,25,26) /*�� ����������*/ THEN isnull(f.Name + ' ', '') ELSE '' END + 
	/*�������������*/ 					 
	CASE WHEN pg.AddNameManufactur = 1 AND tp.[ManufacturerID] NOT IN (1672, 1674, 1357) THEN m.Manufacturer + ' ' ELSE '' END + 
	/*�������� �����*/	 
	CASE WHEN pg.AddNameTradeMark = 1 AND tm.TradeMark <> m.Manufacturer AND tp.[TradeMarkID] NOT IN (1313, 1009) THEN tm.TradeMark + ' ' ELSE '' END +
	/*��� ��*/
	isnull(vki.Viewforconstructor, '') 
AS NameConstructorWeight, 

/*�������� ������������ ������ ��� ����*/ 
isnull(rdn.[ReportNameForConstructor] + ' ', 
	/*�������� �������� ������*/
    CASE WHEN pg.AddNameGroup = 1 THEN isnull(pg.ProductGroupShort + ' ', pg.ProductGroup + ' ') ELSE '' END) +  
	/*���������*/ 
	CASE WHEN pg.AddNameSubGroup = 1 AND rdn.[ReportNameForConstructor] IS NULL AND spg.SubProductGroupID <> 10 THEN isnull(spg.SubProductGroup + ' ', '') ELSE '' END + 
	/*������������*/ 
	CASE WHEN pg.AddNameConstructor = 1 THEN isnull(tp.[ShortNameForConstructor] + ' ', '') ELSE '' END + 
	/*������*/ 
	isnull(h.[halalForConstructor]+' ','')+
	/*��� �� ���� � �����*/ 
	/*����� �� ������������� ��� 29.08.2024*/
	CASE WHEN m.ManufacturerID NOT IN (7) THEN
		CASE WHEN pg.AddNamePacking = 1 AND ts .TradeSeriaID NOT IN (4, 19)  and ts .TradeSeria<> tm.TradeMark THEN isnull(ts .TradeSeria + ' ', '') ELSE '' END 
		ELSE '' END + 
	/*��� ��������*/ 
	CASE WHEN pg.AddNameShell = 1 THEN isnull(sh.ShellNameShort + ' ', '')  ELSE '' END + 
	/*CASE WHEN pg.AddNameform = 1 AND f.FormID <> 19 /*�� ����������*/ THEN isnull(f.Name + ' ', '') ELSE '' END + /*�������\�����\���� ������� 15/06/2022*/*/ 
	/*�������������*/ 
	CASE WHEN pg.AddNameManufactur = 1 AND tp.[ManufacturerID] NOT IN (1672, 1674, 1357) THEN isnull(m.Manufacturer + ' ', '') ELSE '' END + 
	/*�������� �����*/
	CASE WHEN pg.AddNameTradeMark = 1 AND tm.TradeMark <> m.Manufacturer AND tp.[TradeMarkID] NOT IN (1313, 1009) THEN isnull(tm.TradeMark + ' ', '') ELSE '' END + 
	/*��� ��*/
	isnull(vki.Viewforconstructor, '') 
AS NameConstructorNoWeight, 

tp.[ShortNameForConstructor] [NameConstructor]
,vki.ViewKI
,spg.SubProductGroup AS [���������]
,spg.SubProductGroupID
,ct.CookingType TypeCooking
,pt.PackingType
,isnull([ProductGroupsName]
,pg.GroupsNSI) GroupsNSI
,p.MARKERSKU
,ISNULL(p.[SalesUnitCode], N'�� ����������') AS [��� ������� ������]
,ISNULL(p.[SalesUnitName], N'�� ����������') AS [������� ������]
, 

/*
/*������� ������������ ������ � �����*/ 
	CASE WHEN pg.AddNameConstructor = 1 THEN isnull(tp.[ShortNameForConstructor] + ' ', CASE WHEN spg.[SubProductGroupID]<>10 then spg.[SubProductGroup]+' ' ELSE pg.[ProductGroup]+' ' END) ELSE '' END
	+ /*������������*/isnull(h.[halalForConstructor]+' ','')+ CASE WHEN pg.AddNamePacking = 1 AND ts .TradeSeriaID NOT IN (4, 19)  and ts .TradeSeria <> tm.TradeMark  THEN isnull(ts .TradeSeria + ' ', '') ELSE '' END 
	+ /*������������ ���������*/ CASE WHEN pg.AddNameShell = 1 THEN isnull(sh.ShellNameShort + ' ', '') ELSE '' END 
	+ /*��� ��������*/ CASE WHEN pg.AddNameWeight = 1 THEN CASE WHEN tp.PackingTypeID = 4 THEN '��� ' ELSE REPLACE(CAST(CAST(tp.ProductWeight AS float) AS nvarchar), '.', ',') END ELSE '' END
	+ CASE WHEN pg.AddNameform = 1 AND f.FormID <> 19 /*�� ����������*/ THEN isnull(f.Name + ' ', '') ELSE '' END +isnull(vki.Viewforconstructor, '')
	AS ShortNameConstructorWeight
,
*/ 

/*�������� �������� ������������ ��� ���� �������*/  
ShortNameConstructorWeight = TertiarySales.prd.CAPITALIZE(
	/*�������� ������� �������� ��� ����+*/
	CASE WHEN spg.SubProductGroupID in (41,40,38) THEN ISNULL(spg.SubProductGroup + ' ', '') ELSE '' END + 
	/*������������*/
	CASE WHEN pg.AddNameConstructor = 1 THEN ISNULL(tp.[ShortNameForConstructor] + ' ', '') ELSE '' END + 
	/*������*/
	ISNULL(h.[halalForConstructor]+' ','') + 
	/*��� �� ���� � �����*/ 
	/*����� �� ������������� ��� 29.08.2024*/
	CASE WHEN m.ManufacturerID NOT IN (7) THEN
		CASE WHEN pg.AddNamePacking = 1 AND ts .TradeSeriaID NOT IN (4, 19)  and ts .TradeSeria<> tm.TradeMark THEN isnull(ts .TradeSeria + ' ', '') ELSE '' END 
		ELSE '' END + 
	/*��������*/
	CASE WHEN pg.AddNameShell = 1 THEN ISNULL(sh.ShellNameShort + ' ', '') ELSE '' END + 
	/*���*/
	CASE WHEN pg.AddNameWeight = 1 THEN 
		CASE WHEN tp.PackingTypeID = 4 THEN '��� ' ELSE REPLACE(CAST(CAST(tp.ProductWeight AS float) AS NVARCHAR), '.', ',')  + '�� ' END 
		ELSE '' END + 
	/*����� (�������\�����\����)*/
	CASE WHEN pg.AddNameform = 1 AND f.FormID not IN (19,24,25,26) /*�� ����������*/ THEN ISNULL(f.Name + ' ', '') ELSE '' END + 
	/*�������������*/
	--CASE WHEN pg.AddNameManufactur = 1 AND tp.[ManufacturerID] NOT IN (1672, 1674, 1357) THEN isnull(m.Manufacturer + ' ', '') ELSE '' END + 
	/*�������� �����*/
	CASE WHEN pg.AddNameTradeMark = 1 /*AND tm.TradeMark <> m.Manufacturer*/ AND tp.[TradeMarkID] NOT IN (1313, 1009) THEN tm.TradeMark + ' ' ELSE '' END + 
	ISNULL(vki.Viewforconstructor, '') 
),
/*����������� �������� ������������ ��� ���� �������*/  

	ch.ChainName, wr.Name[������� �������], 
     wr2.Name[������� ������� (���������)]
	, tp.[DuplicatedProductID] doubleid, isnull(sg.segmentGroup, N'�� ����������') [������ ��������], sg.SegmentGroupID, isnull(BrandMgt, N'�� ����������') [����� ��������], 
     CASE WHEN fullname.productid IS NULL THEN N'���' ELSE N'��' END [���� ������ �����������],
	 keyc.KeyComponent [�������� ���������]
	 ,isnull(p.Brand, N'�� ����������') [�����]
	 , cn.Country [������ �������������]
	 ,sch.ChainName [���� �������]
	 ,fmt.FacetValue as [����� ��� ����]
	 ,fis.FacetValue as [����� ��������]
	 ,f�s.FacetValue as [����� �������� �����������]
	 ,fti.FacetValue as [����� �������� ���������]
	 ,fmi.FacetValue as [����� ������ ���������]
	 ,fch.FacetValue as [����� ����������] 
	 ,fbab.FacetValue as [����� �������]
	 ,fn1.FacetValue as [����� ���� �������1]
	 ,fn2.FacetValue as [����� ���� �������2]
	 ,fn3.FacetValue as [����� ���� �������3]
	 ,fps.FacetValue as [����� ������ �������]
	-- ,fth.FacetValue as [����� �������]
	 ,fhal.FacetValue as [����� ������]
	 ,fgost.FacetValue as [����� ����]
	 ,fprs.FacetValue as [����� ������ ��������]
	 ,case when fn1.FacetValue is null or fn2.FacetValue  is null or fn3.FacetValue is null then Null else fn1.FacetValue +case when fn1.FacetValue <> fn2.FacetValue then '|'+fn2.FacetValue  ELSE '' END + case when fn2.FacetValue <> fn3.FacetValue then '|'+fn3.FacetValue else '' end end as [����� ���� �������]
	 ,CASE WHEN tp.PackingTypeID = 4 AND tp.ProductGroupID = 13 THEN '�������' ELSE fwseg.FacetValue END AS [����� ������� ��������]
	 ,ffat.FacetValue AS [����� ����]
	 ,fform.FacetValue AS [����� �����]
	 ,fstpd.FacetValue AS [����� �������]
	 ,fsh.FacetValue AS [����� ��������]
	 ,st.[FacetValue] as [����� ��� �����]
	 ,fnfor.[FacetValue] as [�����  ��������� �����]
	 ,fnun.[FacetValue] as [����� ������������ �����]
	 ,fntast.[FacetValue] as [����� �������� ����]
	 ,fp.[FacetValue] as [����� ��� ��������]
	 ,coalesce (pricS.[PriceStartegyNameShort],pricSs.[PriceStartegyNameShort], 'High-Low') as PriceStartegyName
	 ,PriceStrategiesInterval
	 ,case when pricS.PriceStartegyName is not null then '�����������' 
	 when pricSs.PriceStartegyName is not null then '������������' 
	 else null end as StrategyGeo
	 ,case when pricS.PriceStartegyName is not null then null 
	 when pricSs.PriceStartegyName is not null then PriceStrategiesRegions
	 else null end as PriceStrategiesRegions,

--�������� ����������� ������� ��� ��������� ��� ����� �����
NameConstructorWeightClps = isnull(rdn.[ReportNameForConstructor] + ' ', 
	/*�������� �������� ������*/
	CASE WHEN pg.AddNameGroup = 1 THEN isnull(pg.ProductGroupShort + ' ', pg.ProductGroup + ' ') ELSE '' END) +  
	/*���������*/ 
	CASE WHEN pg.AddNameSubGroup = 1 AND rdn.[ReportNameForConstructor] IS NULL AND spg.SubProductGroupID <> 10 THEN isnull(spg.SubProductGroup + ' ', '') ELSE '' END + 
	/*������������*/
	CASE WHEN pg.AddNameConstructor = 1 and ncc.[ShortNameForConstructor] is not null THEN ncc.[ShortNameForConstructor] + ' ' 
		 WHEN pg.AddNameConstructor = 1 then isnull(tp.[ShortNameForConstructor] + ' ', '') ELSE '' END + 
	isnull(h.[halalForConstructor]+' ','')+
	/*��� �� ���� � �����*/ 
	/*����� �� ������������� ��� 29.08.2024*/
	CASE WHEN m.ManufacturerID NOT IN (7) THEN
		CASE WHEN pg.AddNamePacking = 1 AND ts .TradeSeriaID NOT IN (4, 19)  and ts .TradeSeria<> tm.TradeMark THEN isnull(ts .TradeSeria + ' ', '') ELSE '' END 
		ELSE '' END + 
	/*��� ��������*/ 
	CASE WHEN pg.AddNameShell = 1 THEN isnull(sh.ShellNameShort + ' ', '') ELSE '' END + 
	/*��� ��������'*/ 
	CASE WHEN pg.AddNameWeight = 1 THEN CASE WHEN tp.PackingTypeID = 4  THEN '��� ' 
		 WHEN ncc.[ProductWeight] is not null 
			  THEN ncc.[ProductWeight] + ' '  ELSE REPLACE(CAST(CAST(tp.ProductWeight AS float) AS nvarchar), '.', ',') + '�� ' END ELSE '' END +
	/*�������\�����\����*/
	CASE WHEN pg.AddNameform = 1 AND f.FormID not IN (19,24,25,26) /*�� ����������*/ THEN isnull(f.Name + ' ', '') ELSE '' END +  
	/*�������������*/
	CASE WHEN pg.AddNameManufactur = 1 AND tp.[ManufacturerID] NOT IN (1672, 1674, 1357) 
							 THEN m.Manufacturer + ' ' ELSE '' END +  
	/*�������� �����*/
	CASE WHEN pg.AddNameTradeMark = 1 and ncc.TradeMark is not null AND ncc.TradeMark <> m.Manufacturer AND tp.[TradeMarkID] NOT IN (1313, 1009) 
		 THEN ncc.TradeMark + ' ' 
		 WHEN pg.AddNameTradeMark = 1 AND tm.TradeMark <> m.Manufacturer AND tp.[TradeMarkID] NOT IN (1313, 1009) 
			  THEN isnull(tm.TradeMark + ' ', '') ELSE '' END +
	isnull(vki.Viewforconstructor, '')

FROM            prd.[Products] AS tp LEFT OUTER JOIN
                         dbo.vwProductsDM AS p ON p.SKU_DAX_Code = tp.AxaptaCode LEFT JOIN
                         [WHSQLP01\SQLENT].[DM].[Dimensions].[CompetitorProducts] cp ON cp.[ProductCode] = tp.AxaptaCode JOIN
                         [Products].[ProductGroups] pg ON pg.ProductGroupID = tp.ProductGroupID  LEFT JOIN
						  prd.KeyComponents keyc on keyc.KeyComponentID=tp.KeyComponentID left join
                         [Prd].[SegmentGroup] sg ON sg.SegmentGroupID = tp.SegmentGroupID JOIN
                         [Products].[TradeSeries] ts ON ts .TradeSeriaID = tp.TradeSeriaID JOIN
                         [Products].[TradeMarks] tm ON tm.TradeMarkID = tp.TradeMarkID JOIN
                         Products.Forms f ON f.FormID = tp.FormID JOIN
                         [Products].[PackingTypes] pt ON pt.PackingTypeID = tp.PackingTypeID JOIN
                         [Products].[Manufacturers] m ON m.ManufacturerID = tp.ManufacturerID JOIN
						 location.Countries cn on cn.CountryID=m.CountryID 
						 join location.chains sch on tp.[SubChainID]= sch.ChainID JOIN
                         [Products].[Shell] sh ON sh.ShellID = tp.ShellID JOIN
                         [Products].[ProductTypes] pc ON tp.ProductTypeID = pc.ProductTypeID LEFT JOIN
                         [Products].[ManufacturerTypes] mt ON tp.ManufacturerID = mt.ManufacturerID AND tp.ProductTypeID = mt.ProductTypeID LEFT JOIN
                         [Products].[ViewKI] vki ON tp.ViewKiID = vki.ViewKIID LEFT OUTER JOIN
                         [Products].[SubProductGroups] spg ON spg.SubProductGroupID = tp.[ProductSubGroupID] LEFT JOIN
                         [prd].[RelationForDetailGroupName] rdn ON rdn.[Productgroupid] = tp.ProductGroupID AND tp.ProductSubGroupID = isnull(rdn.[Subproductgroupid], tp.ProductSubGroupID) AND tp.cookingtypeid = isnull(rdn.productcookingid, tp.cookingtypeid) 
                         LEFT JOIN
                         [Location].[Chains] ch ON tp.ChainID = ch.ChainID LEFT JOIN
                         nsi.ProductFormat pf ON pf.NSIId = tp.SAPProductTypeID LEFT JOIN
                         [prd].[WeightRangeFilter] wr ON ProductWeight >= wr.[From] AND ProductWeight < wr.[To] AND pg.ProductGroupID = wr.ProductGroupID AND wr.[WeigthType] = 1 /* ��� ������� ��� ������ ��*/ LEFT JOIN
                         [prd].[WeightRangeFilter] wr2 ON ProductWeight >= wr2.[From] AND ProductWeight < wr2.[To] AND pg.ProductGroupID = wr2.ProductGroupID AND wr2.[WeigthType] = 2 /* ��� ��������� ��� ������ ��*/ 
						 outer apply (select top 1 pn.ProductNameSrc
									from TertiarySales.prd.ProductNameSrcDynamic AS pn
									where tp.ProductCodeConverted = pn.ProductCode AND tp.ChainID = pn.ChainID 
										AND pn.[AddDate] BETWEEN tp.[AddDate] AND tp.SplitDate
									order by  pn.[AddDate]  desc
								)pn

						outer apply (select top 1 mn.ManufacturerSrc
									from TertiarySales.prd.ManufacturerSrcDynamic AS mn
									where tp.ProductCodeConverted = mn.ProductCode 
									AND tp.ChainID = mn.ChainID 
									AND mn.[AddDate] BETWEEN tp.[AddDate] AND tp.SplitDate
									order by  mn.[AddDate]  desc
								)mn
						 left join prd.halal h on h.id = tp.halalid LEFT JOIN
                         [prd].[CookingType] ct ON ct.CookingTypeID = tp.CookingTypeID LEFT JOIN
                         [NSI].[Categories] nsicat ON nsicat.NSIId = tp.NSICategoryID LEFT JOIN
                         [prd].[vwFullConstructorProducts] fullname ON fullname.productid = tp.ProductID
						 left join [facet].[MeatType] fmt on fmt.[FacetValueID] = tp.[FT_MeatType_ID]
						 left join [facet].[IsSmoked] fis on fis.[FacetValueID] = tp.[FT_IsSmoked_ID]
						 left join [facet].[ConsumptSituation] f�s on f�s.[FacetValueID] = tp.[FT_ConsumptSituation_ID]
						 left join [facet].[TasteInclusion] fti on fti.[FacetValueID] = tp.[FT_TasteInclusion_ID]
						 left join [facet].[MeatInclusion] fmi on fmi.[FacetValueID] = tp.[FT_MeatInclusion_ID]
						 left join [facet].[Chopped] fch on fch.[FacetValueID] = tp.[FT_Chopped_ID]
						 left join [facet].[Baby] fbab on fbab.[FacetValueID] = tp.[FT_Baby_ID]
						 left join [facet].[Name] fn1 on fn1.[FacetValueID] = tp.[FT_NameLvl1_ID]
						 left join [facet].[Name] fn2 on fn2.[FacetValueID] = tp.[FT_NameLvl2_ID]
						 left join [facet].[Name] fn3 on fn3.[FacetValueID] = tp.[FT_NameLvl3_ID]
						 left join [facet].[PackSize] fps on fps.[FacetValueID] = tp.[FT_PackSize_ID]
						 --left join [facet].[Thickness] fth on fth.[FacetValueID] = tp.[FT_Thickness_ID]
						 left join [facet].[Halal] fhal on fhal.[FacetValueID] = tp.[FT_Halal_ID]
						 left join [facet].[GOST] fgost on fgost.[FacetValueID] = tp.[FT_GOST_ID]
						 left join [facet].[PrdSize] fprs on fprs.[FacetValueID] = tp.[FT_PrdSize_ID]
						 left join [facet].[Fat] ffat on ffat.[FacetValueID] = tp.[FT_Fat_ID]
						 left join [facet].[Form] fform on fform.[FacetValueID] = tp.[FT_Form_ID]
						 left join [facet].[Strapped] fstpd on fstpd.[FacetValueID] = tp.[FT_Strapped_ID]
						 left join [facet].[Shell] fsh on fsh.[FacetValueID] = tp.[FT_Shell_ID]
						 LEFT JOIN [facet].[WeightSegment] fwseg ON (tp.ProductGroupID = fwseg.ProductGroupID) AND (tp.ProductWeight >= fwseg.FromValue AND tp.ProductWeight < fwseg.TOValue)
						 left join [facet].[SliceType] st on st.[FacetValueID] = tp.[FT_SliceType_ID]
						 left join [TertiarySales].[facet].[NameForeign] fnfor on fnfor.[FacetValueID] = tp.[FT_NameForeign_ID]
						 left join [TertiarySales].[facet].[NameUnique] fnun on fnun.[FacetValueID] = tp.[FT_NameUnique_ID]
						 left join [TertiarySales].[facet].[NameTaste] fntast on fntast.[FacetValueID] = tp.[FT_NameTaste_ID]
						 left join [TertiarySales].[facet].[Packing] fp on fp.[FacetValueID] = tp.[FT_Packing_ID]
						 ---�������� ����� ������������� EDLP/EDPP ��� ����� ������ � ���������
						 left join ( 
							select distinct ProductID, max(PriceStrategyID) over (partition by ProductID) as PriceStrategyID  from [edpp].[ProductPriceStrategiesAllGeo]) pps on pps.ProductID = tp.ProductID
						 left join (
							select distinct ProductID, STRING_AGG(cast ([FromDate] as nvarchar (max))+':'+cast ([ToDate]as nvarchar (max)), ', ') as PriceStrategiesInterval 
							from [edpp].[ProductPriceStrategiesAllGeo] group by ProductID ) pps2 on pps2.ProductID = tp.ProductID

						 left join [prd].[PriceStrategies] pricS on pricS.PriceStrategyID = pps.PriceStrategyID

						 left join ( 
							select distinct ProductID, max(PriceStrategyIDAllGeo) over (partition by ProductID) as PriceStrategyIDAllGeo  from [edpp].[ProductPriceStrategiesRegions]) ppsr on ppsr.ProductID = tp.ProductID
						 
						 left join (select distinct ProductID, STRING_AGG(cast (Region as nvarchar (max)), ', ') as PriceStrategiesRegions 
							from(select distinct ProductID,r.Region
							from [edpp].[ProductPriceStrategiesRegions]  ppsr1 
							join [Location].[Regions] r on r.RegionID =  ppsr1.RegionID) t
                            group by ProductID)  ppsr2 on ppsr2.ProductID = tp.ProductID
						 
						 left join [prd].[PriceStrategies] pricSs on pricSs.[PriceStrategyID] = ppsr.PriceStrategyIDAllGeo
						 left join [TertiarySales].[prd].[viewNCClpsAttr] ncc on ncc.[DuplicatedProductID] = tp.DuplicatedProductID
						 --left join [TertiarySales].[Products].[CompanyGroup] GK on GK.[ManufacturerID]=tp.[ManufacturerID] ---12.03.2024 GK ���� �������
		--where tp.[DuplicatedProductID]=140846				 
		
GO


