/*@version 1.4
 * @author Sandhya Gunturu.
 * VRDCoverPage class is written to disply first page as cover page in the PDF generated.
 * This is called from VRDPDFProductSpecPageGenerator2.java
 */


package com.vrd.wc.product;

import java.awt.Font;
import java.beans.PropertyVetoException;
import java.io.File;

import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;
import java.util.Vector;

import wt.content.ApplicationData;
import wt.content.ContentHelper;
import wt.fc.PersistenceHelper;
import wt.fc.WTObject;
import wt.util.WTException;
import wt.util.WTProperties;
import wt.util.WTMessage;
import java.util.Iterator;

import com.lcs.wc.sample.LCSSample;
import com.lcs.wc.sample.LCSSampleQuery;
import com.lcs.wc.season.LCSSeason;
import com.lcs.wc.season.LCSSeasonQuery;
import com.lcs.wc.season.LCSProductSeasonLink;
import com.lcs.wc.season.LCSSeasonProductLink;
import com.lcs.wc.sourcing.LCSSourcingConfig;
import com.lcs.wc.sourcing.LCSSourcingConfigMaster;
import com.lcs.wc.specification.FlexSpecification;
import com.lcs.wc.util.FormatHelper;
import com.lcs.wc.util.LCSLog;
import com.lcs.wc.util.LCSProperties;
import com.lcs.wc.util.VersionHelper;
import com.lcs.wc.util.RB;
import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Image;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lcs.wc.client.web.PDFGeneratorHelper;
import com.lcs.wc.construction.LCSConstructionInfo;
import com.lcs.wc.db.FlexObject;
import com.lcs.wc.db.SearchResults;
import com.lcs.wc.document.LCSDocument;
import com.lcs.wc.document.LCSDocumentHelper;
import com.lcs.wc.flexbom.FlexBOMPart;
import com.lcs.wc.flextype.FlexType;
import com.lcs.wc.part.LCSPartMaster;
import com.lcs.wc.specification.FlexSpecQuery;
import com.lcs.wc.season.LCSSeasonMaster;
import com.lcs.wc.foundation.LCSQuery;
import com.lcs.wc.measurements.LCSMeasurements;
import com.lcs.wc.product.LCSProduct;
import com.lcs.wc.product.LCSProductQuery;
import com.lcs.wc.util.FileLocation;
import com.lowagie.text.pdf.PdfWriter;

public class VRDCoverPage {

	private static PDFGeneratorHelper pgh = new PDFGeneratorHelper();
	
	private VRDPSDUtil util = null; 
	public static String PRODUCT_ID = "PRODUCT_ID"; 
    public static  String SPEC_ID = "SPEC_ID";
    public static String SEASON_MASTER_ID = "SEASONMASTER_ID";
	private static FlexSpecification spec;
    public static final String disclaimerText = LCSProperties.get("com.vrd.wc.techpack.Disclaimer");
	public static String fileExtns =  LCSProperties.get("com.vrd.wc.techpack.CoverPageContentImageExtensionType");
	public static float imageDimension = LCSProperties.get("com.vrd.wc.techpack.CoverPageContentImageScalingDimension",250f);
	private static String RB_VALUEREADY = "com.lcs.wc.resource.ValueReadyRB";
	private static String tableContentsLbl = WTMessage.getLocalizedMessage ( RB_VALUEREADY, "tableOfContents_LBL", RB.objA ) ;
	private static String componentListLbl = WTMessage.getLocalizedMessage ( RB_VALUEREADY, "componentList_LBL", RB.objA ) ;
	private static String lastUpdatedLbl = WTMessage.getLocalizedMessage ( RB_VALUEREADY, "lastUpdate_LBL", RB.objA ) ;
   
    /*This method is called from VRDpdfProductSpecGenerator2,internally 
     * is calling methods to get the cover page content.
     * @param doc
     * @param params
     * @param keys
     * @return void
     * 
     */
    
