<%-- Copyright (c) 2002 PTC Inc.   All Rights Reserved --%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- //////////////////////////////// JSP HEADERS ////////////////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%@page language="java"
       import="com.lcs.wc.db.*,
            com.lcs.wc.calendar.*,
            com.lcs.wc.client.*,
            com.lcs.wc.client.web.*,
            com.lcs.wc.season.*,
            com.lcs.wc.color.*,
            com.lcs.wc.util.*,
            com.lcs.wc.foundation.*,
            com.lcs.wc.flexbom.*,
            com.lcs.wc.material.*,
            com.lcs.wc.product.*,
            com.lcs.wc.flextype.*,
            com.lcs.wc.sourcing.*,
            org.w3c.dom.*,
            javax.xml.parsers.DocumentBuilderFactory,
            javax.xml.parsers.DocumentBuilder,
            org.apache.xerces.jaxp.DocumentBuilderFactoryImpl,
            org.apache.xerces.jaxp.DocumentBuilderImpl,
            com.lcs.wc.db.*,
            wt.pds.*,
            wt.introspection.*,
            java.beans.*,
            wt.fc.*,
            wt.util.*,
            wt.org.*,
            com.lcs.wc.infoengine.client.web.*,
            java.util.*"
%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- //////////////////////////////// BEAN INITIALIZATIONS ///////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<jsp:useBean id="lcsContext" class="com.lcs.wc.client.ClientContext" scope="session"/>
<jsp:useBean id="wtcontext" class="wt.httpgw.WTContextBean" scope="request"/>
<jsp:setProperty name="wtcontext" property="request" value="<%=request%>"/>
<jsp:useBean id="ftg" scope="request" class="com.lcs.wc.client.web.FlexTypeGenerator" />
<jsp:useBean id="fg" scope="request" class="com.lcs.wc.client.web.FormGenerator" />
<jsp:useBean id="tg" scope="request" class="com.lcs.wc.client.web.TableGenerator" />
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- ////////////////////////////// INITIALIZATION JSP CODE //////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%!
    public static final String URL_CONTEXT = LCSProperties.get("flexPLM.urlContext.override");
    public static final boolean ENABLE_SUBASSEMBLIES = LCSProperties.getBoolean("com.lcs.wc.flexbom.enableSubassemblies");
    public static final String defaultCharsetEncoding = LCSProperties.get("com.lcs.wc.util.CharsetFilter.Charset","UTF-8");
%>

<%
	response.setContentType("text/html; charset=" +defaultCharsetEncoding);
    Locale locale = lcsContext.getLocale();

    String imageLabel = WTMessage.getLocalizedMessage ( RB.MAIN,  "image_LBL", RB.objA, locale ) ;
    String colorLabel = WTMessage.getLocalizedMessage ( RB.COLOR,  "color_LBL", RB.objA, locale ) ;
    String stateLabel = WTMessage.getLocalizedMessage ( RB.MAIN,  "state_LBL", RB.objA, locale ) ;
%>

