package com.kipling.wc.sourcing;

import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import com.lcs.wc.db.FlexObject;
import com.lcs.wc.flextype.FlexType;
import com.lcs.wc.flextype.FlexTypeAttribute;
import com.lcs.wc.flextype.FlexTypeCache;
import com.lcs.wc.flextype.FlexTyped;
import com.lcs.wc.foundation.LCSLifecycleManaged;
import com.lcs.wc.foundation.LCSLifecycleManagedQuery;
import com.lcs.wc.foundation.LCSQuery;
import com.lcs.wc.product.LCSProduct;
import com.lcs.wc.season.LCSSeason;
import com.lcs.wc.season.LCSSeasonQuery;
import com.lcs.wc.season.SeasonProductLocator;
import com.lcs.wc.sourcing.LCSProductCostSheet;
import com.lcs.wc.util.FormatHelper;
import com.lcs.wc.util.LCSLog;
import com.lcs.wc.util.LCSProperties;
import com.lcs.wc.util.VersionHelper;

import wt.fc.WTObject;
import wt.util.WTException;
import wt.util.WTPropertyVetoException;

public final class KipCostSheetPlugins {

	
	private KipCostSheetPlugins(){
		
	}
	//Attributes to be considered fr fetching margin details
	private static String GBA_PRODUCT_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.gba.product","kipGBA");
	private static String COLLECTIONEU_PRODUCT_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.collectioneu.product","kipCollectionEU");
	private static String SUBCATEGORY_PRODUCT_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.productsubcategory.product","kipProductSubCategory");

	//Attributes in margin tables
	private static String GBA_BO_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.gba.margintables.businessobject","kipGBALookupTables");
	private static String COLLECTIONEU_BO_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.collectioneu.margintables.businessobject","kipCollectionEULookupTables");
	private static String SUBCATEGORY_BO_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.productsubcategory.margintables.businessobject","kipProductSubCategoryLookupTables");
	private static String RRPMARGIN_BO_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.rrpmargin.margintables.businessobject","kipTargetRRPMarginPercLookupTables");
	private static String WHOLESALEMARGIN_BO_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.wholesalemargin.margintables.businessobject","kipTargetWholesaleMarginPercLookupTables");

	//Attributes in costsheet
	private static String RRPMARGIN_COSTSHEET_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.rrpmargin.costsheet","vrdTargetRetailMargin");
	private static String WHOLESALEMARGIN_CCOSTSHEET_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.wholesalemargin.costsheet","vrdTargetWhlslMargin");
	private static String TARGETSTDCOST_COSTSHEET_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.standardcost.costsheet","kipTargetStandardCostEMEAUS");

	//Hierarchy attributes
	private static String MARGINTABLE_HIERARCHY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.margintables.hierarchy","Business Object\\Lookup Tables\\Margin_LookupTables_BusinessObject");
	private static String STANDARDCOST_HIERARCHY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.standardcost.hierarchy","Business Object\\Lookup Tables\\StandardCostFactors_LookupTables_BusinessObject");

	//Attributes in season
	private static String YEAR_SEASON_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.year.season","year");
    
	//Attributes in standard cost business object
	private static String YEAR_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.year.standardcost.businessobject","kipYearStdCost");
	private static String AIRFREIGHT_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.airfreight.standardcost.businessobject","kipAirFrieghtStdCost");
	private static String DUTIES_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.duties.standardcost.businessobject","kipDutiesStdCost");
	private static String FREIGHT_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.freight.standardcost.businessobject","kipFreightStdCost");
	private static String GSOFEE_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.gsofee.standardcost.businessobject","kipGSOFeeStdCost");
	private static String NOTUSED_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.notused.standardcost.businessobject","kipNotUsedStdCost");
	private static String NOTUSEDROUND_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.notusedround.standardcost.businessobject","kipNotUsedRoundStdCost");
    private static String OPERATIONS_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.operations.standardcost.businessobject","kipOperationsStdCost");
    private static String PLANNING_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.planning.standardcost.businessobject","kipPlanningStdCost");
    private static String QUALITYCONTROL_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.qualitycontrol.standardcost.businessobject","kipQualityControlStdCost");
    private static String RESERVES_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.reserves.standardcost.businessobject","kipReservesStdCost");
    private static String ROYALTIES_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.royalties.standardcost.businessobject","kipRoyaltiesStdCost");
    private static String SOURCING_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.sourcing.standardcost.businessobject","kipSourcingStdCost");
    private static String WARRANTY_STDCOST_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.warranty.standardcost.businessobject","kipWarrantyStdCost");

