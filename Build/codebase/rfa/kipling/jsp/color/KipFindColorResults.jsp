<%-- Copyright (c) 2002 PTC Inc.   All Rights Reserved --%>

<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- //////////////////////////////// JSP HEADERS ////////////////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%@page language="java"
       import="com.lcs.wc.db.SearchResults,
                com.lcs.wc.db.FlexObject,
                com.lcs.wc.client.*,
                com.lcs.wc.client.web.*,
                com.lcs.wc.util.*,
                wt.indexsearch.*,
                wt.util.*,
                com.lcs.wc.flextype.*,
                com.lcs.wc.color.*,
                com.lcs.wc.report.*,
                wt.org.WTUser,
                java.util.*"
%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- //////////////////////////////// BEAN INITIALIZATIONS ///////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<jsp:useBean id="flexg" scope="request" class="com.lcs.wc.client.web.FlexTypeGenerator" />
<jsp:useBean id="tg" scope="request" class="com.lcs.wc.client.web.TableGenerator" />
<jsp:useBean id="lcsContext" class="com.lcs.wc.client.ClientContext" scope="session"/>
<jsp:useBean id="fg" scope="request" class="com.lcs.wc.client.web.FormGenerator" />




<%!
    public static final String JSPNAME = "FindColorResults";
    public static final boolean DEBUG = true;

    public static final String getCellClass(boolean b){
       if(b){
            return "TABLEBODYDARK";
        } else {
            return "TABLEBODYLIGHT";
        }
    }
%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%-- ////////////////////////////// INITIALIZATION JSP CODE //////////////////////////////--%>
<%-- /////////////////////////////////////////////////////////////////////////////////////--%>
<%

String colorLabel = WTMessage.getLocalizedMessage ( RB.COLOR, "color_LBL", RB.objA ) ;
String typeLabel = WTMessage.getLocalizedMessage ( RB.MAIN, "type_LBL", RB.objA ) ;
String createdLabel = WTMessage.getLocalizedMessage ( RB.MAIN, "createdOn_LBL", RB.objA ) ;
String modifiedLabel = WTMessage.getLocalizedMessage ( RB.MAIN, "modifiedOn_LBL", RB.objA ) ;
String chooseLabel = WTMessage.getLocalizedMessage ( RB.MAIN, "choose_LBL",RB.objA ) ;
String allLabel = WTMessage.getLocalizedMessage ( RB.MAIN, "all_LBL", RB.objA ) ;



    FlexType flexType = null;
    String type = request.getParameter("type");
    if(FormatHelper.hasContent(type)){
        flexType = FlexTypeCache.getFlexType(type);
    }

    String types = "Color|" + type;

    String ajaxWindow = "false";

    if(FormatHelper.hasContent(request.getParameter("ajaxWindow"))) {
        ajaxWindow = FormatHelper.format(request.getParameter("ajaxWindow"));
    }

%>

<%@ include file="../../../jsp/reports/ViewLookup.jspf" %>



<%

    FlexObject color = null;
    boolean darkRow = false;


    String returnAction = request.getParameter("returnAction");
    boolean chooser = FormatHelper.parseBoolean(request.getParameter("chooser"));
    boolean multiple = FormatHelper.parseBoolean(request.getParameter("multiple"));
    boolean idOnly = FormatHelper.parseBoolean(request.getParameter("idOnly"));

    String  SEARCH_CLASS_DISPLAY = flexType.getFullNameDisplay(true);

    String idColumn = "LCSCOLOR.IDA2A2";
    String bulkActivity = "FIND_COLOR";
    String bulkAction = "SEARCH";
    String tableLayout = FormatHelper.format(request.getParameter("layout"));
    FlexTypeAttribute nameAttr = FlexTypeCache.getFlexTypeRoot("Color").getAttribute("name");
    boolean updateMode = "true".equals(request.getParameter("updateMode"));
    //boolean updateMode = true;

    if(updateMode){
        FTSLHolder hldr = new FTSLHolder();
        ArrayList keys = new ArrayList();
        String nameCriteriaKey = nameAttr.getSearchCriteriaIndex();
        keys.add(nameCriteriaKey);

        hldr.add(type, null, null, keys);

        session.setAttribute("BU_FTSLHOLDER", hldr);
    }

