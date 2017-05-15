package com.kipling.wc.product;

import java.util.HashMap;
import java.util.Map;

import com.kipling.wc.sourcing.KipCostSheetPlugins;
import com.lcs.wc.foundation.LCSLifecycleManaged;
import com.lcs.wc.product.LCSProduct;
import com.lcs.wc.season.LCSProductSeasonLink;
import com.lcs.wc.season.LCSSeason;
import com.lcs.wc.season.SeasonProductLocator;
import com.lcs.wc.util.FormatHelper;
import com.lcs.wc.util.LCSLog;
import com.lcs.wc.util.LCSProperties;

import wt.fc.WTObject;
import wt.util.WTException;
import wt.util.WTPropertyVetoException;

public final class KipProductSeasonPlugins {

	private KipProductSeasonPlugins(){
		
	}
	//Attributes to be considered fr fetching margin details
	private static String GBA_PRODUCT_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.gba.product","kipGBA");
	private static String COLLECTIONEU_PRODUCT_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.collectioneu.product","kipCollectionEU");
	private static String SUBCATEGORY_PRODUCT_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.productsubcategory.product","kipProductSubCategory");

	//Attributes in product season
	private static String RRPMARGIN_PRODSEASON_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.rrpmargin.productseason","kipTargetRetailMarginPerc");
	private static String WHOLESALEMARGIN_PRODSEASON_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.wholesalemargin.productseason","kipTargetWholeSaleMarginPerc");
	private static String TARGETSTDCOST_PRODSEASON_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.standardcost.productseason","kipTargetStandardCost");

	//Attributes in season
	private static String YEAR_SEASON_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.year.season","year");

	/**
	 * populateRetailMargins.
	 * @param obj for obj
	 * @throws WTException for WTException
	 * @throws WTPropertyVetoException for WTPropertyVetoException
	 */
	//This method is called upon to fetch the value of retail margin and wholesale margin
	//sets it in the product season
	public static void populateRetailMargins(WTObject obj) throws WTException, WTPropertyVetoException{
		
		LCSLog.debug("Start of populateRetailMargins method in KipProductSeasonPlugins class========>>>>>>>>");

		LCSProductSeasonLink linkObj = (LCSProductSeasonLink)obj;
		LCSProduct prodAObj = SeasonProductLocator.getProductARev(linkObj);

		String gbaKey = (String)prodAObj.getValue(GBA_PRODUCT_ATTKEY);
		String subCategoryProdKey = (String)prodAObj.getValue(SUBCATEGORY_PRODUCT_ATTKEY);
		LCSLifecycleManaged collectionEUprod = (LCSLifecycleManaged)prodAObj.getValue(COLLECTIONEU_PRODUCT_ATTKEY);
		String boStr = FormatHelper.getNumericObjectIdFromObject(collectionEUprod);

		Map attDetails =  new HashMap();
		attDetails.put("GBA", gbaKey);
		attDetails.put("COLLECTIONEU", boStr);
		attDetails.put("SUBCATEGORY", subCategoryProdKey);
		
		Map returnMap = KipCostSheetPlugins.getRetailMarginsFromBO(linkObj, attDetails, "productseason");
		
		Double rrpBo = (Double) returnMap.get("RRP");
		Double wholesaleBo = (Double) returnMap.get("WHOLESALE");

		linkObj.setValue(RRPMARGIN_PRODSEASON_ATTKEY, rrpBo);
		linkObj.setValue(WHOLESALEMARGIN_PRODSEASON_ATTKEY, wholesaleBo);
		
		LCSLog.debug("End of populateRetailMargins method in KipProductSeasonPlugins class========>>>>>>>>");

	}

	/**
	 * populateStandardCostFactors.
	 * @param obj for obj
	 * @throws WTException for WTException
	 * @throws WTPropertyVetoException for WTPropertyVetoException
	 */
	//This method is called to set the standard cost values in the product season
	public static void populateStandardCostFactors(WTObject obj) throws WTException, WTPropertyVetoException{
		
		LCSLog.debug("Start of populateStandardCostFactors method in KipProductSeasonPlugins class========>>>>>>>>");

		LCSProductSeasonLink linkObj = (LCSProductSeasonLink)obj;
		
		LCSSeason seasonObj = SeasonProductLocator.getSeasonRev(linkObj);
		
		String seasonYear = (String) seasonObj.getValue(YEAR_SEASON_ATTKEY);
		
		Double csTargetStandardCost =  KipCostSheetPlugins.getStandardCostFactorsFromBO(linkObj, seasonYear, "productseason");
		linkObj.setValue(TARGETSTDCOST_PRODSEASON_ATTKEY, csTargetStandardCost);
		
		LCSLog.debug("End of populateStandardCostFactors method in KipProductSeasonPlugins class========>>>>>>>>");
	}

}
