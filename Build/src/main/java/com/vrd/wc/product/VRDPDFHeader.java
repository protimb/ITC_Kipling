
/*@version 1.4
 * @author Sandhya Gunturu.
 * VRDPDFHeader class is written to get header for every  page generated.
 * This is called from VRDPDFProductSpecPageHeaderGenerator.java
 */
package com.vrd.wc.product;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.util.Map;
import java.util.StringTokenizer;

import wt.fc.WTObject;
import wt.util.WTException;
import wt.util.WTProperties;

import com.lcs.wc.client.web.PDFGeneratorHelper;
import com.lcs.wc.flextype.FlexType;
import com.lcs.wc.flextype.FlexTypeCache;
import com.lcs.wc.foundation.LCSQuery;
import com.lcs.wc.part.LCSPartMaster;
import com.lcs.wc.product.LCSProduct;
import com.lcs.wc.product.LCSProductQuery;
import com.lcs.wc.season.LCSSeason;
import com.lcs.wc.season.LCSProductSeasonLink;
import com.lcs.wc.season.LCSSeasonProductLink;
import com.lcs.wc.season.LCSSeasonQuery;
import com.lcs.wc.season.LCSSeasonMaster;
import com.lcs.wc.specification.FlexSpecification;
import com.lcs.wc.util.FileLocation;
import com.lcs.wc.util.FormatHelper;
import com.lcs.wc.util.LCSLog;
import com.lcs.wc.util.LCSProperties;
import com.lcs.wc.util.VersionHelper;
import com.lowagie.text.BadElementException;
import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Image;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.ptc.windchill.uwgm.cadx.createecaddesign.documentECADResource;


public class VRDPDFHeader {

    public static String PRODUCT_ID = "PRODUCT_ID";
    public static String SPEC_ID = "SPEC_ID";
    public static String SEASON_MASTER_ID = "SEASONMASTER_ID";
    public static PDFGeneratorHelper pgh = new PDFGeneratorHelper();
    private static final String IMAGE_NOT_FOUND = LCSProperties.get("com.vrd.wc.techpack.ImageNotFoundURL");
    private Image imageNotFound = null;
    public static String wt_home = "";
    public static String imageFile = "";

    /*
     * This method is called from VRDPDFProductSpecPageHeaderGenerator.java
     *
     * @param doc @param params @return void
     *
     */
    public void drawContent(Document doc, Map params) {
        try {   

        	wt_home = WTProperties.getServerProperties().getProperty("wt.home");
            imageFile = FormatHelper.formatOSFolderLocation(wt_home) + FormatHelper.formatOSFolderLocation(IMAGE_NOT_FOUND);

            imageNotFound = Image.getInstance(imageFile);
            PdfPTable headerTable = new PdfPTable(1);
            PdfPCell cell = createFirstRowDataCell(params, "first",doc);
            headerTable.addCell(cell);
            //cell = createFirstRowDataCell(params, "second");
            //headerTable.addCell(cell);
            //cell = createFirstRowDataCell(params, "third");
            //headerTable.addCell(cell);
            headerTable.setWidthPercentage(95F);
            headerTable.setSpacingAfter(5.0F);
            doc.add(headerTable);
        } catch (Exception e) {
            LCSLog.stackTrace(e);
        }
    }