%>
 <%
    HashMap columnMap = new HashMap();

    flexg.setScope(null);
    flexg.setLevel(null);
    flexg.createTableColumns(flexType, columnMap, flexType.getAllAttributes(null, null, false), updateMode, false, "Color.", null, true, null);

    TableColumn column = null;

     if(updateMode){


		UpdateFileTableColumn fcolumn = new UpdateFileTableColumn();
		fcolumn.setHeaderLabel(colorLabel);
		fcolumn.setDisplayed(true);
		fcolumn.setTableIndex("LCSCOLOR.THUMBNAIL");
		fcolumn.setColumnWidth("10%");
		fcolumn.setClassname("LCSCOLOR");
		fcolumn.setWorkingIdIndex("LCSCOLOR.IDA2A2");
		fcolumn.setFormElementName("thumbnail");
		fcolumn.setFormatHTML(false);
		fcolumn.setColumnWidth("7%");
		fcolumn.setWrapping(true);
		fcolumn.setImage(true);
		columnMap.put("Color.thumbnail", fcolumn);

     }else {
        column = new TableColumn();
        column.setDisplayed(true);
        column.setHeaderLabel(colorLabel);
        column.setHeaderAlign("left");
        column.setTableIndex("LCSCOLOR.thumbnail");
        //column.setColumnWidth("30");
        column.setBgColorIndex("LCSCOLOR.ColorHexidecimalValue");
        column.setImage(true);
        column.setImageWidth(75);
        column.setColumnWidth("7%");
		
 //<!--added kipling custom code to disable click of thumbnail for Vendors-- =====>>>>>>>>>>>>>Start-->
	if(!lcsContext.isVendor){
        column.setLinkMethod("launchImageViewer");
       }
 //<!--added kipling custom code to disable click of thumbnail for Vendors-- =====>>>>>>>>>>>>>End-->

	   column.setLinkTableIndex("LCSCOLOR.thumbnail");
       column.setShowFullImage(FormatHelper.parseBoolean(request.getParameter("showThumbs")));        
       columnMap.put("Color.thumbnail", column);
	}

    String nameLabel = WTMessage.getLocalizedMessage(RB.QUERYDEFINITION, "colorName", RB.objA);
    nameLabel = nameLabel.substring(nameLabel.indexOf('\\') +1);
    column = new TableColumn();
    column.setDisplayed(true);
    column.setHeaderLabel(nameLabel);
    column.setUseQuickInfo(true);
    column.setHeaderAlign("left");
    column.setLinkMethod("viewObject");
    column.setLinkTableIndex("LCSCOLOR.IDA2A2");
    column.setTableIndex(nameAttr.getSearchResultIndex());
    column.setLinkMethodPrefix("OR:com.lcs.wc.color.LCSColor:");
    column.setHeaderLink("javascript:resort('" + nameAttr.getSearchResultIndex() + "')");
    column.setWrapping(false);
    columnMap.put("Color.name", column);

    columnMap.putAll(flexg.createHardColumns(flexType, "LCSColor", "Color"));

    //Build the collection of Columns to use in the report
    Collection columnList = new ArrayList();

    if(chooser){
        column = new TableColumn();
        column.setDisplayed(true);
        column.setHeaderLabel("");
        column.setHeaderAlign("left");

        column.setTableIndex("SKUMASTER.NAME");

        if(multiple){
            if(ajaxWindow.equals("true")){
                column.setHeaderLabel("<input type=\"checkbox\" id=\"selectAllChooserCheckBox\" value=\"false\" onClick=\"javascript:toggleAllChooserItems()\">" + allLabel);
            }else{
                column.setHeaderLabel("<input type=\"checkbox\" id=\"selectAllCheckBox\" value=\"false\" onClick=\"javascript:toggleAllItems()\">" + allLabel);
            }            TableFormElement fe = new CheckBoxTableFormElement();
            fe.setValueIndex("LCSCOLOR.IDA2A2");
            fe.setValuePrefix("OR:com.lcs.wc.color.LCSColor:");
            if(ajaxWindow.equals("true")){
                fe.setName("selectedChooserIds");
            }else{
                fe.setName("selectedIds");
            }
            column.setFormElement(fe);
        } else {
            column.setLinkMethod("opener.choose");
            column.setLinkTableIndex("LCSCOLOR.IDA2A2");
            if(!idOnly){
                column.setLinkMethodPrefix("OR:com.lcs.wc.color.LCSColor:");
            }
            column.setLinkTableIndex2("LCSCOLOR.COLORNAME");
            column.setConstantDisplay(true);
            column.setWrapping(false);
            column.setConstantValue(chooseLabel);
        }


        column.setColumnWidth("10%");
        columnList.add(column);
        
    } else if(!"thumbnails".equals(tableLayout) && !"filmstrip".equals(tableLayout)) {

        column = new TableColumn();
        column.setDisplayed(true);
        column.setHeaderLabel("<input type=\"checkbox\" id=\"selectAllCheckBox\" value=\"false\" onClick=\"javascript:toggleAllItems()\">");
        column.setHeaderAlign("left");
        TableFormElement fe1 = new CheckBoxTableFormElement();
        fe1.setValueIndex(idColumn);
        fe1.setValuePrefix("OR:com.lcs.wc.color.LCSColor:");
        fe1.setName("selectedIds");
        column.setFormElement(fe1);
        //column.setValue("<input type=\"checkbox\" id=\"selectedIds\" value=\"false\" onClick=\"javascript:toggleAllItems()\">");
        column.setHeaderLink("javascript:toggleAllItems()");
        columnList.add(column);

        column = new ActionsTableColumn();
        column.setHeaderLabel("");
        column.setDisplayed(true);
        column.setLinkTableIndex(idColumn);
        column.setLinkMethodPrefix("OR:com.lcs.wc.color.LCSColor:");
        column.setColumnWidth("10%");
        columnList.add(column);

    }


    //Setup the attlist/columns
    //attList is the list of attribute keys...required for the query to get the attributes
    Collection attList = new ArrayList();
    //columns is the list of Columns in the order they should be displayed from the column map
    Collection columns = new ArrayList(columnList);

	TableDataModel tdm = null;
	if(FormatHelper.hasContent(viewId)){
		tdm = new TableDataModel(columnMap, new ArrayList(), columns, viewId);
		attList = tdm.attList;
		//System.out.println(tdm.toString());
	}
    else{
        flexg.setScope(null);
        flexg.setLevel(null);
        flexg.setSingleLevel(false);
        Collection searchColumns = flexg.createSearchResultColumnKeys(flexType, "Color.");

        columns.add(columnMap.get("Color.thumbnail"));
        columns.add(columnMap.get("Color.name"));
        columns.add(columnMap.get("Color.typename"));
        flexg.extractColumns(searchColumns, columnMap, attList, columns);
        columns.add(columnMap.get("Color.createdOn"));
        columns.add(columnMap.get("Color.modifiedOn"));

    }

 if(flexType != null){
        String fullName = flexType.getFullName(true);
        ColorTileCellRenderer cellRenderer = new ColorTileCellRenderer();
        cellRenderer.setImageIndex("LCSCOLOR.THUMBNAIL");
		cellRenderer.setBgColorIndex("LCSCOLOR.ColorHexidecimalValue");
        cellRenderer.setIdIndex(idColumn);
        cellRenderer.setNameIndex(flexType.getAttribute("name").getSearchResultIndex());
        cellRenderer.setIdPrefix("OR:com.lcs.wc.color.LCSColor:");
        request.setAttribute("tileCellRenderer", cellRenderer);
    }

    // BEGIN INDEX SEARCH - Set Up and Run the query via this plugin
    Collection oidList = null; 
    String searchterm = null;
    if (FormatHelper.hasContent(request.getParameter("indexSearchKeyword"))) {
        searchterm = (request.getParameter("indexSearchKeyword")).trim();
    }
    String typeclass = null;
    if (FormatHelper.hasContent(request.getParameter("typeClass"))) {
        typeclass =request.getParameter("typeClass");
    }