	public void drawCoverpageContent(PdfWriter writer, Document doc,Map params,Collection keys)
	{
		 
		try{
		
			float mainHeight = writer.getVerticalPosition(true)-doc.bottomMargin()-20f;
			float mainWidth = doc.getPageSize().getWidth()-doc.rightMargin()-doc.leftMargin();
			float disclaimerHeight = 40f;
			float blankHeight = 5f;
			float cellTableHeight = mainHeight-blankHeight-disclaimerHeight-3f;
			float attHeight = 40f;
			float imageCellHeight = cellTableHeight-attHeight;
			float width[]= {75.0f,25.0f};
			float imageMaxHeight = imageCellHeight-20f; // NEED TO ADD SOME PADDING
			float imageMaxWidth = mainWidth*(width[0]/100f)-50f; // NEED TO ADD SOME PADDING
			float imageMaxSize = Math.min(imageMaxHeight,imageMaxWidth);

			if(imageDimension>imageMaxSize) {
				imageDimension = imageMaxSize;
			}

			PdfPTable finalTable = new PdfPTable(1);
			PdfPTable mainTable = new PdfPTable(1);
			LCSProduct product = null;
			util = new VRDPSDUtil();
			product = (LCSProduct) LCSProductQuery.findObjectById((String) params.get("PRODUCT_ID"));			
			
			//PdfPTable coverpageTable = new PdfPTable(2); 
			PdfPTable coverpageTable = new PdfPTable(1); 
			//coverpageTable.setWidths(width);
			try
			{
				PdfPCell coverPageAttributesCell = coverPageAttributes(params);
				coverPageAttributesCell.setBorder(0);
				coverPageAttributesCell.setBorderWidthRight(0.5F);
				PdfPCell imageCell = addImageContentTable(params);
				imageCell.setBorder(1);
				imageCell.setBorderWidthRight(0.5f);
				imageCell.setBorderWidthBottom(0.5f);
				imageCell.setBorderWidthTop(0.5f);
				imageCell.setBorderWidthLeft(0.5f);				
			
				//PdfPCell tocCell = createTableOfContent(keys,params);

				coverPageAttributesCell.setFixedHeight(attHeight);					
				coverpageTable.addCell(coverPageAttributesCell);
				
				imageCell.setFixedHeight(imageCellHeight);
				coverpageTable.addCell(imageCell);		

				//tocCell.setFixedHeight(imageCellHeight);					
				//coverpageTable.addCell(tocCell);

				PdfPCell emptyCell =new PdfPCell(pgh.multiFontPara(" "));
				emptyCell.setBorder(1);
				//coverpageTable.addCell(emptyCell);
				
			}catch(Exception e){ 
				LCSLog.stackTrace(e);
			}
			coverpageTable.setWidthPercentage(100F);
			
			PdfPCell cellTable = new PdfPCell(coverpageTable);
			cellTable.setBorder(0);
			cellTable.setFixedHeight(cellTableHeight);
			mainTable.addCell(cellTable);
			
			mainTable.addCell(util.createBlankDataCell(blankHeight));
			
			PdfPCell cell = returnTableOfContentCell(disclaimerText, 7, true);
			cell.setBorderWidth(1.0f);
			cell.setFixedHeight(disclaimerHeight);
			mainTable.addCell(cell);
			
			mainTable.setWidthPercentage(100f);
			PdfPCell mainCell = new PdfPCell();
			mainCell.setFixedHeight(mainHeight);
			mainCell.addElement(mainTable);
			mainCell.setBorderWidth(1.0f);
			finalTable.addCell(mainCell);
			finalTable.setWidthPercentage(95F);
			
			doc.add(finalTable);
			
		}catch(Exception e){ 
			LCSLog.stackTrace(e);
		}
	}
/*This method is called to get coverpage attributes.
     * @param params
     * @return PdfPCell
     * 
     */
   public PdfPCell coverPageAttributes(Map params){
	
	StringTokenizer classToken = null;
	String className = null; 
	String keyName = null;
	String tempKey = null;
	StringTokenizer attToken=null;
	WTObject object=null;
	FlexType type = null; 
	String seasonId=null;
	LCSProduct product = null;
	LCSSeason season = null;
	LCSSeasonProductLink productLink = null;
	FlexSpecification spec = null;
	String key=null;
	String displayValue=null;
	PdfPCell cell= null;
	String value=null;
	String columnCount= LCSProperties.get("com.vrd.wc.techpack.ContentPageColumnNumber");
	columnCount="4";
	PdfPTable attTable= new PdfPTable(FormatHelper.parseInt(columnCount));
	PdfPCell contentRowCell = null;
	PdfPCell spacerCell = new PdfPCell(pgh.multiFontPara(" "));
	try{
		String contentRowAttributes = LCSProperties.get("com.vrd.wc.techpack.ContentPageAttributes"); 	
		
		if (FormatHelper.hasContent(contentRowAttributes)) 
		{ 		
			classToken = new StringTokenizer(contentRowAttributes,"|~*~|");
			int attCount =Integer.parseInt(LCSProperties.get("com.vrd.wc.techpack.ContentPageColumnNumber"));
			if (!FormatHelper.hasContent((String) params.get(PRODUCT_ID))) {
				throw new WTException(
						"Can not create PDFProductSpecificationHeader without product_ID");
			} 
			product = (LCSProduct) LCSProductQuery.findObjectById((String) params.get(PRODUCT_ID));
			
			if (!params.containsKey(SEASON_MASTER_ID)) {
				
				 LCSProduct productObject = LCSProductQuery.getProductVersion((LCSPartMaster)product.getMaster(),"B");
				season=LCSSeasonQuery.findSeasonUsed(productObject);
				
			}else{
				seasonId = (String) params.get(SEASON_MASTER_ID);
				LCSSeasonMaster seasonOBJ = (LCSSeasonMaster) LCSQuery
			   .findObjectById(seasonId);
				if (FormatHelper.hasContent(seasonId)) {
				 season = (LCSSeason) VersionHelper.latestIterationOf(seasonOBJ);
				}
			}
			if(season != null) {
				productLink = LCSSeasonQuery.findSeasonProductLink(product,season);
			}

			int countAttributesperRow=0;
			while(classToken.hasMoreTokens()){
				tempKey = classToken.nextToken();
				attToken = new StringTokenizer(tempKey,":");
				if(attToken.hasMoreTokens()){
					className = (String)attToken.nextToken();
					if("Product".equalsIgnoreCase(className)){
						 
						type = product.getFlexType();
						object = product;
						  
					}else if("Season".equalsIgnoreCase(className)){
						type = season.getFlexType();
						  object = season;
					 
					}else if("Product-Season".equalsIgnoreCase(className)){
									 
						type = productLink.getFlexType();
						object = (LCSProductSeasonLink) productLink;
									 
					}else if("Specification".equalsIgnoreCase(className)){
						spec = (FlexSpecification) LCSProductQuery
						.findObjectById((String) params.get(SPEC_ID));
						type = spec.getFlexType();
						object = spec;
					}
					keyName = (String)attToken.nextToken();
					attToken = new StringTokenizer(keyName,",");
					while(attToken.hasMoreTokens()){
						key = attToken.nextToken();
						displayValue = type.getAttribute(key).getAttDisplay();
						countAttributesperRow+=1;
						if(countAttributesperRow <=attCount){
							
						cell = new PdfPCell(pgh.multiFontPara(displayValue +" : ",pgh.getCellFont("FORMLABEL", null, null)));
						cell.setBorder(1);
						cell.setBorderWidthRight(0.5f);
						cell.setBorderWidthLeft(0.5f);
						attTable.addCell(cell);
						
						value = VRDTechPackUtil.getData(object, key, null);
						cell = new PdfPCell(pgh.multiFontPara(value,pgh.getCellFont("DISPLAYTEXT", null, null)));
						cell.setBorder(1);
						cell.setBorderWidthRight(0.5f);
						attTable.addCell(cell); 
						}
						
					}
				}
				
			}//Added code to add empty cell  when there is a mismatch in the property entries for the header attributes.
			if(countAttributesperRow < attCount ){
				int attributeCountDiff=attCount-countAttributesperRow;
				for(int i=0;i<=attributeCountDiff;i++){
					cell =new PdfPCell(spacerCell);
					cell.setBorder(0);
					attTable.addCell(cell);
				}
			}
			contentRowCell= new PdfPCell(attTable);
			contentRowCell.setBorder(0);
		}
	}catch(Exception e){
		LCSLog.stackTrace(e);
	}
	return contentRowCell;
}
   