    //Static vairables which stores the percentages from business object
	public static Double gsoFeeBO = 0.00;
	public static Double airFreightBO = 0.00;
	public static Double dutiesBO = 0.00;
	public static Double freightBO = 0.00;
	public static Double notUsedBO = 0.00;
	public static Double notUsedRoundBO = 0.00;
	public static Double operationsBO = 0.00;
	public static Double planningBO = 0.00;
	public static Double qualityControlBO = 0.00;
	public static Double reservesBO = 0.00;
	public static Double royaltiesBO = 0.00;
	public static Double sourcingBO = 0.00;
	public static Double warrantyBO = 0.00;

    //Static vairables which stores the converted values
	public static Double gsoFee = 0.00;
	public static Double airFreight = 0.00;
	public static Double duties = 0.00;
	public static Double freight = 0.00;
	public static Double notUsed = 0.00;
	public static Double notUsedRound = 0.00;
	public static Double operations = 0.00;
	public static Double planning = 0.00;
	public static Double qualityControl = 0.00;
	public static Double reserves = 0.00;
	public static Double royalties = 0.00;
	public static Double sourcing = 0.00;
	public static Double warranty = 0.00;
	public static Double targetFOB = 0.00;
	public static Double targetStdCost = 0.00;
	public static Double subTotalRound = 0.00;
	public static Double subTotal = 0.00;
	

	/**
	 * populateRetailMargins.
	 * @param obj for obj
	 * @throws WTException for WTException
	 * @throws WTPropertyVetoException for WTPropertyVetoException
	 */
	//This method is called upon to fetch the value of retail margin and wholesale margin
	//sets it in the Costs sheet
	public static void populateRetailMargins(WTObject obj) throws WTException, WTPropertyVetoException{
		
		LCSLog.debug("Start of populateRetailMargins method in KipCostSheetPlugins class========>>>>>>>>");
		
		LCSProductCostSheet csObj = (LCSProductCostSheet)obj;
		
		LCSProduct prodObj = (LCSProduct) VersionHelper.latestIterationOf(csObj.getProductMaster());
		prodObj = SeasonProductLocator.getProductARev(prodObj);
		
		//Getting all the attributes from the product
		String gbaKey = (String)prodObj.getValue(GBA_PRODUCT_ATTKEY);
		String subCategoryProdKey = (String)prodObj.getValue(SUBCATEGORY_PRODUCT_ATTKEY);
		LCSLifecycleManaged collectionEUprod = (LCSLifecycleManaged)prodObj.getValue(COLLECTIONEU_PRODUCT_ATTKEY);
		String boStr = FormatHelper.getNumericObjectIdFromObject(collectionEUprod);

		//putting the values in a map
		Map attDetails =  new HashMap();
		attDetails.put("GBA", gbaKey);
		attDetails.put("COLLECTIONEU", boStr);
		attDetails.put("SUBCATEGORY", subCategoryProdKey);
		
		Map returnMap = getRetailMarginsFromBO(csObj, attDetails, "costsheet");
		
		//getting the values from the map
		Double rrpBo = (Double) returnMap.get("RRP");
		Double wholesaleBo = (Double) returnMap.get("WHOLESALE");

		//Setting the values in the cost sheet
		csObj.setValue(RRPMARGIN_COSTSHEET_ATTKEY, rrpBo);
		csObj.setValue(WHOLESALEMARGIN_CCOSTSHEET_ATTKEY, wholesaleBo);

		LCSLog.debug("End of populateRetailMargins method in KipCostSheetPlugins class========>>>>>>>>");
	}
	
	/**
	 * populateStandardCostFactors.
	 * @param obj for obj
	 * @throws WTException for WTException
	 * @throws WTPropertyVetoException for WTPropertyVetoException
	 */
	//This method is called to set the standard cost values in the cost sheet
	public static void populateStandardCostFactors(WTObject obj) throws WTException, WTPropertyVetoException{
		
		LCSLog.debug("Start of populateStandardCostFactors method in KipCostSheetPlugins class========>>>>>>>>");

		LCSProductCostSheet csObj = (LCSProductCostSheet)obj;
		
		//getting the season object from the link
		LCSProduct prodObj = (LCSProduct) VersionHelper.latestIterationOf(csObj.getProductMaster());
		LCSSeason seasonObj = LCSSeasonQuery.findSeasonUsed(prodObj);
		
		//getting the year object
		String seasonYear = (String) seasonObj.getValue(YEAR_SEASON_ATTKEY);
		
		//getting the standard cost
		Double csTargetStandardCost =  getStandardCostFactorsFromBO(csObj, seasonYear, "costsheet");
		
		//setting the standard cost in cost sheet
		csObj.setValue(TARGETSTDCOST_COSTSHEET_ATTKEY, csTargetStandardCost);
		LCSLog.debug("End of populateStandardCostFactors method in KipCostSheetPlugins class========>>>>>>>>");
	}
		