%>
    <%@ include file="../../../jsp/indexsearch/IndexSearchLibraryPlugin.jspf" %>
<%
    // oidList should be populated now if user specified a keyword to search against, otherwise size=0
    // END INDEX SEARCH filter

    //Run the FlexPLM query
	LCSColorQuery query = new LCSColorQuery();
    SearchResults results = new SearchResults();
    results.setResults(new Vector());
    results.setResultsFound(0);
    if ( FormatHelper.hasContent(searchterm)) {
        if (oidList != null) {
            results = query.findColorsByCriteria(request, flexType, attList, filter, oidList);
        } // no else - no findby criteria needed if a keyword search was done and no hits occured
    } else {
        results = query.findColorsByCriteria(request, flexType, attList, filter, oidList);
    }



    //Iterator colors = results.getResults().iterator();
    if(results.getResultsFound() == 1 && !chooser){
        // IF ONLY ONE PRODUCT IS FOUND, TAKE THE USER TO THE DETAILS PAGE
        FlexObject colorData = (FlexObject) results.getResults().elementAt(0);
        %>
        <script>
            viewColor('OR:com.lcs.wc.color.LCSColor:<%= colorData.getString("LCSCOLOR.IDA2A2") %>');
        </script>
        <%
    }


 %>
<%@ include file="../../../jsp/main/SearchResultsTable.jspf" %>