   /**This method is called to get coverpage Image.
    * @return PdfPCell
    * @throws Exception
    */ 
	public  PdfPCell createCoverPageImage(Map params) throws WTException{
		PdfPCell imageCell=null;
		try{
			Image image = null;
			String imageUrl="";
			WTObject obj2 =  (WTObject)LCSProductQuery.findObjectById((String)params.get(SPEC_ID));
			if(obj2 instanceof FlexSpecification){
				spec = (FlexSpecification)obj2;
			}
			imageUrl = FileLocation.imageNotAvailable;
			image = Image.getInstance(imageUrl);
			
			LCSProduct prodObj = (LCSProduct) LCSProductQuery.findObjectById((String) params.get("PRODUCT_ID"));	
			String prodImageURL = prodObj.getPartPrimaryImageURL();
			
			if(!FormatHelper.hasContent(prodImageURL)){
				prodImageURL = FileLocation.imageNotAvailable;
			}else{
				prodImageURL = prodImageURL.replaceFirst("Windchill/", "");
				prodImageURL = FileLocation.codebase+prodImageURL;
			}
			
			imageUrl = prodImageURL; 
				
			image = Image.getInstance(imageUrl); 
			image.scalePercent(1000.0f);
			image.scaleToFit(imageDimension,imageDimension);
			imageCell = new PdfPCell(image);
		}catch(Exception e){
			Image img = null;
			try{
			img = Image.getInstance(FileLocation.imageNotAvailable);
			}catch(Exception exp){
				exp.printStackTrace();
			}
			img.scalePercent(1000.0f);
			img.scaleToFit(imageDimension,imageDimension);
			imageCell = new PdfPCell(img);
		}
		imageCell.setHorizontalAlignment(Element.ALIGN_CENTER);
		imageCell.setVerticalAlignment(Element.ALIGN_MIDDLE);

		return imageCell;
	}
	
/**This method is used to get one cell of Image Page.
    * @return String
    * @throws Exception
    */ 
	