	/**
	 * getStandardCostFactorsFromBO.
	 * @param flextypedObj for flextypedObj
	 * @param seasonYear for seasonYear
	 * @param objectType for objectType
	 * @return double for double
	 * @throws WTException for WTException
	 */ 
	//custom method to calculate the standard costs
	public static Double getStandardCostFactorsFromBO(FlexTyped flextypedObj, String seasonYear, String objectType) throws WTException{
	
		LCSLog.debug("Start of getStandardCostFactorsFromBO method in KipCostSheetPlugins class========>>>>>>>>");

		//getting the property value depending upon either its a costsheet or product season
		String FOB_ATTKEY = LCSProperties.get("com.kipling.wc.sourcing.KiplingCostSheetPlugins.targetfobemea."+objectType);

		//constructing the search input criteria
		FlexType boType = FlexTypeCache.getFlexTypeFromPath(STANDARDCOST_HIERARCHY);
		Map inputCriteria = new HashMap();
		FlexTypeAttribute yearAttribute = boType.getAttribute(YEAR_STDCOST_ATTKEY);
		inputCriteria.put(yearAttribute.getSearchCriteriaIndex(), seasonYear);
	
		//querying the business objects
		LCSLifecycleManagedQuery qry = new LCSLifecycleManagedQuery();		
		Collection boCol = qry.findLifecycleManagedsByCriteria(inputCriteria, boType, null, null, null).getResults();
	
		//iterating the collection
		Iterator boItr = boCol.iterator();
			while(boItr.hasNext()){
					FlexObject fObj = (FlexObject) boItr.next();
					String boId = fObj.getString("LCSLIFECYCLEMANAGED.IDA2A2");
					LCSLifecycleManaged boObj = (LCSLifecycleManaged) LCSQuery.findObjectById("OR:com.lcs.wc.foundation.LCSLifecycleManaged:"+boId);

					//getting all the attributes from business objects
					gsoFeeBO = (Double) boObj.getValue(GSOFEE_STDCOST_ATTKEY);
					airFreightBO = (Double) boObj.getValue(AIRFREIGHT_STDCOST_ATTKEY);
					dutiesBO = (Double) boObj.getValue(DUTIES_STDCOST_ATTKEY);
					freightBO = (Double) boObj.getValue(FREIGHT_STDCOST_ATTKEY);
					notUsedBO = (Double) boObj.getValue(NOTUSED_STDCOST_ATTKEY);
					notUsedRoundBO = (Double) boObj.getValue(NOTUSEDROUND_STDCOST_ATTKEY);
					operationsBO = (Double) boObj.getValue(OPERATIONS_STDCOST_ATTKEY);
					planningBO = (Double) boObj.getValue(PLANNING_STDCOST_ATTKEY);
					qualityControlBO = (Double) boObj.getValue(QUALITYCONTROL_STDCOST_ATTKEY);
					reservesBO = (Double) boObj.getValue(RESERVES_STDCOST_ATTKEY);
					royaltiesBO = (Double) boObj.getValue(ROYALTIES_STDCOST_ATTKEY);
					sourcingBO = (Double) boObj.getValue(SOURCING_STDCOST_ATTKEY);
					warrantyBO = (Double) boObj.getValue(WARRANTY_STDCOST_ATTKEY);

					//performing calculations as per the formulas
					targetFOB = (Double)flextypedObj.getValue(FOB_ATTKEY);
					targetFOB = roundOffTwoPlaces(targetFOB);
					
					gsoFee = targetFOB*gsoFeeBO/100;
					gsoFee = roundOffTwoPlaces(gsoFee);
					
					freight = targetFOB*freightBO/100;
					freight = roundOffTwoPlaces(freight);
			
					airFreight = targetFOB*airFreightBO/100;
					airFreight = roundOffTwoPlaces(airFreight);
			
					notUsedRound = targetFOB*notUsedRoundBO/100;
					notUsedRound = roundOffTwoPlaces(notUsedRound);
			
					subTotalRound = targetFOB+gsoFee+freight+airFreight+notUsedRound;
					subTotalRound = roundOffTwoPlaces(subTotalRound);
					
					duties = (targetFOB+freight+airFreight)*dutiesBO/100; 
					duties = roundOffTwoPlaces(duties);
					
					subTotal = subTotalRound + duties;			
					notUsed = subTotal*notUsedBO/100;			
					operations = subTotal * operationsBO/100;			
					planning = subTotal * planningBO/100;
					sourcing = subTotal * sourcingBO/100;			
					royalties = subTotal * royaltiesBO/100;
					qualityControl = subTotal * qualityControlBO/100;			
					warranty = subTotal * warrantyBO/100;			
					reserves = subTotal*reservesBO/100;
					targetStdCost = subTotal+notUsed+operations+planning+sourcing+royalties+qualityControl+warranty+reserves;
					targetStdCost = roundOffTwoPlaces(targetStdCost);
		
			}
			LCSLog.debug("End of getStandardCostFactorsFromBO method in KipCostSheetPlugins class========>>>>>>>>");

			return targetStdCost;

	}