<%

    try {
        String stColorTypeId = request.getParameter("colorTypeId");

        FlexType ftColorType = null;

        if(FormatHelper.hasContent(stColorTypeId)){
            ftColorType = FlexTypeCache.getFlexType(stColorTypeId);
        }
        else{
            ftColorType = FlexTypeCache.getFlexTypeRoot("Color");
        }

        String stAttCols = request.getParameter("attCols");
        Collection colAttCols = new Vector();
        if(FormatHelper.hasContent(stAttCols)){
            colAttCols = MOAHelper.getMOACollection(stAttCols);
        }

        SearchResults results = new LCSColorQuery().findColorsByCriteria(request, ftColorType, colAttCols, null);
        System.out.println("+++++ Result size: "+ results.getResults().size());
        //System.out.println("+++++ Result:\n "+ results);
        if(results.getResults().size() > 1){

            FlexType ftColorRoot = FlexTypeCache.getFlexTypeFromPath("Color");

            Collection columns = new ArrayList();

            TableColumn column;
            column = new TableColumn();

            column = new TableColumn();
            column.setHeaderLabel("");
            column.setDisplayed(true);
            column.setLinkMethod("popUpChooseColor");
            column.setLinkTableIndex("LCSCOLOR.IDA2A2");
            column.setLinkMode("ONCLICK");
            column.setConstantDisplay(true);
            column.setConstantValue("<img title='" + colorLabel + "' src='" + URL_CONTEXT + "/images/linker.gif' border='0'>");
            column.setFormatHTML(false);
            columns.add(column);

            ftg.setScope(null);
            ftg.setLevel(null);



            column = new TableColumn();
            column.setDisplayed(true);
            column.setHeaderLabel(imageLabel);
            column.setHeaderAlign("left");
            column.setTableIndex("LCSCOLOR.thumbnail");
            //column.setColumnWidth("30");
            column.setBgColorIndex("LCSCOLOR.ColorHexidecimalValue");
            column.setImage(true);
            column.setImageWidth(75);
            column.setColumnWidth("1%");
			
 //<!--added kipling custom code to disable click of thumbnail for Vendors-- =====>>>>>>>>>>>>>Start-->
	if(!lcsContext.isVendor){
			column.setLinkMethod("launchImageViewer");
       }
 //<!--added kipling custom code to disable click of thumbnail for Vendors-- =====>>>>>>>>>>>>>End-->            
			
			column.setLinkTableIndex("LCSCOLOR.thumbnail");
			column.setShowFullImage(FormatHelper.parseBoolean(request.getParameter("showThumbs")));        
            columns.add(column);


            column = new TableColumn();
            column.setDisplayed(true);
            column.setHeaderLabel(colorLabel);
            column.setHeaderAlign("left");
            column.setLinkMethod("viewObjectNewWindow");
            column.setLinkTableIndex("LCSCOLOR.IDA2A2");
            column.setTableIndex("LCSCOLOR.COLORNAME");
            column.setLinkMethodPrefix("OR:com.lcs.wc.color.LCSColor:");
            column.setHeaderLink("javascript:resort('LCSColor.colorName')");
            columns.add(column);



            column = new LifecycleStateTableColumn();
            column.setDisplayed(true);
            column.setHeaderLabel(stateLabel);
            column.setHeaderAlign("left");
            column.setTableIndex("LCSCOLOR.STATESTATE");
            column.setHeaderLink("javascript:resort('LCSColor.statestate')");
            column.setWrapping(false);
            columns.add(column);


            %>
            <!-- resultsCount:<%= results.getResultsFound() %>            -->

            <div style="overflow-y:auto; height:400px;">
                <%
                out.print(tg.drawTable(results.getResults(), columns, "", false, false));
                %>
            </div>
            <%


        }
        else {

            String [] arFlexKeys = {"LCSCOLOR.IDA2A2","LCSCOLOR.THUMBNAIL","LCSCOLOR.COLORNAME"
                                   ,"LCSCOLOR.STATESTATE","BOM_ID","BOM_INSERTIONMODE",ftColorType.getAttribute("name").getSearchResultIndex()};
            TableColumn column;
            Collection columns = new ArrayList();

            for (int i = 0;i < arFlexKeys.length;i++) {
                column = new TableColumn();
                column.setDisplayed(true);
                column.setTableIndex(arFlexKeys[i]);
                columns.add(column);
            }

            //add type column
            column = new FlexTypeDescriptorTableColumn();
            column.setDisplayed(true);
            column.setTableIndex("WTTYPEDEFINITION.BRANCHIDITERATIONINFO");
            column.setHeaderLink("javascript:resort('WTTypeDefinition.branchIdIterationInfo')");
            columns.add(column);

            response.setContentType("text/xml");
            String oid = request.getParameter("oid");

            Map hmAttColumns = new HashMap();

            ftg.setScope(null);
            ftg.setLevel(null);
            ftg.createTableColumns(ftColorType, hmAttColumns, ftColorType.getAllAttributes(null, null, false), false, false, "Color.", colAttCols, false, null);

            for (Iterator itColumns = hmAttColumns.values().iterator();itColumns.hasNext();){
                column = (TableColumn)itColumns.next();
                if(FormatHelper.hasContent(column.getLinkMethod())){
                    column.setLinkMethod(null);
                }
                if(FormatHelper.hasContent(column.getLinkMethodIndex())){
                    column.setLinkMethodIndex(null);
                }
            }
            columns.addAll(hmAttColumns.values());

            //Do we need this?
            /*
            FlexObject fo = (FlexObject) results.getResults().iterator().next();
            String colorId = "OR:com.lcs.wc.color.LCSColor:" + fo.getString("LCSCOLOR.IDA2A2");
            LCSColor color = (LCSColor) LCSQuery.findObjectById(colorId);
            */


            String xmlText = null;
            xmlText = new XMLHelper().generateXML(results, null, null, columns);
            xmlText = xmlText.substring(xmlText.indexOf("\n") + 1, xmlText.length());
            System.out.println("xmlText = " + xmlText);
            out.print(xmlText);
        }
    } catch (Exception e){
        e.printStackTrace();

    }
%>