	/*public static String getImageURL(LCSDocument imgObj) throws WTException {
		String imgURL = FileLocation.imageNotAvailable;
		String strFileName = null;
		boolean checkFlag = false;
		LCSDocument imageDoc = null;
		try{	
			imageDoc = (LCSDocument)ContentHelper.service.getContents(imgObj);
			Vector ads = ContentHelper.getApplicationData(imageDoc);
			if(imageDoc != null) {
				ApplicationData data = null;
				for(int i = 0; i < ads.size(); i++){
					 data = (ApplicationData)ads.elementAt(i);					 
					 strFileName = data.getFileName();					 				
					 checkFlag = checkFileNameExtn(strFileName);					 
					 if(!checkFlag)
						break;					 
				}				
				if(data != null) { 							
					imgURL = LCSDocumentHelper.service.downloadContent(data);									
				}
			}
		}catch(PropertyVetoException e){
			e.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	
		return imgURL;
	}*/
	
	/**This method is used to get the webviwable Images rather than ai,pdf etc.
    * @return boolean
    * @param strFileName
    */ 
	
	/*
	public static boolean checkFileNameExtn(String strFileName)
	{
		boolean checkFlag = false;
		StringTokenizer fileTokens = null;
		String strTemp = null;
		fileTokens = new StringTokenizer(fileExtns,",");		
		if (FormatHelper.hasContent(strFileName))
		{
			while(fileTokens.hasMoreTokens())
			{
				strTemp = fileTokens.nextToken();				
				if(strFileName.endsWith(strTemp))
				{
					checkFlag = true;
					break;
				}			 
			}			
		}
		return checkFlag;
	}
	*/
	