    /*
     * This method is called for each row in the header,which takes the row
     * name,depending on which the row order,number of attributes per row is
     * decided.This is the method called for all the three row data in the
     * header. @param rowName @param params @return PdfPCell
     *
     */
    public PdfPCell createFirstRowDataCell(Map params, String rowName,Document doc) {
        String key = null;
        PdfPCell spacerCell = new PdfPCell(pgh.multiFontPara(" "));
        String firstRowDetails = LCSProperties.get("com.vrd.wc.techpack.header." + rowName + "RowOrder");
        String attributesKey = null;
        StringTokenizer classToken = null;
        StringTokenizer attToken = null;
        String className = null;
        String keyName = null;
        String tempKey = null;
        LCSProduct product = null;
        LCSSeason season = null;
        LCSSeasonProductLink productLink = null;
        String seasonId = null;
        int attCount = Integer.parseInt(LCSProperties.get("com.vrd.wc.techpack.header." + rowName + "RowColumnNumber"));
        String displayValue = null;
        String value = null;
        PdfPTable attTable = null;
        FlexType type = null;
        FlexTypeCache typeCache = null;
        PdfPCell attCell = null;
        PdfPCell firstRowCell = null;
        FlexSpecification spec = null;
        int columnsIntable = 4;

        try {
            if (!FormatHelper.hasContent((String) params.get(PRODUCT_ID))) {
                throw new WTException(
                        "Can not create PDFProductSpecificationHeader without product_ID");
            }
            product = (LCSProduct) LCSProductQuery.findObjectById((String) params.get(PRODUCT_ID));
            if (params.containsKey(SEASON_MASTER_ID)) {
                seasonId = (String) params.get(SEASON_MASTER_ID);
                LCSSeasonMaster seasonOBJ = (LCSSeasonMaster) LCSQuery.findObjectById(seasonId);
                if (FormatHelper.hasContent(seasonId)) {
                    season = (LCSSeason) VersionHelper.latestIterationOf(seasonOBJ);
                }
            }

                /*
                 * Fix: Removed the following code for VRD Tech Pack Design.
                 *
                 * else { LCSProduct productObject =
                 * LCSProductQuery.getProductVersion((LCSPartMaster)product.getMaster(),"B");
                 * season = LCSSeasonQuery.findSeasonUsed(productObject); }
                 *
                 * This fix removes the assumption that any season is acceptable
                 * in the case that a Product does not have a season associated
                 * to it.
                 *
                 * Name: Darron Brumsey 
                 * Date: 7.9.2014
                 */
            	
           
                if (null != season) {
                    productLink = LCSSeasonQuery.findSeasonProductLink(product, season);
                }
                StringTokenizer st = new StringTokenizer(firstRowDetails, "|~*~|");
                int firstRowCount = st.countTokens();
                PdfPTable firstRowTable = new PdfPTable(firstRowCount);
                float first[] = {20F, 70F,10F};
                float second[] = {100F};

                if ("first".equalsIgnoreCase(rowName)) {
                    firstRowTable.setWidths(first);
                } else if ("second".equalsIgnoreCase(rowName)) {
                    firstRowTable.setWidths(second);
                }
                PdfPCell cell = null;
                attTable = new PdfPTable(columnsIntable);
				float attWidths[] = new float[columnsIntable];
				for (int i=0; i<columnsIntable; i++) {
					attWidths[i] = (i%2)*30f+35f;
				}
				attTable.setWidths(attWidths);

                while (st.hasMoreTokens()) {

                    key = st.nextToken();
                    int countAttributesperRow = 0;
                    if ("image".equalsIgnoreCase(key)) {
                        firstRowTable.addCell(createImageCell());
                    } else if ("thumbnail".equalsIgnoreCase(key)) {
                        //firstRowTable.addCell(emptyCell);
                        firstRowTable.addCell(createThumbnailImageCell(params));
                    } else if ("attributes".equalsIgnoreCase(key)) {
                        attributesKey = LCSProperties.get("com.vrd.wc.techpack.header." + rowName + "RowOrder." + key);
                        classToken = new StringTokenizer(attributesKey, "|~*~|");
                        while (classToken.hasMoreTokens()) {
							WTObject object = null;
                            LCSPartMaster productMaster = null;
                            tempKey = classToken.nextToken();
                            attToken = new StringTokenizer(tempKey, ":");
                            if (attToken.hasMoreTokens()) {
                                className = (String) attToken.nextToken();
                                keyName = (String) attToken.nextToken();
                                attToken = new StringTokenizer(keyName, ",");
                                if ("Product".equalsIgnoreCase(className)) {
                                    type = product.getFlexType();
                                    object = product;

                                    /*
                                     * Fix: Allows generation of Tech Pack
                                     * header for season-less Products. This
                                     * else-if statement verifies if there is a
                                     * Season associated to the Product and if
                                     * so selects the current season
                                     *
                                     * Name: Darron Brumsey 
                                     * Date: 7.9.2014
                                     */
                                } else if ((null != season) && ("Season".equalsIgnoreCase(className))) {
                                    type = season.getFlexType();
                                    object = season;

                                    /*
                                     * Fix: Allows generation of Tech Pack
                                     * header for season-less Products This
                                     * else-if statement is for the use-case
                                     * where no season is associated to the
                                     * Product. Variable "type" is used for
                                     * generation of Season-specific Attribute
                                     * Display Name's on the Tech Pack Header.
                                     *
                                     * Name: Darron Brumsey 
                                     * Date: 7.9.2014
                                     */
                                } else if ((null == season) && ("Season".equalsIgnoreCase(className))) {
                                    type = typeCache.getFlexTypeRoot("Season");

                                    /*
                                     * Fix: Allows generation of Tech Pack
                                     * header for season-less Products This
                                     * else-if statement verifies if there is a
                                     * Product-Season link established for the
                                     * Product.
                                     *
                                     * Name: Darron Brumsey 
                                     * Date: 7.9.2014
                                     */
                                } else if ((null != productLink) && ("Product-Season".equalsIgnoreCase(className))) {
                                    type = productLink.getFlexType();
                                    object = (LCSProductSeasonLink) productLink;

                                } else if ("Specification".equalsIgnoreCase(className)) {
                                    spec = (FlexSpecification) LCSProductQuery.findObjectById((String) params.get(SPEC_ID));
                                    type = spec.getFlexType();
                                    object = spec;
                                }
								
								while (attToken.hasMoreTokens()) {
									key = attToken.nextToken();

									if ("Date".equalsIgnoreCase(keyName)) {
										displayValue = "Date";
										value = VRDPSDHelper.getCurrentDate();
										
									} else if ("sizingDefinition".equalsIgnoreCase(key)) {
										displayValue = "Size Definitions";
										value = VRDPSDUtil.getSizeRangeTable(product, season);
										
									}else if ("specName".equalsIgnoreCase(key)) {
										displayValue = "Specification Name";
										FlexSpecification specObj = (FlexSpecification)object;
										value = specObj.getName();
										
									}else if ("seasonName".equalsIgnoreCase(key)) {
										displayValue = "Season";
										LCSSeason seasonObj = (LCSSeason)object;
											if(seasonObj!=null){
												value = seasonObj.getName();
											}else{
												value="";
											}
										
									}else if ("vrdSpecStatus".equalsIgnoreCase(key)) {
										displayValue = "Sepcification Status";
										FlexSpecification specObj = (FlexSpecification)object;
										String specStatusKey = (String)specObj.getValue(key);
											if(FormatHelper.hasContent(specStatusKey)){
												value = specObj.getFlexType().getAttribute(key).getAttValueList().getValue(specStatusKey, null);
											}
									} else {
										if(object != null) {
											displayValue = type.getAttribute(key).getAttDisplay();  // Not Locale Specific
											value = VRDTechPackUtil.getData(object, key, null);
										}
									}
									countAttributesperRow += 1;
									if (countAttributesperRow <= attCount) {
										cell = new PdfPCell(pgh.multiFontPara(displayValue + ": ", pgh.getCellFont("FORMLABEL", null, null)));
										cell.setBorder(1);
							            cell.setBorderWidthRight(0.0f);

										attTable.addCell(cell);
										cell = new PdfPCell(pgh.multiFontPara(value, pgh.getCellFont("DISPLAYTEXT", null, null)));
										cell.setBorder(1);
							            cell.setBorderWidthRight(0.5f);

										attTable.addCell(cell);
									}

                                }

                            }

                        }//Added code to add empty cell  when there is a mismatch in the property entries for the header attributes.
                        if (countAttributesperRow < attCount) {

                            int attributeCountDiff = attCount - countAttributesperRow;
                            for (int i = 0; i <= attributeCountDiff; i++) {
                                cell = new PdfPCell(spacerCell);
                                cell.setBorder(0);
                                attTable.addCell(cell);
                            }
                        }
                                                
                        attCell = new PdfPCell(attTable);
                        firstRowTable.addCell(attCell);
                    }
                }
                
                firstRowCell = new PdfPCell(firstRowTable);
            
        } catch (Exception e) {
            LCSLog.stackTrace(e);
        }
        return firstRowCell;
    }