	/**
	 * getRetailMarginsFromBO.
	 * @param flextypedObj for flextypedObj
	 * @param attDetails for attDetails
	 * @param objectType for objectType
	 * @return map for map
	 * @throws WTException for WTException
	 */
	//custom method to get the retail margins
	public static Map getRetailMarginsFromBO(FlexTyped flextypedObj, Map attDetails, String objectType) throws WTException{
		
		LCSLog.debug("Start of getRetailMarginsFromBO method in KipCostSheetPlugins class========>>>>>>>>");

		Map returnMap = new HashMap();
		
		//getting all the values from the map
		String gbaKey = (String) attDetails.get("GBA");
		String boStr  = (String) attDetails.get("COLLECTIONEU");
		String subCategoryProdKey = (String) attDetails.get("SUBCATEGORY");

		//constructing the search input criteria
		Map inputCriteria  = new HashMap();
		FlexType boType = FlexTypeCache.getFlexTypeFromPath(MARGINTABLE_HIERARCHY);
		FlexTypeAttribute gbaBOAttribute = boType.getAttribute(GBA_BO_ATTKEY);
		FlexTypeAttribute collectioneuBOAttribute = boType.getAttribute(COLLECTIONEU_BO_ATTKEY);
		FlexTypeAttribute subcategoryBOAttribute = boType.getAttribute(SUBCATEGORY_BO_ATTKEY);
			
		inputCriteria.put(gbaBOAttribute.getSearchCriteriaIndex(),gbaKey);
		inputCriteria.put(subcategoryBOAttribute.getSearchCriteriaIndex(), subCategoryProdKey);
		inputCriteria.put(collectioneuBOAttribute.getSearchCriteriaIndex(), boStr);
		
		//querying the business objects
		LCSLifecycleManagedQuery qry =  new LCSLifecycleManagedQuery();
		Collection boCol = qry.findLifecycleManagedsByCriteria(inputCriteria, boType, null, null, null).getResults();
		
		Double rrpBo = 0.00;
		Double wholesaleBo = 0.00;

			Iterator boItr = boCol.iterator();
				
				//iterating the collection
				while(boItr.hasNext()){
					FlexObject fObj = (FlexObject) boItr.next();
					String boId = fObj.getString("LCSLIFECYCLEMANAGED.IDA2A2");
					LCSLifecycleManaged boObj = (LCSLifecycleManaged) LCSQuery.findObjectById("OR:com.lcs.wc.foundation.LCSLifecycleManaged:"+boId);
					
					rrpBo = (Double) boObj.getValue(RRPMARGIN_BO_ATTKEY);
					wholesaleBo = (Double) boObj.getValue(WHOLESALEMARGIN_BO_ATTKEY);
					
					returnMap.put("RRP", rrpBo);
					returnMap.put("WHOLESALE", wholesaleBo);
					break;
				}

		LCSLog.debug("End of getRetailMarginsFromBO method in KipCostSheetPlugins class========>>>>>>>>");

		return returnMap;
	}
	
	/**
	 * roundOffTwoPlaces.
	 * @param dbl for dbl
	 * @return double for double
	 */
	//custom method to round off the double to 2 decimal places
	public static Double roundOffTwoPlaces(Double dbl){	
		LCSLog.debug("Start of roundOffTwoPlaces method in KipCostSheetPlugins class========>>>>>>>>");
		LCSLog.debug("Start of roundOffTwoPlaces method in KipCostSheetPlugins class========>>>>>>>>");

		return Math.round(dbl * 100.0) / 100.0;
	}

}