	/**
	 * This method generates the Table of Content table
	 * @param params
	 * @param keys
	 * @return
	 * @throws WTException
	 */
	/*
	private PdfPCell createTableOfContent(Collection keys,Map params) throws WTException
	{					
		float[] width = {65.0f,65.0f};		
		PdfPTable table = new PdfPTable(width);

		table.addCell(util.createBlankDataCell());
		table.addCell(util.createBlankDataCell());
		
		PdfPCell cell =returnTableOfContentCell(tableContentsLbl,8,true);
		
		cell.setColspan(2);
		table.addCell(cell);
		table.addCell(util.createBlankDataCell());
		table.addCell(util.createBlankDataCell());
		table.addCell(util.createBlankDataCell());
		table.addCell(util.createBlankDataCell());

		table.addCell(returnTableOfContentCell(componentListLbl,8,true));
		cell = returnTableOfContentCell(lastUpdatedLbl,8,true);
		cell.setHorizontalAlignment(Element.ALIGN_LEFT);
		table.addCell(cell);
		table.addCell(util.createBlankDataCell());
		table.addCell(util.createBlankDataCell()); 

		List keylist = new ArrayList(keys);
		
		
		FlexBOMPart bomFromKeyList;
		LCSDocument imageFromKeyList;
		LCSMeasurements measFromKeylist;
		LCSConstructionInfo consFromKeyList;
		LCSSample sampleFromKeyList;
		String componentName = "";
		Timestamp componentModifiedDate = null; 
		String date = "";
		DateFormat dateFormat = new SimpleDateFormat("MM/dd/yyyy");

		for(int i=0;i<=keylist.size()-1;i++){
			String contentsOfKeys = (String)keylist.get(i);
			String  entryFromKeyList;
			if(contentsOfKeys.indexOf("VR:")!=-1)
				entryFromKeyList=contentsOfKeys.substring(contentsOfKeys.indexOf("VR:"), contentsOfKeys.length());
			else
				entryFromKeyList=contentsOfKeys.substring(contentsOfKeys.indexOf("OR:"), contentsOfKeys.length());

			Object obj = LCSQuery.findObjectById(entryFromKeyList);

			if(contentsOfKeys.contains("BOM"))
			{
				bomFromKeyList = (FlexBOMPart)obj ;
				componentName = bomFromKeyList.getName();
				componentModifiedDate = PersistenceHelper.getModifyStamp(bomFromKeyList);

			}else if(contentsOfKeys.contains("Images Page")) 
			{
				imageFromKeyList = (LCSDocument)obj;
				componentName = imageFromKeyList.getName();
				componentModifiedDate = PersistenceHelper.getModifyStamp(imageFromKeyList);

			}else if(contentsOfKeys.contains("Measurements")){

				measFromKeylist= (LCSMeasurements)obj;
				componentName = measFromKeylist.getName();
				componentModifiedDate = PersistenceHelper.getModifyStamp(measFromKeylist);

			}else if(contentsOfKeys.contains("Construction")){

				consFromKeyList = (LCSConstructionInfo)obj;
				componentName = consFromKeyList.getName();
				componentModifiedDate = PersistenceHelper.getModifyStamp(consFromKeyList);
				
			}///Added code to include Sample to get in the generated Techpack during mannual selection in the Available Component list.
			else if(contentsOfKeys.contains("Sample")){
				sampleFromKeyList = (LCSSample)obj;
				componentName = sampleFromKeyList.getName();
				componentModifiedDate = PersistenceHelper.getModifyStamp(sampleFromKeyList);
				
			}
			date = dateFormat.format(componentModifiedDate);
			table.addCell(returnTableOfContentCell( componentName, 8,false));
			table.addCell(returnTableOfContentCell( date, 8,false));
		}
	     ////Added to display  samples names "when reportType is fitSpecReport" on the Table of Contents in Cover page.
		LCSProduct productObj = (LCSProduct) LCSProductQuery.findObjectById((String) params.get(PRODUCT_ID));
		FlexSpecification spec = (FlexSpecification) LCSProductQuery.findObjectById((String) params.get(SPEC_ID));
		LCSSourcingConfigMaster sourceMaterObj =(LCSSourcingConfigMaster)spec.getSpecSource();
		LCSSourcingConfig sourceObj=(LCSSourcingConfig)VersionHelper.latestIterationOf(sourceMaterObj);
		FlexType type=sourceObj.getFlexType();
		ArrayList list=(ArrayList)params.get("COMPONENT_PAGE_OPTIONS");
		if(list!=null && list.size()>1){
		String reportType=(String)list.get(1);
		
		LCSSample samplelist=null;
			if(reportType.equalsIgnoreCase("fitSpecReport")){
				
				   SearchResults sampleResults= LCSSampleQuery.findSamplesForProduct(productObj, new Hashtable(), type, sourceObj);
			       Collection sampleColl=sampleResults.getResults();
			       Iterator sampleIter=sampleColl.iterator();
					while (sampleIter.hasNext())
					{						
						FlexObject flexobj=(FlexObject)sampleIter.next();
						 String id= "OR:com.lcs.wc.sample.LCSSample:"+flexobj.get("LCSSAMPLE.IDA2A2");
						 LCSSample sample= (LCSSample)LCSQuery.findObjectById(id);
						 samplelist = sample;
						 componentName = samplelist.getName();
						 if(componentName.contains("Fit")&& !componentName.contains("PrePro")){
							 componentModifiedDate = PersistenceHelper.getModifyStamp(samplelist);
							 table.addCell(returnTableOfContentCell(componentName, 8,false));
							 table.addCell(returnTableOfContentCell(date, 8,false));
						 }
					
					} 
				}
		}
		table.addCell(util.createBlankDataCell());
		table.addCell(util.createBlankDataCell());

		cell = new PdfPCell(table);
		cell.setPaddingRight(1.0f);
		cell.setBorderWidth(0.0f);
		
		
		return cell;
	}*/
	