    /*
     * This method is to get the customer logo on the first row of header.
     *
     * @return PdfPCell @throws
     */
    private PdfPCell createImageCell() throws BadElementException, MalformedURLException, IOException {
        Image image = null;
        String imageURL = "";
        imageURL = LCSProperties.get("com.vrd.wc.techpack.header.firstRowOrder.image");
        wt_home = WTProperties.getServerProperties().getProperty("wt.home");
        imageURL = FormatHelper.formatOSFolderLocation(wt_home) + FormatHelper.formatOSFolderLocation(imageURL);
        PdfPCell imageCell = null;

        if (imageURL != null && !imageURL.equals("")) {
            if (new File(imageURL).exists()) {
                image = Image.getInstance(imageURL);
            } else {
                image = this.imageNotFound;
            }
        } else {
            image = this.imageNotFound;
        }

        image.scalePercent(800f);
        image.scaleToFit(60f, 500f);
        imageCell = new PdfPCell(image);
        imageCell.setHorizontalAlignment(Element.ALIGN_CENTER);
        imageCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        imageCell.setFixedHeight(50.0F);
        return imageCell;
    }

    /*
     * This method is to get theproduct thumbnail for second row of header.
     * @params params @return PdfPCell
     *
     */
    private PdfPCell createThumbnailImageCell(Map params) throws WTException {
        String wthome = "";
        try {
            if (!FormatHelper.hasContent((String) params.get(PRODUCT_ID))) {
                throw new WTException(
                        "Can not create PDFProductSpecificationHeader without product_ID");
            }
            LCSProduct product = (LCSProduct) LCSProductQuery.findObjectById((String) params.get(PRODUCT_ID));
            String productThumbnail = "";
            Image image = null;
            productThumbnail = product.getPartPrimaryImageURL();

            if (FormatHelper.hasContent(productThumbnail)) {
                productThumbnail = FileLocation.imageLocation + FileLocation.fileSeperator + productThumbnail.substring(productThumbnail.lastIndexOf("/") + 1);
                if (new File(productThumbnail).exists()) {
                    image = Image.getInstance(productThumbnail);
                } else {
                    image = this.imageNotFound;
                }
            } else {
                image = this.imageNotFound;
            }
            image.scalePercent(1000f);
            image.scaleToFit(50f, 3500f);
            PdfPCell cell = new PdfPCell(image, false);
            // cell.setFixedHeight(70.0F);
			cell.setPadding(2f);
            cell.setHorizontalAlignment(Element.ALIGN_CENTER);
            cell.setVerticalAlignment(Element.ALIGN_MIDDLE);

            return cell;
        } catch (Exception e) {

            throw new WTException(e);
        }
    }
}