	/**
	 * This method generates the Text headings like Table of Content..
	 * @param phrase
	 * @param fontSize
	 * @param fontStyle
	 * @return PdfPCell
	 * 
	 */
	public static PdfPCell returnTableOfContentCell(String phrase,int fontSize,boolean fontStyle)
	{
		PdfPCell cell = null;
		Font font=null;
		if(fontStyle){
			cell = new PdfPCell(pgh.multiFontPara(phrase,pgh.getCellFont("FORMLABEL", null, ""+fontSize)));
		}
		else{
			cell = new PdfPCell(pgh.multiFontPara(phrase,pgh.getCellFont("DISPLAYTEXT", null, ""+fontSize)));
		} 	
		cell.setBorderWidth(0.0f);
		cell.setPaddingTop(1.0f);
		cell.setHorizontalAlignment(Element.ALIGN_LEFT);
		
		return cell;
	}
	/**
	 * This method is used to get the image in the coverpage according to the dimensiond providing spaces and padding.
	 * @throws Wt Exception.
	 * @return PdfPCell
	 * 
	 */
	
	private PdfPCell addImageContentTable(Map params) throws WTException{

		PdfPTable table = new PdfPTable(1);
		float[] widths = {100.0f};
		PdfPCell tableCell = null;
		PdfPCell emptyCell = new PdfPCell(pgh.multiFontPara(" ")); 

		try {
			table.setWidths(widths);
			PdfPCell cell = createCoverPageImage(params);
			cell.setBorder(0);
			table.addCell(cell);
			tableCell = new PdfPCell(table);
			tableCell.setBorder(0);
			tableCell.setHorizontalAlignment(Element.ALIGN_LEFT);
			tableCell.setVerticalAlignment(Element.ALIGN_MIDDLE);

		} catch (Exception e) {

			LCSLog.stackTrace(e);			

		}
		if(tableCell != null){
			return tableCell;
		}else{
			return emptyCell;
		}

	}
	
}

